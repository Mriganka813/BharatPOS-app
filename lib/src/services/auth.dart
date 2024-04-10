import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/models/input/sign_up_input.dart';
import 'package:shopos/src/models/user.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:shopos/src/services/user.dart';

class AuthService {
  const AuthService();

  ///
  /// Send verification code
  Future<bool> sendVerificationCode(String phoneNumber) async {
    final response = await ApiV1Service.postRequest('/api/v1/sendOtp');
    if ((response.statusCode ?? 400) < 300) {
      return true;
    }
    return false;
  }

  ///
  /// Send login request
  Future<User?> signUpRequest(SignUpInput input) async {
    final inputMap = FormData.fromMap(input.toMap());
    final filePath = input.imageFile?.path ?? "";
    if (filePath.isNotEmpty) {
      final image = MapEntry("image", await MultipartFile.fromFile(filePath));
      inputMap.files.add(image);
    }
    final response = await ApiV1Service.postRequest(
      '/registration',
      formData: inputMap,
    );
    if ((response.statusCode ?? 400) > 300) {
      return null;
    }
    await const ApiV1Service().saveCookie(response);
    return User.fromMap(response.data['user']);
  }

  /// Save cookies after sign in/up
  // Future<void> saveCookie(Response response) async {
  //   List<Cookie> cookies;
  //
  //   if(response.data['token_subuser'] != null && response.data['token_subuser'] != ""){
  //     cookies= [Cookie("token", response.data['token']), Cookie("token_subuser", response.data['token_subuser'])];
  //   }
  //   else{
  //     cookies = [Cookie("token", response.data['token'])];
  //   }
  //   final cj = await ApiV1Service.getCookieJar();
  //   await cj.saveFromResponse(Uri.parse(Const.apiUrl), cookies);
  //   // _dio.interceptors.add(CookieManager(cj));
  // }

  ///
  Future<void> signOut() async {
    const ApiV1Service().clearCookies();


    await fb.FirebaseAuth.instance.signOut();
    final response = await ApiV1Service.getRequest('/logout');

    if((response.statusCode ?? 400) > 300) {
      print("\n\nERROR IN LOGOUT\n\n");
      return;
    }

    // final res = await ApiV1Service.getRequest('/logout');
  }

  /// Clear cookies before log out
  // Future<void> clearCookies() async {
  //   final cj = await ApiV1Service.getCookieJar();
  //   await cj.deleteAll();
  // }

  /// Send sign in request
  ///
  Future<User?> signInRequest(String email, String password) async {
    final response = await ApiV1Service.postRequest(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    if ((response.statusCode ?? 400) > 300) {
      return null;
    }
    print("line 70 signin request");
    print('res = ${response.data}');
    await ApiV1Service().saveCookie(response);
    if(response.data['subUser'] != null && response.data['subUser'] != ""){
      return User.fromMap(response.data['subUser']);
    }
    return User.fromMap(response.data['user']);
  }

  ///password change request
  ///
  Future<bool> PasswordChangeRequest(
      String oldPassword, String newPassword, String confirmPassword) async {
    final response = await ApiV1Service.putRequest(
      '/password/update',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    if ((response.statusCode ?? 400) > 300) {
      return false;
    }
    return true;
  }

  ///password change request
  ///
  Future<bool> ForgotPasswordChangeRequest(
      String newPassword, String confirmPassword, String phoneNumber) async {
    // print(newPassword + " " + confirmPassword + " " + phoneNumber);
    final response = await ApiV1Service.putRequest(
      '/password/reset',
      data: {
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
        'phoneNumber': phoneNumber,
      },
    );
    if ((response.statusCode ?? 400) > 300) {
      return false;
    }
    return true;
  }
}
