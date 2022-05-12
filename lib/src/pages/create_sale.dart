import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:magicstep/src/models/input/order_input.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/pages/checkout.dart';
import 'package:magicstep/src/pages/products_list.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/product_card_horizontal.dart';

import '../services/product.dart';

class CreateSale extends StatefulWidget {
  static const routeName = '/create_sale';
  const CreateSale({Key? key}) : super(key: key);

  @override
  State<CreateSale> createState() => _CreateSaleState();
}

class _CreateSaleState extends State<CreateSale> {
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
        title: const Text('Sales'),
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
                            if (_orderItem.quantity == 1) {
                              setState(() {
                                _orderInput.orderItems?.removeAt(index);
                              });
                              return;
                            }
                            setState(() {
                              _orderItem.quantity -= 1;
                            });
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
                    title: "Add manually",
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
                                quantity: 1,
                                price: 0,
                              ))
                          .toList();
                      setState(() {
                        _orderInput.orderItems?.addAll(orderItems);
                      });
                    },
                  ),
                ),
                const VerticalDivider(color: Colors.transparent),
                Expanded(
                  child: CustomButton(
                    title: "Scan barcode",
                    onTap: () async {
                      _searchProductByBarcode();
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

  ///
  Future<void> _searchProductByBarcode() async {
    locator<GlobalServices>().showBottomSheetLoader();
    final barcode = await FlutterBarcodeScanner.scanBarcode(
      "#000000",
      "Cancel",
      false,
      ScanMode.BARCODE,
    );
    try {
      /// Fetch product by barcode
      final res = await const ProductService().getProductByBarcode(barcode);
      final product = Product.fromMap(res.data['inventory']);
      final order = OrderItemInput(product: product, quantity: 1, price: 0);
      final hasProduct =
          _orderInput.orderItems?.any((e) => e.product?.id == product.id);

      /// Check if product already exists
      if (hasProduct ?? false) {
        final i = _orderInput.orderItems
            ?.indexWhere((e) => e.product?.id == product.id);

        /// Increase quantity if product already exists
        setState(() {
          _orderInput.orderItems![i!].quantity += 1;
        });
      } else {
        setState(() {
          _orderInput.orderItems?.add(order);
        });
      }
    } catch (_) {}
    Navigator.pop(context);
  }
}
