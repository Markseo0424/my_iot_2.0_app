import 'dart:async';

import 'package:flutter/material.dart';
import 'package:myiot/screen/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  if(defaultTargetPlatform == TargetPlatform.android) {
    await initializeService();
  }
   */

  runApp(const MaterialApp(
    home: HomeScreen(),
  ));
}