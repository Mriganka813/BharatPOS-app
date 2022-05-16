import 'package:dio/dio.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    final message = err.response?.data['message'] ?? "Something went wrong";
    locator<GlobalServices>().errorSnackBar(message);
    return super.onError(err, handler);
  }
}
