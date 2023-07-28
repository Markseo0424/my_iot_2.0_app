// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myiot/screen/home_screen.dart';
import 'package:myiot/supports/iot_background_service.dart';
import 'package:myiot/types/iot_memories.dart';
import 'package:myiot/types/iot_request.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(defaultTargetPlatform == TargetPlatform.android) {
    await initializeService();
  }

  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}


const notificationChannelId = 'background_iot';
const notificationId = 820;

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, 'MYIOT FOREGROUND SERVICE',
    description:
    'foreground service for schedule',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if(Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
    ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
  AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,

      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: notificationChannelId,
      initialNotificationTitle: 'myIOT foreground service',
      initialNotificationContent: 'running',
      foregroundServiceNotificationId: notificationId,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  //final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  IotBackgroundService backgroundService = IotBackgroundService();
  IotMemories backgroundMemories = IotMemories();

  backgroundMemories.getFromPref(() {
    IotRequest.setServerAddress(backgroundMemories.serverUrl);
    backgroundService.initializeBackgroundService(
      memories: backgroundMemories,
      modules: backgroundMemories.moduleList,
      schedules: backgroundMemories.scheduleList,
    );
  });

  Timer.periodic(const Duration(seconds: 50), (timer) async {
    if(service is AndroidServiceInstance) {
      if(await service.isForegroundService()) {
        backgroundMemories.getFromPref(() {
          IotRequest.setServerAddress(backgroundMemories.serverUrl);
          backgroundService.initializeBackgroundService(
            memories: backgroundMemories,
            modules: backgroundMemories.moduleList,
            schedules: backgroundMemories.scheduleList,
          );
          backgroundService.synchronize();

          service.setForegroundNotificationInfo(
              title: "myIOT 2.0 is running",
              content: "last sync at ${DateTime.now()}",
          );
        });
      }
    }
  }
  );
}
