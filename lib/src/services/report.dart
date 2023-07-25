import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/report_input.dart';
import 'package:shopos/src/services/api_v1.dart';

class ReportService {
  const ReportService();

  ///
  Future<Response> getAllReport(ReportInput input) async {
    final response = await ApiV1Service.getRequest(
      '/report',
      queryParameters: input.toMap(),
    );
    // print(response.data);
    return response;
  }

  ///
  Future<Response> getStockReport() async {
    final response = await ApiV1Service.getRequest(
      '/report?type=report',
    );
    return response;
  }
}
