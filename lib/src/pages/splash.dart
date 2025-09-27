import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'package:shopos/src/config/config_service.dart';
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:shopos/src/widgets/custom_button.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatefulWidget {
  BuildContext context;
  SplashScreen(this.context, {Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isUpdateAvailable = false;
  late AppUpdateInfo update;
  double pos = 900;

  ///
  @override
  void initState() {
    super.initState();
    authStatus();
    checkForUpdate();
  }

  checkForUpdate() async {
    update = await InAppUpdate.checkForUpdate();
    if (update.updateAvailability == UpdateAvailability.updateAvailable) {
      isUpdateAvailable = true;
    }
  }

  Future<void> authStatus() async {
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        pos = 0;
      });
    });

    await ConfigService.clearCachedConfig();
    // CRITICAL: Fetch the config FIRST before initializing API services
    String currentBaseUrl;
    try {
      currentBaseUrl = await ConfigService.getBaseUrl(); // Get the actual URL being used
    } catch (e) {
      print("Error loading config: $e. Using fallback.");
      currentBaseUrl = Const.apiUrl; // Fallback to hardcoded URL
    }

    // NOW initialize the API service with the updated config
    final cj = await ApiV1Service().initCookiesManager();
    final cookies = await cj.loadForRequest(Uri.parse(currentBaseUrl));
    final isAuthenticated = cookies.isNotEmpty;

    Future.delayed(
      const Duration(milliseconds: 3000),
          () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => (isAuthenticated
              ? isUpdateAvailable
              ? UpgradeAlert(
            upgrader: Upgrader(
              showIgnore: false,
              canDismissDialog: false,
              showLater: false,
              debugDisplayOnce: true,
              showReleaseNotes: false,
              durationUntilAlertAgain: Duration(seconds: 2),
            ),
            child: HomePage(widget.context),
          )
              : HomePage(widget.context)
              : SignInPage()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: false,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.white,
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SvgPicture.asset("assets/icon/BharatPos.svg"),
      ),
    );
  }
}