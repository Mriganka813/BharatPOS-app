import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/product_input.dart';
import 'package:magicstep/src/models/product.dart';
import 'package:magicstep/src/services/api_v1.dart';

class ProductService {
  const ProductService();

  Future<Response> createProduct(ProductFormInput input) async {
    final response =
        await ApiV1Service.postRequest('/inventory/new', data: input.toMap());
    return response;
  }

  ///
  Future<Response> updateProduct(ProductFormInput input) async {
    final response = await ApiV1Service.putRequest(
      '/update/inventory/${input.id}',
      data: input.toMap(),
    );
    return response;
  }

  ///
  Future<Response> getProducts() async {
    final response = await ApiV1Service.getRequest('/inventory/me');
    return response;
  }

  ///
  Future<Response> getProduct(String id) async {
    final response = await ApiV1Service.getRequest('/inventory/$id');
    return response;
  }

  /// Fetch Product by barcode
  Future<Response> getProductByBarcode(String barcode) async {
    return await ApiV1Service.getRequest('/inventory/barcode/$barcode');
  }

  ///
  Future<Response> searchProducts(String keyword) async {
    return await ApiV1Service.getRequest('/inventories?keyword=$keyword');
  }

  ///
  Future<Response> deleteProduct(Product product) async {
    final response =
        await ApiV1Service.deleteRequest('/del/inventory/${product.id}');
    return response;
  }
}
