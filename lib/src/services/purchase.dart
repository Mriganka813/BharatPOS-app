import 'package:dio/dio.dart';
import 'package:shopos/src/services/api_v1.dart';

import '../models/input/order_input.dart';

class PurchaseService {
  const PurchaseService();

  ///
  static Future<Response> createPurchaseOrder(
    OrderInput orderItemInput,
  ) async {
    final response = await ApiV1Service.postRequest(
      '/purchaseOrder/new',
      data: {
        'orderItems':
            orderItemInput.orderItems?.map((e) => e.toPurchaseMap()).toList(),
        'modeOfPayment': orderItemInput.modeOfPayment,
        'party': orderItemInput.party?.id,
      },
    );
    return response;
  }

  ///
  static Future<Response> getAllSalesOrders() async {
    final response = await ApiV1Service.getRequest('/purchaseOrders/me');
    return response;
  }
}
