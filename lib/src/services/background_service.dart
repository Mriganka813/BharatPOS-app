import 'dart:async';
import 'dart:ui';


import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shopos/src/services/api_v1.dart';

import '../config/const.dart';

import '../models/online_order.dart';
import 'order_services.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
List<OnlineOrder> pendingData = [];

@pragma('vm:entry-point')
Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>;
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
        onStart: onStart, isForegroundMode: true, autoStart: true),
  );
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsBackgroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final cj = await const ApiV1Service().initCookiesManager();
  final cookies = await cj.loadForRequest(Uri.parse(Const.apiUrl));
  final isAuthenticated = cookies.isNotEmpty;
  Timer.periodic(Duration(seconds: 10), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        service.setForegroundNotificationInfo(
            title: 'BharatPOS', content: 'Tap to view more');
      }
    }
    WidgetsFlutterBinding.ensureInitialized();
    try {
      final cj = await const ApiV1Service().initCookiesManager();
      final cookies = await cj.loadForRequest(Uri.parse(Const.apiUrl));
      final isAuthenticated = cookies.isNotEmpty;
      if (isAuthenticated) {
        List<OnlineOrder> orderHistory = [];

        orderHistory = await OrderServices.orderHistory();
        orderHistory = orderHistory.reversed.toList();

        print(orderHistory.length);
        pendingData = orderHistory
            .where((element) =>
                element.items![0].status == "PENDING".toLowerCase())
            .toList();
        // print(pendingData.length);
        if (pendingData.length > 0) {
          scheduleAlarm('New order is available',
              'Order id - ' + pendingData[0].orderId.toString());
        }
        print('background service running');
      }
    } catch (e) {
      print("EXCEPTION: $e");
    }
  });
}

Future<void> scheduleAlarm(String newOrder, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('ring_ring'),
    enableVibration: true,
    playSound: true,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);
  flutterLocalNotificationsPlugin.show(
      0, newOrder, body, platformChannelSpecifics);
}
