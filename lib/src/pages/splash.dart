import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
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
    // // if (update.immediateUpdateAllowed) {
    // //   await InAppUpdate.startFlexibleUpdate();
    // //   await InAppUpdate.completeFlexibleUpdate();
    // //   return;
    // // }
    // await InAppUpdate.performImmediateUpdate();

    // showUpdateRequiredDialog();
  }

  Future<void> authStatus() async {
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        pos = 0;
      });
    });
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
          statusBarColor: /*Color.fromARGB(255, 81, 163, 251)*/Colors.white,
        ),
        backgroundColor: /*Color.fromARGB(255, 81, 163, 251)*/Colors.white,
      ),
      backgroundColor: /*Color.fromARGB(255, 81, 163, 251)*/Colors.white,
      body: Center(
        child: SvgPicture.asset("assets/icon/BharatPos.svg"),
      ),
    );
  }

  // Future<bool?> showRestartAppDialouge() {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (ctx) => AlertDialog(
  //             content: Text('App needed to restart'),
  //             title: Text('Alert'),
  //             actions: [
  //               Center(
  //                   child: CustomButton(
  //                       title: 'ok',
  //                       onTap: () async {
  //                            Navigator.of(context).pop();
  //                       await  DatabaseHelper().deleteTHEDatabase();
  //
  //
  //
  //                       }))
  //             ],
  //           ));
  // }
}
