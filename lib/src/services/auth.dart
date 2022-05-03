import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:magicstep/src/config/const.dart';
import 'package:magicstep/src/models/input/sign_up_input.dart';
import 'package:magicstep/src/models/user.dart';
import 'package:magicstep/src/services/api_v1.dart';
import 'package:path_provider/path_provider.dart';

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
    final response = await ApiV1Service.postRequest(
      '/registration',
      data: input.toMap(),
    );
    if ((response.statusCode ?? 400) > 300) {
      return null;
    }
    await _saveCookie(response);
    return User.fromMap(response.data['user']);
  }

  Future<void> _saveCookie(Response response) async {
    Directory tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final PersistCookieJar cj = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(tempPath),
    );
    List<Cookie> cookies = [Cookie("token", response.data['token'])];
    await cj.saveFromResponse(Uri.parse(Const.apiUrl), cookies);
  }

  Future<void> clearCookies() async {
    Directory tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final PersistCookieJar cj = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(tempPath),
    );
    await cj.deleteAll();
  }

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
    await _saveCookie(response);
    return User.fromMap(response.data['user']);
  }
}
