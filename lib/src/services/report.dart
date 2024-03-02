import 'package:dio/dio.dart';
import 'package:shopos/src/models/input/report_input.dart';
import 'package:shopos/src/services/api_v1.dart';

class ReportService {
  const ReportService();

  Future<String> getCurrentDate() async {
    final response = await ApiV1Service.getRequest('/current-date');
    return response.data['date'];
  }
  ///
  Future<Response> getAllReport(ReportInput input) async {
    print(input.type);
    print(input.startDate);
    print(input.endDate);
    print('ok');
    final response = await ApiV1Service.getRequest(
      '/report',
      queryParameters: input.toMap(),
    );
    print("--line 18 in report.dart");
    print("response:${response.data}");
    print("--------------");

    
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
