import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/party_input.dart';
import 'package:shopos/src/models/party.dart';
import 'package:shopos/src/services/api_v1.dart';

class PartyService {
  const PartyService();

  Future<Response> createParty(PartyInput party) async {
    return await ApiV1Service.postRequest('/party/new', data: party.toMap());
  }

  /// Get all parties for the current user
  Future<Response> getParties() async {
    return await ApiV1Service.getRequest('/party/me');
  }

  /// Get all parties
  Future<Response> getSearch(String searchQuery, {String? type}) async {
    final params = {
      "searchQuery": searchQuery,
      "limit": 10,
    };
    if (type != null) {
      params.addAll({"type": type});
    }
    return await ApiV1Service.getRequest(
      '/party/search',
      queryParameters: params,
    );
  }

  Future<Response> deleteParty(Party party) async {
    return await ApiV1Service.deleteRequest('/del/party/${party.id}');
  }

  ///
  Future<Response> updateParty(PartyInput party) async {
    return await ApiV1Service.putRequest(
      '/update/party/${party.id}',
      data: party.toMap(),
    );
  }

  ///
  Future<List<Party>> getCreditPurchaseParties() async {
    final response = await ApiV1Service.getRequest('/party/purchase/credit');
    return (response.data['data'] as List)
        .map((e) => Party.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  ///
  Future<List<Party>> getCreditSaleParties() async {
    final response = await ApiV1Service.getRequest('/party/sale/credit');
    return (response.data['data'] as List)
        .map((e) => Party.fromMap(e as Map<String, dynamic>))
        .toList();
  }
}
