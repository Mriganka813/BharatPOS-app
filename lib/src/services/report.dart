import 'package:dio/dio.dart';
import 'package:magicstep/src/services/api_v1.dart';

class ReportService {
  const ReportService();

  ///
  Future<Response> getAllReport() async {
    final response = await ApiV1Service.getRequest('/report');
    return response;
  }
}
