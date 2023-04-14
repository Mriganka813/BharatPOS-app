import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/services/dio_interceptor.dart';

class ApiV1Service {
  static final Dio _dio = Dio(
    BaseOptions(
      contentType: 'application/json',
      baseUrl: Const.apiV1Url,
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 50000),
    ),
  );
  const ApiV1Service();

  ///
  Future<PersistCookieJar> initCookiesManager() async {
    // Cookie files will be saved in files in "./cookies"
    _dio.interceptors.clear();
    final cj = await getCookieJar();
    _dio.interceptors.add(CookieManager(cj));
    _dio.interceptors.add(CustomInterceptor());
    return cj;
  }

  static Future<PersistCookieJar> getCookieJar() async {
    Directory tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    return PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(tempPath),
    );
  }

  ///
  static Future<Response> postRequest(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
  }) async {
    return await _dio.post(url, data: formData ?? data);
  }

  ///
  static Future<Response> getRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(url, queryParameters: queryParameters);
  }

  ///
  static Future<Response> putRequest(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
  }) async {
    return await _dio.put(url, data: formData ?? data);
  }

  ///
  static Future<Response> deleteRequest(String url,
      {Map<String, dynamic>? data}) async {
    return await _dio.delete(url);
  }
}
