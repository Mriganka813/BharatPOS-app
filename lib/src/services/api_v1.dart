import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:magicstep/src/config/const.dart';

class ApiV1Service {
  // Cookie files will be saved in files in "./cookies"
  static final cj = PersistCookieJar(
    ignoreExpires: true, //save/load even cookies that have expired.
  );
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Const.apiV1Url,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    ),
  );
  const ApiV1Service();

  ///
  initCookiesManager() {
    final cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));
  }

  ///
  static Future<Response> postRequest(
    String url, {
    Map<String, dynamic>? data,
  }) async {
    return await _dio.post(url, data: data);
  }

  ///
  static Future<Response> getRequest(String url,
      {Map<String, dynamic>? data}) async {
    return await _dio.get(url);
  }
}
