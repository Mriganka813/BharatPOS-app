import 'package:dio/dio.dart';
import 'package:magicstep/src/models/input/party_input.dart';
import 'package:magicstep/src/models/party.dart';
import 'package:magicstep/src/services/api_v1.dart';

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
  Future<Response> getSearch(String searchQuery) async {
    return await ApiV1Service.getRequest(
      '/party/search',
      queryParameters: {
        "searchQuery": searchQuery,
        "limit": 10,
      },
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
}
