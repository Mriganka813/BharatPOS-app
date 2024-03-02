import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/billing_list.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_product.dart';

import 'package:shopos/src/pages/create_sale.dart';
// import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/pages/search_result.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';
import 'package:slidable_button/slidable_button.dart';

import '../services/global.dart';
import '../services/locator.dart';

class CreatePurchase extends StatefulWidget {
  static const routeName = '/create_purchase';
  CreatePurchase({Key? key, this.args}) : super(key: key);

  BillingPageArgs? args;

  @override
  State<CreatePurchase> createState() => _CreatePurchaseState();
}

class _CreatePurchaseState extends State<CreatePurchase> {
  late Order _Order;

  @override
  void initState() {
    super.initState();
    _Order = Order(
      orderItems: widget.args == null ? [] : widget.args!.editOrders,
    );
  }
  double roundToDecimalPlaces(double value, int decimalPlaces) {
    final factor = pow(10, decimalPlaces).toDouble();
    return (value * factor).round() / factor;
  }
  void _onAdd(OrderItemInput orderItem) {
    setState(() {
      orderItem.quantity = orderItem.quantity + 1;
      orderItem.quantity = roundToDecimalPlaces(orderItem.quantity, 4);
      orderItem.product?.quantityToBeSold = orderItem.quantity;
    });
  }
  void setQuantityToBeSold(OrderItemInput orderItem, double value,int index){
    if (value < 0) {
      locator<GlobalServices>().infoSnackBar("Quantity cannot be negative");
      return;
    }

    setState(() {
      if(value <=0 ){
        orderItem.quantity = 0;
        _Order.orderItems?[index].product?.quantityToBeSold = 0;
        _Order.orderItems?.removeAt(index);
      }else{
        orderItem.quantity = value;
        orderItem.product?.quantityToBeSold = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _Order.orderItems ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: _orderItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No products added yet',
                      ),
                    )
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _orderItems.length,
                      itemBuilder: (context, index) {
                        final _orderItem = _orderItems[index];
                        final product = _orderItems[index].product!;
                        return ProductCardPurchase(
                          type: "purchase",
                          product: product,
                          onQuantityFieldChange: (double value){
                            setQuantityToBeSold(_orderItems[index], value, index);
                          },
                          onAdd: () {
                            _onAdd(_orderItem);
                          },
                          onDelete: () {
                              if(_orderItem.quantity <= 1){
                                _orderItem.quantity = 0;
                                _Order.orderItems?[index].product?.quantityToBeSold = 0;
                                _Order.orderItems?.removeAt(index);
                              }else{
                                _orderItem.quantity = _orderItem.quantity - 1;
                                _orderItem.quantity = roundToDecimalPlaces(_orderItem.quantity, 4);
                                _orderItem.product?.quantityToBeSold = _orderItem.quantity;
                              }
                            setState(() {});
                          },
                          productQuantity: _orderItem.quantity,
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(color: Colors.transparent);
                      },
                    ),
            ),
            const Divider(color: Colors.transparent),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    title: "Add Product",
                    onTap: () async {
                      addProduct();
                    },
                  ),
                  // const VerticalDivider(
                  //   color: Colors.transparent,
                  //   width: 10,
                  // ),
                  CustomButton(
                    title: "Create Product",
                    onTap: () {
                      Navigator.pushNamed(context, CreateProduct.routeName, arguments: CreateProductArgs());
                    },
                    type: ButtonType.outlined,
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.transparent),
            HorizontalSlidableButton(
              width: double.maxFinite,
              buttonWidth: 50,
              color: Colors.green,
              isRestart: true,
              buttonColor: Colors.green,
              dismissible: false,
              label: const Center(
                  child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.black,
                ),
              )),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Swipe to continue",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              height: 50,
              onChanged: (position) {
                if (position == SlidableButtonPosition.end) {
                  // final provider = Provider.of<Billing>(context, listen: false);
                  // if (_orderItems.isNotEmpty) {
                  //   provider.addPurchaseBill(_Order, widget.args?.orderId == null ? DateTime.now().toString() : widget.args!.orderId!);
                  // }

                  if(_orderItems.isNotEmpty){
                    Navigator.pushNamed(
                        context, CheckoutPage.routeName,
                        arguments: CheckoutPageArgs(
                          invoiceType: OrderType.purchase,
                          order: _Order,
                        )
                    );
                  }else{
                    locator<GlobalServices>().errorSnackBar("No Products added");
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Map CountNoOfitemIsList(List<Product> temp) {
    var tempMap = {};

    for (int i = 0; i < temp.length; i++) {
      int count = 1;
      if (!tempMap.containsKey("${temp[i].id}")) {
        // for (int j = i + 1; j < temp.length; j++) {
        //   if (temp[i].id == temp[j].id) {
        //     count++;
        //     print("count =$count");
        //   }
        // }
        temp[i].quantityToBeSold = roundToDecimalPlaces(temp[i].quantityToBeSold!, 4);
        tempMap["${temp[i].id}"] = temp[i].quantityToBeSold;
      }
    }

    for (int i = 0; i < temp.length; i++) {
      for (int j = i + 1; j < temp.length; j++) {
        if (temp[i].id == temp[j].id) {
          temp.removeAt(j);
          j--;
        }
      }
    }

    return tempMap;
  }

  void addProduct() async {
    final result = await Navigator.pushNamed(
      context,
      SearchProductListScreen.routeName,
      arguments: ProductListPageArgs(isSelecting: true, orderType: OrderType.purchase, productlist: _Order.orderItems!),
    );
    if (result == null && result is! List<Product>) {
      return;
    }

    var temp = result as List<Product>;

    // Kotlist.addAll(temp);

    var tempMap = CountNoOfitemIsList(temp);
    final orderItems = temp
        .map((e) => OrderItemInput(
              product: e,
              quantity: tempMap["${e.id}"].toDouble(),
              price: 0,
            ))
        .toList();

    var tempOrderItems = _Order.orderItems;

    for (int i = 0; i < tempOrderItems!.length; i++) {
      for (int j = 0; j < orderItems.length; j++) {
        if (tempOrderItems[i].product!.id == orderItems[j].product!.id) {
          // tempOrderItems[i].product!.quantity = tempOrderItems[i].product!.quantity! + orderItems[j].quantity;
          tempOrderItems[i].quantity = tempOrderItems[i].quantity + orderItems[j].quantity;
          tempOrderItems[i].quantity = roundToDecimalPlaces(tempOrderItems[i].quantity, 4);
          tempOrderItems[i].product?.quantityToBeSold = (tempOrderItems[i].product?.quantityToBeSold ?? 0) + (orderItems[j].product?.quantityToBeSold ?? 0);
          tempOrderItems[i].product?.quantityToBeSold = roundToDecimalPlaces(tempOrderItems[i].product!.quantityToBeSold!, 4);
          orderItems.removeAt(j);
        }
      }
    }

    _Order.orderItems = tempOrderItems;

    setState(() {
      _Order.orderItems?.addAll(orderItems);
    });
  }
}
