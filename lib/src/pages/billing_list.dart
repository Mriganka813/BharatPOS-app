import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/blocs/billing/billing_cubit.dart';
import 'package:shopos/src/models/input/kot_model.dart';
import 'package:shopos/src/models/input/order.dart';


import 'package:shopos/src/pages/bluetooth_printer_list.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/billing_service.dart';
import 'package:shopos/src/services/kot_services.dart';

import '../config/colors.dart';
import '../services/global.dart';
import '../services/locator.dart';
import '../services/set_or_change_pin.dart';
import '../widgets/custom_button.dart';
import '../widgets/pin_validation.dart';

enum kotType {
  is57mm,
  is80mm,
}

enum billType {
  is57mm,
  is80mm,
}

class BluetoothArgs {
  // final User user;
  // final Order order;
  // final List<String> headers;
  // final DateTime date;
  // final String invoiceNum;
  // final String total;
  // final String subtotal;
  // final String gst;

  final Order order;
  final DateTime dateTime;
  kotType type;

  BluetoothArgs(
      {required this.order, required this.dateTime, required this.type});
}

class BillingListScreen extends StatefulWidget {
  static const routeName = '/billing-list';
  BuildContext context;
  BillingListScreen(this.context, {Key? key, required this.orderType})
      : super(key: key);

  final OrderType orderType;

  @override
  State<BillingListScreen> createState() => _BillingListScreenState();
}

class _BillingListScreenState extends State<BillingListScreen> {
  // List<Order> _Order = [];
  // List<OrderType> _orderType = [];

  // bool _isEdit = false;

  // getAllOrderList() async {
  //   final provider = Provider.of<Billing>(context, listen: false);
  //   _Order = provider.getAllOrder();
  //   _orderType = provider.getAllOrderType();
  // }
  // Timer? timer;
  String date = '';
  bool showOption = false;
  late SharedPreferences prefs;
  final TextEditingController pinController = TextEditingController();
  PinService _pinService = PinService();
  late final BillingCubit _billingCubit;

  @override
  void initState() {
    super.initState();
    fetchNTPTime();
    init();
    _billingCubit = BillingCubit()..getBillingOrders();
    // startTimer();
  }
  // @override
  // void dispose() {
  //   super.dispose();
  //   timer?.cancel(); // Cancel the timer when the widget is disposed
  // }

  // void startTimer() {
  //   print("timer started");
  //   timer = Timer.periodic(Duration(seconds: 10), (_) => refreshPage());
  // }

  void refreshPage() {
    _billingCubit.getBillingOrders();
    // print("Function executed!");
  }
  init() async {
    prefs =
    await SharedPreferences.getInstance();
  }
  // getBillingOrders() async {
  //   List<dynamic> allBillingOrders = await BillingService.getAllBillingOrder();
  //   allBillingOrders.forEach((element) {
  //     print("element: ${element}");
  //     _allBills.add(Order.fromMap(element));
  //   });
  //   print("all bills length: ${_allBills.length}");
  //   setState(() {
  //
  //   });
  // }

  Future<void> fetchNTPTime() async {
    DateTime currentTime;

    currentTime = DateTime.now();

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
    print('date1=$date');
  }

