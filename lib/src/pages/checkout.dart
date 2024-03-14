import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:ntp/ntp.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/blocs/billing/billing_cubit.dart';
import 'package:shopos/src/blocs/checkout/checkout_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/input/product_input.dart';

import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/bluetooth_printer_list.dart';
import 'package:shopos/src/pages/create_party.dart';
import 'package:shopos/src/pdf_templates/58mm_kot_template.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/services/party.dart';
import 'package:shopos/src/services/product.dart';
import 'package:shopos/src/services/sales.dart';
import 'package:shopos/src/services/user.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_drop_down.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/invoice_template_withGST.dart';
import 'package:shopos/src/widgets/pdf_bill_template.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/party.dart';
import '../models/product.dart';

enum OrderType { purchase, sale, saleReturn, estimate, none }

class PrintBillArgs {
  final billType type;
  final Order order;
  final User user;
  final List<String> headers;
  final DateTime dateTime;
  final String invoiceNum;
  final String totalPrice;
  final String subtotalPrice;
  final String gsttotalPrice;

  PrintBillArgs({
    required this.type,
    required this.order,
    required this.user,
    required this.headers,
    required this.dateTime,
    required this.invoiceNum,
    required this.totalPrice,
    required this.subtotalPrice,
    required this.gsttotalPrice,
  });
}

class CheckoutPageArgs {
  final OrderType invoiceType;
  final Order order;
  // final String orderId;
  ///canEdit flag is used for: checkout from sale report(stopping user to edit sale
  ///if canEdit is set to false while go to sale is executed from report page
  final bool? canEdit;
  CheckoutPageArgs({
    required this.invoiceType,
    required this.order,
    // required this.orderId,
    this.canEdit,
  });
}

