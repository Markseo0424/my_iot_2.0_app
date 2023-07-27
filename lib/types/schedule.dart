import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:myiot/types/iot_action.dart';
import 'package:myiot/types/iot_condition.dart';

import 'module.dart';

class Schedule {
  IotConditionList conditionList = IotConditionList([]);
  IotActionList actionList = IotActionList([]);
  String scheduleName = "";

  Schedule(this.scheduleName, this.conditionList, this.actionList);
  Schedule.fromJson(Map<String, dynamic> jsonData, ModuleList moduleList) {
    scheduleName = jsonData["name"]??"";
    on = jsonData["on"]??false;
    conditionList = IotConditionList.fromJson(List<Map<String,dynamic>>.from(jsonData["conditions"]??[]), moduleList);
    actionList = IotActionList.fromJson(List<Map<String,dynamic>>.from(jsonData["actions"]??[]), moduleList);
  }
  Map<String,dynamic> toJson() {
    String jsonString = '''{
      "name" : "$scheduleName",
      "on" : $on,
      "conditions" : ${jsonEncode(conditionList.toJson())},
      "actions" : ${jsonEncode(actionList.toJson())}
    }''';
    return jsonDecode(jsonString);
  }

  bool on = false;

  void evaluate(ValueNotifier<int> moduleChangeListener) {
    if(!on) return;
    bool evaluation = conditionList.evaluate();
    if(evaluation && conditionList.isOnce) on = false;
    //print("${evaluation}");
    if(evaluation) actionList.doActions(moduleChangeListener);
  }
}

class ScheduleList {
  List<Schedule> scheduleList = [];

  ScheduleList(this.scheduleList);
  ScheduleList.fromJson(List<Map<String,dynamic>> jsonList, ModuleList moduleList) {
    for(Map<String,dynamic> jsonData in jsonList) {
      scheduleList.add(Schedule.fromJson(jsonData, moduleList));
    }
  }
  List<Map<String,dynamic>> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for(Schedule schedule in scheduleList) {
      jsonList.add(schedule.toJson());
    }
    return jsonList;
  }

  void reOrder(List<int> reorderList) {
    List<Schedule> newComp = [];
    for(int i in reorderList) {
      newComp.add(scheduleList[i]);
    }
    scheduleList = newComp;
  }

  void evaluateSchedules(ValueNotifier<int> moduleChangeListener) {
    for(Schedule schedule in scheduleList){
      //print("evaluate schedule ${schedule.scheduleName} : ");
      schedule.evaluate(moduleChangeListener);
    }
  }

  Schedule? findByName(String name) {
    for(Schedule schedule in scheduleList) {
      if(schedule.scheduleName == name) {
        return schedule;
      }
    }
    return null;
  }
}