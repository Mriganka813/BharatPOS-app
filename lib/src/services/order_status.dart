import 'package:shopos/src/models/online_order.dart';

import 'api_v1.dart';

class OrderStatus {
  // order accept

  Future<List<OnlineOrder>> orderAcceptAll(String orderId) async {
    final response =
        await ApiV1Service.getRequest('/myorders/acceptall/$orderId');
    return (response.data as List)
        .map((e) => OnlineOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  //order reject

  Future<List<OnlineOrder>> orderRejectAll(String orderId) async {
    final response =
        await ApiV1Service.getRequest('/myorders/rejectall/$orderId');
    return (response.data as List)
        .map((e) => OnlineOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
