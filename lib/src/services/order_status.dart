import 'api_v1.dart';

class OrderStatus {
  // order accept

  orderAcceptAll(String orderId) async {
    final response =
        await ApiV1Service.getRequest('/myorders/acceptall/$orderId');
    print(response.data);
  }

  //order reject

  orderRejectAll(String orderId) async {
    final response =
        await ApiV1Service.getRequest('/myorders/rejectall/$orderId');
    print(response.data);
  }
}
