import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'module.dart';

class IotAction {
  Module? module;
  double _targetVal = 0;
  bool _targetBool = false;

  bool isTimeDelay = false;
  double delaySeconds = 0;

  IotAction(this.module,);
  IotAction.fromJson(Map<String,dynamic> jsonData, ModuleList moduleList) {
    isTimeDelay = jsonData["isTimeDelay"]??true;
    if(isTimeDelay) {
      delaySeconds = jsonData["delayTime"]??0;
    }
    else {
      module = moduleList.findByID(jsonData["moduleId"]??"");
      boolTarget = jsonData["valueBool"]??false;
      doubleTarget = jsonData["valueDouble"]??0;
    }
  }
  Map<String, dynamic> toJson() {
    String jsonString;
    if(isTimeDelay) {
      jsonString = '''{
        "isTimeDelay" : $isTimeDelay,
        "delayTime" : $delaySeconds
      }''';
    }
    else {
      if(module == null) {
        jsonString = '''{
          "isTimeDelay" : $isTimeDelay
        }''';
      }
      else if(module!.type == Module.ONOFF){
        jsonString = '''{
          "isTimeDelay" : $isTimeDelay,
          "moduleId" : "${module!.moduleId}",
          "valueBool" : $boolValue
        }''';
      }
      else {
        jsonString = '''{
          "isTimeDelay" : $isTimeDelay,
          "moduleId" : "${module!.moduleId}",
          "valueDouble" : $doubleValue
        }''';
      }
    }
    return jsonDecode(jsonString);
  }

  set doubleTarget(double val) => _targetVal = val;
  set boolTarget(bool val) => _targetBool = val;
  set delayTime(double seconds) => delaySeconds = seconds;

  get doubleValue => _targetVal;
  get boolValue => _targetBool;
  get delayValue => delaySeconds;

  void doAction() {
    if(module == null || isTimeDelay) return;
    if(module!.type == Module.SLIDER) {
      module!.setValue = _targetVal;
      module!.sendRequest();
    }
    else if(module!.type == Module.ONOFF) {
      module!.setValue = _targetBool;
      module!.sendRequest();
    }
    else {
      return;
    }
  }
}

class IotActionList {
  List<IotAction> actions = [];

  IotActionList(this.actions);
  IotActionList.fromJson(List<Map<String,dynamic>> jsonList, ModuleList moduleList) {
    for(Map<String,dynamic> jsonData in jsonList) {
      actions.add(IotAction.fromJson(jsonData, moduleList));
    }
  }
  List<Map<String,dynamic>> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for(IotAction action in actions) {
      jsonList.add(action.toJson());
    }
    return jsonList;
  }

  void doActions(ValueNotifier<int> moduleChangeListener) {
    double totalDelay = 0;
    for(IotAction action in actions) {
      if (action.isTimeDelay) totalDelay += action.delayValue;
      Timer(Duration(milliseconds: (totalDelay * 1000).round()), () {
        action.doAction();
        moduleChangeListener.value *= -1;
      });
    }
  }

  String? getDescription() {
    if(actions.isEmpty) {
      return null;
    } else {
      Module? module = actions[0].module;
      String str = "";
      if(actions[0].isTimeDelay) {
        str = "wait ${actions[0].delaySeconds.toStringAsFixed(1)} seconds";
      }
      else if(module == null) {
        return null;
      } else if(module.type == Module.ONOFF) {
        str = "set ${module.moduleName} to ${actions[0].boolValue? "ON" : "OFF"}";
      } else {
        str =  "set ${module.moduleName} is ${module.decimal? actions[0].doubleValue.toStringAsFixed(1): actions[0].doubleValue.round()}${module.unit}";
      }
      if(actions.length > 1) str += "...";
      return str;
    }
  }
}