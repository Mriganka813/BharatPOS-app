import 'package:dio/dio.dart';
import 'package:shopos/src/services/api_v1.dart';

class UserService {
  const UserService();

  static Future<Response<dynamic>> me() async {
    final response = await ApiV1Service.getRequest('/me');
    return response;
  }
}
