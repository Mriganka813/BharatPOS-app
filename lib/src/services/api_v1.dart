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
    }
    else{
      cookies = [Cookie("token", response.data['token'])];
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

      print("First GET $url");
      print("dio cookie value = ${_dio.options.headers['cookie']}");
      print("dio Authorization value = ${_dio.options.headers['Authorization']}");
      if(_dio.options.headers.containsKey('Authorization_subuser'))
      print("dio Authorization_subuser value = ${_dio.options.headers['Authorization_subuser']}");

      final response = await _dio.get(url, queryParameters: queryParameters,);
      if (response.statusCode == 401) {
           print("401 error");
            // await UserService.getNewToken();
            // response = await _dio.get(url, queryParameters: queryParameters);
      }
      print("STATUSCODE ${response.statusCode}");
      // print(  response.headers);
      print("First get ${url} resonse ${response}");
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
    return await _dio.put(url, data: formData ?? data);
  }

  ///
  static Future<Response> deleteRequest(String url,
      {Map<String, dynamic>? data}) async {
    return await _dio.delete(url);
  }
}
