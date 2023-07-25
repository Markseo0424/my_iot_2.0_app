import 'dart:convert';

import 'package:myiot/types/iot_memories.dart';

class Module {
  String moduleName = "";
  String moduleId = "";
  int type = 0;

  static const int ONOFF = 0;
  static const int SLIDER = 1;
  static const int VALUE = 2;

  Module({required this.moduleName, required this.moduleId, required this.type,});
  Module.fromJson(Map<String,dynamic> jsonData) {
    moduleName = jsonData["name"]??"";
    moduleId = jsonData["id"]??"";
    type = jsonData["type"]??0;
    if(type == ONOFF) {
      onOffVal = jsonData["valueBool"]??false;
    }
    else {
      doubleVal = jsonData["valueDouble"]??0;
      valueRange = List<double>.from(jsonData["valueRange"]??<double>[0,100]);
      decimal = jsonData["decimal"]??false;
      unit = jsonData["unit"]??"";
    }
  }
  Map<String, dynamic> toJson() {
    String jsonString;
    if(type == ONOFF) {
      jsonString = '''{
        "name" : "$moduleName",
        "id" : "$moduleId",
        "type" : $type,
        "valueBool" : $onOffVal
      }''';
    }
    else {
      jsonString = '''{
        "name" : "$moduleName",
        "id" : "$moduleId",
        "type" : $type,
        "valueDouble" : $doubleVal,
        "valueRange" : $valueRange,
        "decimal" : $decimal,
        "unit" : "$unit"
      }''';
    }
    return jsonDecode(jsonString);
  }

  bool onOffVal = false;
  double doubleVal = 0;

  get value => (type == ONOFF? onOffVal: doubleVal);
  set setValue(dynamic val) => (type == ONOFF? (onOffVal = val): (doubleVal = val));

  String unit = "";
  set setUnit(String unit) => this.unit = unit;

  List<double> valueRange = [0,100];
  get startVal => valueRange[0];
  get endVal => valueRange[1];
  set setValueRange(List<double> range) => valueRange = range;

  bool decimal = false;
  set setDecimal(bool val) => decimal = val;

  bool sendRequest() {
    if(type==ONOFF){
      print("set $moduleId to $onOffVal");
      IotMemories.memoryUpdate();
      return true;
    }
    else if(type==SLIDER){
      print("set $moduleId to $doubleVal");
      IotMemories.memoryUpdate();
      return true;
    }
    else {
      print("value of $moduleId is $doubleVal");
      IotMemories.memoryUpdate();
      return true;
    }
  }
}

class ModuleList {
  List<Module> comp = [];

  ModuleList(this.comp);
  ModuleList.fromJson(List<Map<String, dynamic>> jsonList) {
    for(Map<String,dynamic> jsonData in jsonList) {
      comp.add(Module.fromJson(jsonData));
    }
  }
  List<Map<String, dynamic>> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for(Module module in comp) {
      jsonList.add(module.toJson());
    }
    return jsonList;
  }

  void reOrder(List<int> reorderList) {
    List<Module> newComp = [];
    for(int i in reorderList) {
      newComp.add(comp[i]);
    }
    comp = newComp;
  }

  Module? findByID(String id) {
    for(Module module in comp) {
      if(module.moduleId == id) {
        return module;
      }
    }
    return null;
  }


  Module? findByName(String name) {
    for(Module module in comp) {
      if(module.moduleName == name) {
        return module;
      }
    }
    return null;
  }
}