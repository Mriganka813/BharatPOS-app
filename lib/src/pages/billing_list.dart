import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/provider/billing_order.dart';

class BillingListScreen extends StatefulWidget {
  static const routeName = '/billing-list';
  const BillingListScreen({Key? key}) : super(key: key);

  @override
  State<BillingListScreen> createState() => _BillingListScreenState();
}

class _BillingListScreenState extends State<BillingListScreen> {
  List<OrderInput> _orderInput = [];
  List<OrderType> _orderType = [];

  // bool _isEdit = false;

  getAllOrderInputList() async {
    final provider = Provider.of<Billing>(context, listen: false);
    _orderInput = provider.getAllOrderInput();
    _orderType = provider.getAllOrderType();
  }

  @override
  void initState() {
    getAllOrderInputList();
    super.initState();
  }

  ///
  String? totalPrice(int index) {
    return _orderInput[index].orderItems?.fold<double>(
      0,
      (acc, curr) {
        if (_orderType[index] == OrderType.purchase) {
          return (curr.quantity * (curr.product?.purchasePrice ?? 1)) + acc;
        }
        return (double.parse(curr.quantity.toString()) *
                (curr.product?.sellingPrice ?? 1.0)) +
            acc;
      },
    ).toString();
  }

  ///
  String? totalbasePrice(int index) {
    return _orderInput[index].orderItems?.fold<double>(
      0,
      (acc, curr) {
        if (_orderType[index] == OrderType.purchase) {
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
  String? totalgstPrice(int index) {
    return _orderInput[index].orderItems?.fold<double>(
      0,
      (acc, curr) {
        if (_orderType[index] == OrderType.purchase) {
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Billing>(context);
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
        body: _orderInput.length == 0
            ? Center(
                child: Text(
                'No bills are pending',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _orderInput.length,
                itemBuilder: (context, index) => GestureDetector(
                  // onLongPress: () {
                  //   showDialog(
                  //       context: context,
                  //       builder: (ctx) {
                  //         return AlertDialog(
                  //           title: InkWell(
                  //               onTap: () {
                  //                 Navigator.of(context).pop();
                  //               },
                  //               child: Text('Edit')),
                  //         );
                  //       });
                  // },
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      CheckoutPage.routeName,
                      arguments: CheckoutPageArgs(
                        invoiceType: _orderType[index],
                        orderInput: _orderInput[index],
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
                      provider.removeBill(
                          _orderInput[index], _orderType[index]);
                      _orderInput.removeAt(index);
                      _orderType.removeAt(index);
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sub Total'),
                                Text('₹ ${totalbasePrice(index)}'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Tax GST'),
                                Text('₹ ${totalgstPrice(index)}'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Discount'),
                                Text('₹ 0'),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Divider(color: Colors.black54),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Grand Total'),
                                Text(
                                  '₹ ${totalPrice(index)}',
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
