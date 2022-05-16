import 'package:dio/dio.dart';
import 'package:magicstep/src/services/api_v1.dart';

class OrdersService {
  ///
  const OrdersService();

  ///
  Future<Response> getPurchaseOrders(int pageNumber) async {
    return await ApiV1Service.getRequest('/purchaseOrders/me?page=$pageNumber');
  }

  ///
  Future<Response> getSalesOrders(int pageNumber) async {
    return await ApiV1Service.getRequest('/salesOrders/me?page=$pageNumber ');
  }
}
