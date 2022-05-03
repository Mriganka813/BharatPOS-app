import 'package:dio/dio.dart';
import 'package:magicstep/src/services/secure_storage.dart';

class ApiService {
  static final Dio _dio = Dio();
  const ApiService();

  ///
  static Future<Dio> client(String token) async {
    final token = await SecureStorageService.getToken();
    return _dio;
  }
}
