import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myiot/screen/home_screen.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myiot/supports/iot_background_service.dart';
import 'package:myiot/types/iot_memories.dart';
import 'package:myiot/types/iot_request.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  if(defaultTargetPlatform == TargetPlatform.android) {
    await initializeService();
  }
   */

  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}