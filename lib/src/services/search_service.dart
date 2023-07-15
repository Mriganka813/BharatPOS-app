// import 'api_v1.dart';
import 'package:shopos/src/services/api_v1.dart';

import '../models/product.dart';

class SearchProductServices {
  Future<List<Product>> searchproduct(String catagory) async {
    final response =
        await ApiV1Service.getRequest('/inventory/me?keyword=$catagory');
    print(response.data);
    return (response.data["inventories"] as List)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Product>> allproduct(int page, int limit) async {
    final response =
        await ApiV1Service.getRequest('/inventory/me?page=$page&limit=$limit');
    print(response.data);
    return (response.data["inventories"] as List)
        .map((e) => Product.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
