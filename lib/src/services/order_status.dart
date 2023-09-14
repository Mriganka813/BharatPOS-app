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

  // change isPaid status
  isPaid(String orderId, String status) async {
    final response =
        await ApiV1Service.getRequest('/payment-status/$orderId/$status');
    print(response.data);
  }
}
