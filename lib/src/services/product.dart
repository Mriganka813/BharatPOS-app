import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/services/api_v1.dart';

class ProductService {
  const ProductService();

  Future<Response> createProduct(ProductFormInput input) async {
    // print('exp=${input.expiryDate}');
    final inputMap = FormData.fromMap(input.toMap());
    // inputMap.fields.add(MapEntry('subProducts', subProducts));
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      inputMap.files.add(image);
    }
    print("line 18 in product.dart");
    print(inputMap);
    // Convert FormData to a Map
    final inputMapAsMap = inputMap.fields.fold<Map<String, dynamic>>(
      {},
          (acc, entry) => acc..[entry.key] = entry.value,
    );

    print("line 18 in product.dart");
    print("InputMap as Map: $inputMapAsMap");
    // var subProducts = MapEntry("subProducts", input.subProducts.toString());
    // inputMap.fields.add(subProducts);
    // final subProductsJson = jsonEncode(input.subProducts);

    // inputMap.fields.add(MapEntry('subProducts', subProductsJson));
    print("input---line 17 in product.dart");
    // print(input.toMap());
    print("FormInput:");
    // print(inputMap.fields[0]);
    // print(inputMap.fields[inputMap.length-1]);

    print(input.available);
    final response =
        await ApiV1Service.postRequest('/inventory/new', formData: inputMap);
    print("line 25 in product.dart");
    print(response.data);
    print(response.toString());
    return response;
  }

  ///
  Future<Response> updateProduct(ProductFormInput input) async {
    final inputMap = FormData.fromMap(input.toMap());
    print("last sec");
    print(input.toMap());
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      inputMap.files.add(image);
    }
    final response = await ApiV1Service.putRequest(
      '/update/inventory/${input.id}',
      formData: inputMap,
    );
    print(response);
    return response;
  }

  ///
  /* Future<Response> getProducts() async {
    //final response = await ApiV1Service.getRequest('/inventory/me/items?page=1&limit=10');
    final response = await ApiV1Service.getRequest('/inventory/me?page=${page}&limit=${limit}');
    return response;
  }
*/
  Future<Response> getProducts(int page, int limit) async {
    print("" + page.toString() + " " + limit.toString());
    final response =
        await ApiV1Service.getRequest('/inventory/me?page=$page&limit=$limit');
    return response;
  }

  ///
  Future<Response> getProduct(String id) async {
    final response = await ApiV1Service.getRequest('/inventory/$id');
    print(response);
    return response;
  }

  /// Fetch Product by barcode
  Future<Response> getProductByBarcode(String barcode) async {
    return await ApiV1Service.getRequest('/inventory/barcode/$barcode');
  }

  ///
  Future<Response> searchProducts(String keyword) async {
    var response =
        await ApiV1Service.getRequest('/inventory/me?keyword=$keyword');
    print(response.data);
    return response;
  }

  ///
  Future<Response> deleteProduct(Product product) async {
    final response =
        await ApiV1Service.deleteRequest('/del/inventory/${product.id}');
    return response;
  }
}
