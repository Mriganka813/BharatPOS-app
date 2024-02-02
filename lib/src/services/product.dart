import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/product_input.dart';
import 'package:shopos/src/models/product.dart';
import 'package:shopos/src/services/api_v1.dart';

class ProductService {
  const ProductService();

  Future<Response> createProduct(ProductFormInput input) async {
    // final inputMap = FormData.fromMap(input.toMap()); //commented out because subproducts were not saving in formdata
    final formData = FormData();
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      // inputMap.files.add(image);
      formData.files.add(image);
    }
    print("line 20 in product.dart");

    // print(inputMap);
    // Convert FormData to a Map
    // final inputMapAsMap = inputMap.fields.fold<Map<String, dynamic>>(
    //   {},
    //       (acc, entry) => acc..[entry.key] = entry.value,
    // );
    //
    // print("line 28 in product.dart");
    // print("InputMap as Map: $inputMapAsMap");
    // var subProducts = MapEntry("subProducts", input.subProducts.toString());
    // inputMap.fields.add(subProducts);
    // final subProductsJson = jsonEncode(input.subProducts);

    // inputMap.fields.add(MapEntry('subProducts', subProductsJson));

    print("FormInput:");
    print(input.toMap());
    // print(inputMap);
    // print(inputMap.fields[inputMap.fields.length-2]);

    var dataToSend = input.toMap();
    // final response = await ApiV1Service.postRequest('/inventory/new',formData: inputMap); //commented out because subproducts were not saving in formdata
    final response =
        await ApiV1Service.postRequest('/inventory/new', data: dataToSend);
    print(response.data);
    // print(response.data["inventory"]);
    print("line 25 in product.dart");
    print("_id is ${response.data["inventory"]["_id"]}");
    final imageResp = await uploadImage(formData, response.data["inventory"]["_id"]);//uploaded image for the product
    print(imageResp.data);
    return response;
  }

  ///for uploading image in a product of _id: id
  Future<Response> uploadImage(FormData formData, String id) async {
    formData.fields.add(MapEntry("inventoryId", id));
    final response = await ApiV1Service.postRequest("/inventory/image", formData: formData);
    return response;
  }
  ///
  Future<Response> updateProduct(ProductFormInput input) async {
    final formData = FormData();
    print("last sec");
    print(input.toMap());
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      formData.files.add(image);
    }
    var dataToSend = input.toMap();
    print("line 71 in update product");
    print(input.id);
    final response = await ApiV1Service.putRequest(
      '/update/inventory/${input.id}',
      data: dataToSend,
    );
    print("line 75 in update product");
    print(response.data);
    // print("_id is ${response.data["inventory"]["_id"]}");
    final imageResp = await uploadImage(formData, response.data["inventory"]["_id"]);//uploaded image for the product
    print(imageResp.data);
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
    // print(response);
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
