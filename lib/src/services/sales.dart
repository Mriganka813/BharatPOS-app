import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/services/api_v1.dart';

class SalesService {
  const SalesService();

  ///
  static Future<Response> createSalesOrder(
    Order orderItemInput,
    String invoiceNum,
  ) async {
    // print('${orderItemInput.orderItems![0].product?.sellingPrice}');
    // print('${orderItemInput.orderItems![0].product?.baseSellingPriceGst}');
    // print('${orderItemInput.orderItems![0].product?.saleigst}');
    print("---line 16 in sales.dart");
    print(orderItemInput.kotId);
    // print(orderItemInput.modeOfPayment);
    // print(orderItemInput.party);
    // print(orderItemInput.invoiceNum);
    var dataSent = {
      'kotId': orderItemInput.kotId,
      'orderItems':
      orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
      'modeOfPayment': orderItemInput.modeOfPayment,
      'party': orderItemInput.party?.id,
      'invoiceNum': invoiceNum,
      'reciverName': orderItemInput.reciverName,
      'businessName': orderItemInput.businessName,
      'businessAddress': orderItemInput.businessAddress,
      'gst': orderItemInput.gst,
    };
    print("--data sent--");
    print(jsonEncode(dataSent));
    final response = await ApiV1Service.postRequest(
      '/salesOrder/new',
      data: {
        'kotId': orderItemInput.kotId,
        'orderItems':
            orderItemInput.orderItems?.map((e) => e.toSaleMap()).toList(),
        'modeOfPayment': orderItemInput.modeOfPayment,
        'party': orderItemInput.party?.id,
        'invoiceNum': invoiceNum,
        'reciverName': orderItemInput.reciverName,
        'businessName': orderItemInput.businessName,
        'businessAddress': orderItemInput.businessAddress,
        'gst': orderItemInput.gst,
      },
    );
    print("line 37 in sales.dart");
    print(response.data);
    return response;
  }
  static Future<Map<String, dynamic>> getNumberOfSales() async {
    final response = await ApiV1Service.getRequest('/salesNum');
    print("sales num is ${response.data}");
    return response.data;
  }
  ///
  static Future<Response> getAllSalesOrders() async {
    final response = await ApiV1Service.getRequest('/salesOrders/me');
    return response;
  }
  static Future<Map<String, dynamic>> getSingleSaleOrder(String invoiceNum) async {
    final response = await ApiV1Service.getRequest('/salesOrder/$invoiceNum');
    print("line 65 in sales.dart");
    print(response.data);
    return response.data;
  }
}
