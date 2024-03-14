import 'package:dio/dio.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    print("---in line 8 of dio_interceptor--");
    // print(err.message);
    print("err.response: ");
    print(err.response);
    print(err.response?.data);
    // print(err.response?.data['message']);

    // final errorMessage = err.response?.data is List
    //     ? err.response?.data['message']
    //     : err.message;
    final errorMessage = err.response?.data['message'];
    const message = "Something went wrong";
    // print("errorMEsg = $errorMessage");
    // if(errorMessage == 'Your subscription is not active')
    if(errorMessage!=null)
      locator<GlobalServices>().errorSnackBar(errorMessage ?? message);
    return super.onError(err, handler);
  }
}
