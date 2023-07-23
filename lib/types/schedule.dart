import 'package:myiot/types/iot_action.dart';
import 'package:myiot/types/iot_condition.dart';

import 'module.dart';

class Schedule {
  IotConditionList conditionList = IotConditionList([]);
  IotActionList actionList = IotActionList([]);
  String scheduleName = "";

  Schedule(this.scheduleName, this.conditionList, this.actionList);

  bool on = false;

  void evaluate() {
    if(!on) return;
    bool evaluation = conditionList.evaluate();
    if(evaluation && conditionList.isOnce) on = false;
    if(evaluation) actionList.doActions();
  }
}

class ScheduleList {
  List<Schedule> scheduleList = [];

  ScheduleList(this.scheduleList);

  void reOrder(List<int> reorderList) {
    List<Schedule> newComp = [];
    for(int i in reorderList) {
      newComp.add(scheduleList[i]);
    }
    scheduleList = newComp;
  }
}