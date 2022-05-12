import 'package:flutter/material.dart';

class GlobalServices {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

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
}
