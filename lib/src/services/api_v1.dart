import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
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
    // _dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: false,
    //     error: true,
    //     compact: true,
    //     maxWidth: 90));
    return cj;
  }

  static Future<PersistCookieJar> getCookieJar() async {
    Directory tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    print(tempPath);
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
    // _dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: false,
    //     responseHeader: false,
    //     error: true,
    //     compact: true,
    //     maxWidth: 90));
    return await _dio.post(url, data: formData ?? data);
  }

  Future<void> saveCookie(response) async {
    clearCookies();
    List<Cookie> cookies;

    String ck = 'token=${response.data['token']};';
    if(response.data['token_subuser'] != null && response.data['token_subuser'] != ""){
      ck += ' token_subuser=${response.data['token_subuser']};';
      _dio.options.headers.addAll({"Authorization_subuser" : "Bearer_subuser ${response.data['token_subuser']}"});
      cookies= [Cookie("token", response.data['token']), Cookie("token_subuser", response.data['token_subuser'])];
      // cookies= [Cookie("token", 'abc'), Cookie("token_subuser", 'def')];
    }
    else{
      cookies = [Cookie("token", response.data['token'])];
      // cookies = [Cookie("token", 'abc')];
    }
    final cj = await ApiV1Service.getCookieJar();
    await cj.saveFromResponse(Uri.parse(Const.apiUrl), cookies);
    _dio.interceptors.add(CookieManager(cj));

    // _dio.options.headers.addAll({"Cookie": ck});
    _dio.options.headers.addAll({"Authorization": "Bearer ${response.data['token']}"});
    print("\n\n COOKIE WAS UPDATED TO ${_dio.options.headers['cookie']} \n\n");
  }
  ///

  ///
  void clearCookies() {
    _dio.interceptors.clear();
    _dio.options.headers.clear();

  }
  ///
  static Future<Response> getRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
      // _dio.interceptors.add(PrettyDioLogger(
      //     requestHeader: true,
      //     requestBody: true,
      //     responseBody: false,
      //     responseHeader: false,
      //     error: true,
      //     compact: true,
      //     maxWidth: 90));

      // if(_dio.options.headers.containsKey('Authorization_subuser'))
      // print("dio Authorization_subuser value = ${_dio.options.headers['Authorization_subuser']}");

      final response = await _dio.get(url, queryParameters: queryParameters,);
      if (response.statusCode == 401) {
           print("401 error");
            // await UserService.getNewToken();
            // response = await _dio.get(url, queryParameters: queryParameters);
      }
      print("STATUSCODE ${response.statusCode}");
      // print(  response.headers);
      // print("First get ${url} resonse ${response}");
      // if(url == '/logout') {
      //   _dio.options.headers.clear();
      //   _dio.options.headers.addAll({"Cookie": "token=j%3Anull; token_subuser=j%3Anull;"});
      // }
      return response;
  }

  ///
  static Future<Response> putRequest(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
  }) async {
    // _dio.interceptors.add(PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: false,
    //     responseHeader: false,
    //     error: true,
    //     compact: true,
    //     maxWidth: 90));
    return await _dio.put(url, data: formData ?? data);
  }

  ///
  static Future<Response> deleteRequest(String url,
      {Map<String, dynamic>? data}) async {
    return await _dio.delete(url);
  }
}
