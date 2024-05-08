import 'dart:io';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:shopos/src/services/auth.dart';

class UserService {
  const UserService();

  
  static Future<Response<dynamic>> me() async {
    var response;
    try {
      // ApiV1Service().clearCookies();
      response = await ApiV1Service.getRequest('/me');
      // final cj = await ApiV1Service.getCookieJar();
      // print(cj.storage.read('token'));
      // print(cj.storage.read('token_subuser'));
      // SharedPreferences pf = await SharedPreferences.getInstance();
      // print("Key:");
      // print(pf.getKeys());

      print("IN MEEEEE \n\n");
      print(response);
      await getNewToken();
    } catch (e) {
      print('cube token expired');
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? email = pref.getString("email");
      String? pass = pref.getString("pass");
      await AuthService().signInRequest(email!, pass!);

      await getNewToken();
      response = await ApiV1Service.getRequest('/me');
    }

    return response;
  }

  // /// get new token from server
  static getNewToken() async {

    final response = await ApiV1Service.getRequest('/get-token');


    if ((response.statusCode ?? 400) > 300) {
      print("\nERROR IN GETTING NEW TOKEN\n");
      return null;
    }
    print("GOT SOME TOKENSSS \N\N\N");
    await const ApiV1Service().saveCookie(response);
  }

  /// shop open or close
  static shopStatus() async {
    final response = await ApiV1Service.getRequest('/change/shop-status');
    if ((response.statusCode ?? 400) > 300) {
      return null;
    }
    print(response.data);
  }
}
