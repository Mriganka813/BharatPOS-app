import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shopos/src/config/const.dart';
import 'package:shopos/src/pages/home.dart';
import 'package:shopos/src/pages/sign_in.dart';
import 'package:shopos/src/services/api_v1.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isUpdateAvailable = false;
  late AppUpdateInfo update;

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
    // // if (update.immediateUpdateAllowed) {
    // //   await InAppUpdate.startFlexibleUpdate();
    // //   await InAppUpdate.completeFlexibleUpdate();
    // //   return;
    // // }
    // await InAppUpdate.performImmediateUpdate();

    // showUpdateRequiredDialog();
  }

  Future<void> authStatus() async {
    final cj = await const ApiV1Service().initCookiesManager();
    final cookies = await cj.loadForRequest(Uri.parse(Const.apiUrl));
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

                        // debugDisplayAlways: true,
                        showReleaseNotes: false,
                        durationUntilAlertAgain: Duration(seconds: 2),
                        //willDisplayUpgrade: ({appStoreVersion, required display, installedVersion, minAppVersion}) => ,
                      ),
                      child: HomePage(),
                    )
                  : HomePage()
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
          statusBarColor: Color.fromARGB(255, 81, 163, 251),
        ),
        backgroundColor: Color.fromARGB(255, 81, 163, 251),
      ),
      backgroundColor: Color.fromARGB(255, 81, 163, 251),
      body: Center(
        child: SvgPicture.asset("assets/icon/splash.svg"),
      ),
    );
  }
}
