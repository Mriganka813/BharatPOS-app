import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magicstep/src/blocs/product/product_cubit.dart';
import 'package:magicstep/src/config/colors.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/pages/create_product.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';
import 'package:magicstep/src/widgets/custom_button.dart';
import 'package:magicstep/src/widgets/custom_text_field.dart';
import 'package:magicstep/src/widgets/product_card_horizontal.dart';

class ProductsListPage extends StatefulWidget {
  /// Will be used to check if user is
  /// selecting products instead of viewing them
  final bool isSelecting;
  const ProductsListPage({
    Key? key,
    this.isSelecting = false,
  }) : super(key: key);

  ///
  static const routeName = '/products-list';

  @override
  State<ProductsListPage> createState() => _ProductsListPageState();
}

class _ProductsListPageState extends State<ProductsListPage> {
  late final ProductCubit _productCubit;
  late List<Product> _products;

  ///
  @override
  void initState() {
    super.initState();
    _productCubit = ProductCubit()..getProducts();
    _products = [];
  }

  @override
  void dispose() {
    _productCubit.close();
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products List')),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
          right: 10,
          left: 30,
          bottom: 20,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.isSelecting)
              Expanded(
                child: CustomButton(
                    title: "Continue",
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    onTap: () {
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
                      Navigator.pop(
                        context,
                        _products,
                      );
                    }),
              ),
            if (widget.isSelecting) const SizedBox(width: 20),
            FloatingActionButton(
              onPressed: () async {
                await Navigator.pushNamed(context, '/create-product');
                _productCubit.getProducts();
              },
              backgroundColor: ColorsConst.primaryColor,
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          CustomTextField(
            prefixIcon: const Icon(Icons.search),
            hintText: 'Search',
            onChanged: (String e) {
              if (e.isNotEmpty) {
                _productCubit.searchProducts(e);
              }
            },
          ),
          const Divider(color: Colors.transparent),
          BlocBuilder<ProductCubit, ProductState>(
            bloc: _productCubit,
            builder: (context, state) {
              if (state is ProductsListRender) {
                return ListView.separated(
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.products.length,
                  shrinkWrap: true,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 5);
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (widget.isSelecting) {
                          final product = state.products[index];
                          if ((product.quantity ?? 0) < 1) {
                            locator<GlobalServices>()
                                .infoSnackBar('Item not available');
                            return;
                          }
                          setState(() {
                            !_products.contains(product)
                                ? _products.add(product)
                                : _products.remove(product);
                          });
                        }
                      },
                      child: Stack(
                        children: [
                          ProductCardHorizontal(
                            product: state.products[index],
                            onDelete: () {
                              _productCubit
                                  .deleteProduct(state.products[index]);
                            },
                            onEdit: () async {
                              await Navigator.pushNamed(
                                context,
                                CreateProduct.routeName,
                                arguments: state.products[index].id,
                              );
                              _productCubit.getProducts();
                            },
                          ),
                          if (_products.contains(state.products[index]))
                            const Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.green,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(
                  color: ColorsConst.primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