  ///
  String? totalPrice(int index, Billing provider, List<Order> _allBills) {
    return widget.orderType == OrderType.sale
        ? _allBills[index].orderItems?.fold<double>(
            0,
            (acc, curr) {
              // if (widget.orderType == OrderType.purchase) {
              //   return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
              // }
              return (double.parse(curr.quantity.toString()) *
                      (curr.product?.sellingPrice ?? 1.0)) +
                  acc;
            },
          ).toString()
        : provider.purchaseBilling.values
            .toList()[index]
            .orderItems
            ?.fold<double>(
            0,
            (acc, curr) {
              // if (widget.orderType == OrderType.purchase) {
              return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
              // }
              // return (double.parse(curr.quantity.toString()) *
              //         (curr.product?.sellingPrice ?? 1.0)) +
              //     acc;
            },
          ).toStringAsFixed(2);
  }
  String? totalDiscount(int index, Billing provider, List<Order> _allBills){
    // print("in total discount");
    // print("line 157 in billing list");
    // print(index);
    // print(provider.salesBilling.values.toList());

    return _allBills[index].orderItems?.fold<double>(
      0,
        (acc, curr){
          // print(acc);
          // print(curr.discountAmt);
          return double.parse(curr.discountAmt)+acc;
        }
    ).toStringAsFixed(2);
  }
  ///
  String? totalbasePrice(int index, Billing provider, List<Order> _allBills) {
    print("line 158 in billing list");
    print("index is $index");
    // print(provider.salesBilling.values.toList()[index].toMap(OrderType.sale));
    return widget.orderType == OrderType.sale
        ? _allBills[index].orderItems?.fold<double>(
            0,
            (acc, curr) {
              // if (_orderType[index] == OrderType.purchase) {
              //   // return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
              //   double sum = 0;
              //   if (curr.product!.basePurchasePriceGst! != "null")
              //     sum = double.parse(curr.product!.basePurchasePriceGst!);
              //   else {
              //     sum = curr.product!.purchasePrice.toDouble();
              //   }
              //   return (curr.quantity * sum) + acc;
              // }
              // else {
              double sum = 0;
              if (curr.product!.baseSellingPriceGst != "null")
                sum = double.parse(curr.product!.baseSellingPriceGst!);
              else {
                sum = curr.product!.sellingPrice!.toDouble();
              }
              return (curr.quantity * sum) + acc;
              // }
            },
          ).toStringAsFixed(2)
        : provider.purchaseBilling.values
            .toList()[index]
            .orderItems
            ?.fold<double>(
            0,
            (acc, curr) {
              // if (_orderType[index] == OrderType.purchase) {
              // return (curr.quantity * (curr.product?.purchasePrice ?? 1)) +
              //     acc;
              double sum = 0;
              if (curr.product!.basePurchasePriceGst! != "null")
                sum = double.parse(curr.product!.basePurchasePriceGst!);
              else {
                sum = curr.product!.purchasePrice.toDouble();
              }
              return (curr.quantity * sum) + acc;
              // }
              // }
              // else {
              // double sum = 0;
              // if (curr.product!.baseSellingPriceGst! != "null")
              //   sum = double.parse(curr.product!.baseSellingPriceGst!);
              // else {
              //   sum = curr.product!.sellingPrice!.toDouble();
              // }
              // return (curr.quantity * sum) + acc;
              // }
            },
          ).toStringAsFixed(2);
  }

  ///
  String? totalgstPrice(int index, Billing provider, List<Order> _allBills) {
    // print("line 230 in billing list");
    // print(provider.salesBilling.values.toList());
    return widget.orderType == OrderType.sale
        ? _allBills[index].orderItems?.fold<double>(
            0,
            (acc, curr) {
              // if (_orderType[index] == OrderType.purchase) {
              //   // return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
              //   double gstsum = 0;
              //   if (curr.product!.purchaseigst! != "null")
              //     gstsum = double.parse(curr.product!.purchaseigst!);
              //   // else {
              //   //   gstsum = curr.product!.sellingPrice;
              //   // }
              //   return double.parse(
              //       ((curr.quantity * gstsum) + acc).toStringAsFixed(2));
              // } else {
              double gstsum = 0;
              if (curr.product!.saleigst! != "null")
                gstsum = double.parse(curr.product!.saleigst!);
              // else {
              //   gstsum = curr.product!.sellingPrice;
              // }
              return double.parse(
                  ((curr.quantity * gstsum) + acc).toStringAsFixed(2));
              // }
            },
          ).toStringAsFixed(2)
        : provider.purchaseBilling.values
            .toList()[index]
            .orderItems
            ?.fold<double>(
            0,
            (acc, curr) {
              // if (_orderType[index] == OrderType.purchase) {
              // return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
              double gstsum = 0;
              if (curr.product!.purchaseigst! != "null")
                gstsum = double.parse(curr.product!.purchaseigst!);
              // else {
              //   gstsum = curr.product!.sellingPrice;
              // }
              return double.parse(
                  ((curr.quantity * gstsum) + acc).toStringAsFixed(2));
              // } else {
              //   double gstsum = 0;
              //   if (curr.product!.saleigst! != "null")
              //     gstsum = double.parse(curr.product!.saleigst!);
              //   // else {
              //   //   gstsum = curr.product!.sellingPrice;
              //   // }
              //   return double.parse(
              //       ((curr.quantity * gstsum) + acc).toStringAsFixed(2));
              // }
            },
          ).toStringAsFixed(2);
  }

