import 'package:dio/dio.dart';
import 'package:shopos/src/services/api_v1.dart';

import '../models/input/order.dart';

class PurchaseService {
  const PurchaseService();

  ///
  static Future<Response> createPurchaseOrder(
    Order orderItemInput,
    String invoiceNum,
  ) async {
    final response = await ApiV1Service.postRequest(
      '/purchaseOrder/new',
      data: {
        'orderItems':
            orderItemInput.orderItems?.map((e) => e.toPurchaseMap()).toList(),
        'modeOfPayment': orderItemInput.modeOfPayment,
        'party': orderItemInput.party?.id,
        'invoiceNum': invoiceNum,
      },
    );
    return response;
  }

  static Future<Map<String, dynamic>> getNumberOfPurchases() async {
    final response = await ApiV1Service.getRequest('/purchasesNum');
    return response.data;
  }

  ///
  static Future<Response> getAllSalesOrders() async {
    final response = await ApiV1Service.getRequest('/purchaseOrders/me');
    return response;
  }
}
