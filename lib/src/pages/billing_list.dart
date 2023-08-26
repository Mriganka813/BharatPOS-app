import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
        body: ListView.builder(
          shrinkWrap: true,
          itemCount: _orderInput.length,
          itemBuilder: (context, index) => GestureDetector(
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
    );
  }
}
