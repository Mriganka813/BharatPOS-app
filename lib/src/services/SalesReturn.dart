import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/order.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:shopos/src/services/user.dart';

class SalesReturnService {
  const SalesReturnService();

  ///
  static Future<Response> createSalesReturnOrder(
      Order orderItemInput, String invoiceNum, String total) async {
    final userresponse = await UserService.me();
    final user = User.fromMap(userresponse.data['user']);
    print('${orderItemInput.orderItems![0].product?.sellingPrice}');
    print('${orderItemInput.orderItems![0].product?.baseSellingPriceGst}');
    print('${orderItemInput.orderItems![0].product?.saleigst}');
    final response = await ApiV1Service.postRequest(
      '/salesOrder/return',
      data: {
        'orderItems':
            orderItemInput.orderItems?.map((e) => e.toSaleReturnMap()).toList(),
        'modeOfPayment': orderItemInput.modeOfPayment,
        'party': orderItemInput.party?.id,
        'invoiceNum': invoiceNum,
        'reciverName': orderItemInput.reciverName,
        'businessName': orderItemInput.businessName,
        'businessAddress': orderItemInput.businessAddress,
        'createdAt': DateTime.now().toString(),
        'gst': orderItemInput.gst,
        'user': user.id,
        'total': double.parse(total),
      },
    );
    print(response.data);
    return response;
  }

  ///
  static Future<Response> getAllSalesReturnOrders() async {
    final response = await ApiV1Service.getRequest('/salesOrders/me');
    return response;
  }
}
