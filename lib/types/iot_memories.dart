import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:myiot/types/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'iot_action.dart';
import 'iot_condition.dart';
import 'module.dart';

class IotMemories {
  static ValueNotifier<int> memoryUpdateListener = ValueNotifier(1);
  static void memoryUpdate() {
    memoryUpdateListener.value *= -1;
  }
  static SharedPreferences? preferences;

  ModuleList moduleList = ModuleList([
    Module(moduleName: "MAIN", moduleId: "0424", type: Module.ONOFF)
      ..setValue = true,
    Module(moduleName: "SUB", moduleId: "1025", type: Module.ONOFF)
      ..setValue = false,
    Module(moduleName: "에어컨 온도", moduleId: "4242", type: Module.SLIDER)
      ..setValue = 20.0
      ..setUnit = "℃"
      ..setValueRange = <double>[18,30]
      ..setDecimal = false,
    Module(moduleName: "습도", moduleId: "2525", type: Module.VALUE)
      ..setValue = 62.8
      ..setUnit = "%"
      ..setValueRange = <double>[0,100]
      ..setDecimal = true,
  ]);
  ScheduleList scheduleList = ScheduleList([
    Schedule("HELLO", IotConditionList([]), IotActionList([]))..on=true,
    Schedule("WORLD", IotConditionList([]), IotActionList([])),
  ]);
  String serverUrl = "http://000.00.00.00:0000";

  void saveToPref() async {
    preferences ??= await SharedPreferences.getInstance();
    String jsonString = '''{
      "serverUrl" : "$serverUrl",
      "moduleList" : ${jsonEncode(moduleList.toJson())},
      "scheduleList" : ${jsonEncode(scheduleList.toJson())}
    }''';
    if(preferences != null) preferences!.setString("savedData", jsonString);
  }

  Future<bool> getFromPref(void Function() atFinishLoad) async {
    preferences = await SharedPreferences.getInstance();
    String? jsonString = preferences!.getString("savedData");
    print("received Data : \n$jsonString");
    if(jsonString != null) {
      Map<String,dynamic> jsonData = jsonDecode(jsonString);
      List<Map<String,dynamic>> moduleJsonData = List<Map<String,dynamic>>.from(jsonData["moduleList"]??[]);
      List<Map<String,dynamic>> scheduleJsonData = List<Map<String,dynamic>>.from(jsonData["scheduleList"]??[]);
      if(jsonData["serverUrl"] != null) serverUrl = jsonData["serverUrl"];
      moduleList = ModuleList.fromJson(moduleJsonData);
      scheduleList = ScheduleList.fromJson(scheduleJsonData, moduleList);
    }
    //print("loaded");
    atFinishLoad();
    return true;
  }

  void printDebugMessage() {
    print("=====memoryListener called.=====");
    print("=====serverURL=====");
    print(serverUrl);
    print("=====modules=====");
    print(jsonEncode(moduleList.toJson()));
    print("=====schedules=====");
    print(jsonEncode(scheduleList.toJson()));
    print("--------------------------------");
  }

}