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

  void _onAdd(OrderItemInput orderItem) {
    setState(() {
      orderItem.quantity += 1;
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
                          onAdd: () {
                            _onAdd(_orderItem);
                          },
                          onDelete: () {
                            setState(
                              () {
                                _orderItem.quantity == 1 ? _Order.orderItems?.removeAt(index) : _orderItem.quantity -= 1;
                              },
                            );
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
                      Navigator.pushNamed(context, CreateProduct.routeName);
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
                  final provider = Provider.of<Billing>(context, listen: false);
                  if (_orderItems.isNotEmpty) {
                    provider.addPurchaseBill(_Order, widget.args?.orderId == null ? DateTime.now().toString() : widget.args!.orderId!);
                  }

                  Navigator.pushNamed(context, BillingListScreen.routeName, arguments: OrderType.purchase);
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
        for (int j = i + 1; j < temp.length; j++) {
          if (temp[i].id == temp[j].id) {
            count++;
            print("count =$count");
          }
        }
        tempMap["${temp[i].id}"] = count;
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
              quantity: tempMap["${e.id}"],
              price: 0,
            ))
        .toList();

    var tempOrderitems = _Order.orderItems;

    for (int i = 0; i < tempOrderitems!.length; i++) {
      for (int j = 0; j < orderItems.length; j++) {
        if (tempOrderitems[i].product!.id == orderItems[j].product!.id) {
          tempOrderitems[i].product!.quantity = tempOrderitems[i].product!.quantity! + orderItems[j].quantity;
          tempOrderitems[i].quantity = tempOrderitems[i].quantity + orderItems[j].quantity;
          orderItems.removeAt(j);
        }
      }
    }

    _Order.orderItems = tempOrderitems;

    setState(() {
      _Order.orderItems?.addAll(orderItems);
    });
  }
}
