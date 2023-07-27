import 'dart:convert';
import 'dart:math';

import 'package:format/format.dart';

import 'module.dart';

class IotCondition {
  Module? _module;
  List<double> _boundValue = <double>[0,100];
  bool _targetValue = false;
  bool isTimeCondition = false;

  IotCondition(this._module);
  IotCondition.fromJson(Map<String, dynamic> jsonData, ModuleList moduleList) {
    isTimeCondition = jsonData["isTimeCondition"]??false;
    and = jsonData["and"]??0;
    if(isTimeCondition) {
      timeRange = List<int>.from(jsonData["time"]["timeRange"]??[0,0,24,0]);
      weekDays = List<bool>.from(jsonData["time"]["days"]??[false,false,false,false,false,false,false]);
    }
    else {
      _module = moduleList.findByID(jsonData["module"]?["moduleId"]??"");
      if(_module == null) return;
      if(_module!.type == Module.ONOFF) {
        _targetValue = jsonData["module"]?["targetBool"]??false;
      }
      else {
        _boundValue = jsonData["module"]?["targetRange"]??<double>[0,100];
      }
    }
  }
  Map<String, dynamic> toJson() {
    String jsonString;
    if(isTimeCondition) {
      jsonString = '''{
        "isTimeCondition" : $isTimeCondition,
        "and" : $and,
        "time" : {
          "timeRange" : $timeRange,
          "days" : $weekDays
         }
      }''';
    }
    else {
      if(_module == null) {
        jsonString = '''{
        "isTimeCondition" : $isTimeCondition,
        "and" : $and
      }''';
      }
      else if(_module!.type == Module.ONOFF) {
        jsonString = '''{
          "isTimeCondition" : $isTimeCondition,
          "and" : $and,
          "module" : {
            "moduleId" : "${_module!.moduleId}",
            "targetBool" : $_targetValue
          }
        }''';
      }
      else {
        jsonString = '''{
          "isTimeCondition" : $isTimeCondition,
          "and" : $and,
          "module" : {
            "moduleId" : "${_module!.moduleId}",
            "targetRange" : $_boundValue
          }
        }''';
      }
    }
    return jsonDecode(jsonString);
  }


  List<int> timeRange = [0,0,24,0];
  List<bool> weekDays = [false,false,false,false,false,false,false]; //mon tue wed ...

  bool and = false; //or

  get module => _module;
  set setModule(Module module) {
    _module = module;
    _boundValue[0] = module.startVal;
    _boundValue[1] = module.endVal;
  }

  get target => _targetValue;
  get minVal => _boundValue[0];
  get maxVal => _boundValue[1];

  set setBound(List<double> bounds) => _boundValue = bounds;
  set setMin(double val) => _boundValue[0] = val;
  set setMax(double val) => _boundValue[1] = val;

  set setTarget(bool val) => _targetValue = val;

  bool evaluate(){
    if(isTimeCondition) {
      //print("time condition");
      DateTime nowTime = DateTime.now();
      if(!ListCompare(weekDays, [false,false,false,false,false,false,false]) && !weekDays[nowTime.weekday]) return false;
      if(timeRange[0] > timeRange[2]) return false;
      if(timeRange[0] == timeRange[2] && timeRange[1] > timeRange[3]) return false;
      if(nowTime.hour > timeRange[0] && nowTime.hour < timeRange[2]) return true;
      if(nowTime.hour == timeRange[0] && nowTime.minute >= timeRange[1]) return true;
      if(nowTime.hour == timeRange[2] && nowTime.minute <= timeRange[3]) return true;
      return false;
    }
    if(_module == null) return false;
    if(_module!.type == Module.ONOFF) {
      return _module!.value == _targetValue;
    }
    if(!_module!.decimal)
      return (_module!.doubleVal.round() <= _boundValue![1].round() && _module!.doubleVal.round() >= _boundValue![0].round());
    else
      return (_module!.value <= _boundValue![1] && _module!.value >= _boundValue![0]);
  }