  void _view57mmPdf(Order Order) async {
    // User user = User();
    // try {
    //   final res = await UserService.me();
    //   if ((res.statusCode ?? 400) < 300) {
    //     user = User.fromMap(res.data['user']);
    //   }
    // } catch (_) {
    //   Navigator.pop(context);
    // }
    // await PdfKotUI.generate57mmKot(
    //     user: user,
    //     order: Order,
    //     headers: ["Item", "Qty"],
    //     date: DateTime.now(),
    //     invoiceNum: date);

    Navigator.of(context).pushNamed(BluetoothPrinterList.routeName,
        arguments: CombineArgs(
            billArgs: null,
            bluetoothArgs: BluetoothArgs(
                order: Order,
                dateTime: DateTime.now(),
                type: kotType.is57mm)));
  }

  void _view80mmPdf(Order order) {
    // User user = User();
    // try {
    //   final res = await UserService.me();
    //   if ((res.statusCode ?? 400) < 300) {
    //     user = User.fromMap(res.data['user']);
    //   }
    // } catch (_) {
    //   Navigator.pop(context);
    // }
    // await PdfKotUI.generate80mmKot(
    //     user: user,
    //     order: Order,
    //     headers: ["Item", "Qty"],
    //     date: DateTime.now(),
    //     invoiceNum: date);

    Navigator.of(context).pushNamed(BluetoothPrinterList.routeName,
        arguments: CombineArgs(
            billArgs: null,
            bluetoothArgs: BluetoothArgs(
                order: order,
                dateTime: DateTime.now(),
                type: kotType.is80mm)));
  }

  // void _viewSmallKot(Order Order, int index, Billing provider) async {
  //   User user = User();
  //   final targetPath = await getExternalCacheDirectories();
  //   const targetFileName = "Invoice";
  //   try {
  //     final res = await UserService.me();
  //     if ((res.statusCode ?? 400) < 300) {
  //       user = User.fromMap(res.data['user']);
  //       // if (type == 0) _viewPdfwithgst(user);
  //       // if (type == 1) _viewPdfwithoutgst(user);
  //     }
  //   } catch (_) {
  //     Navigator.pop(context);
  //   }
  //   // final htmlContent = smallKotTemplate(
  //   //     invoiceNum: date,
  //   //     user: user,
  //   //     date: DateTime.now(),
  //   //     order: Order,
  //   //     headers: [
  //   //       "Invoice 0000000",
  //   //       "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
  //   //     ],
  //   //     subtotal: totalbasePrice(index, provider)!,
  //   //     gstTotal: totalgstPrice(index, provider)!,
  //   //     totalPrice: totalPrice(index, provider)!);
  //   // final generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
  //   //   htmlContent,
  //   //   targetPath!.first.path,
  //   //   targetFileName,
  //   // );

  //   PdfUI.generate80mmPdf(
  //     user: user,
  //     order: Order,
  //     headers: [
  //       "Invoice 0000000",
  //       "${DateFormat('dd/MM/yyyy').format(DateTime.now())}"
  //     ],
  //     date: DateTime.now(),
  //     invoiceNum: date,
  //     totalPrice: totalPrice(index, provider)!,
  //     subtotal: totalbasePrice(index, provider)!,
  //     gstTotal: totalgstPrice(index, provider)!,
  //   );

  //   // for open pdf
  //   // try {
  //   //   OpenFile.open(generatedPdfFile.path);
  //   // } catch (e) {
  //   //   print(e);
  //   // }
  // }