class CheckoutPage extends StatefulWidget {
  final CheckoutPageArgs args;
  static const routeName = '/checkout';
  const CheckoutPage({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  late CheckoutCubit _checkoutCubit;
  late final TextEditingController _typeAheadController;

  late User userData;
  UPIDetails? _myUpiId;
  bool _isLoading = false;
  bool _isUPI = false;
  bool _isCash = false;
  bool _isCredit = false;
  bool _isBankTransfer = false;
  bool _singlePayMode = true;
  String date = '';
  var salesInvoiceNo;
  var purchasesInvoiceNo;
  var estimateNo;
  bool isBillTo = false;
  bool convertToSale = false;
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessAddressController =
      TextEditingController();
  final TextEditingController gstController = TextEditingController();
  final TextEditingController dlNumController = TextEditingController();

  final List<TextEditingController> _amountControllers = [];
  final List<TextEditingController> _modeOfPayControllers = [];

  bool shareButtonPref = false;
  bool _loadingShareButton = false;
  late SharedPreferences prefs;
  
  ///
  @override
  void initState() {
    super.initState();
    print("init state of checkout");
    init();
    // String date = DateTime.now().toString();
    // print(date);
    // print(date.substring(11,16));
    // print(date.substring(10,12));
    getUserData();
    // _isUPI = widget.args.Order.modeOfPayment == 'UPI' ? true : false;

    _checkoutCubit = CheckoutCubit();
    _typeAheadController = TextEditingController();
    fetchNTPTime();
    _amountControllers.add(TextEditingController());
    _modeOfPayControllers.add(TextEditingController());

    if (widget.args.order.reciverName != null &&
        widget.args.order.reciverName != "") {
      isBillTo = true;
      receiverNameController.text = widget.args.order.reciverName!;
      businessNameController.text = widget.args.order.businessName!;
      businessAddressController.text = widget.args.order.businessAddress!;
      gstController.text = widget.args.order.gst!;
    }

    if(widget.args.canEdit==false)
      calculate();
  }

  ///to show proper data (when coming from reports page)
  calculate(){
    for (int i = 0; i < widget.args.order.orderItems!.length; i++) {
      OrderItemInput orderItem = widget.args.order.orderItems![i];
      double? totalInputAmount = widget.args.order.modeOfPayment?.fold<double>(0, (acc, curr) {
        return curr['amount'] + acc;
      });
      _onTotalChange(orderItem.product!, orderItem.price?.toStringAsFixed(2));
    }
  }
  _addPaymentMethodField() {
    setState(() {
      _amountControllers.add(TextEditingController());
      _modeOfPayControllers.add(TextEditingController());
      if (_modeOfPayControllers.length > 1) _singlePayMode = false;
      checkUpi();
    });
  }

  void init() async {
    _loadingShareButton = true;
    prefs = await SharedPreferences.getInstance();
    shareButtonPref = (await prefs.getBool('share-button-preference'))!;
    _loadingShareButton = false;
  }
  _removePaymentMethodField(i) {
    setState(() {
      _amountControllers.removeAt(i);
      _modeOfPayControllers.removeAt(i);
      if (_modeOfPayControllers.length == 1) {
        _singlePayMode = true;
        _amountControllers[0].text = '';
      }
      checkUpi();
      // if(_modeOfPayControllers.elementAt(i).text=="UPI"){
      //   _isUPI=false;
      // }
    });
  }
  _onTotalChange(Product product, String? discountedPrice) {
    product.sellingPrice = double.parse(discountedPrice!);
    double newBasePrice = (product.sellingPrice! * 100.0) / (100.0 + double.parse(product.gstRate == 'null' ? '0.0' : product.gstRate!));
    product.baseSellingPriceGst = newBasePrice.toString();
    double newGst = product.sellingPrice! - newBasePrice;
    product.saleigst = newGst.toStringAsFixed(2);
    product.salecgst = (newGst / 2).toStringAsFixed(2);
    product.salesgst = (newGst / 2).toStringAsFixed(2);
  }
  Future<void> fetchNTPTime() async {
    DateTime currentTime;

    try {
      currentTime = await NTP.now();
    } catch (e) {
      currentTime = DateTime.now();
    }

    String day;
    String month;
    String hour;
    String minute;
    String second;

    // for day 0-9
    if (currentTime.day < 10) {
      day = '0${currentTime.day}';
    } else {
      day = '${currentTime.day}';
    }

    // for month 0-9
    if (currentTime.month < 10) {
      month = '0${currentTime.month}';
    } else {
      month = '${currentTime.month}';
    }

    // for hour 0-9
    if (currentTime.hour < 10) {
      hour = '0${currentTime.hour}';
    } else {
      hour = '${currentTime.hour}';
    }

    // for minute
    if (currentTime.minute < 10) {
      minute = '0${currentTime.minute}';
    } else {
      minute = '${currentTime.minute}';
    }

    // for seconds 0-9
    if (currentTime.second < 10) {
      second = '0${currentTime.second}';
    } else {
      second = '${currentTime.second}';
    }

    date = '${day}${month}${currentTime.year}${hour}${minute}${second}';
  }

  getUserData() async {
    setState(() {
      _isLoading = true;
    });
    final response = await UserService.me();
    userData = User.fromMap(response.data['user']);
    getUPIDetails();
    setState(() {
      _isLoading = false;
    });
  }

  getUPIDetails() {
    String? amount = totalPrice();
    if (amount == null) {
      return;
    }
    _myUpiId = UPIDetails(
        upiID: userData.upi_id!,
        payeeName: userData.businessName!,
        amount: double.parse(amount));
  }

  @override
  void dispose() {
    _checkoutCubit.close();
    _typeAheadController.dispose();
    super.dispose();
  }

  ///
  openShareModal(context, user, bool popAll) {
    final String successMsg = widget.args.invoiceType == OrderType.estimate
        ? widget.args.order.estimateNum != null
        ? convertToSale
        ? 'Estimate converted to Sale'
        : 'Estimate updated successfully'
        : 'Estimate created successfully'
        : 'Order created successfully';
    Alert(
      title: widget.args.canEdit==false || popAll == false ? "Share Invoice" : "",
        style: const AlertStyle(
          animationType: AnimationType.grow,
          // isCloseButton: false,,
          isOverlayTapDismiss: false,
          isButtonVisible: false,
        ),
        context: context,
        closeFunction: (){
          if(popAll){
            Future.delayed(const Duration(milliseconds: 50), () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            });
          }else{
            Navigator.pop(context);
          }
        },

        content: WillPopScope(
          onWillPop: () async {
            if(popAll){
              Future.delayed(const Duration(milliseconds: 50), () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
            }else{
              Navigator.pop(context);
            }
            return true;
          },
          child: Column(
            children: [
              SizedBox(height: 10,),
              // if(widget.args.canEdit != false && popAll == true)
              if(popAll == true)
              Lottie.asset('assets/anims/check3.json',
                  width: 150,
                  height: 150,
                  repeat: false,
                  fit: BoxFit.contain),
              // widget.args.canEdit != false ? SizedBox(height: 20,): SizedBox.shrink(),
              // widget.args.canEdit != false ? Text("$successMsg",style: TextStyle(fontSize: 14),): SizedBox.shrink(),
              // widget.args.canEdit != false ? SizedBox(height: 60,): SizedBox(height: 20,),
              popAll ? SizedBox(height: 20,): SizedBox.shrink(),
              popAll ? Text("$successMsg",style: TextStyle(fontSize: 14),): SizedBox.shrink(),
              popAll ? SizedBox(height: 60,): SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      // titleAlignment: ListTileTitleAlignment.center,
                      // tileColor: Colors.red[500],
                      // textColor: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.all(Radius.circular(20)),
                      // ),
                      paddingOutside: 5,
                      title: "Print",
                      type: ButtonType.outlined,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      onTap: () async {
                        // _onTapShare(2);
                        if (widget.args.invoiceType != OrderType.estimate) {
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          String? defaultBill = prefs.getString('defaultBill');

                          if (defaultBill == null) {
                            _showNewDialog(widget.args.order, popAll);
                          } else if (defaultBill == '57mm') {
                            await _view57mmBill(widget.args.order, popAll);
                          } else if (defaultBill == '80mm') {
                            await _view80mmBill(widget.args.order, popAll);
                          } else if (defaultBill == 'A4') {
                            await _viewPdf(popAll);
                            if(popAll){
                              Future.delayed(const Duration(milliseconds: 400), () {
                                Navigator.of(context).popUntil((route) => route.isFirst);
                              });
                            }
                          }
                        } else {
                          await _viewPdf(popAll);
                          if(popAll){
                            Future.delayed(const Duration(milliseconds: 400), () {
                              Navigator.of(context).popUntil((route) => route.isFirst);
                            });
                          }
                        }
                      },
                    ),
                  ),
                  // ListTile(
                  //   title: const Text("With GST"),
                  //   onTap: () {
                  //     _onTapShare(0);
                  //   },
                  // ),
                  // ListTile(
                  //   title: const Text("Without GST"),
                  //   onTap: () {
                  //     _onTapShare(1);
                  //   },
                  // ),

                  Expanded(
                    child: CustomButton(
                        // titleAlignment: ListTileTitleAlignment.center,
                        // tileColor: Colors.green,
                        // textColor: Colors.white,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.all(Radius.circular(20)),
                        // ),
                        paddingOutside: 5,
                        type: ButtonType.outlined,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 10,
                        ),
                        title: "WhatsApp",
                        onTap: () {
                          TextEditingController t = TextEditingController();
                          showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                                backgroundColor: Colors.white,
                                title: Column(children: [
                                  Text(
                                    "Enter Whatsapp number\n(10-digit number only)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Poppins-Regular",
                                        color: Colors.black),
                                  )
                                ]),
                                content: TextField(
                                  autofocus: true,
                                  controller: t,
                                  decoration: InputDecoration(
                                    hintText: "Enter 10-digit number",
                                    enabledBorder: OutlineInputBorder(),
                                    focusedBorder: OutlineInputBorder(),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        if (int.tryParse(t.text.trim()) != null &&
                                            t.text.length == 10)
                                          includePayments();
                                        _launchUrl(
                                            t.text.trim(),
                                            user,
                                            widget.args.order.modeOfPayment,
                                            totalbasePrice(),
                                            totalgstPrice(),
                                            totalDiscount(),
                                            widget.args.order.orderItems);
                                      },
                                      child: Text("Yes")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text("Cancel"))
                                ],
                              ));
                        }),
                  ),
                ],
              )
            ],
          ),
        )).show();
  }

  ///
  _viewPdf(bool popAll) async {
    bool expirydateAvailableFlag = false;
    bool hsnAvailableFlag = false;
    bool mrpAvailableFlag = false;

    widget.args.order.orderItems!.forEach((element) {
      if (element.product!.expiryDate != null &&
          element.product!.expiryDate != "null" &&
          element.product!.expiryDate != "") {
        expirydateAvailableFlag = true;
      }
      if (element.product!.hsn != null &&
          element.product!.hsn != "null" &&
          element.product!.hsn != "") {
        hsnAvailableFlag = true;
      }
      if (element.product!.mrp != null &&
          element.product!.mrp != "null" &&
          element.product!.mrp != "") {
        mrpAvailableFlag = true;
      }
    });

    var headerList = ["Name", "Qty", "Taxable value", "GST", "Amount"];
    if(mrpAvailableFlag){
      headerList.insert(2, "MRP");
    }
    if (hsnAvailableFlag && widget.args.invoiceType!=OrderType.purchase) {
      headerList.insert(2, "HSN");
    }
    if (expirydateAvailableFlag  && widget.args.invoiceType!=OrderType.purchase) {
      headerList.insert(2, "Expiry");
    }
    final targetPath = await getExternalCacheDirectories();
    var targetFileName = "Invoice " + DateTime.now().toString();
    salesInvoiceNo = await _checkoutCubit.getSalesNum() as int;
    purchasesInvoiceNo = await _checkoutCubit.getPurchasesNum() as int;
    estimateNo = await _checkoutCubit.getEstimateNum() as int;
    if(!popAll){
      estimateNo++; //for showing in the pdf
      salesInvoiceNo++;
      purchasesInvoiceNo++;
    }
    print("line 392 in checkout.dart");
    print(widget.args.order.invoiceNum.runtimeType);
    // print(salesInvoiceNo);
    // print(widget.args.order.createdAt);
    print("total price is ${totalPrice()}");
    final htmlContent = invoiceTemplatewithGST(
      type: widget.args.invoiceType.toString(),
      date: widget.args.order.createdAt.toString() ?? "",
      companyName: userData.businessName ?? "",
      order: widget.args.order,
      user: userData,
      headers: headerList,
      total: totalPrice() ?? "",
      subtotal: totalbasePrice() ?? "",
      gsttotal: totalgstPrice() ?? "",
      dlNum: dlNumController.text,
      convertToSale: convertToSale,
      invoiceNum: widget.args.invoiceType == OrderType.sale
          ? "Invoice No: ${widget.args.order.invoiceNum != '' && widget.args.order.invoiceNum != null && widget.args.order.invoiceNum != "null" ? widget.args.order.invoiceNum : salesInvoiceNo.toString()}"
          : widget.args.invoiceType == OrderType.purchase
          ? "Invoice No: ${purchasesInvoiceNo.toString()}"
          : widget.args.invoiceType == OrderType.estimate
          ? widget.args.order.estimateNum == '' || widget.args.order.estimateNum == "null" || widget.args.order.estimateNum == null
          ? "Estimate No: ${estimateNo.toString()}"
          : convertToSale
          ? "Invoice No: ${salesInvoiceNo.toString()}"
          : "Estimate No: ${widget.args.order.estimateNum}"
          : "",
    );
    final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
      htmlContent,
      targetPath!.first.path,
      targetFileName,
    );

    // for open pdf
    try {
      OpenFile.open(generatedPdfFile.path);
    } catch (e) {
      print(e);
    }
    print("last line of _view pdf");
  }

  ///
  // void _viewPdfwithgst(User user) async {
  //   final targetPath = await getExternalCacheDirectories();
  //   const targetFileName = "Invoice";
  //   final htmlContent = invoiceTemplatewithGST(
  //     type: widget.args.invoiceType.toString(),
  //     date: DateTime.now(),
  //     companyName: user.businessName ?? "",
  //     order: widget.args.Order,
  //     user: user,
  //     headers: ["Name", "Qty", "Rate/Unit", "GST/Unit", "Amount"],
  //     total: totalPrice() ?? "",
  //     subtotal: totalbasePrice() ?? "",
  //     gsttotal: totalgstPrice() ?? "",
  //     invoiceNum: date,
  //   );
  //   final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
  //     htmlContent,
  //     targetPath!.first.path,
  //     targetFileName,
  //   );
  //   // for open pdf
  //   try {
  //     await OpenFile.open(generatedPdfFile.path);
  //   } catch (e) {
  //     print(e.toString());
  //   }

  // final input = _typeAheadController.value.text.trim();
  // if (input.length == 10 && int.tryParse(input) != null) {
  //   await WhatsappShare.shareFile(
  //     text: 'Invoice',
  //     phone: '91$input',
  //     filePath: [generatedPdfFile.path],
  //   );
  //   return;
  // }
  // final party = widget.args.Order.party;
  // if (party == null) {
  //   final path = generatedPdfFile.path;
  //   await Share.shareFiles([path], mimeTypes: ['application/pdf']);
  //   return;
  // }
  // final isValidPhoneNumber = Utils.isValidPhoneNumber(party.phoneNumber);
  // if (!isValidPhoneNumber) {
  //   locator<GlobalServices>()
  //       .infoSnackBar("Invalid phone number: ${party.phoneNumber ?? ""}");
  //   return;
  // }
  // await WhatsappShare.shareFile(
  //   text: 'Invoice',
  //   phone: '91${party.phoneNumber ?? ""}',
  //   filePath: [generatedPdfFile.path],
  // );
  // }

  ///
  // void _viewPdfwithoutgst(User user) async {
  //   final targetPath = await getExternalCacheDirectories();
  //   const targetFileName = "Invoice";
  //   final htmlContent = invoiceTemplatewithouGST(
  //     type: widget.args.invoiceType.toString(),
  //     date: DateTime.now(),
  //     companyName: user.businessName ?? "",
  //     order: widget.args.Order,
  //     user: user,
  //     headers: ["Name", "Qty", "Rate/Unit", "Amount"],
  //     total: totalPrice() ?? "",
  //     invoiceNum: date,
  //   );
  //   final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
  //     htmlContent,
  //     targetPath!.first.path,
  //     targetFileName,
  //   );
  //   final input = _typeAheadController.value.text.trim();
  //   if (input.length == 10 && int.tryParse(input) != null) {
  //     await WhatsappShare.shareFile(
  //       text: 'Invoice',
  //       phone: '91$input',
  //       filePath: [generatedPdfFile.path],
  //     );
  //     return;
  //   }

  //   final party = widget.args.Order.party;
  //   if (party == null) {
  //     final path = generatedPdfFile.path;
  //     await Share.shareFiles([path], mimeTypes: ['application/pdf']);
  //     return;
  //   }
  //   final isValidPhoneNumber = Utils.isValidPhoneNumber(party.phoneNumber);
  //   if (!isValidPhoneNumber) {
  //     locator<GlobalServices>()
  //         .infoSnackBar("Invalid phone number: ${party.phoneNumber ?? ""}");
  //     return;
  //   }
  //   await WhatsappShare.shareFile(
  //     text: 'Invoice',
  //     phone: '91${party.phoneNumber ?? ""}',
  //     filePath: [generatedPdfFile.path],
  //   );
  // }

  Future<Iterable<Party>> _searchParties(String pattern) async {
    if (pattern.isEmpty) {
      return [];
    }
    final type =
        widget.args.invoiceType == OrderType.purchase ? "supplier" : "customer";

    try {
      final response =
          await const PartyService().getSearch(pattern, type: type);
      final data = response.data['allParty'] as List<dynamic>;
      return data.map((e) => Party.fromMap(e));
    } catch (err) {
      log(err.toString());
      return [];
    }
  }

  ///
  String? totalPrice() {
    return widget.args.order.orderItems?.fold<double>(
      0,
      (acc, curr) {
        if (widget.args.invoiceType == OrderType.purchase) {
          return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
        }
        return (double.parse(curr.quantity.toString()) *
                (curr.product?.sellingPrice ?? 1.0)) +
            acc;
      },
    ).toStringAsFixed(2);
  }

  ///
  String? totalbasePrice() {
    return widget.args.order.orderItems?.fold<double>(
      0,
      (acc, curr) {
        if (widget.args.invoiceType == OrderType.purchase) {
          // return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
          double sum = 0;
          if (curr.product!.basePurchasePriceGst! != "null")
            sum = double.parse(curr.product!.basePurchasePriceGst!);
          else {
            sum = curr.product!.purchasePrice.toDouble();
          }
          return (curr.quantity * sum) + acc;
        } else {
          double sum = 0;
          if (curr.product!.baseSellingPriceGst! != "null")
            sum = double.parse(curr.product!.baseSellingPriceGst!);
          else {
            sum = curr.product!.sellingPrice!.toDouble();
          }
          return (curr.quantity * sum) + acc;
        }
      },
    ).toStringAsFixed(2);
  }
  String? totalDiscount(){
    return widget.args.order.orderItems?.fold<double>(
        0,
            (acc, curr){
          return double.parse(curr.discountAmt)+acc;
        }
    ).toStringAsFixed(2);
  }
  ///
  String? totalgstPrice() {
    return widget.args.order.orderItems?.fold<double>(
      0,
      (acc, curr) {
        if (widget.args.invoiceType == OrderType.purchase) {
          // return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
          double gstsum = 0;
          if (curr.product!.purchaseigst! != "null")
            gstsum = double.parse(curr.product!.purchaseigst!);
          // else {
          //   gstsum = curr.product!.sellingPrice;
          // }
          return double.parse(
              ((curr.quantity * gstsum) + acc).toStringAsFixed(2));
        } else {
          double gstsum = 0;
          if (curr.product!.saleigst! != "null")
            gstsum = double.parse(curr.product!.saleigst!);
          // else {
          //   gstsum = curr.product!.sellingPrice;
          // }
          return double.parse(
              ((curr.quantity * gstsum) + acc).toStringAsFixed(2));
        }
      },
    ).toStringAsFixed(2);
  }

  _view80mmBill(Order Order, bool popAll) async {
    // PdfUI.generate80mmPdf(
    //   user: userData,
    //   order: Order,
    //   headers: [
    //     "Invoice 0000000",
    //     "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
    //   ],
    //   date: DateTime.now(),
    //   invoiceNum: date,
    //   totalPrice: totalPrice() ?? '',
    //   subtotal: totalbasePrice() ?? '',
    //   gstTotal: totalgstPrice() ?? '',
    // );

    // PrintBillArgs(
    //   user: userData,
    //   order: Order,
    //   headers: [
    //     "Invoice 0000000",
    //     "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
    //   ],
    //   dateTime: DateTime.now(),
    //   invoiceNum: date,
    //   totalPrice: totalPrice() ?? '',
    //   subtotalPrice: totalbasePrice() ?? '',
    //   gsttotalPrice: totalgstPrice() ?? '',
    // );
    salesInvoiceNo = await _checkoutCubit.getSalesNum() as int;
    purchasesInvoiceNo = await _checkoutCubit.getPurchasesNum() as int;
    if(!popAll){
      salesInvoiceNo++;
      purchasesInvoiceNo++;
    }
    var combineArgs = CombineArgs(
        bluetoothArgs: null,
        billArgs: PrintBillArgs(
          type: billType.is80mm,
          user: userData,
          order: Order,
          headers: [
            "Invoice 0000000",
            "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
          ],
          dateTime: DateTime.now(),
          invoiceNum: widget.args.invoiceType == OrderType.sale
              ? widget.args.order.invoiceNum != ''&& widget.args.order.invoiceNum != null && widget.args.order.invoiceNum != "null"
              ? widget.args.order.invoiceNum!
              : salesInvoiceNo.toString()
              : purchasesInvoiceNo.toString(),
          totalPrice: totalPrice() ?? '',
          subtotalPrice: totalbasePrice() ?? '',
          gsttotalPrice: totalgstPrice() ?? '',
        ));
    if(popAll){
      Navigator.of(context).pushNamedAndRemoveUntil(
          BluetoothPrinterList.routeName,
          ((route)=>route.isFirst),
          arguments: combineArgs);
    }else{
      Navigator.of(context).pushNamed(
        BluetoothPrinterList.routeName,
        arguments: combineArgs
      );
    }

    // for open pdf
    // try {
    //   OpenFile.open(generatedPdfFile.path);
    // } catch (e) {
    //   print(e);
    // }
  }

  _view57mmBill(Order Order, bool popAll) async {
    // PdfUI.generate57mmPdf(
    //   user: userData,
    //   order: Order,
    //   headers: [
    //     "Invoice 0000000",
    //     "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
    //   ],
    //   date: DateTime.now(),
    //   invoiceNum: date,
    //   totalPrice: totalPrice() ?? '',
    //   subtotal: totalbasePrice() ?? '',
    //   gstTotal: totalgstPrice() ?? '',
    // );

    // print(
    //     widget.args.order.orderItems![0].product!.baseSellingPriceGst == 'null'
    //         ? widget.args.order.orderItems![0].product!.sellingPrice
    //         : 0);
    salesInvoiceNo = await _checkoutCubit.getSalesNum() as int;
    purchasesInvoiceNo = await _checkoutCubit.getPurchasesNum() as int;
    if(!popAll){
      salesInvoiceNo++;
      purchasesInvoiceNo++;
    }
    var combineArgs = CombineArgs(
        bluetoothArgs: null,
        billArgs: PrintBillArgs(
          type: billType.is57mm,
          user: userData,
          order: Order,
          headers: [
            "Invoice 0000000",
            "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
          ],
          dateTime: DateTime.now(),
          invoiceNum: widget.args.invoiceType == OrderType.sale
              ? widget.args.order.invoiceNum != '' &&
              widget.args.order.invoiceNum != null &&
              widget.args.order.invoiceNum != "null"
              ? widget.args.order.invoiceNum!
              : salesInvoiceNo.toString()
              : purchasesInvoiceNo.toString(),
          totalPrice: totalPrice() ?? '',
          subtotalPrice: totalbasePrice() ?? '',
          gsttotalPrice: totalgstPrice() ?? '',
        ));

    if(popAll){
      Navigator.of(context).pushNamedAndRemoveUntil(
          BluetoothPrinterList.routeName,
          ((route)=>route.isFirst),
          arguments: combineArgs);
    }else{
      Navigator.of(context).pushNamed(
        BluetoothPrinterList.routeName,
        arguments: combineArgs
      );
    }
  }

  _showNewDialog(
    Order order, bool popAll
  ) async {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('defaultBill', '57mm');
                await _view57mmBill(order, popAll);
              },
              title: Text('58mm'),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('defaultBill', '80mm');
                await _view80mmBill(order, popAll);
              },
              title: Text('80mm'),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('defaultBill', 'A4');
                await _viewPdf(popAll);
                if(popAll){
                  Future.delayed(const Duration(milliseconds: 400), () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                }
              },
              title: Text('A4'),
            )
          ],
        ),
      ),
    );
  }
  void checkUpi() {
    _isUPI = false;
    for (int i = 0; i < _modeOfPayControllers.length; i++) {
      if (_modeOfPayControllers[i].text == "UPI") {
        _isUPI = true;
      }
    }
  }

  void checkCredit() {
    _isCredit = false;
    for (int i = 0; i < _modeOfPayControllers.length; i++) {
      if (_modeOfPayControllers[i].text == "Credit") {
        _isCredit = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          // "${widget.args.order.orderItems?.fold<double>(0, (acc, item) => item.quantity + acc)} Products",
          "Checkout",
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : SingleChildScrollView(
              child: BlocListener<CheckoutCubit, CheckoutState>(
                bloc: _checkoutCubit,
                listener: (context, state) async{
                  if (state is CheckoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(
                          widget.args.invoiceType == OrderType.estimate
                              ? widget.args.order.estimateNum != null
                                  ? convertToSale
                                      ? 'Estimate Converted to Sale'
                                      : 'Estimate Updated successfully'
                                  : 'Estimate Created Successfully'
                              : 'Order was created successfully',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                    // Future.delayed(const Duration(milliseconds: 400), () {
                    //   Navigator.of(context).popUntil((route) => route.isFirst);
                    // });
                    try {
                      final res = await UserService.me();
                      if ((res.statusCode ?? 400) < 300) {
                        final user = User.fromMap(res.data['user']);
                        openShareModal(context, user, true);
                      }
                    } catch (_) {}
                  }
                },
                child: BlocBuilder<CheckoutCubit, CheckoutState>(
                  bloc: _checkoutCubit,
                  builder: (context, state) {
                    if (state is CheckoutLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ColorsConst.primaryColor,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 20,left: 20, right: 30,),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Divider(color: Colors.transparent),
                            // const Divider(color: Colors.transparent, height: 30),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              elevation: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    // Divider(color: Colors.black54),
                                    // Text(
                                    //   "INVOICE",
                                    //   style: TextStyle(
                                    //       fontSize: 30, fontWeight: FontWeight.w500),
                                    // ),
                                    // Divider(color: Colors.black54),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Sub Total'),
                                        Text('₹ ${totalbasePrice()}'),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Tax GST'),
                                        Text('₹ ${totalgstPrice()}'),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Discount'),
                                        Text('₹ ${totalDiscount()}'),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Divider(color: Colors.black54),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Grand Total'),
                                        Text(
                                          '₹ ${double.parse(totalPrice()!).toStringAsFixed(2)}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    // Divider(color: Colors.black54),
                                    // const Divider(color: Colors.transparent),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(color: Colors.transparent),
                            const Divider(color: Colors.transparent),
                            if (widget.args.invoiceType == OrderType.estimate &&
                                widget.args.order.estimateNum != null)
                              Column(
                                children: [
                                  SwitchListTile(
                                      title: Text('Convert to Sale: '),
                                      value: convertToSale,
                                      onChanged: (val) {
                                        convertToSale = val;
                                        setState(() {});
                                      }),
                                  const Divider(color: Colors.transparent),
                                ],
                              ),
                            if (widget.args.invoiceType != OrderType.estimate &&
                                    widget.args.canEdit != false ||
                                convertToSale != false)
                              Column(
                                children: [
                                  TypeAheadFormField<Party>(
                                    validator: (value) {
                                      final isEmpty =
                                          (value == null || value.isEmpty);
                                      if (isEmpty && _isCredit) {
                                        return "Please select a party for credit order";
                                      }
                                      return null;
                                    },
                                    debounceDuration:
                                        const Duration(milliseconds: 500),
                                    textFieldConfiguration:
                                        TextFieldConfiguration(
                                      controller: _typeAheadController,
                                      autofocus: true,
                                      decoration: InputDecoration(
                                        hintText: "Party",
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(context,
                                                CreatePartyPage.routeName,
                                                arguments: CreatePartyArguments(
                                                  "",
                                                  "",
                                                  "",
                                                  "",
                                                  widget.args.invoiceType ==
                                                          OrderType.purchase
                                                      ? 'supplier'
                                                      : 'customer',
                                                ));
                                          },
                                          child: const Icon(
                                              Icons.add_circle_outline_rounded),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 10,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                    suggestionsCallback: (String pattern) {
                                      if (int.tryParse(pattern.trim()) !=
                                          null) {
                                        return Future.value([]);
                                      }
                                      return _searchParties(pattern);
                                    },
                                    itemBuilder: (context, party) {
                                      return ListTile(
                                        leading: const Icon(Icons.person),
                                        title: Text(party.name ?? ""),
                                      );
                                    },
                                    onSuggestionSelected: (Party party) {
                                      setState(() {
                                        widget.args.order.party = party;
                                      });
                                      _typeAheadController.text =
                                          party.name ?? "";
                                    },
                                  ),
                                  const Divider(
                                      color: Colors.transparent, height: 30),
                                  if (widget.args.invoiceType !=
                                      OrderType.saleReturn)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomDropDownField(
                                                items: const <String> ["Cash","Credit","Bank Transfer","UPI"],
                                                onSelected: (e) {
                                                  // widget.args.order.modeOfPayment = e;
                                                  _modeOfPayControllers[0]
                                                      .text = e;
                                                  checkUpi();
                                                  checkCredit();
                                                  // if (widget.args.order.modeOfPayment ==
                                                  //     'UPI') {
                                                  //   _isUPI = true;
                                                  //   getUPIDetails();
                                                  // } else {
                                                  //   _isUPI = false;
                                                  // }

                                                  setState(() {});
                                                },
                                                validator: (e) {
                                                  if ((e ?? "").isEmpty) {
                                                    return 'Please select a mode of payment';
                                                  }
                                                  return null;
                                                },
                                                hintText: "Payment Mode",
                                              ),
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Expanded(
                                                child: TextFormField(
                                              enabled: !_singlePayMode,
                                              controller: _amountControllers[0],
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      signed: false,
                                                      decimal: true),
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 5,
                                                          horizontal: 7),
                                                  label: Text("Amount"),
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10))),
                                              validator: (e) {
                                                if (e!.contains(",")) {
                                                  return '(,) character are not allowed';
                                                }
                                                if (e.isNotEmpty) if (double
                                                        .parse(e) >
                                                    99999.0) {
                                                  return 'Maximum value is 99999';
                                                }
                                                return null;
                                              },
                                            )),
                                            SizedBox(
                                              width: 30,
                                            ),
                                          ],
                                        ),

                                        SizedBox(
                                          height: 10,
                                        ),
                                        // qr code image
                                        Column(
                                          children: [
                                            for (int i = 1; i < _amountControllers.length; i++)
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            CustomDropDownField(
                                                          items: const <String> ["Cash","Credit","Bank Transfer","UPI"],
                                                          onSelected: (e) {
                                                            _modeOfPayControllers[i].text = e;
                                                            checkUpi();
                                                            checkCredit();
                                                            setState(() {});
                                                          },
                                                          validator: (e) {
                                                            if ((e ?? "").isEmpty) {
                                                              return 'Please select a mode of payment';
                                                            }
                                                            return null;
                                                          },
                                                          hintText:"Payment Mode",
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Expanded(
                                                          child: TextFormField(
                                                        controller:_amountControllers[i],
                                                        keyboardType: TextInputType.numberWithOptions(signed: false,decimal: true),
                                                        decoration: InputDecoration(
                                                            contentPadding:EdgeInsets.symmetric(vertical: 5,horizontal:7),
                                                            label:Text("Amount"),
                                                            border: OutlineInputBorder(borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10))),
                                                        validator: (e) {
                                                          if (e!.contains(",")) {
                                                            return '(,) character are not allowed';
                                                          }
                                                          if (e.isNotEmpty) if (double.parse(e) > 99999.0) {
                                                            return 'Amount not correct';
                                                          }
                                                          return null;
                                                        },
                                                      )),
                                                      SizedBox(width: 5,),
                                                      i == _modeOfPayControllers.length - 1
                                                          ? InkWell(
                                                              onTap: () => _removePaymentMethodField(i),
                                                              child: Container(
                                                                width: 25, // Adjust the width as needed
                                                                child: Icon(Icons.remove_circle,
                                                                  color: Colors.red,
                                                                ),
                                                              ),
                                                            )
                                                          : SizedBox(width: 25,)
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  )
                                                ],
                                              )
                                          ],
                                        ),
                                        Row(
                                            //add payment mode button
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (_modeOfPayControllers.length < 4) {
                                                    _addPaymentMethodField();
                                                  }
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(left: 18, right: 20, top: 8, bottom: 8),
                                                  decoration: ShapeDecoration(
                                                    // color: const Color(0xFF1E232C),
                                                    color: Colors.grey[100],
                                                    shape: RoundedRectangleBorder(
                                                        side: const BorderSide(color:Colors.black),
                                                        borderRadius: BorderRadius.circular(18)),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.add_circle,
                                                        color: _modeOfPayControllers.length >= 4
                                                                ? Colors.grey
                                                                : Colors.green,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        'Payment Mode',
                                                        style: TextStyle(
                                                          color: _modeOfPayControllers.length >= 4
                                                              ? Colors.grey
                                                              : Colors.black,
                                                          fontSize: 14,
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                            ]),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        if (_isUPI)
                                          Center(
                                            child: UPIPaymentQRCode(
                                              upiDetails: _myUpiId!,
                                              size: 200,
                                              embeddedImagePath:
                                                  'assets/icon/BharatPos.png',
                                              embeddedImageSize:
                                                  const Size(40, 40),
                                              upiQRErrorCorrectLevel:
                                                  UPIQRErrorCorrectLevel.high,
                                              qrCodeLoader: Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          ),
                                        if (_isUPI)
                                          SizedBox(
                                            height: 20,
                                          ),
                                        if (_isUPI)
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Upi id: ',
                                              ),
                                              // to copy upi id
                                              SelectableText(
                                                _myUpiId!.upiID,
                                              )
                                            ],
                                          ),
                                      ],
                                    )
                                ],
                              ),
                            SwitchListTile(
                                title: Text('Bill to: '),
                                value: isBillTo,
                                onChanged: (val) {
                                  isBillTo = val;
                                  setState(() {});
                                }),
                            SizedBox(
                              height: 5,
                            ),
                            Visibility(
                              visible: isBillTo,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: receiverNameController,
                                    decoration: InputDecoration(
                                        label: Text("Receiver name"),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onChanged: (val) {
                                      widget.args.order.reciverName = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: businessNameController,
                                    decoration: InputDecoration(
                                        label: Text("Business Name"),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onChanged: (val) {
                                      widget.args.order.businessName = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: businessAddressController,
                                    decoration: InputDecoration(
                                        label: Text("Business Address"),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onChanged: (val) {
                                      widget.args.order.businessAddress = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: gstController,
                                    decoration: InputDecoration(
                                        label: Text("GSTIN"),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onChanged: (val) {
                                      widget.args.order.gst = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  TextFormField(
                                    controller: dlNumController,
                                    decoration: InputDecoration(
                                        label: Text("DL Number"),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10))),
                                    onChanged: (val) {
                                      // widget.args.order.dlNum = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 300,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            if(convertToSale)
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width*0.8,
                  child: CustomButton(
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          ?.copyWith(color: Colors.white, fontSize: 18),
                      title: "Submit",
                      onTap: (){
                    _onTapSubmit();
                  }),
                ),
              ),
            if((shareButtonPref == true && convertToSale == false) || (shareButtonPref == false && widget.args.canEdit == false))
            Visibility(
              visible: !_loadingShareButton,
              child: Expanded(
                child: CustomButton(
                  title: "Share",
                  onTap: () async {
                    try {
                      final res = await UserService.me();
                      if ((res.statusCode ?? 400) < 300) {
                        final user = User.fromMap(res.data['user']);

                        openShareModal(context, user, false);
                      }
                    } catch (_) {}
                  },
                  type: ButtonType.outlined,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                ),
              ),
            ),

            if (widget.args.canEdit != false)
              if(!convertToSale)
              Expanded(
                child: CustomButton(
                  onTap: () {
                    _onTapSubmit();
                  },
                  title: 'Save',
                  style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white, fontSize: 16)
                ),
              )
          ],
        ),
      ),
    );
  }

  bool checkAmounts() {
    if (!_singlePayMode) {
      var inputAmount = 0.0;
      for (int i = 0; i < _amountControllers.length; i++) {
        inputAmount += double.parse(_amountControllers[i].text);
      }
      print("checking amount");
      print(inputAmount);
      var total = double.parse(totalPrice()!);
      print(total);
      double tolerance = 0.99;

      if ((inputAmount - total).abs() > tolerance) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            'Payment amount mismatch. Check grand total.',
            style: TextStyle(color: Colors.white),
          ),
        ));
        return false;
      } else {
        return true;
      }
    }
    return true;
  }
  void includePayments(){
    widget.args.order.modeOfPayment = [];

    if (_singlePayMode) {
      _amountControllers[0].text = totalPrice()!;
      var defaultPayment = {
        "mode": _modeOfPayControllers[0].text,
        "amount": double.parse(_amountControllers[0].text)
      };
      widget.args.order.modeOfPayment?.add(defaultPayment);
    } else {
      for (int i = 0; i < _modeOfPayControllers.length; i++) {
        if (_modeOfPayControllers[i].text.isNotEmpty) {
          var newPayment = {
            "mode": _modeOfPayControllers[i].text,
            "amount": 0
          };
          if (_amountControllers[i].text.isNotEmpty) {
            newPayment["amount"] = double.parse(_amountControllers[i].text);
          } else {
            newPayment["amount"] = "0";
          }
          widget.args.order.modeOfPayment?.add(newPayment);
        }
      }
    }
  }
  void _onTapSubmit() async {
    _formKey.currentState?.save();
    if (_formKey.currentState?.validate() ?? false) {
      // print("discountttttttt=${widget.args.order.orderItems![0].discountAmt}");
      print("widget.args.order ${widget.args.order}");
      print("widget.args.order ${widget.args.order.kotId}");
      print(totalPrice());
      print(totalbasePrice());
      print(totalgstPrice());
      widget.args.order.modeOfPayment = [];

      if (_singlePayMode) {
        _amountControllers[0].text = totalPrice()!;
        var defaultPayment = {
          "mode": _modeOfPayControllers[0].text,
          "amount": double.parse(_amountControllers[0].text)
        };
        widget.args.order.modeOfPayment?.add(defaultPayment);
      } else {
        for (int i = 0; i < _modeOfPayControllers.length; i++) {
          if (_modeOfPayControllers[i].text.isNotEmpty) {
            var newPayment = {
              "mode": _modeOfPayControllers[i].text,
              "amount": 0
            };
            if (_amountControllers[i].text.isNotEmpty) {
              newPayment["amount"] = double.parse(_amountControllers[i].text);
            } else {
              newPayment["amount"] = "0";
            }
            widget.args.order.modeOfPayment?.add(newPayment);
          }
        }
      }

      salesInvoiceNo = await _checkoutCubit.getSalesNum() as int;
      purchasesInvoiceNo = await _checkoutCubit.getPurchasesNum() as int;
      estimateNo = await _checkoutCubit.getEstimateNum() as int;
      // print("lilne 1310 in checkout.dart");
      // print("sales invoice no is: $salesInvoiceNo");

      if (widget.args.invoiceType == OrderType.purchase) {
        if(checkAmounts()){
          _checkoutCubit.createPurchaseOrder(
              widget.args.order, (purchasesInvoiceNo + 1).toString());
        }
      } else if (widget.args.invoiceType == OrderType.saleReturn) {
        _checkoutCubit.createSalesReturn(
            widget.args.order, date, totalPrice()!);
      } else if (widget.args.invoiceType == OrderType.estimate) {
        if (widget.args.order.estimateNum != null) {
          //update estimate
          if (convertToSale) {
            if(checkAmounts()){
              //TODO: implement sub Product availability validation
              _checkoutCubit.convertEstimateToSales(
                  widget.args.order, (salesInvoiceNo + 1).toString());
            }
          } else {
            _checkoutCubit.updateEstimateOrder(widget.args.order);
          }
        } else {
          //TODO: implement sub Product availability validation
          _checkoutCubit.createEstimateOrder(
              widget.args.order, (estimateNo + 1).toString());
        }
      } else if (widget.args.invoiceType == OrderType.sale) {
        if(checkAmounts()){
          //TODO: implement sub Product availability validation
          _checkoutCubit.createSalesOrder(
              widget.args.order,(salesInvoiceNo + 1).toString());
        }
      }

      // final provider = Provider.of<Billing>(context, listen: false);
      if (widget.args.invoiceType == OrderType.sale ||
          widget.args.invoiceType == OrderType.purchase) {
        if(widget.args.invoiceType == OrderType.sale){
          BillingCubit().deleteBillingOrder(widget.args.order.kotId!);
        }
        // DatabaseHelper().deleteOrderItemInput(widget.args.order);
        // if (widget.args.invoiceType == OrderType.purchase) {
          // provider.removePurchaseBillItems(widget.args.orderId);
        // } else {
          // provider.removeSalesBillItems(widget.args.orderId);
        // }
      }
    }
  }

  ///for validation of availability of Sub Product quantity
  // _validateSubProductQuantity() {
  //   widget.args.order.orderItems?.forEach((orderItem) async {
  //     //fetch product
  //     var resp = await ProductService().getProduct(orderItem.product!.id!);
  //     final product = Product.fromMap(resp.data['inventory']);
  //     print("productJson : ${product.subProducts?[0].inventoryId}");
  //     product.subProducts?.forEach((subProduct) async {
  //       var resp = await ProductService().getProduct(subProduct.inventoryId!);
  //       final subProductFetched = Product.fromMap(resp.data['inventory']);
  //       print("subProduct quantity: ${subProductFetched.quantity}");
  //       print("orderItem quantity: ${orderItem.quantity}");
  //       double quantityToBeSold = orderItem.quantity*subProduct.quantity!.toDouble();
  //       print(quantityToBeSold);
  //
  //       // if(subProductFetched.quantity)
  //
  //     });
  //   });
  // }
}

