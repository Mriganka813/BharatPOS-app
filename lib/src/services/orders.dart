import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:shopos/src/services/api_v1.dart';

class OrdersService {
  ///
  const OrdersService();

  ///
  Future<Response> getPurchaseOrders(int pageNumber) async {
    final res =
        await ApiV1Service.getRequest('/purchaseOrders/me?page=$pageNumber');
    log("${res.data}");
    return res;
  }

  ///
  Future<Response> getSalesOrders(int pageNumber) async {
    final res =
        await ApiV1Service.getRequest('/salesOrders/me?page=$pageNumber ');
    return res;
  }
}
