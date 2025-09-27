import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shopos/src/config/config_service.dart';
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/services/dio_interceptor.dart';

class ApiV1Service {
  // Make _dio nullable and late-initialized
  static Dio? _dio;

  // Make the initialization function
  static Future<Dio> _initDio() async {
    // 1. Get the base URL dynamically
    final String baseUrl = await ConfigService.getBaseUrl();
    print('Initializing Dio with baseUrl: $baseUrl');

    // 2. Create the Dio instance with the dynamic baseUrl
    final dioInstance = Dio(
      BaseOptions(
        contentType: 'application/json',
        baseUrl: baseUrl + Const.apiV1Path, // Construct the full v1 endpoint
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 50000),
      ),
    );

    // 3. Add interceptors (keep your existing logic)
    dioInstance.interceptors.clear();
    final cj = await getCookieJar();
    dioInstance.interceptors.add(CookieManager(cj));
    dioInstance.interceptors.add(CustomInterceptor());
    // ... your other interceptor logic (PrettyDioLogger)

    return dioInstance;
  }

  // Getter for Dio that ensures initialization
  static Future<Dio> get dio async {
    _dio ??= await _initDio();
    return _dio!;
  }

  ///
  Future<PersistCookieJar> initCookiesManager() async {
    // Get the initialized Dio instance
    final dioInstance = await dio;
    final cj = await getCookieJar();
    // ... rest of your existing function remains the same
    dioInstance.interceptors.add(CookieManager(cj));
    dioInstance.interceptors.add(CustomInterceptor());
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
    final dioInstance = await dio; // <- Get the initialized Dio client
    return await dioInstance.post(url, data: formData ?? data);
  }

  static Future<Response> getRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final dioInstance = await dio; // <- Get the initialized Dio client
    final response =
        await dioInstance.get(url, queryParameters: queryParameters);
    if (response.statusCode == 401) {
      print("401 error");
    }
    print("STATUSCODE ${response.statusCode}");
    return response;
  }

  // ... Similarly, update putRequest and deleteRequest
  static Future<Response> putRequest(
    String url, {
    Map<String, dynamic>? data,
    FormData? formData,
  }) async {
    final dioInstance = await dio;
    return await dioInstance.put(url, data: formData ?? data);
  }

  static Future<Response> deleteRequest(String url,
      {Map<String, dynamic>? data}) async {
    final dioInstance = await dio;
    return await dioInstance.delete(url);
  }

  // ... The rest of your existing functions (saveCookie, clearCookies, getCookieJar)
  // need to be updated to use the async 'dio' getter as well.
  Future<void> saveCookie(Response response) async {
    clearCookies();
    final dioInstance = await dio; // <- Get Dio here
    List<Cookie> cookies;

    String ck = 'token=${response.data['token']};';
    if (response.data['token_subuser'] != null &&
        response.data['token_subuser'] != "") {
      ck += ' token_subuser=${response.data['token_subuser']};';
      dioInstance.options.headers.addAll({
        "Authorization_subuser":
            "Bearer_subuser ${response.data['token_subuser']}"
      });
      cookies = [
        Cookie("token", response.data['token']),
        Cookie("token_subuser", response.data['token_subuser'])
      ];
      // cookies= [Cookie("token", 'abc'), Cookie("token_subuser", 'def')];
    } else {
      cookies = [Cookie("token", response.data['token'])];
      // cookies = [Cookie("token", 'abc')];
    }
    final cj = await ApiV1Service.getCookieJar();
    await cj.saveFromResponse(Uri.parse(Const.apiUrl), cookies);
    dioInstance.interceptors.add(CookieManager(cj));

    // _dio.options.headers.addAll({"Cookie": ck});
    dioInstance.options.headers
        .addAll({"Authorization": "Bearer ${response.data['token']}"});
    print(
        "\n\n COOKIE WAS UPDATED TO ${dioInstance.options.headers['cookie']} \n\n");
    // ... rest of your existing saveCookie logic
  }

  void clearCookies() {
    // This is tricky because _dio might not be initialized yet.
    // You might need to make this async or handle the null case.
    _dio?.interceptors.clear();
    _dio?.options.headers.clear();
  }
// It's often better to make clearCookies async too:
// Future<void> clearCookies() async {
//   final dioInstance = await dio;
//   dioInstance.interceptors.clear();
//   dioInstance.options.headers.clear();
// }
}
