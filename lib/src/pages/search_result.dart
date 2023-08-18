import 'package:flutter/material.dart';
import 'package:shopos/src/blocs/product/product_cubit.dart';
import 'package:shopos/src/config/colors.dart';
import 'package:shopos/src/pages/checkout.dart';
import 'package:shopos/src/pages/create_product.dart';
import 'package:shopos/src/services/search_service.dart';
import 'package:shopos/src/widgets/custom_text_field.dart';
import 'package:shopos/src/widgets/product_card_horizontal.dart';

import '../models/product.dart';
import '../services/global.dart';
import '../services/locator.dart';
import '../widgets/custom_button.dart';

class ProductListPageArgs {
  final bool isSelecting;
  final OrderType orderType;
  const ProductListPageArgs({
    required this.isSelecting,
    required this.orderType,
  });
}

class SearchProductListScreen extends StatefulWidget {
  static const routeName = '/search-product-list-screen';

  const SearchProductListScreen({this.args});
  final ProductListPageArgs? args;

  @override
  State<SearchProductListScreen> createState() =>
      _SearchProductListScreenState();
}

class _SearchProductListScreenState extends State<SearchProductListScreen> {
  final scrollController = ScrollController();
  final SearchProductServices searchProductServices = SearchProductServices();
  List<Product> prodList = [];
  bool isLoadingMore = false;
  late final ProductCubit _productCubit;
  late List<Product> _products;

  int page = 0;
  int _currentPage = 1;
  int _limit = 20;
  bool isAvailable = true;

  @override
  void initState() {
    super.initState();
    _products = [];
    _productCubit = ProductCubit()..getProducts(_currentPage, _limit);
    scrollController.addListener(_scrollListener);
    fetchSearchedProducts();
  }

  //goToProductDetails(BuildContext context, int idx) {
  // Navigator.of(context).pushNamed(SearchProductDetailsScreen.routeName,
  //    arguments: prodList[idx]);
  //}

  Future<void> fetchSearchedProducts() async {
    var newProducts =
        await searchProductServices.allproduct(_currentPage, _limit);
    for (var product in newProducts) {
      if (!prodList.contains(product)) {
        prodList.add(product);
      }
    }
    print("searched products: $prodList");
    setState(() {});
  }

  void _scrollListener() async {
    if (isLoadingMore) return;
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      _currentPage++;
      setState(() {
        isLoadingMore = true;
      });
      await fetchSearchedProducts();
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void _selectProduct(Product product) {
    final canSelect = widget.args?.isSelecting ?? false;
    if (!canSelect) {
      return;
    }
    final isSale = widget.args?.orderType == OrderType.sale;
    if (isSale && (product.quantity ?? 0) < 1) {
      locator<GlobalServices>().infoSnackBar('Item not available');
      return;
    }

    setState(() {
      !_products.contains(product)
          ? _products.add(product)
          : _products.remove(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text(
            "Product List",
            style: TextStyle(
                color: Colors.black,
                fontSize: height / 45,
                fontFamily: 'GilroyBold'),
          ),
        ),
        floatingActionButton: Container(
          margin: const EdgeInsets.only(
            right: 10,
            left: 30,
            bottom: 20,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (widget.args?.isSelecting ?? false)
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
              if (widget.args?.isSelecting ?? false) const SizedBox(width: 20),
              FloatingActionButton(
                onPressed: () async {
                  _productCubit.getProducts(_currentPage, _limit);

                  await Navigator.pushNamed(context, '/create-product');
                  _productCubit.getProducts(_currentPage, _limit);
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
        body: Stack(children: [
          Column(
            children: [
              SizedBox(
                height: 60,
              ),
              prodList.length == 0
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 15),
                        child: Text('No products found!'),
                      ),
                    )
                  : Expanded(
                      child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 5);
                          },
                          shrinkWrap: true,
                          padding: EdgeInsets.all(8),
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: isLoadingMore
                              ? prodList.length + 1
                              : prodList.length,
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            if (index < prodList.length) {
                              return GestureDetector(
                                onTap: () {
                                  _selectProduct(prodList[index]);
                                },
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: height / 240,
                                    ),
                                    Stack(
                                      children: [
                                        ProductCardHorizontal(
                                          product: prodList[index],
                                          isAvailable: isAvailable,
                                          onDelete: () {
                                            _productCubit.deleteProduct(
                                                prodList[index],
                                                _currentPage,
                                                _limit);
                                            setState(() {
                                              prodList.removeAt(index);
                                            });
                                          },
                                          onEdit: () async {
                                            await Navigator.pushNamed(
                                              context,
                                              CreateProduct.routeName,
                                              arguments: prodList[index].id,
                                            );

                                            _productCubit.getProducts(
                                                _currentPage, _limit);
                                          },
                                        ),
                                        if (_products.contains(prodList[index]))
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
                                          ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: height / 240,
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          }),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               child: CustomTextField(
            child: CustomTextField(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Search',
              onChanged: (String e) async {
                if (e.isNotEmpty) {
                  prodList = await searchProductServices.searchproduct(e);

                  print("searchbar running");
                  setState(() {});
                }
              },
              // onsubmitted: (value) {
              //   Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) =>
              //         SearchProductListScreen(title: value!),
              //   ));
              // },
            ),
          ),
        ]));
  }
}
