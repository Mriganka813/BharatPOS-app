import 'package:flutter/material.dart';
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/services/api_v1.dart';

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
    final cj = await const ApiV1Service().initCookiesManager();
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