  String weekDayString() {
    if(ListCompare<bool>(weekDays, [false,false,false,false,false,false,false])) {
      return "once";
    }
    else if(ListCompare<bool>(weekDays, [false,false,false,false,false,true,true])) {
      return "weekends";
    }
    else if(ListCompare<bool>(weekDays, [true,true,true,true,true,false,false])) {
      return "weekdays";
    }
    else if(ListCompare<bool>(weekDays, [true,true,true,true,true,true,true])) {
      return "everyday";
    }
    else {
      List<String> weekDaysNames = ["mon", "tue", "wed", "thu", 'fri', 'sat','sun'];
      String result = weekDaysNames.where((element) => weekDays[weekDaysNames.indexOf(element)]).toString();
      return result.substring(1,result.length - 1);
    }
  }

  bool ListCompare<T>(List<T> firstList, List<T> secondList) {
    bool result = true;
    for(int i = 0; i < firstList.length; i++) {
      if(firstList[i] != secondList[i]) result = false;
    }
    return result;
  }

}

class IotConditionList {
  List<IotCondition> conditions = [];
  bool _once = false;

  get isOnce => _once;
  IotConditionList(this.conditions);
  IotConditionList.fromJson(List<Map<String,dynamic>> jsonList, ModuleList moduleList) {
    for(Map<String,dynamic> jsonData in jsonList) {
      conditions.add(IotCondition.fromJson(jsonData, moduleList));
    }
  }
  List<Map<String,dynamic>> toJson() {
    List<Map<String, dynamic>> jsonList = [];
    for(IotCondition condition in conditions) {
      jsonList.add(condition.toJson());
    }
    return jsonList;
  }

  bool evaluate() {
    bool previousAnd = false;
    bool skip = false;
    bool evaluation = false;
    List<IotCondition> stack = [];

    for(int i = 0; i < conditions.length; i++) {
      bool conditionEvaluation = conditions[i].evaluate();
      bool conditionAnd = conditions[i].and;
      //print("condition $i : $conditionEvaluation");
      if(conditionEvaluation && !skip) stack.add(conditions[i]);

      if(previousAnd == false) {
        if(conditionAnd == false && conditionEvaluation == true) {
          evaluation = true;
          break;
        } else if(conditionAnd == false && conditionEvaluation == false) null;
        else if(conditionAnd == true && conditionEvaluation == true) evaluation |= true;
        else if(conditionAnd == true && conditionEvaluation == false) {
          evaluation = false;
          skip = true;
        }
      }
      else {
        if(conditionAnd == false && conditionEvaluation == true) {
          if(skip) skip = false;
          else {
            evaluation = true;
            break;
          }
        }
        else if(conditionAnd == false && conditionEvaluation == false) evaluation = false;
        else if(conditionAnd == true && conditionEvaluation == true && !skip) evaluation |= true;
        else if(conditionAnd == true && conditionEvaluation == false && !skip) {
          evaluation = false;
          skip = true;
        }
      }

      if(skip) stack.clear();
      previousAnd = conditionAnd;
    }

    _once = false;
    for(IotCondition condition in stack) {
      if(condition.isTimeCondition && condition.weekDays.reduce((a,b) => a || b) == false) _once = true;
      //print("once : ${_once}");
    }

    return evaluation;
  }

  String? getDescription() {
    if(conditions.isEmpty) return null;
    else {
      Module? module = conditions[0].module;
      String str = "";
      if(conditions[0].isTimeCondition) {
        str = "when time is {:02d}:{:02d} to {:02d}:{:02d}".format(conditions[0].timeRange[0], conditions[0].timeRange[1], conditions[0].timeRange[2], conditions[0].timeRange[3]);
      }
      else if(module == null) return null;
      else if(module.type == Module.ONOFF)
        str = "when ${module.moduleName} is ${conditions[0].target? "ON" : "OFF"}";
      else
        str =  "when ${module.moduleName} is ${module!.decimal? conditions[0].minVal.toStringAsFixed(1): conditions[0].minVal.round()}${module!.unit} to ${module!.decimal? conditions[0].maxVal.toStringAsFixed(1): conditions[0].maxVal.round()}${module!.unit}";
      if(conditions.length > 1) str += "...";
      return str;
    }

  }
}