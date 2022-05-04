import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:magicstep/src/config/const.dart';
import 'package:path_provider/path_provider.dart';

class ApiV1Service {
  static final Dio _dio = Dio(
    BaseOptions(
      contentType: 'application/json',
      baseUrl: Const.apiV1Url,
      connectTimeout: 5000,
      receiveTimeout: 3000,
    ),
  );
  const ApiV1Service();

  ///
  Future<PersistCookieJar> initCookiesManager() async {
    // Cookie files will be saved in files in "./cookies"
    final cj = await getCookieJar();
    _dio.interceptors.add(CookieManager(cj));
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
  }) async {
    return await _dio.post(url, data: data);
  }

  ///
  static Future<Response> getRequest(String url,
      {Map<String, dynamic>? data}) async {
    return await _dio.get(url);
  }
}
