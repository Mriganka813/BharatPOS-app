// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shopos/src/blocs/product/product_cubit.dart';
// import 'package:shopos/src/config/colors.dart';
// import 'package:shopos/src/models/product.dart';
// import 'package:shopos/src/pages/checkout.dart';
// import 'package:shopos/src/pages/create_product.dart';
// import 'package:shopos/src/pages/search_result.dart';
// import 'package:shopos/src/services/global.dart';
// import 'package:shopos/src/services/locator.dart';
// import 'package:shopos/src/widgets/custom_button.dart';
// import 'package:shopos/src/widgets/custom_text_field.dart';
// import 'package:shopos/src/widgets/product_card_horizontal.dart';

// class ProductListPageArgs {
//   final bool isSelecting;
//   final OrderType orderType;
//   const ProductListPageArgs({
//     required this.isSelecting,
//     required this.orderType,
//   });
// }

// class ProductsListPage extends StatefulWidget {
//   /// Will be used to check if user is
//   /// selecting products instead of viewing them
//   final ProductListPageArgs? args;
//   const ProductsListPage({
//     Key? key,
//     this.args,
//   }) : super(key: key);

//   ///
//   static const routeName = '/products-list';

//   @override
//   State<ProductsListPage> createState() => _ProductsListPageState();
// }

// class _ProductsListPageState extends State<ProductsListPage> {
//   late final ProductCubit _productCubit;
//   late List<Product> _products;

//   List<Product> _newList = [];
//   bool addList = false;
//   int _currentPage = 1;
//   int _limit = 20;
//   int _newLimit = 0;
//   bool _isLoading = false;
//   bool _hasNextPage = true;
//   ScrollController _scrollController = ScrollController();

//   bool isLoadingMore = false;
//   @override
//   void initState() {
//     super.initState();

//     _products = [];
//     _productCubit = ProductCubit()..getProducts(_currentPage, _limit);
//   }

//   void _loadNextPage() {
//     if (!_isLoading && _hasNextPage) {
//       //_isLoading = true;

//       _currentPage++;

//       _productCubit.getProducts(_currentPage, _limit);
//       print(_newList.length);
//     }
//   }

//   @override
//   void dispose() {
//     _productCubit.close();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _selectProduct(Product product) {
//     final canSelect = widget.args?.isSelecting ?? false;
//     if (!canSelect) {
//       return;
//     }
//     final isSale = widget.args?.orderType == OrderType.sale;
//     if (isSale && (product.quantity ?? 0) < 1) {
//       locator<GlobalServices>().infoSnackBar('Item not available');
//       return;
//     }

//     setState(() {
//       !_products.contains(product)
//           ? _products.add(product)
//           : _products.remove(product);
//     });
//   }

//   ///
//   @override
//   Widget build(BuildContext context) {
//     setState(() {
//       _scrollController.addListener(() {
//         if (_scrollController.position.pixels ==
//             _scrollController.position.maxScrollExtent) {
//           _loadNextPage();
//         }
//       });
//     });
//     return Scaffold(
//         appBar: AppBar(title: const Text('Products List')),
//         floatingActionButton: Container(
//           margin: const EdgeInsets.only(
//             right: 10,
//             left: 30,
//             bottom: 20,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.end,
//             children: [
//               if (widget.args?.isSelecting ?? false)
//                 Expanded(
//                   child: CustomButton(
//                       title: "Continue",
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       onTap: () {
//                         if (_products.isEmpty) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               backgroundColor: Colors.red,
//                               content: Text(
//                                 "Please select products before continuing",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           );
//                           return;
//                         }
//                         Navigator.pop(
//                           context,
//                           _products,
//                         );
//                       }),
//                 ),
//               if (widget.args?.isSelecting ?? false) const SizedBox(width: 20),
//               FloatingActionButton(
//                 onPressed: () async {
//                   _productCubit.getProducts(_currentPage, _limit);
//                   await Navigator.pushNamed(context, '/create-product');
//                   _productCubit.getProducts(_currentPage, _limit);
//                 },
//                 backgroundColor: ColorsConst.primaryColor,
//                 child: const Icon(
//                   Icons.add,
//                   color: Colors.white,
//                   size: 40,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         body: Stack(
//           children: [
//             Padding(
//               padding: const EdgeInsets.only(top: 70),
//               // child: ListView(
//               // padding: const EdgeInsets.all(20),
//               //shrinkWrap: true,
//               //  children: [
//               //  const Divider(color: Colors.transparent),
//               child: BlocBuilder<ProductCubit, ProductState>(
//                 bloc: _productCubit,
//                 builder: (context, state) {
//                   if (state is ProductLoading) {
//                     if (!isLoadingMore)
//                       return const Center(
//                         child: CircularProgressIndicator(
//                           color: ColorsConst.primaryColor,
//                         ),
//                       );
//                   } else if (state is ProductsListRender) {
//                     _newList.addAll(state.products);
//                     isLoadingMore = true;
//                   }
//                   return ListView.separated(
//                     physics: const ClampingScrollPhysics(),
//                     itemCount: _newList.length,
//                     controller: _scrollController,
//                     shrinkWrap: true,
//                     separatorBuilder: (context, index) {
//                       return const SizedBox(height: 5);
//                     },
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () {
//                           _selectProduct(_newList[index]);
//                         },
//                         child: Stack(
//                           children: [
//                             ProductCardHorizontal(
//                               product: _newList[index],
//                               onDelete: () {
//                                 _productCubit.deleteProduct(
//                                     _newList[index], _currentPage, _limit);
//                               },
//                               onEdit: () async {
//                                 await Navigator.pushNamed(
//                                   context,
//                                   CreateProduct.routeName,
//                                   arguments: _newList[index].id,
//                                 );
//                                 _productCubit.getProducts(_currentPage, _limit);
//                               },
//                             ),
//                             if (_products.contains(_newList[index]))
//                               const Align(
//                                 alignment: Alignment.topRight,
//                                 child: Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: CircleAvatar(
//                                     radius: 15,
//                                     backgroundColor: Colors.green,
//                                     child: Icon(
//                                       Icons.check,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                 ),
//                               )
//                           ],
//                         ),
//                       );
//                       return Center(child: CircularProgressIndicator());
//                     },
//                   );
//                 },
//               ),
//               //  ],
//               //),
//             ),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               child: CustomTextField(
//                 prefixIcon: const Icon(Icons.search),
//                 hintText: 'Search',
//                 //  onChanged: (String e) {
//                 //     if (e.isNotEmpty) {
//                 //       _productCubit.searchProducts(e);
//                 //       print("searchbar running");
//                 //       setState(() {});
//                 //     }
//                 //   },
//                 onsubmitted: (value) {
//                   Navigator.of(context).push(MaterialPageRoute(
//                     builder: (context) =>
//                         SearchProductListScreen(title: value!),
//                   ));
//                 },
//               ),
//             ),
//           ],
//         ));
//   }
// }
