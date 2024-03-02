import 'package:dio/dio.dart';

import '../models/input/order.dart';
import '../pages/checkout.dart';
import 'api_v1.dart';

class BillingService{
  const BillingService();

  Future<Response> createBillingOrder(Order order) async {
    print("data to be sent in create ${order.toMapForCopy()}");
    final response = await ApiV1Service.postRequest(
      '/billingorder/new',
      data: order.toMapForCopy()
    );
    return response;
  }
  Future<Response> updateBillingOrder(Order order) async {
    print("data to be sent in update bill ${order.toMapForCopy()}");
    final response = await ApiV1Service.putRequest(
      '/billingorder/${order.kotId}',
      data: order.toMapForCopy()
    );
    print("response.data from update bill ${response.data}");
    return response;
  }
  Future<List<dynamic>> getAllBillingOrder() async {
    final response = await ApiV1Service.getRequest('/billingOrder/all');
    return response.data['allBillingOrder'];
  }
  Future<Response> deleteBillingOrder(String kotId) async {
    final response = await ApiV1Service.deleteRequest('/billingOrder/$kotId');
    return response;
  }

}