import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shopos/firebase_options.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/background_service.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.registerLazySingleton(() => GlobalServices());
  await Firebase.initializeApp(
      name: 'CUBE', options: DefaultFirebaseOptions.currentPlatform);
  await Permission.notification.isDenied.then((value) => {
        if (value) {Permission.notification.request()}
      });

  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (details) {
      print(details.payload);
      print(details.notificationResponseType.name);
    },
  );

  /// TODO uncomment this line
//await const Utils().checkUpdates();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => Billing(),
    )
  ], child: const MyApp()));
}
