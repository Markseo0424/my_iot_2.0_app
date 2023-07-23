import 'dart:async';

import 'module.dart';

class IotAction {
  Module? module;
  double _targetVal = 0;
  bool _targetBool = false;

  bool isTimeDelay = false;
  double delaySeconds = 0;

  IotAction(this.module,);

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

  void doActions() {
    double totalDelay = 0;
    for(IotAction action in actions) {
      if (action.isTimeDelay) totalDelay += action.delayValue;
      Timer(Duration(milliseconds: (totalDelay * 1000).round()), () {
        action.doAction();
      });
    }
  }

  String? getDescription() {
    if(actions.isEmpty) return null;
    else {
      Module? module = actions[0].module;
      String str = "";
      if(actions[0].isTimeDelay) {
        str = "wait ${actions[0].delaySeconds.toStringAsFixed(1)} seconds";
      }
      else if(module == null) return null;
      else if(module.type == Module.ONOFF)
        str = "set ${module.moduleName} to ${actions[0].boolValue? "ON" : "OFF"}";
      else
        str =  "set ${module.moduleName} is ${module!.decimal? actions[0].doubleValue.toStringAsFixed(1): actions[0].doubleValue.round()}${module!.unit}";
      if(actions.length > 1) str += "...";
      return str;
    }
  }
}