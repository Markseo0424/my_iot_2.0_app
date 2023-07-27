import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myiot/types/iot_memories.dart';
import 'package:myiot/types/module.dart';

import '../types/iot_request.dart';
import '../types/schedule.dart';

class IotBackgroundService {
  ModuleList? moduleList;
  ScheduleList? scheduleList;
  ValueNotifier<int>? updateModuleListener;
  IotMemories? iotMemories;

  initializeBackgroundService({ModuleList? modules, ScheduleList? schedules, IotMemories? memories, ValueNotifier<int>? listener}) {
    moduleList = modules;
    scheduleList = schedules;
    iotMemories = memories;
    updateModuleListener = listener;
  }

  synchronize() async {
    IotRequest.sendListRequest((jsonResponse) {
      //print(jsonResponse);
      if(jsonResponse['data'] == null) return;
      List<Map<String,dynamic>> dataList = List<Map<String,dynamic>>.from(jsonResponse['data']);
      for(var jsonData in dataList) {
        if(moduleList!=null) {
          var module = moduleList!.findByID(jsonData["id"]??"");
          if(jsonData['val']==null) continue;
          if(module==null) continue;
          if(module.type == Module.ONOFF){
            if(jsonData['val'] == 'ON') {
              module.setValue = true;
            }
            else {
              module.setValue = false;
            }
          }
          else {
            try {
              double value = double.parse(jsonData['val']);
              module.setValue = value;
            }
            catch(e) {
              continue;
            }
          }
        }
      }
      if(scheduleList!=null) scheduleList!.evaluateSchedules(ValueNotifier(1));
      if(iotMemories!=null) iotMemories!.saveToPref();
      if(updateModuleListener!=null) updateModuleListener!.value *= -1;
    });
  }
}