  _showNewDialog(Order order) async {
    return showDialog(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('default', '57mm');
                _view57mmPdf(order);
                Navigator.of(ctx).pop();
              },
              title: Text('58mm'),
            ),
            ListTile(
              onTap: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setString('default', '80mm');
                _view80mmPdf(order);
                Navigator.of(ctx).pop();
              },
              title: Text('80mm'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Billing>(
      context,
    );
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(HomePage.routeName, (route) => false);

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Pending orders'),
          actions: [
            IconButton(onPressed: (){
              _billingCubit.getBillingOrders();
              locator<GlobalServices>().successSnackBar("Bills Refreshed");
            }, icon: Icon(Icons.refresh))
          ],
        ),
        body:BlocListener<BillingCubit, BillingState>(
              bloc: _billingCubit,
              listener: (context, state){
                if(state is BillingSuccess){
                  print("state is billing success");
                  _billingCubit.getBillingOrders();
                }
              },
              child: BlocBuilder<BillingCubit, BillingState>(
                  bloc: _billingCubit,
                 builder: (context, state){
                   if(state is BillingLoading){
                     return const Center(
                       child: CircularProgressIndicator(
                         valueColor: AlwaysStoppedAnimation<Color>(
                           ColorsConst.primaryColor,
                         ),
                       ),
                     );
                   }else if(state is BillingListRender){
                     List<Order> _allBills = state.bills;
                     print("_allBills length is ${_allBills.length}");
                     if(_allBills.length == 0){
                       return Center(
                           child: Text(
                             'No bills are pending',
                             style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                           ));
                     } else {
                       return ListView.builder(
                         shrinkWrap: true,
                         itemCount: widget.orderType == OrderType.sale
                             ? _allBills.length
                             : provider.purchaseBilling.length,
                         itemBuilder: (context, index) => GestureDetector(
                           onLongPress: () {
                             // showDialog(
                             //     context: context,
                             //     builder: (ctx) {
                             //       return AlertDialog(
                             //         content: Column(
                             //           crossAxisAlignment: CrossAxisAlignment.start,
                             //           mainAxisSize: MainAxisSize.min,
                             //           children: [
                             //             ListTile(
                             //               onTap: () async {
                             //                 widget.orderType == OrderType.sale
                             //                     ? await Navigator.pushNamed(
                             //                     context, CreateSale.routeName,
                             //                     arguments: BillingPageArgs(
                             //                         editOrders: _allBills[index]
                             //                             .orderItems,
                             //                         kotId: _allBills[index].kotId,
                             //                          tableNo: _allBills[index].tableNo))
                             //                     : await Navigator.pushNamed(
                             //                     context, CreatePurchase.routeName,
                             //                     arguments: BillingPageArgs(
                             //                         editOrders: provider.purchaseBilling.values
                             //                             .toList()[index]
                             //                             .orderItems));
                             //
                             //                 // var data = await DatabaseHelper().getOrderItems();
                             //                 //
                             //                 // provider.removeAll();
                             //                 //
                             //                 // data.forEach((element) {
                             //                 //   print("adding sales bill");
                             //                 //   provider.addSalesBill(element, element.id.toString());
                             //                 // });
                             //
                             //               },
                             //               title: Text('Edit',
                             //                   style: TextStyle(
                             //                       fontWeight: FontWeight.w600,
                             //                       fontSize: 19)),
                             //             ),
                             //
                             //             ListTile(
                             //                 onTap: () async {
                             //                   String? defaultFormat =
                             //                   prefs.getString('default');
                             //
                             //                   if (defaultFormat == null) {
                             //                     _showNewDialog(_allBills[index],);
                             //                   } else if (defaultFormat == "57mm") {
                             //                     _view57mmPdf(_allBills[index],);
                             //                   } else if (defaultFormat == "80mm") {
                             //                     _view80mmPdf(_allBills[index],);
                             //                   }
                             //
                             //                 },
                             //                 title: Text(
                             //                   'KOT',
                             //                   style: TextStyle(
                             //                       fontWeight: FontWeight.w600,
                             //                       fontSize: 19),
                             //                 )),
                             //           ],
                             //         ),
                             //       );
                             //     });
                           },
                           onTap: () {
                             Navigator.pushNamed(
                               context,
                               CheckoutPage.routeName,
                               arguments: CheckoutPageArgs(
                                 invoiceType: widget.orderType,
                                 // orderId: widget.orderType == OrderType.sale
                                 //     ? provider.salesBilling.keys.toList()[index]
                                 //     : provider.purchaseBilling.keys.toList()[index],
                                 order: widget.orderType == OrderType.sale
                                     ? _allBills[index]
                                     : provider.purchaseBilling.values.toList()[index],
                               ),
                             );
                           },
                           child: Dismissible(
                             key: ValueKey(DateTime.now()),
                             background: Container(
                               color: Theme.of(context).colorScheme.error,
                               alignment: Alignment.centerLeft,
                               padding: const EdgeInsets.only(right: 20, left: 20),
                               margin: const EdgeInsets.symmetric(
                                   horizontal: 15, vertical: 4),
                               child: Row(
                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                 children: [
                                   const Icon(
                                     Icons.delete,
                                     size: 40,
                                     color: Colors.white,
                                   ),
                                   const Icon(
                                     Icons.delete,
                                     size: 40,
                                     color: Colors.white,
                                   ),
                                 ],
                               ),
                             ),
                             confirmDismiss: (direction) {
                               return _showDialog();
                             },
                             onDismissed: (direction) async {
                               var result = true;

                               if (await _pinService.pinStatus() == true) {
                                 result = await PinValidation.showPinDialog(context) as bool;
                               }
                               if(result){
                                 _billingCubit.deleteBillingOrder(_allBills[index].kotId!);
                                 // _billingCubit.getBillingOrders();
                                 // DatabaseHelper().deleteOrderItemInput(
                                 //     provider.salesBilling.values.toList()[index]);
                                 // widget.orderType == OrderType.sale
                                 //     ? provider.removeSalesBillItems(
                                 //     provider.salesBilling.keys.toList()[index])
                                 //     : provider.removePurchaseBillItems(
                                 //     provider.purchaseBilling.keys.toList()[index]);
                               }
                               // startTimer();
                               setState(() {});
                             },
                             child: Card(
                               elevation: 2,
                               // color: Theme.of(context).scaffoldBackgroundColor,
                               child: Padding(
                                 padding: const EdgeInsets.all(8.0),
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
                                     if(_allBills.isNotEmpty)
                                       if (_allBills[index].tableNo !="-1" &&
                                           _allBills[index].tableNo !="" && _allBills[index].tableNo!='null')
                                         if(widget.orderType == OrderType.sale)
                                           Row(
                                             mainAxisAlignment:
                                             MainAxisAlignment.spaceBetween,
                                             children: [
                                               Text(''
                                                   'Table No',style: TextStyle(fontWeight: FontWeight.bold)),
                                               Text(
                                                   '${_allBills[index].tableNo}',
                                                   style: TextStyle(fontWeight: FontWeight.bold)),
                                             ],
                                           ),
                                     const SizedBox(height: 20),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('Sub Total'),
                                         Text('₹ ${totalbasePrice(index, provider, _allBills)}'),
                                       ],
                                     ),
                                     const SizedBox(height: 5),
                                     const SizedBox(height: 5),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('Tax GST'),
                                         Text('₹ ${totalgstPrice(index, provider, _allBills)}'),
                                       ],
                                     ),
                                     const SizedBox(height: 5),
                                     const SizedBox(height: 5),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('Discount'),
                                         // Text('₹ ${provider.salesBilling.values.toList()[index].orderItems}'),
                                         widget.orderType!=OrderType.purchase ? Text('₹ ${totalDiscount(index, provider, _allBills)}'):Text('₹ 0'),
                                       ],
                                     ),
                                     const SizedBox(height: 5),
                                     const SizedBox(height: 5),

                                     const SizedBox(height: 5),
                                     Divider(color: Colors.black54),
                                     const SizedBox(height: 5),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('Grand Total'),
                                         Text(
                                           '₹ ${ double.parse(totalPrice(index, provider, _allBills)!).toStringAsFixed(2)}',
                                           style: TextStyle(fontWeight: FontWeight.bold),
                                         ),
                                       ],
                                     ),

                                     const SizedBox(height: 5),
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                           children: [
                                             IconButton(onPressed:(){
                                               String kotId = _allBills[index].kotId!;
                                               _showKotHistory(kotId);
                                             }, icon: Icon(Icons.history, color: Colors.blue,)),
                                             IconButton(onPressed: (){
                                               String? defaultFormat =
                                               prefs.getString('default');

                                               if (defaultFormat == null) {
                                                 _showNewDialog(_allBills[index],);
                                               } else if (defaultFormat == "57mm") {
                                                 _view57mmPdf(_allBills[index],);
                                               } else if (defaultFormat == "80mm") {
                                                 _view80mmPdf(_allBills[index],);
                                               }
                                             }, icon: Icon(Icons.print, color: Colors.blue[400],)),
                                           ],
                                         ),
                                         InkWell(
                                           onTap: () async {
                                             // print("on tap edit");
                                             // print(_allBills[index].orderItems![0].quantity);
                                             widget.orderType == OrderType.sale
                                                 ? await Navigator.pushNamed(
                                                 context, CreateSale.routeName,
                                                 arguments: BillingPageArgs(
                                                     editOrders: _allBills[index]
                                                         .orderItems,
                                                     kotId: _allBills[index].kotId,
                                                     tableNo: _allBills[index].tableNo))
                                                 : await Navigator.pushNamed(
                                                 context, CreatePurchase.routeName,
                                                 arguments: BillingPageArgs(
                                                     editOrders: provider.purchaseBilling.values
                                                         .toList()[index]
                                                         .orderItems));

                                             // var data = await DatabaseHelper().getOrderItems();
                                             //
                                             // provider.removeAll();
                                             //
                                             // data.forEach((element) {
                                             //   print("adding sales bill");
                                             //   provider.addSalesBill(element, element.id.toString());
                                             // });
                                           },
                                           child: Container(
                                             decoration: BoxDecoration(
                                             shape: BoxShape.rectangle,
                                               borderRadius: BorderRadius.circular(20),
                                             color: Colors.white, // Adjust color and opacity as needed
                                             border: Border.all(
                                               color: Colors.blue, // Border color
                                               width: 1, // Border width
                                             ),
                                           ),
                                             padding: EdgeInsets.only(top: 6, bottom: 6, left: 20, right: 20),
                                             child: Center(
                                               child: Container(
                                                 // padding: EdgeInsets.only(left: 30, right: 10, top: 15, bottom: 15),
                                                 // color: Colors.red,
                                                 child: Row(
                                                   mainAxisAlignment: MainAxisAlignment.end,
                                                   children: [
                                                     Text('Edit', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),),
                                                     // SizedBox(width: 10,)
                                                   ],
                                                 ),
                                               ),
                                             ),
                                           ),
                                         )
                                       ],
                                     )
                                     // Divider(color: Colors.black54),
                                     // const Divider(color: Colors.transparent),
                                   ],
                                 ),
                               ),
                             ),
                           ),
                         ),
                       );
                     }
                   }

                   return const Center(
                     child: CircularProgressIndicator(
                       valueColor:
                       AlwaysStoppedAnimation(ColorsConst.primaryColor),
                     ),
                   );
                 },
              ),
             )

      ),
    );
  }
  Future<bool?> _showDialog() {
    // timer?.cancel();//pausing timer if this dialog is open
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.red,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Delete'),
            ],
          ),
          content: Text('Are you sure?'),
          actions: [
            TextButton(
                onPressed: () {
                  // startTimer();
                  Navigator.pop(ctx, false);
                },
                child: Text('No')),
            TextButton(
                onPressed: () {
                  Navigator.pop(ctx, true);
                },
                child: Text('Yes'))
          ],
        );
      },
    );
  }
  Widget currentdate(DateTime createdAt) {
    var datereq = DateFormat.MMMM().format(createdAt);

    final String _inputTime = '${createdAt.hour}:${createdAt.minute}';
    final DateFormat _inputFormat = DateFormat('HH:mm');
    final DateFormat _outputFormat = DateFormat('h:mm a');

    DateTime inputDateTime = _inputFormat.parse(_inputTime);
    String outputTime = _outputFormat.format(inputDateTime);

    String pmAmFlag = "AM";

    if (createdAt.hour >= 13) {
      pmAmFlag = "PM";
    } else {
      pmAmFlag = "AM";
    }
    return Text(
      '${createdAt.day.toString()}.${createdAt.month.toString()}.${createdAt.year.toString()} | $outputTime',
      style: const TextStyle(color: Colors.black45, fontSize: 13),
    );
  }
  _showKotHistory(String kotId) async {
    Map<String, dynamic> kotHistory = await KOTService.getKot(kotId);
    Kot kot = Kot.fromMap(kotHistory['kot']);
    return showModalBottomSheet(
      isScrollControlled: true,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 20, left: 20, right: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 4,
                  width: 40,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  "KOT History",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: kot.items?.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (kot.items?[index].name == "Printed")
                                      Icon(Icons.print),
                                    kot.items?[index].name == "Printed"
                                        ? Text(" KOT Printed at",style: TextStyle(fontSize: 16),)
                                        : Text('${kot.items?[index].name} x ${kot.items?[index].quantity}',style: TextStyle(fontSize: 16),),
                                    SizedBox(width: 5),
                                    currentdate(kot.items![index].createdAt!),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
                if(kot.items!.length < 5) SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );

  }
}
