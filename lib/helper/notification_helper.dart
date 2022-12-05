import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static final NotificationHelper instance = NotificationHelper._internal();

  NotificationHelper._internal();

  final _random = Random(1);
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

  static const _androidInitializationSetting = AndroidInitializationSettings('notification_icon');
  static const _androidPlatformChannelSpecifies = AndroidNotificationDetails(
      'com.example.rent2car_pushed_notification', 'Space Complete Notification',
      channelDescription: 'Driver space complete notification for rating.',
      styleInformation: BigTextStyleInformation(''),
      importance: Importance.high,
      priority: Priority.high,
      enableLights: true);
  static const _notificationDetails =
      NotificationDetails(android: _androidPlatformChannelSpecifies, iOS: IOSNotificationDetails(presentSound: true));

  IOSInitializationSettings get _iosInitializationSettings =>
      IOSInitializationSettings(onDidReceiveLocalNotification: _onDidReceiveLocalNotification);

  InitializationSettings get _initializationSettings =>
      InitializationSettings(android: _androidInitializationSetting, iOS: _iosInitializationSettings);

  Future<void> _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) async {}

  bool isPluginInitialize = false;

  int get _randomNumber => int.parse(List.generate(6, (_) => _random.nextInt(9)).join());

  Future<String?> getLastPayload() async {
    final notificationDetails = await _flutterLocalNotificationPlugin.getNotificationAppLaunchDetails();
    return notificationDetails?.payload;
  }

  Future<void> showNotification(String title, String content,
      {BuildContext? context, String route = '', String? payload, Map<String, dynamic>? arguments}) async {
    if (!isPluginInitialize) {
      await _flutterLocalNotificationPlugin.initialize(_initializationSettings, onSelectNotification: (s) async {
        if (route.isNotEmpty && context != null) Navigator.pushNamed(context, route, arguments: arguments);
      });
      if (route.isNotEmpty) isPluginInitialize = true;
    }
    _flutterLocalNotificationPlugin.show(_randomNumber, title, content, _notificationDetails, payload: payload);
  }
}
