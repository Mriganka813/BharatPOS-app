// import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopos/firebase_options.dart';
import 'package:shopos/src/provider/billing_order.dart';
import 'package:shopos/src/services/LocalDatabase.dart';
import 'package:shopos/src/services/background_service.dart';
import 'package:shopos/src/services/firebase_api.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;

  // Store the current version in SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String previousVersion = prefs.getString('appVersion') ?? '';

  // Check if the app is updated
  if (currentVersion != previousVersion) {
    print("version are not correct");
   await DatabaseHelper().deleteTHEDatabase();
        await DatabaseHelper().initDatabase();
    prefs.setString('appVersion', currentVersion);
  }
  else
  {
    print("Versions Are correct");
  }

  locator.registerLazySingleton(() => GlobalServices());
  await Firebase.initializeApp(
      name: 'BharatPOS', options: DefaultFirebaseOptions.currentPlatform);
 
  await FirebaseApi().initNotifications();
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
   //await Utils().checkForUpdate();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (context) => Billing(),
    )
  ], child: const MyApp()));
}
