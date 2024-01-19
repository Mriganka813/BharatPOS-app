import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/models/input/order.dart';


import 'package:shopos/src/pages/bluetooth_printer_list.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_purchase.dart';
import 'package:shopos/src/pages/create_sale.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';

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

  String date = '';
  bool showOption = false;

  @override
  void initState() {
    super.initState();
    fetchNTPTime();
  }

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
  String? totalPrice(int index, Billing provider) {
    return widget.orderType == OrderType.sale
        ? provider.salesBilling.values.toList()[index].orderItems?.fold<double>(
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
  String? totalDiscount(int index, Billing provider){
    // print("in total discount");
    // print("line 157 in billing list");
    // print(index);
    // print(provider.salesBilling.values.toList());

    return provider.salesBilling.values.toList()[index].orderItems?.fold<double>(
      0,
        (acc, curr){
          // print(acc);
          // print(curr.discountAmt);
          return double.parse(curr.discountAmt)+acc;
        }
    ).toStringAsFixed(2);
  }
  ///
  String? totalbasePrice(int index, Billing provider) {
    print("line 158 in billing list");
    // print(provider.salesBilling.values.toList()[index].toMap(OrderType.sale));
    return widget.orderType == OrderType.sale
        ? provider.salesBilling.values.toList()[index].orderItems?.fold<double>(
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
  String? totalgstPrice(int index, Billing provider) {
    // print("line 230 in billing list");
    // print(provider.salesBilling.values.toList());
    return widget.orderType == OrderType.sale
        ? provider.salesBilling.values.toList()[index].orderItems?.fold<double>(
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

  void _view57mmPdf(Order Order) {
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
          title: Text('Billing orders'),
        ),
        body: (widget.orderType == OrderType.sale &&
                    provider.salesBilling.length == 0) ||
                (widget.orderType == OrderType.purchase &&
                    provider.purchaseBilling.length == 0)
            ? Center(
                child: Text(
                'No bills are pending',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.orderType == OrderType.sale
                    ? provider.salesBilling.length
                    : provider.purchaseBilling.length,
                itemBuilder: (context, index) => GestureDetector(
                  onLongPress: () {
                    showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  onTap: () {
                                    print("line 453 in billing list");
                                    // print(" id is: ${provider.salesBilling.values
                                    //     .toList()[index]
                                    //     .id}");
                                    widget.orderType == OrderType.sale
                                        ? Navigator.pushNamed(context, CreateSale.routeName,
                                            arguments: BillingPageArgs(
                                                orderId: provider.salesBilling.keys
                                                    .toList()[index],
                                                editOrders: provider.salesBilling.values
                                                    .toList()[index]
                                                    .orderItems,
                                                id: provider.salesBilling.values
                                                    .toList()[index]
                                                    .id))
                                        : Navigator.pushNamed(
                                            context, CreatePurchase.routeName,
                                            arguments: BillingPageArgs(
                                                orderId: provider.purchaseBilling.keys
                                                    .toList()[index],
                                                editOrders: provider.purchaseBilling.values
                                                    .toList()[index]
                                                    .orderItems));
                                  },
                                  title: Text('Edit',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 19)),
                                ),

                                // InkWell(
                                //     onTap: () {
                                //       _viewPdf(provider.salesBilling.values
                                //           .toList()[index]);

                                //       print(showOption);
                                //     },
                                //     child: Text(
                                //       'Print KOT',
                                //       style: TextStyle(
                                //           fontWeight: FontWeight.w600,
                                //           fontSize: 19),
                                //     )),

                                ListTile(
                                    onTap: () async {
                                      // _viewSmallKot(
                                      //     provider.salesBilling.values
                                      //         .toList()[index],
                                      //     index,
                                      //     provider);
                                      // _chekBluetoothPrinterDevices(
                                      //     provider.salesBilling.values
                                      //         .toList()[index],
                                      //     index,
                                      //     provider);

                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();

                                      String? defaultFormat =
                                          prefs.getString('default');

                                      if (defaultFormat == null) {
                                        _showNewDialog(
                                          provider.salesBilling.values
                                              .toList()[index],
                                        );
                                      } else if (defaultFormat == "57mm") {
                                        _view57mmPdf(
                                          provider.salesBilling.values
                                              .toList()[index],
                                        );
                                      } else if (defaultFormat == "80mm") {
                                        _view80mmPdf(
                                          provider.salesBilling.values
                                              .toList()[index],
                                        );
                                      }
                                    },
                                    title: Text(
                                      'KOT',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 19),
                                    )),
                                // showOption
                                //     ? Row(
                                //         children: [Text('58mm'), Text('80mm')],
                                //       )
                                //     : Container()
                              ],
                            ),
                          );
                        });
                  },
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CheckoutPage.routeName,
                      arguments: CheckoutPageArgs(
                        invoiceType: widget.orderType,
                        orderId: widget.orderType == OrderType.sale
                            ? provider.salesBilling.keys.toList()[index]
                            : provider.purchaseBilling.keys.toList()[index],
                        order: widget.orderType == OrderType.sale
                            ? provider.salesBilling.values.toList()[index]
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
                      DatabaseHelper().deleteOrderItemInput(
                          provider.salesBilling.values.toList()[index]);
                      widget.orderType == OrderType.sale
                          ? provider.removeSalesBillItems(
                              provider.salesBilling.keys.toList()[index])
                          : provider.removePurchaseBillItems(
                              provider.purchaseBilling.keys.toList()[index]);

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
                            if(provider.salesBilling.values
                                    .toList().isNotEmpty)
                            if (provider.salesBilling.values
                                    .toList()[index]
                                    .tableNo !=
                                "-1")
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Table No',style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    '${provider.salesBilling.values.toList()[index].tableNo}',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sub Total'),
                                Text('₹ ${totalbasePrice(index, provider)}'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tax GST'),
                                Text('₹ ${totalgstPrice(index, provider)}'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Discount'),
                                // Text('₹ ${provider.salesBilling.values.toList()[index].orderItems}'),
                                widget.orderType!=OrderType.purchase ? Text('₹ ${totalDiscount(index, provider)}'):Text('₹ 0'),
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
                                  '₹ ${ double.parse(totalPrice(index, provider)!).toStringAsFixed(2)}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  ),
                ),
              ),
      ),
    );
  }

  Future<bool?> _showDialog() {
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
}