Future<void> _launchUrl(mobNum, user,List<Map<String, dynamic>>? paymethod, sub, tax, dis, items) async {
  //916000637319
  final String mobile = "91${mobNum}";
  final String invoiceHeader =
      "%0A%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%3D%0A";
  final String invoiceText =
      "%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20INVOICE";
  final String email = "%0AEmail%3A%20${user.email}";
  final String cusName = "%0ABusiness%20Name%3A%20${user.businessName}";
  // final String Date = "%0ADate%3A%20%5BDate%5D";
  final String Date =
      "Date%3A%20${DateFormat('dd LLLL yyyy').format(DateTime.now())}";
  final String invoiceNumber = "%0AMobile%20Number%3A%20${user.phoneNumber}";
  final String dash1 = "%0A------------------------------------";
  final String tableHead =
      "%0A%20%20%20%20%20ITEM%20%20%20%20%20QTY%20%20%20%20%20PRICE%20%20%20%20%20TOTAL";
  String x = "";
  for (int i = 0; i < items.length; i++) {
    if (items[i].product.name.length <= 4) {
      x = x +
          "%0A%09%09%09${items[i].product.name}%09%09%20%09%09%09${items[i].quantity}%09%09%09%09%09%09${items[i].product.sellingPrice}%09%09%09%09%09%09%09${items[i].product.sellingPrice * items[i].quantity}";
    } else {
      x = x +
          "%0A%09%09%09${items[i].product.name.substring(0, 4)}%09%09%20%09%09%09${items[i].quantity}%09%09%09%09%09%09${items[i].product.sellingPrice}%09%09%09%09%09%09%09${items[i].product.sellingPrice * items[i].quantity}";
      x = x + "%0A%09%09%09${items[i].product.name.substring(4)}";
    }
  }
  /* final String tableData1 =
        "%0A%5BItem%201%5D%20%20%20%20${items[0]["qty"]}%20%20%5BPrice%201%5D%20%20%5BTotal%201%5D";
    final String tableData2 =
        "%0A%5BItem%202%5D%20%20%20%5BQty%202%5D%20%20%5BPrice%202%5D%20%20%5BTotal%202%5D";
    final String tableData3 = "%0A%5BItem%203%5D%20%20%20%5BQty%203%5D%20%20";*/
  final String subTotal = "%0ASubtotal%3A%20₹%20${sub}";
  final String delivery = "%0AGST%20Charges%3A%20₹%20${tax}";
  final String discount = "%0ADiscount%3A%20₹%20${dis}";
  final String grandTotal =
      "%0AGrand%20Total%3A%20₹%20${num.parse(sub) + num.parse(tax) - num.parse(dis)}";
  final String detailsText =
      "%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20PAYMENT%20DETAILS";

  final String method = "%0APayment%20Method%3A%20${paymethod?.map((map) => "${map['mode'] ?? "N/A"} : ${map['amount'] ?? ""}")
      .join(', ')}";
  final String dueDate =
      "%0ADue%20Date%3A%20${DateFormat('dd LLLL yyyy').format(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1))}";
  final String thanks = "%0AThank%20you%20for%20your%20business%21%0A";

  final Uri _url = Uri.parse(
      'https://wa.me/${mobile}?text=${invoiceHeader}${invoiceText}${invoiceHeader}${Date}${cusName}${email}${invoiceNumber}${dash1}${tableHead}${dash1}${x}${dash1}${subTotal}${delivery}${discount}${grandTotal}${dash1}${detailsText}${dash1}${method}${dash1}${thanks}');

  if (await canLaunchUrl(_url)) {
    await launchUrl(_url, mode: LaunchMode.externalApplication);
  } else {
    throw Exception('Could not launch $_url');
  }
}
