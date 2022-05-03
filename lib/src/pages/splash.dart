import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:magicstep/src/config/const.dart';
import 'package:magicstep/src/pages/home.dart';
import 'package:magicstep/src/pages/sign_in.dart';
import 'package:path_provider/path_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  ///
  @override
  void initState() {
    super.initState();
    authStatus();
  }

  Future<void> authStatus() async {
    Directory tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    final PersistCookieJar cj = PersistCookieJar(
      ignoreExpires: true,
      storage: FileStorage(tempPath),
    );
    final cookies = await cj.loadForRequest(Uri.parse(Const.apiUrl));
    final isAuthenticated = cookies.isNotEmpty;
    Future.delayed(
      const Duration(milliseconds: 600),
      () => Navigator.pushReplacementNamed(
        context,
        isAuthenticated ? HomePage.routeName : SignInPage.routeName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash"),
      ),
    );
  }
}
