import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/blocs/checkout/checkout_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/models/input/order.dart';


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
import 'package:shopos/src/services/user.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/custom_drop_down.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/invoice_template_withGST.dart';
import 'package:shopos/src/widgets/pdf_bill_template.dart';
import 'package:upi_payment_qrcode_generator/upi_payment_qrcode_generator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/party.dart';

enum OrderType { purchase, sale,saleReturn }

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
  final String orderId;
  const CheckoutPageArgs({
    required this.invoiceType,
    required this.order,
    required this.orderId,
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
  String date = '';

  bool isBillTo = false;

  ///
  @override
  void initState() {
    super.initState();

    getUserData();
    // _isUPI = widget.args.Order.modeOfPayment == 'UPI' ? true : false;

    _checkoutCubit = CheckoutCubit();
    _typeAheadController = TextEditingController();
    fetchNTPTime();
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
  openShareModal(context, user) {
    Alert(
        style: const AlertStyle(
          animationType: AnimationType.grow,
          isButtonVisible: false,
        ),
        context: context,
        title: "Share Invoice",
        content: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: const Text("Print"),
              onTap: () async {
                // _onTapShare(2);
                SharedPreferences prefs = await SharedPreferences.getInstance();
                String? defaultBill = prefs.getString('defaultBill');

                if (defaultBill == null) {
                  _showNewDialog(widget.args.order);
                } else if (defaultBill == '57mm') {
                  _view57mmBill(widget.args.order);
                  // _viewPdf();
                } else if (defaultBill == '80mm') {
                  _view80mmBill(widget.args.order);
                } else if (defaultBill == 'A4') {
                  _viewPdf();
                }
              },
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
            ListTile(
                title: const Text("Whatsapp Message"),
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
                                "Enter Whatsapp numer\n(10-digit number only)",
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
                                      _launchUrl(
                                          t.text.trim(),
                                          user,
                                          widget.args.order.modeOfPayment,
                                          totalbasePrice(),
                                          totalgstPrice(),
                                          "0.00",
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
                })
          ],
        )).show();
  }

  ///
  void _viewPdf() async {
    bool expirydateAvailableFlag = false;
    bool hsnAvailableFlag = false;
  
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
    });

    var headerList = ["Name", "Qty", "Taxable value", "GST", "Amount"];

    if (hsnAvailableFlag == true) {
      headerList.insert(2, "HSN");
    }
    if (expirydateAvailableFlag == true) {
      headerList.insert(2, "Expiry");
    }
    final targetPath = await getExternalCacheDirectories();
    var targetFileName = "Invoice " + DateTime.now().toString();
    final htmlContent = invoiceTemplatewithGST(
      type: widget.args.invoiceType.toString(),
      date: DateTime.now(),
      companyName: userData.businessName ?? "",
      order: widget.args.order,
      user: userData,
      headers: headerList,
      total: totalPrice() ?? "",
      subtotal: totalbasePrice() ?? "",
      gsttotal: totalgstPrice() ?? "",
      invoiceNum: date,
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
        widget.args.invoiceType == OrderType.sale ? "customer" : "supplier";

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
    ).toString();
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

  void _view80mmBill(Order Order) {
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

    Navigator.of(context).pushNamed(BluetoothPrinterList.routeName,
        arguments: CombineArgs(
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
              invoiceNum: date,
              totalPrice: totalPrice() ?? '',
              subtotalPrice: totalbasePrice() ?? '',
              gsttotalPrice: totalgstPrice() ?? '',
            )));

    // for open pdf
    // try {
    //   OpenFile.open(generatedPdfFile.path);
    // } catch (e) {
    //   print(e);
    // }
  }

  void _view57mmBill(Order Order) {
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

    print(widget.args.order.orderItems![0].product!.baseSellingPriceGst ==
            'null'
        ? widget.args.order.orderItems![0].product!.sellingPrice
        : 0);
    Navigator.of(context).pushNamed(BluetoothPrinterList.routeName,
        arguments: CombineArgs(
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
              invoiceNum: date,
              totalPrice: totalPrice() ?? '',
              subtotalPrice: totalbasePrice() ?? '',
              gsttotalPrice: totalgstPrice() ?? '',
            )));
  }

  _showNewDialog(
    Order order,
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
                _view57mmBill(order);
                Navigator.of(ctx).pop();
              },
              title: Text('58mm'),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('defaultBill', '80mm');
                _view80mmBill(order);
                Navigator.of(ctx).pop();
              },
              title: Text('80mm'),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('defaultBill', 'A4');
                _viewPdf();
                Navigator.of(ctx).pop();
              },
              title: Text('A4'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "${widget.args.order.orderItems?.fold<double>(0, (acc, item) => item.quantity + acc)} products",
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: Center(
              child: Text(
                "₹ ${ double.parse(totalPrice()!).toStringAsFixed(2)}",
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : SingleChildScrollView(
              child: BlocListener<CheckoutCubit, CheckoutState>(
                bloc: _checkoutCubit,
                listener: (context, state) {
                  if (state is CheckoutSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text(
                          'Order was created successfully',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                    Future.delayed(const Duration(milliseconds: 400), () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
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
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 20,
                        left: 20,
                        right: 30,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Divider(color: Colors.transparent),
                            // const Divider(color: Colors.transparent, height: 30),
                            Card(
                              elevation: 0,
                              color: Theme.of(context).scaffoldBackgroundColor,
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
                                      Text('₹ 0'),
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
                            const Divider(color: Colors.transparent),
                            const Divider(color: Colors.transparent),
                            TypeAheadFormField<Party>(
                              validator: (value) {
                                final isEmpty =
                                    (value == null || value.isEmpty);
                                final isCredit =
                                    widget.args.order.modeOfPayment ==
                                        "Credit";
                                if (isEmpty && isCredit) {
                                  return "Please select a party for credit order";
                                }
                                return null;
                              },
                              debounceDuration:
                                  const Duration(milliseconds: 500),
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _typeAheadController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: "Party",
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, CreatePartyPage.routeName,
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
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              suggestionsCallback: (String pattern) {
                                if (int.tryParse(pattern.trim()) != null) {
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
                                _typeAheadController.text = party.name ?? "";
                              },
                            ),
                            const Divider(color: Colors.transparent, height: 5),
                            const Divider(
                                color: Colors.transparent, height: 20),
                            CustomDropDownField(
                              items: const <String>[
                                "Cash",
                                "Credit",
                                "Bank Transfer",
                                "UPI"
                              ],
                              onSelected: (e) {
                                widget.args.order.modeOfPayment = e;

                                if (widget.args.order.modeOfPayment ==
                                    'UPI') {
                                  _isUPI = true;
                                  getUPIDetails();
                                } else {
                                  _isUPI = false;
                                }

                                setState(() {});
                              },
                              validator: (e) {
                                if ((e ?? "").isEmpty) {
                                  return 'Please select a mode of payment';
                                }
                                return null;
                              },
                              hintText: "Mode of payment",
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            // qr code image
                            if (_isUPI)
                              Center(
                                child: UPIPaymentQRCode(
                                  upiDetails: _myUpiId!,
                                  size: 200,
                                  embeddedImagePath:
                                      'assets/icon/BharatPos.png',
                                  embeddedImageSize: const Size(40, 40),
                                  upiQRErrorCorrectLevel:
                                      UPIQRErrorCorrectLevel.high,
                                  qrCodeLoader: Center(
                                      child: CircularProgressIndicator()),
                                ),
                              ),
                            if (_isUPI)
                              SizedBox(
                                height: 20,
                              ),
                            if (_isUPI)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                  CustomTextField(
                                    hintText: 'Receiver name',
                                    onChanged: (val) {
                                      widget.args.order.reciverName = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                    hintText: 'Business name',
                                    onChanged: (val) {
                                      widget.args.order.businessName = val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                    hintText: 'Business address',
                                    onChanged: (val) {
                                      widget.args.order.businessAddress =
                                          val;
                                      setState(() {});
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  CustomTextField(
                                    hintText: 'GSTIN',
                                    onChanged: (val) {
                                      widget.args.order.gst = val;
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
            CustomButton(
              title: "Share",
              onTap: () async {
                try {
                  final res = await UserService.me();
                  if ((res.statusCode ?? 400) < 300) {
                    final user = User.fromMap(res.data['user']);

                    openShareModal(context, user);
                  }
                } catch (_) {}
              },
              type: ButtonType.outlined,
              padding: const EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 10,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                _onTapSubmit();
              },
              style: TextButton.styleFrom(
                backgroundColor: ColorsConst.primaryColor,
                shape: const CircleBorder(),
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 40,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onTapShare(int type) async {
    locator<GlobalServices>().showBottomSheetLoader();
    // try {
    //   // final res = await UserService.me();
    //   // if ((res.statusCode ?? 400) < 300) {
    //     // final user = User.fromMap(res.data['user']);
    //     // if (type == 0) _viewPdfwithgst(user);
    //     // if (type == 1) _viewPdfwithoutgst(user);

    //   }
    // } catch (_) {}
    if (type == 2) _viewPdf();
    Navigator.pop(context);
  }

  void _onTapSubmit() async {
    _formKey.currentState?.save();
    if (_formKey.currentState?.validate() ?? false) {

        print("discountttttttt=${widget.args.order.orderItems![0].discountAmt}");
      widget.args.invoiceType == OrderType.purchase
          ? _checkoutCubit.createPurchaseOrder(widget.args.order, date): widget.args.invoiceType == OrderType.saleReturn?_checkoutCubit.createSalesReturn(widget.args.order, date,totalPrice()!)
          : _checkoutCubit.createSalesOrder(widget.args.order, date);

      final provider = Provider.of<Billing>(context, listen: false);

      DatabaseHelper().deleteOrderItemInput(widget.args.order);
      widget.args.invoiceType == OrderType.purchase
          ? provider.removePurchaseBillItems(widget.args.orderId)
          : provider.removeSalesBillItems(widget.args.orderId);
    }
  }
}

Future<void> _launchUrl(mobNum, user, paymethod, sub, tax, dis, items) async {
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

  final String method = "%0APayment%20Method%3A%20${paymethod}";
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
