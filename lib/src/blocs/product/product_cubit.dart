import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
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
    emit(ProductLoading());
    final response = await _productService.getProducts();
    if ((response.statusCode ?? 400) > 300) {
      emit(ProductsError('Failed to get products'));
      return;
    }
    final products = List.generate(
      response.data['inventories'].length,
      (int index) => Product.fromMap(
        response.data['inventories'][index],
      ),
    );
    emit(ProductsListRender(products));
  }

  ///
  void searchProducts(String pattern) async {
    emit(ProductLoading());
    try {
      final response = await _productService.searchProducts(pattern);
      final data = response.data['InventoriesRes'];
      final prods = List.generate(data.length, (int index) {
        return Product.fromMap(data[index]);
      });
      emit(ProductsListRender(prods));
    } on DioError {
      emit(ProductsError('Failed to get products'));
    }
  }

  ///
  void createProduct(ProductFormInput product) async {
    emit(ProductLoading());
    try {
      final response = product.id == null
          ? await _productService.createProduct(product)
          : await _productService.updateProduct(product);
      if ((response.statusCode ?? 400) > 300) {
        emit(ProductsError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(ProductsError(err.response?.data['message'] ?? err.message));
    }
    emit(ProductCreated());
  }

  ///
  void deleteProduct(Product product) async {
    try {
      final response = await _productService.deleteProduct(product);
      if ((response.statusCode ?? 400) > 300) {
        emit(ProductsError(response.data['message']));
        return;
      }
    } on DioError catch (err) {
      emit(ProductsError(err.message));
    }
    getProducts();
  }
}
