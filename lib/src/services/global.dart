import 'package:flutter/material.dart';
import 'package:shopos/src/config/colors.dart';

class GlobalServices {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  ///
  void showSnackBar(
      {required String message, required int time, Color? bgcolor}) {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: bgcolor ?? Colors.black,
      content: Text(message),
      duration: Duration(seconds: time),
    ));
  }

  ///
  void errorSnackBar(String message) {
    final cntxt = navigatorKey.currentContext;
    if (cntxt == null) {
      return;
    }
    ScaffoldMessenger.of(cntxt).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  ///
  void infoSnackBar(String message) {
    final cntxt = navigatorKey.currentContext;
    if (cntxt == null) {
      return;
    }
    ScaffoldMessenger.of(cntxt).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange[700],
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  ///
  void successSnackBar(String message) {
    final cntxt = navigatorKey.currentContext;
    if (cntxt == null) {
      return;
    }
    ScaffoldMessenger.of(cntxt).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  ///
  void showBottomSheetLoader() {
    final BuildContext? context = navigatorKey.currentContext;
    if (context == null) {
      return;
    }
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsConst.primaryColor),
          ),
        );
      },
    );
  }
}
