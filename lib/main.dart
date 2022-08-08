//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shopos/firebase_options.dart';
import 'package:shopos/src/services/global.dart';
import 'package:shopos/src/services/locator.dart';
import 'package:shopos/src/utils.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  locator.registerLazySingleton(() => GlobalServices());
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// TODO uncomment this line
  // await const Utils().checkUpdates();
  runApp(const MyApp());
}
