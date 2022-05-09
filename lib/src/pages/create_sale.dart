import 'package:flutter/material.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/pages/checkout.dart';
import 'package:magicstep/src/pages/products_list.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/product_card_horizontal.dart';

class CreateSale extends StatefulWidget {
  static const routeName = '/create_sale';
  const CreateSale({Key? key}) : super(key: key);

  @override
  State<CreateSale> createState() => _CreateSaleState();
}

class _CreateSaleState extends State<CreateSale> {
  late List<Product> _products;

  @override
  void initState() {
    super.initState();
    _products = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: _products.isEmpty
                  ? const Center(
                      child: Text(
                        'No products added yet',
                      ),
                    )
                  : ListView.separated(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        return ProductCardPurchase(
                          product: _products[index],
                          onAdd: () {
                            setState(() {
                              _products[index].purchaseQuantity += 1;
                            });
                          },
                          onDelete: () {
                            if (_products[index].purchaseQuantity == 1) {
                              setState(() {
                                _products.removeAt(index);
                              });
                              return;
                            }
                            setState(() {
                              _products[index].purchaseQuantity -= 1;
                            });
                          },
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
                      setState(() {
                        _products = result as List<Product>;
                      });
                    },
                  ),
                ),
                const VerticalDivider(color: Colors.transparent),
                Expanded(
                  child: CustomButton(
                    title: "Scan barcode",
                    onTap: () {},
                    type: ButtonType.outlined,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.transparent),
            TextButton(
              onPressed: () {
                if (_products.isEmpty) {
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
                  arguments: _products,
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
