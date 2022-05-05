import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/product_input.dart';
import 'package:magicstep/src/services/api_v1.dart';

class ProductService {
  const ProductService();

  Future<Response> createProduct(ProductFormInput input) async {
    final response =
        await ApiV1Service.postRequest('/inventory/new', data: input.toMap());
    return response;
  }

  ///
  Future<Response> getProducts() async {
    final response = await ApiV1Service.getRequest('/inventory/me');
    return response;
  }
}
