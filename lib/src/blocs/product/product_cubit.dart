import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:magicstep/src/models/input/product_input.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/services/product.dart';
import 'package:meta/meta.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService _productService = const ProductService();
  ProductCubit() : super(ProductInitial());

  ///
  void getProducts() async {
    final response = await _productService.getProducts();
    if ((response.statusCode ?? 400) > 300) {
      emit(ProductsError('Failed to get products'));
      return;
    }
    log("${response.data}");
    final products = List.generate(
      response.data['inventories'].length,
      (int index) => Product.fromMap(
        response.data['inventories'][index],
      ),
    );
    emit(ProductsListRender(products));
  }

  ///
  void createProduct(ProductFormInput product) async {
    final response = await _productService.createProduct(product);
    if (response.statusCode == 200) {
      emit(ProductCreated());
      getProducts();
    } else {
      emit(ProductCreationFailed());
    }
  }
}
