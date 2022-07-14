import 'package:flutter/material.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_product.dart';
import 'package:shopos/src/pages/products_list.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';
import 'package:slidable_button/slidable_button.dart';

class CreatePurchase extends StatefulWidget {
  static const routeName = '/create_purchase';
  const CreatePurchase({Key? key}) : super(key: key);

  @override
  State<CreatePurchase> createState() => _CreatePurchaseState();
}

class _CreatePurchaseState extends State<CreatePurchase> {
  late OrderInput _orderInput;

  @override
  void initState() {
    super.initState();
    _orderInput = OrderInput(
      orderItems: [],
    );
  }

  void _onAdd(OrderItemInput orderItem) {
    setState(() {
      orderItem.quantity += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _orderItems = _orderInput.orderItems ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase'),
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
                                _orderItem.quantity == 1
                                    ? _orderInput.orderItems?.removeAt(index)
                                    : _orderItem.quantity -= 1;
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
                      final result = await Navigator.pushNamed(
                        context,
                        ProductsListPage.routeName,
                        arguments: const ProductListPageArgs(
                          isSelecting: true,
                          orderType: OrderType.purchase,
                        ),
                      );
                      if (result == null && result is! List<Product>) {
                        return;
                      }
                      final orderItems = (result as List<Product>)
                          .map((e) => OrderItemInput(
                                product: e,
                                quantity: 1,
                                price: 0,
                              ))
                          .toList();
                      setState(() {
                        _orderInput.orderItems = orderItems;
                      });
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
            SlidableButton(
              width: double.maxFinite,
              buttonWidth: 100.0,
              color: Colors.green,
              isRestart: true,
              buttonColor: Colors.white24,
              dismissible: false,
              label: const Center(
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Swipe to continue",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
              height: 50,
              onChanged: (position) {
                if (position == SlidableButtonPosition.right) {
                  if (_orderItems.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                          "Please select products before continuing",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                    return;
                  }
                  Navigator.pushNamed(
                    context,
                    CheckoutPage.routeName,
                    arguments: CheckoutPageArgs(
                      invoiceType: OrderType.purchase,
                      orderInput: _orderInput,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
