import 'package:flutter/material.dart';
import 'package:magicstep/src/models/input/order_input.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/pages/checkout.dart';
import 'package:magicstep/src/pages/create_product.dart';
import 'package:magicstep/src/pages/products_list.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/product_card_horizontal.dart';

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
                          product: product,
                          onAdd: () {
                            setState(() {
                              _orderItem.quantity += 1;
                            });
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
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    title: "Add Product",
                    onTap: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        ProductsListPage.routeName,
                        arguments: true,
                      );
                      if (result == null && result is! List<Product>) {
                        return;
                      }
                      final orderItems = (result as List<Product>)
                          .map((e) => OrderItemInput(
                                product: e,
                                quantity: 0,
                                price: 0,
                              ))
                          .toList();
                      setState(() {
                        _orderInput.orderItems = orderItems;
                      });
                    },
                  ),
                ),
                const VerticalDivider(color: Colors.transparent),
                Expanded(
                  child: CustomButton(
                    title: "Create Product",
                    onTap: () {
                      Navigator.pushNamed(context, CreateProduct.routeName);
                    },
                    type: ButtonType.outlined,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.transparent),
            TextButton(
              onPressed: () {
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
                    invoiceType: OrderType.sale,
                    orderInput: _orderInput,
                  ),
                );
              },
              child: const Text("Swipe to continue"),
            ),
          ],
        ),
      ),
    );
  }
}
