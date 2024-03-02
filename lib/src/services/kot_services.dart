import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/kot_model.dart';
import 'package:shopos/src/services/api_v1.dart';

class KOTService {
  const KOTService();

  static Future<Response> createKot(Kot kot) async {
    var dataToBeSent = {
      "kotId": kot.kotId,
      "item": kot.items?.map((item) => item.toMap()).toList()
    };
    print("dataSent in createKot: $dataToBeSent");
    final response = await ApiV1Service.postRequest(
      '/kot/new',
      data: {
        "kotId": kot.kotId,
        "item": kot.items?.map((item) => item.toMap()).toList()
      },
    );
    print("response.data from createKot is ${response.data}");
    return response;
  }

  static Future<Response> updateKot(Kot kot) async {
    var dataToBeSent = {
      "kotId": kot.kotId,
      "item": kot.items?.map((item) => item.toMap()).toList(),
    };
    print("data sent in update kot: $dataToBeSent");
    final response = await ApiV1Service.putRequest(
      '/kot/${kot.kotId}',
      data: {
        "item": kot.items?.map((item) => item.toMap()).toList()
      },
    );
    print("response.data from update kot is ${response.data}");
    return response;
  }
  static Future<Map<String, dynamic>> getKot(String kotId) async {
    final response = await ApiV1Service.getRequest('/kot/${kotId}');
    return response.data;
  }
}
