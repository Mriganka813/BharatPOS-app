import 'package:dio/dio.dart';
import 'package:shopos/src/models/order.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/api_v1.dart';

class SpecificPartyService {
  ///

  Future<List<Order>> getSalesCreditHistory(String id) async {
    final response = await ApiV1Service.getRequest('/sales/credit-history/$id');
    return (response.data['data'] as List)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  ///
  Future<List<Order>> getpurchaseCreditHistory(String id) async {
    final response =
        await ApiV1Service.getRequest('/purchase/credit-history/$id');
    return (response.data['data'] as List)
        .map((e) => Order.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  ///
  Future<Response> updateSalesCredit(Party party) async {
    return await ApiV1Service.postRequest(
      '/sales/credit-history/${party.id}',
      data: party.toMap(),
    );
  }

  ///
  Future<Response> updatepurchasedCredit(Party party) async {
    return await ApiV1Service.postRequest(
      '/purchase/credit-history/${party.id}',
      data: party.toMap(),
    );
  }

  ///
  Future<Party> getCreditPurchaseParty(String id) async {
    final response =
        await ApiV1Service.getRequest('/party/purchase/credit/$id');
    print(response.data);
    return Party.fromMap(response.data['data'] as Map<String, dynamic>);
  }

  ///
  Future<Party> getCreditSaleParty(String id) async {
    final response = await ApiV1Service.getRequest('/party/sale/credit/$id');
    return Party.fromMap(response.data['data'] as Map<String, dynamic>);
  }
}
