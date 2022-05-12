import 'package:flutter/material.dart';
import 'package:magicstep/src/services/global.dart';
import 'package:magicstep/src/services/locator.dart';

import 'src/app.dart';

void main() async {
  locator.registerLazySingleton(() => GlobalServices());
  runApp(const MyApp());
}
