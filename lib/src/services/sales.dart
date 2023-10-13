import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/order_input.dart';
import 'package:shopos/src/services/api_v1.dart';

class SalesService {
  const SalesService();

  ///
  static Future<Response> createSalesOrder(
    OrderInput orderItemInput,
    String invoiceNum,
  ) async {
    print('${orderItemInput.orderItems![0].product?.sellingPrice}');
    print('${orderItemInput.orderItems![0].product?.baseSellingPriceGst}');
    print('${orderItemInput.orderItems![0].product?.saleigst}');
    final response = await ApiV1Service.postRequest(
      '/salesOrder/new',
      data: {
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
    print(response.data);
    return response;
  }

  ///
  static Future<Response> getAllSalesOrders() async {
    final response = await ApiV1Service.getRequest('/salesOrders/me');
    return response;
  }
}
