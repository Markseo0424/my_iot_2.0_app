// ignore_for_file: overridden_fields, depend_on_referenced_packages, deprecated_member_use

import "dart:async";
import "dart:math";
import "dart:ui";

import "package:flutter/material.dart";
import "package:format/format.dart";
import "package:myiot/components/constants.dart";
import "package:myiot/components/colors.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:myiot/components/custom_slider.dart";
import "package:myiot/types/iot_action.dart";

import "../components/custom_listview.dart";
import "../components/multi_hit_stack.dart";
import "../types/iot_condition.dart";
import "../types/iot_memories.dart";
import "../types/module.dart";
import "../types/schedule.dart";

class ScheduleAddPage extends StatefulWidget {
  final PageController addPageController;
  final PageController addOverPageController;
  final ModuleList moduleList;
  final ScheduleList scheduleList;
  final Schedule schedule;
  final bool isScheduleNew;

  const ScheduleAddPage({Key?key, required this.addPageController, required this.addOverPageController, required this.moduleList, required this.scheduleList, required this.schedule, required this.isScheduleNew}): super(key:key);

  @override
  State<ScheduleAddPage> createState() => _ScheduleAddPageState();
}

class _ScheduleAddPageState extends State<ScheduleAddPage> with TickerProviderStateMixin{
  bool conditionOpen = false;
  bool actionOpen = false;
  bool conditionShow = false;
  bool actionShow = false;
  ValueNotifier<int> changeListener = ValueNotifier(1);
  ScrollController scrollController = ScrollController();
  TextEditingController scheduleNameController = TextEditingController();
  
  IotConditionList conditionList = IotConditionList([]);
  IotActionList actionList = IotActionList([]);

  @override
  void initState(){
    super.initState();
    //print("init");
    if(!widget.isScheduleNew) {
      scheduleNameController = TextEditingController(text: widget.schedule.scheduleName);
      conditionList = IotConditionList.fromJson(widget.schedule.conditionList.toJson(), widget.moduleList);
      actionList = IotActionList.fromJson(widget.schedule.actionList.toJson(), widget.moduleList);
    }

    //print("init ${widget.schedule.scheduleName} ${conditionList.conditions.length}");
  }

  @override
  void dispose() {
    //print("dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(scrollController.hasClients) {
      if (conditionOpen || conditionShow) {
        conditionShow = true;
        scrollController.animateTo(
            150, duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut);
      }
      else if (actionOpen || actionShow) {
        actionShow = true;
        scrollController.animateTo(
            200, duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut);
      }
      else {
        scrollController.animateTo(
            0, duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut);
      }
    }

    return SingleChildScrollView(
      controller: scrollController,
      physics: const NeverScrollableScrollPhysics(),
      child: MultiHitStack(children: [
        Column(children: [
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 315),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 50 + calculateConditionHeight(),
              child: ClipRect(
                  child: TweenAnimationBuilder<double> (
                      tween: Tween<double>(begin: 0, end: (conditionOpen)? 5 : 0),
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      curve: Curves.easeOut,
                      builder: (context, blurValue, _) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue, tileMode: TileMode.mirror),
                          child: Container(),
                        );
                      }
                  )
              ),),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 50 + calculateActionHeight(),
              child: ClipRect(
                  child: TweenAnimationBuilder<double> (
                      tween: Tween<double>(begin: 0, end: (actionOpen)? 5 : 0),
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      curve: Curves.easeOut,
                      builder: (context, blurValue, _) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue, tileMode: TileMode.mirror),
                          child: Container(),
                        );
                      }
                  )
              ),),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: MediaQuery.of(context).size.height - 300 - calculateActionHeight() - calculateConditionHeight(),),
        ],),
        Column(children: [
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut,height: 315, color: Colors.transparent),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 50 + calculateConditionHeight(), color: Colors.black.withOpacity(conditionShow? 0.5: 0)),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: calculateActionHeight() + 50, color: Colors.black.withOpacity(actionShow? 0.5: 0)),
        ],),
        Padding(
            padding: const EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
            ),
            child:
            Column(
              children: [
                Align(alignment: Alignment.topLeft, child: IconButton(
                  onPressed: () {
                    widget.addOverPageController.animateToPage(1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                    Timer(const Duration(milliseconds: 50), (){widget.addPageController.animateToPage(1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                  },
                  icon: SvgPicture.asset(
                    "asset/icon/back.svg",
                    color: const Color(white),
                  )
                  ,iconSize: 30,
                ),),
                SizedBox(height: 105, child: Align(alignment: Alignment.bottomCenter, child: Text(widget.isScheduleNew? "ADD SCHEDULE" : "EDIT SCHEDULE", style: const TextStyle(
                  color: Color(white),
                  fontFamily: "pretendard",
                  fontWeight: FontWeight.w700,
                  fontSize:40,
                  height: 36/40,
                ),),),),
                const SizedBox(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("Schedule Name", style: TextStyle(
                  color: Color(white),
                  fontFamily: "pretendard",
                  fontWeight: FontWeight.w700,
                  fontSize:20,
                  height: 1,
                ),),)),),
                Stack(children:[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    height: 60,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(5, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      curve: Curves.easeOut, height: 60, decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(white).withOpacity(0.15), const Color(white).withOpacity(0.05)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(white).withOpacity(0.3),
                      )
                  ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Center(
                        child: TextField(
                          controller: scheduleNameController,
                          readOnly: conditionOpen || actionOpen,
                          style: pretendard(FontWeight.w700, 24, const Color(white)),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],),
                const SizedBox(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("CONDITIONS", style: TextStyle(
                  color: Color(white),
                  fontFamily: "pretendard",
                  fontWeight: FontWeight.w700,
                  fontSize:20,
                  height: 1,
                ),),)),),
                Stack(children:[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    height: calculateConditionHeight(),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(5, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    height: calculateConditionHeight(),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut, height: calculateConditionHeight(), decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(white).withOpacity(0.15), const Color(white).withOpacity(0.05)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(white).withOpacity(0.3),
                      )
                  ),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: conditionOpen?0:0.2),
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    builder: (_,opacity,__) {
                      return Center(child: Text(conditionList.getDescription()?? "+CONDITION",style: TextStyle(fontFamily: "pretendard", fontWeight: FontWeight.w700, fontSize: 20, color: conditionList.getDescription() == null? const Color(black).withOpacity(opacity) : const Color(white).withOpacity(opacity*5)),),);
                    },
                  )
                  ),
                ],),
                const SizedBox(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("ACTIONS", style: TextStyle(
                  color: Color(white),
                  fontFamily: "pretendard",
                  fontWeight: FontWeight.w700,
                  fontSize:20,
                  height: 1,
                ),),)),),
                Stack(children:[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    height: calculateActionHeight(),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(5, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    height: calculateActionHeight(),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      curve: Curves.easeOut,
                      height: calculateActionHeight(), decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(white).withOpacity(0.15), const Color(white).withOpacity(0.05)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(white).withOpacity(0.3),
                      )
                  ),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: actionOpen?0:0.2),
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      curve: Curves.easeOut,
                      builder: (_,opacity,__) {
                        return Center(child: Text(actionList.getDescription()?? "+ACTION",style: TextStyle(fontFamily: "pretendard", fontWeight: FontWeight.w700, fontSize: 20, color: actionList.getDescription() == null? const Color(black).withOpacity(opacity) : const Color(white).withOpacity(opacity*5)),),);
                      },
                    )
                  ),
                ],),
                SizedBox(height: 90, child: Align(alignment: Alignment.bottomCenter, child: Stack(children:[
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(5, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      String newName = scheduleNameController.value.text;
                      Schedule? foundByName = widget.scheduleList.findByName(newName);
                      String snackBarText = "";
                      if(foundByName != null && foundByName != widget.schedule) {
                        snackBarText = "Same name! Try again.";
                      }
                      else {
                        if (widget.isScheduleNew &&
                            conditionList.conditions.isNotEmpty &&
                            actionList.actions.isNotEmpty) {
                          widget.schedule.scheduleName = newName;
                          widget.schedule.conditionList = conditionList;
                          widget.schedule.actionList = actionList;
                          widget.scheduleList.scheduleList.add(widget.schedule);
                          IotMemories.memoryUpdate();
                          widget.addOverPageController.animateToPage(1,
                              duration: const Duration(
                                  milliseconds: animationDelayMilliseconds),
                              curve: Curves.easeOut);
                          Timer(const Duration(milliseconds: 50), () {
                            widget.addPageController.animateToPage(1,
                                duration: const Duration(
                                    milliseconds: animationDelayMilliseconds),
                                curve: Curves.easeOut);
                          });
                          snackBarText = "Schedule successfully added.";
                        }
                        else if (!widget.isScheduleNew &&
                            conditionList.conditions.isNotEmpty &&
                            actionList.actions.isNotEmpty) {
                          widget.schedule.scheduleName = newName;
                          widget.schedule.conditionList = conditionList;
                          widget.schedule.actionList = actionList;
                          IotMemories.memoryUpdate();
                          widget.addOverPageController.animateToPage(1,
                              duration: const Duration(
                                  milliseconds: animationDelayMilliseconds),
                              curve: Curves.easeOut);
                          Timer(const Duration(milliseconds: 50), () {
                            widget.addPageController.animateToPage(1,
                                duration: const Duration(
                                    milliseconds: animationDelayMilliseconds),
                                curve: Curves.easeOut);
                          });
                          snackBarText = "Schedule successfully edited.";
                        }
                        else {
                          snackBarText = "Condition or Action is not filled.";
                        }
                      }
                      final snackBar = SnackBar(content: Text(snackBarText),);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Container(height: 60, decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(color2).withOpacity(0.5), const Color(color1).withOpacity(0.5)],
                          begin: Alignment.bottomLeft, end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(white).withOpacity(0.3),
                        )
                    ),child: Center(child: Text(widget.isScheduleNew? "ADD SCHEDULE": "EDIT SCHEDULE", style: const TextStyle(
                      color: Color(white),
                      fontFamily: "pretendard",
                      fontWeight: FontWeight.w700,
                      fontSize:24,
                      height: 26/24,
                    ),),),),
                  ),
                ],),),),
                if(!widget.isScheduleNew)
                SizedBox(height: 90, child: Align(alignment: Alignment.bottomCenter, child: Stack(children:[
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          offset: const Offset(5, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 60,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.scheduleList.scheduleList.remove(widget.schedule);
                      IotMemories.memoryUpdate();
                      const snackBar = SnackBar(content: Text("Schedule successfully deleted."),);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      widget.addOverPageController.animateToPage(1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                      Timer(const Duration(milliseconds: 50), () {widget.addPageController.animateToPage(1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                    },
                    child: Container(height: 60, decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(black).withOpacity(0.8), const Color(black).withOpacity(0.5)],
                          begin: Alignment.bottomLeft, end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color(white).withOpacity(0.3),
                        )
                    ),child: const Center(child: Text("DELETE SCHEDULE", style: TextStyle(
                      color: Color(white),
                      fontFamily: "pretendard",
                      fontWeight: FontWeight.w700,
                      fontSize:24,
                      height: 26/24,
                    ),),),),
                  ),
                ],),),),
              ],
            )
        ),
        Column(children: [
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 315, color: Colors.black.withOpacity((conditionShow || actionShow)? 0.5: 0),
              child: Stack(children: [
                if(conditionOpen || actionOpen) GestureDetector(behavior: HitTestBehavior.translucent, onTap: () {
                  setState(() {
                    if(conditionOpen || actionOpen) conditionOpen = false; actionOpen = false;
                  });
                }),
              ],)),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 50 + calculateConditionHeight(), color: Colors.black.withOpacity(actionShow? 0.5: 0),
              child: Stack(children: [
                GestureDetector(behavior: HitTestBehavior.translucent, onTap: () {
                  setState(() {
                    if(!conditionOpen && !actionOpen) conditionOpen = true;
                    if(actionOpen) actionOpen = false;
                  });
                })
              ],)),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: 50 + calculateActionHeight(), color: Colors.black.withOpacity(conditionShow? 0.5: 0),
              child: Stack(children: [
                GestureDetector(behavior: HitTestBehavior.translucent, onTap: () {
                  setState(() {
                    if(!conditionOpen && !actionOpen) actionOpen = true;
                    if(conditionOpen) conditionOpen = false;
                  });
                })
              ],)),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: MediaQuery.of(context).size.height - 200 - calculateActionHeight() - calculateConditionHeight(), color: Colors.black.withOpacity((conditionShow || actionShow)? 0.5: 0),
              child: Stack(children: [
                if(conditionOpen || actionOpen) GestureDetector(behavior: HitTestBehavior.translucent, onTap: () {
                  setState(() {
                    if(conditionOpen || actionOpen) {
                      conditionOpen = false;
                      actionOpen = false;
                    }
                  });
                })
              ],)),
        ],),
        Column(children: [
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut,height: 315,
            child:
            ClipRect(
                child: TweenAnimationBuilder<double> (
                    tween: Tween<double>(begin: 0, end: (conditionOpen || actionOpen)? 5 : 0),
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    builder: (context, blurValue, _) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue, tileMode: TileMode.mirror),
                        child: Container(),
                      );
                    }
                )
            ),),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut,height: 50 + calculateConditionHeight(),
            child: ClipRect(
                child: TweenAnimationBuilder<double> (
                    tween: Tween<double>(begin: 0, end: (actionOpen)? 5 : 0),
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    builder: (context, blurValue, _) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue, tileMode: TileMode.mirror),
                        child: Container(),
                      );
                    }
                )
            ),),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
            curve: Curves.easeOut,height: 50 + calculateActionHeight(),
            child: ClipRect(
                child: TweenAnimationBuilder<double> (
                    tween: Tween<double>(begin: 0, end: (conditionOpen)? 5 : 0),
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    builder: (context, blurValue, _) {
                      return BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue, tileMode: TileMode.mirror),
                        child: Container(),
                      );
                    }
                )
            ),),
          AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,height: MediaQuery.of(context).size.height - 200 - calculateActionHeight() - calculateConditionHeight(),
              child: ClipRect(
                  child: TweenAnimationBuilder<double> (
                      tween: Tween<double>(begin: 0, end: (conditionOpen || actionOpen)? 5 : 0),
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      curve: Curves.easeOut,
                      builder: (context, blurValue, _) {
                        return BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: blurValue, sigmaY: blurValue, tileMode: TileMode.mirror),
                          child: Container(),
                        );
                      }
                  )
              ),),
        ],),
        if(conditionShow)
          AnimatedOpacity(opacity: conditionOpen? 1: 0, duration: Duration(milliseconds: (animationDelayMilliseconds * 0.5).round()), curve: Curves.easeOut, child:
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
            ),
            child:
            Column(
              children: [
                Container(height: 320),
                SizedBox(height: calculateConditionHeight(), child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                  ValueListenableBuilder<int>(
                    valueListenable: changeListener,
                    builder: (context, value, child){
                      //print("rebuild");
                      return CustomListView(
                        bottom: 60,
                        changeListener: changeListener,
                        vsync: this,
                        open: conditionOpen,
                        onClose: () {setState(() {
                          conditionShow = false;
                        });},
                        onReorder: (oldIndex,newIndex) {
                          IotCondition temp = conditionList.conditions[oldIndex];
                          conditionList.conditions.removeAt(oldIndex);
                          conditionList.conditions.insert(newIndex, temp);
                        },
                        onDelete: (Key elementKey) {
                          //print("delete called");
                          for(var element in conditionList.conditions){
                            if(ValueKey(element) == elementKey) {
                              conditionList.conditions.remove(element);
                              break;
                            }
                          }
                          },
                        children: conditionList.conditions.map((condition) => _renderCondition(condition)).toList(),
                      );
                    },
                  ),
                ),
                ),
              ],
            ),
          ),),
        AnimatedPositioned(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
              top: 350 + calculateConditionHeight() - 60, left: 0, right: 0, child:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedOpacity(opacity: conditionOpen? 1: 0, duration: const Duration(milliseconds: animationDelayMilliseconds~/2), child:
              MultiHitStack(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: conditionShow? (){
                      //print("added");
                      conditionList.conditions.add(IotCondition(null));
                      //print(conditionList.conditions.length);
                      changeListener.value *= -1;
                    } : null,
                    child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(),
                          ),
                        )
                    ),
                  ),
                  Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Center(child: Text(
                      "+ CONDITIONS",
                      style: pretendard(FontWeight.w700, 20, const Color(white)),
                    ))
                  ),
                ],
              ),
            ),
          ),
        ),
        if(actionShow)
          AnimatedOpacity(opacity: actionOpen? 1: 0, duration: Duration(milliseconds: (animationDelayMilliseconds * 0.5).round()), curve: Curves.easeOut, child:
          Padding(
            padding: const EdgeInsets.only(
              top: 30,
              left: 15,
              right: 15,
            ),
            child:
            Column(
              children: [
                Container(height: 440),
                SizedBox(height: calculateActionHeight(), child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child:
                  ValueListenableBuilder<int>(
                    valueListenable: changeListener,
                    builder: (context, value, child){
                      //print("rebuild");
                      return CustomListView(
                        bottom: 60,
                        changeListener: changeListener,
                        vsync: this,
                        open: actionOpen,
                        onClose: () {setState(() {
                          actionShow = false;
                        });},
                        onReorder: (oldIndex,newIndex) {
                          IotAction temp = actionList.actions[oldIndex];
                          actionList.actions.removeAt(oldIndex);
                          actionList.actions.insert(newIndex, temp);
                        },
                        onDelete: (Key elementKey) {
                          for(var element in actionList.actions){
                            if(ValueKey(element) == elementKey) {
                              actionList.actions.remove(element);
                              break;
                            }
                          }
                        },
                        children: actionList.actions.map((action) => _renderAction(action)).toList(),
                      );
                    },
                  ),
                ),

                ),
              ],
            ),
          ),),
        AnimatedPositioned(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
          top: 470 + calculateActionHeight() - 60, left: 0, right: 0, child:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: AnimatedOpacity(opacity: actionOpen? 1: 0, duration: const Duration(milliseconds: animationDelayMilliseconds~/2), child:
            MultiHitStack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: actionShow? (){
                    //print("added");
                    actionList.actions.add(IotAction(null));
                    //print(actionList.actions.length);
                    changeListener.value *= -1;
                  } : null,
                  child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(),
                        ),
                      )
                  ),
                ),
                Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                    ),
                    child: Center(child: Text(
                      "+ ACTIONS",
                      style: pretendard(FontWeight.w700, 20, const Color(white)),
                    ))
                ),
              ],
            ),
            ),
          ),
        ),
      ],
    ),
    );
  }

  double calculateConditionHeight() {
    return conditionShow? max(MediaQuery.of(context).size.height - 450, 120) : 60;
  }

  double calculateActionHeight() {
    return actionShow? max(MediaQuery.of(context).size.height - 450, 120) : 60;
  }

  BoxDecoration glassDecoration(Color color1, Color color2, Color color3, {double shadow = 1}) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors:[color1, color2],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
          color: color3,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05*shadow),
          blurRadius: 10,
          offset: const Offset(5,5),
        ),
      ]
    );
  }
  TextStyle pretendard(FontWeight weight, double size, Color color){
    return TextStyle(
      fontFamily: "pretendard",
      fontSize: size,
      fontWeight: weight,
      color: color
    );
  }

  CustomListViewElement _renderCondition(IotCondition condition) {
    bool open = false;
    Module? module = condition.module;
    List<String> weekDays = ["MON","TUE","WED","THU","FRI","SAT","SUN"];

    return CustomListViewElement(key: ValueKey<IotCondition>(condition), closeHeight: condition.isTimeCondition? 120 : 95, openHeight: condition.isTimeCondition? 270 : ((module != null && module.type != Module.ONOFF)? 220 :140), onTap: () {open = !open;},
    child:
    LayoutBuilder(
      builder: (context, constraint) {
        double firstFraction = (module != null)? (condition.minVal - module!.startVal)/(module!.endVal - module!.startVal): 0;
        double secondFraction = (module != null)? (condition.maxVal - module!.startVal)/(module!.endVal - module!.startVal): 1;
        bool checkingWeekDays = false;

        return StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AnimatedPadding(
                  duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: (condition.isTimeCondition)? 0 : 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: (open)?(){
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white.withOpacity(0.8),
                                      scrollable: true,
                                      content: Column(
                                        children: [
                                          Text("Select Module", style: pretendard(FontWeight.w700, 24, const Color(black))),
                                          const SizedBox(height: 15,),
                                          GestureDetector(
                                              behavior: HitTestBehavior.translucent,
                                              onTap: (){
                                                Navigator.pop(context);
                                                setState((){
                                                  condition.isTimeCondition = true;
                                                  changeListener.value *= -1;
                                                });
                                              }, child:
                                            SizedBox(height: 60, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
                                              Expanded(child: Align(alignment: Alignment.centerLeft, child: Text("Time", style: pretendard(FontWeight.w500, 18, const Color(black)),))),
                                            ],)))
                                          ),
                                          ...widget.moduleList.comp.map((element) {
                                            return GestureDetector(
                                                behavior: HitTestBehavior.translucent,
                                                onTap: (){
                                                  Navigator.pop(context);
                                              setState((){
                                                condition.isTimeCondition = false;
                                                condition.setModule = element;
                                                module = element;
                                                if(module!.type != Module.ONOFF) {
                                                  condition.setMin = module!.startVal + min(firstFraction, secondFraction) * (module!.endVal - module!.startVal);
                                                  condition.setMax = module!.startVal + max(firstFraction, secondFraction) * (module!.endVal - module!.startVal);
                                                }
                                                changeListener.value *= -1;
                                              });
                                            }, child:
                                              SizedBox(height: 60, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
                                              Expanded(child: Align(alignment: Alignment.centerLeft, child: Text(element.moduleName, style: pretendard(FontWeight.w500, 18, const Color(black)),))),
                                              Expanded(child: Align(alignment: Alignment.centerRight, child: Text("id: ${element.moduleId}", style: pretendard(FontWeight.w400, 12, const Color(black).withOpacity(0.6)),))),
                                            ],)))
                                            );
                                          })
                                        ],
                                      ),
                                    );
                                  }
                                );
                              }:null,
                              child: AnimatedContainer(
                                  duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,
                                  height: open? 60:35,
                                  decoration: glassDecoration(Colors.white.withOpacity(open? 0.15 : 0), Colors.white.withOpacity(open? 0.05 : 0), Colors.white.withOpacity(open? 0.2: 0), shadow: open?1:0),
                                  child: AnimatedPadding(padding: EdgeInsets.only(left: open? 14 : 0), duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, child: Align(alignment: Alignment.centerLeft, child:
                                  AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(open? FontWeight.w300 : FontWeight.w500, 32, const Color(white)),child: Text(condition.isTimeCondition? "Time" : (module==null? "-" : module!.moduleName)),)))
                              ),
                            ),
                            Container(height: condition.isTimeCondition&&open? 10: 5,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if(!condition.isTimeCondition)
                                  AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(FontWeight.w400, open?24:16, Colors.white.withOpacity(0.6)),child: Text((module == null || (module!.type == Module.ONOFF))? "is" : "is ${module!.decimal? condition.minVal.toStringAsFixed(1): condition.minVal.round()}${module!.unit} to ${module!.decimal? condition.maxVal.toStringAsFixed(1): condition.maxVal.round()}${module!.unit}")),
                                if(!condition.isTimeCondition)
                                  Container(width: 5),
                                if(!condition.isTimeCondition && module != null && module!.type == Module.ONOFF)
                                  GestureDetector(behavior: HitTestBehavior.translucent,
                                    onTap: open? () {
                                      setState(() {
                                        condition.setTarget = !condition.target;
                                      });
                                    } : null, child: AnimatedContainer(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, width: open?55:32, height: open?35:22, decoration: glassDecoration((condition.target? const Color(color2) : Colors.white).withOpacity(open?(condition.target? 0.5 : 0.15):0), (condition.target? const Color(color1) : Colors.white).withOpacity(open?(condition.target? 0.5 : 0.05):0), Colors.white.withOpacity(open?0.2:0),shadow: open?1:0),child:
                                    Center(child: AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, style: pretendard(FontWeight.w400, 16, condition.target||!open? Colors.white.withOpacity(open?1:0.6) : Colors.black.withOpacity(0.4)), child:Text(condition.target? "ON" : "OFF"),))),),
                                if(condition.isTimeCondition)
                                  AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                                    height: open? 100 : 20,
                                    width: 150,
                                    child: Wrap(
                                      runSpacing: 5,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(FontWeight.w400, open?24:16, Colors.white.withOpacity(0.6)),child: const Text("is")),
                                        AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, width:open? 10 : 2),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: open? (){
                                            Future<TimeOfDay?> targetTime = showTimePicker(context: context, initialTime: TimeOfDay(hour: condition.timeRange[0], minute: condition.timeRange[1]),);
                                            targetTime.then((timeOfDay) {
                                              setState((){
                                                if(timeOfDay != null) {
                                                  condition.timeRange[0] =
                                                      timeOfDay.hour;
                                                  condition.timeRange[1] =
                                                      timeOfDay.minute;
                                                }
                                              });
                                            });
                                          }: null,
                                          child: AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                                              width: open? 100:50, height: open?45:20, decoration: glassDecoration(Colors.white.withOpacity(open? 0.15: 0), Colors.white.withOpacity(open? 0.05:0), Colors.white.withOpacity(open? 0.2:0)),child:
                                              Center(
                                                child: AnimatedDefaultTextStyle(duration: const Duration(milliseconds: animationDelayMilliseconds), curve:Curves.easeOut,
                                                  style: pretendard(FontWeight.w400, open? 32 : 16, Colors.white.withOpacity(0.6)), child:
                                                  Text("{:02d}:{:02d}".format(condition.timeRange[0], condition.timeRange[1])),    ),
                                              )
                                          ),
                                        ),
                                        AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, width:open? 10 : 2),
                                        AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(FontWeight.w400, open?24:16, Colors.white.withOpacity(0.6)),child: const Text("to")),
                                        AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, width:open? 7 : 2),
                                        GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTap: (){
                                            Future<TimeOfDay?> targetTime = showTimePicker(context: context, initialTime: TimeOfDay(hour:condition.timeRange[2], minute: condition.timeRange[3]),);
                                            targetTime.then((timeOfDay) {
                                              setState((){
                                                if(timeOfDay != null) {
                                                  condition.timeRange[2] =
                                                      timeOfDay.hour;
                                                  condition.timeRange[3] =
                                                      timeOfDay.minute;
                                                }
                                              });
                                            });
                                          },
                                          child: AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                                              width: open? 100:50, height: open?45:20, decoration: glassDecoration(Colors.white.withOpacity(open? 0.15: 0), Colors.white.withOpacity(open? 0.05:0), Colors.white.withOpacity(open? 0.2:0)),child:
                                              Center(
                                                child: AnimatedDefaultTextStyle(duration: const Duration(milliseconds: animationDelayMilliseconds), curve:Curves.easeOut,
                                                  style: pretendard(FontWeight.w400, open? 32 : 16, Colors.white.withOpacity(0.6)), child:
                                                  Text("{:02d}:{:02d}".format(condition.timeRange[2], condition.timeRange[3])),    ),
                                              )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Align(alignment: Alignment.topRight, child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap:(){
                          setState((){
                            condition.and = !condition.and;
                          });
                        },
                        child: AnimatedContainer(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, width: 80, height: 60, decoration: glassDecoration(Color(condition.and? color2 : color1).withOpacity(0.4), Color(condition.and? color2 : color1).withOpacity(0.2), Color(condition.and? color2 : color1).withOpacity(0.8)),child:
                        Center(child: Text(condition.and? "AND" : "OR", style: pretendard(FontWeight.w400, 24, Colors.white)))),
                      )),
                    ],),
                ),
                AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, height: (module != null && module!.type != Module.ONOFF && open)? 80 : 0, child:
                    Padding(padding: const EdgeInsets.only(left: 15, right: 15,), child: FractionallySizedBox(widthFactor: 1, heightFactor: 0.8, child:
                      MultiHitStack(children: [
                        Center(child: FractionallySizedBox(heightFactor: 0.6, widthFactor: 0.95, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.black.withOpacity(0.2))))),
                        Center(
                          child: FractionallySizedBox(heightFactor: 0.6,widthFactor: 0.95,
                            child: ClipPath(
                              clipper: SliderDoubleClipper(fraction1: firstFraction, fraction2: secondFraction),
                              child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(
                                colors: [Color(color2), Color(color1)],
                                begin: Alignment.centerLeft, end: Alignment.centerRight,
                              ))),
                            )
                          ),
                        ),
                        if(module != null && module!.type != Module.ONOFF && open)
                          CustomSlider(initFraction: firstFraction, right: 64.0,
                          onChange: (fraction){
                            setState((){
                              firstFraction = fraction;
                              if(firstFraction < secondFraction) {
                                condition.setMin = module!.startVal + fraction * (module!.endVal - module!.startVal);
                              } else {
                                condition.setMax = module!.startVal + fraction * (module!.endVal - module!.startVal);
                              }
                            });
                          }, handle: AspectRatio(aspectRatio: 1, child: FractionallySizedBox(widthFactor: 0.8, heightFactor: 0.8, child:
                          Container(decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ColorTween(begin: const Color(color2), end: const Color(color1)).transform(firstFraction),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(5,5),
                              )
                            ],
                          ),)
                        )),),
                        if(module != null && module!.type != Module.ONOFF && open)
                          CustomSlider(initFraction: secondFraction, right: 64.0,
                            onChange: (fraction){
                              setState((){
                                secondFraction = fraction;
                                if(firstFraction < secondFraction) {
                                  condition.setMax = module!.startVal + fraction * (module!.endVal - module!.startVal);
                                } else {
                                  condition.setMin = module!.startVal + fraction * (module!.endVal - module!.startVal);
                                }
                              });
                            }, handle: AspectRatio(aspectRatio: 1, child: FractionallySizedBox(widthFactor: 0.8, heightFactor: 0.8, child:
                            Container(decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: ColorTween(begin: const Color(color2), end: const Color(color1)).transform(secondFraction),
                              boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(5,5),
                              )
                            ],
                            ),)
                            )),),
                      ],),
                    )),
                  ),
                AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds~/2), curve: Curves.easeOut, height: condition.isTimeCondition&&open? 80:0, child:
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          ...weekDays.map((weekDay) {
                            int index = weekDays.indexOf(weekDay);
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: GestureDetector(
                                  onTap: (){
                                    setState((){
                                      condition.weekDays[index] = !condition.weekDays[index];
                                    });
                                  },
                                  onHorizontalDragStart: (info){
                                    checkingWeekDays = !condition.weekDays[index];
                                  },
                                  onHorizontalDragUpdate: (info){
                                    double position = info.globalPosition.dx - 30;
                                    double range = constraint.maxWidth - 30;
                                    int changeIndex = position ~/ (range/7);
                                    if(changeIndex < 0) {
                                      changeIndex = 0;
                                    } else if(changeIndex > 6) {
                                      changeIndex = 6;
                                    }

                                    setState((){
                                      condition.weekDays[changeIndex] = checkingWeekDays;
                                    });
                                  },
                                  onHorizontalDragEnd: (info) {
                                  },
                                  child: Container(
                                    height: 45,
                                    decoration: glassDecoration(condition.weekDays[index]? const Color(color1).withOpacity(0.7) : Colors.white.withOpacity(0.15), condition.weekDays[index]? const Color(color2).withOpacity(0.7) : Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.2)),
                                    child: Center(child: AnimatedDefaultTextStyle(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                                        style: pretendard(FontWeight.w400, 16, condition.weekDays[index]? Colors.white : const Color(black)), child: Text(weekDay))),
                                  ),
                                ),
                              ),
                            );
                          })
                        ],
                      ),
                    )
                ),
                AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, height: (!condition.isTimeCondition || open)? 0 : 35 ,child:
                Padding(
                  padding: const EdgeInsets.only(left: 15, bottom: 15),
                  child: Align(alignment: Alignment.topLeft, child: Text(condition.weekDayString(), style: pretendard(FontWeight.w400, 16, Colors.white.withOpacity(0.6)),)),
                ),
                ),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Container(decoration: glassDecoration(Colors.transparent, Colors.transparent, Colors.white.withOpacity(0.2), shadow: 0)),)
              ],
            ),
          );
        });
      },
    ) );
  }

  CustomListViewElement _renderAction(IotAction action) {
    bool open = false;
    Module? module = action.module;

    return CustomListViewElement(key: ValueKey<IotAction>(action), closeHeight: action.isTimeDelay? 60 : 95, openHeight: action.isTimeDelay? 105 : ((module != null && module.type != Module.ONOFF)? 220 :140), onTap: () {open = !open;},
        child:
        LayoutBuilder(
          builder: (context, constraint) {
            double fraction = (module != null)? (action.doubleValue - module!.startVal)/(module!.endVal - module!.startVal): 1;

            return StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedPadding(
                      duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                      padding: const EdgeInsets.all(15),
                      child:
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 60, maxWidth: double.infinity),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: (open)?(){
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.white.withOpacity(0.8),
                                              scrollable: true,
                                              content: Column(
                                                children: [
                                                  Text("Select Module", style: pretendard(FontWeight.w700, 24, const Color(black))),
                                                  const SizedBox(height: 15,),
                                                  GestureDetector(
                                                      behavior: HitTestBehavior.translucent,
                                                      onTap: (){
                                                        Navigator.pop(context);
                                                        setState((){
                                                          action.isTimeDelay = true;
                                                          changeListener.value *= -1;
                                                        });
                                                      }, child:
                                                  SizedBox(height: 60, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
                                                    Expanded(child: Row(children: [
                                                      Expanded(child: Align(alignment: Alignment.centerLeft, child: Text("wait", style: pretendard(FontWeight.w500, 18, const Color(black)),))),
                                                      Expanded(child: Align(alignment: Alignment.centerRight, child: Text("Time Delay", style: pretendard(FontWeight.w400, 12, const Color(black).withOpacity(0.6)),))),
                                                    ],)),
                                                  ],)))
                                                  ),
                                                  ...widget.moduleList.comp.where((element) => element.type != Module.VALUE).map((element) {
                                                    return GestureDetector(
                                                        behavior: HitTestBehavior.translucent,
                                                        onTap: (){
                                                          Navigator.pop(context);
                                                          setState((){
                                                            action.isTimeDelay = false;
                                                            action.module = element;
                                                            module = element;
                                                            if(module!.type != Module.ONOFF) {
                                                              action.doubleTarget = module!.startVal + fraction * (module!.endVal - module!.startVal);
                                                            }
                                                            changeListener.value *= -1;
                                                          });
                                                        }, child:
                                                    SizedBox(height: 60, child: Padding(padding: const EdgeInsets.all(15), child: Row(children: [
                                                      Expanded(child: Align(alignment: Alignment.centerLeft, child: Text(element.moduleName, style: pretendard(FontWeight.w500, 18, const Color(black)),))),
                                                      Expanded(child: Align(alignment: Alignment.centerRight, child: Text("id: ${element.moduleId}", style: pretendard(FontWeight.w400, 12, const Color(black).withOpacity(0.6)),))),
                                                    ],)))
                                                    );
                                                  })
                                                ],
                                              ),
                                            );
                                          }
                                      );
                                    }:null,
                                    child: AnimatedContainer(
                                        duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,
                                        height: open? 60: (action.isTimeDelay? 20 :35),
                                        width: action.isTimeDelay? (open? 95 : 40) : MediaQuery.of(context).size.width - 60,
                                        decoration: glassDecoration(Colors.white.withOpacity(open? 0.15 : 0), Colors.white.withOpacity(open? 0.05 : 0), Colors.white.withOpacity(open? 0.2: 0), shadow: open?1:0),
                                        child: AnimatedPadding(padding: EdgeInsets.only(left: open? 14 : 0), duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, child: Align(alignment: Alignment.centerLeft, child:
                                        AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(open? FontWeight.w300 : (action.isTimeDelay? FontWeight.w400: FontWeight.w500), open || !action.isTimeDelay? 32 : 16, const Color(white).withOpacity(open || !action.isTimeDelay? 1 : 0.6)),child: Text(action.isTimeDelay? "wait" : (module==null? "-" : module!.moduleName)),)))
                                    ),
                                  ),
                                  if(action.isTimeDelay)
                                    AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, width: open? 10 :0),
                                  if(action.isTimeDelay)
                                    GestureDetector(
                                      onTap: (open)?(){
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              TextEditingController controller = TextEditingController(text: action.delaySeconds.toStringAsFixed(1));
                                              return AlertDialog(
                                                backgroundColor: Colors.white.withOpacity(0.8),
                                                scrollable: true,
                                                content: Column(
                                                  children: [
                                                    const Text("write time delay"),
                                                    TextField(
                                                      controller: controller,
                                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                                    ),
                                                    const SizedBox(height: 10),
                                                    ElevatedButton(onPressed: (){
                                                      Navigator.pop(context);
                                                      setState((){
                                                        String inputText = controller.value.text;
                                                        try{
                                                          double value = double.parse(inputText);
                                                          action.delaySeconds = value;
                                                        }
                                                        catch(e) {
                                                          return;
                                                        }
                                                      });
                                                    }, child: const Text("OK")),
                                                  ],
                                                ),
                                              );
                                            }
                                        );
                                      }:null,
                                      child: AnimatedContainer(
                                          duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,
                                          height: open? 60: (action.isTimeDelay? 20 :35),
                                          width: open? (28 + 15.0 * action.delaySeconds.toStringAsFixed(1).length) : (10.0 * action.delaySeconds.toStringAsFixed(1).length),
                                          decoration: glassDecoration(Colors.white.withOpacity(open? 0.15 : 0), Colors.white.withOpacity(open? 0.05 : 0), Colors.white.withOpacity(open? 0.2: 0), shadow: open?1:0),
                                          child: AnimatedPadding(padding: EdgeInsets.only(left: open? 14 : 0), duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, child: Align(alignment: Alignment.centerLeft, child:
                                          AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(open? FontWeight.w300 : FontWeight.w400, open? 32 : 16, const Color(white).withOpacity(open? 1 : 0.6)),child: Text((action.delaySeconds).toStringAsFixed(1)))))
                                      ),
                                    ),
                                  if(action.isTimeDelay)
                                    AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, width: open? 10 :0),
                                  if(action.isTimeDelay)
                                    AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(open? FontWeight.w300 : FontWeight.w400, open? 32 : 16, const Color(white).withOpacity(open? 1 : 0.6)),child: const Text("seconds")),
                                ],
                              ),
                              Container(height: 5,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if(!action.isTimeDelay)
                                    AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut,style: pretendard(FontWeight.w400, open?24:16, Colors.white.withOpacity(0.6)),child: Text((module == null || (module!.type == Module.ONOFF))? "to" : "to ${module!.decimal? action.doubleValue.toStringAsFixed(1): action.doubleValue.round()}${module!.unit}")),
                                  if(!action.isTimeDelay)
                                    Container(width: 5),
                                  if(!action.isTimeDelay && module != null && module!.type == Module.ONOFF)
                                    GestureDetector(behavior: HitTestBehavior.translucent,
                                      onTap: open? () {
                                        setState(() {
                                          action.boolTarget = !action.boolValue;
                                        });
                                      } : null, child: AnimatedContainer(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, width: open?55:32, height: open?35:22, decoration: glassDecoration((action.boolValue? const Color(color2) : Colors.white).withOpacity(open?(action.boolValue? 0.5 : 0.15):0), (action.boolValue? const Color(color1) : Colors.white).withOpacity(open?(action.boolValue? 0.5 : 0.05):0), Colors.white.withOpacity(open?0.2:0),shadow: open?1:0),child:
                                      Center(child: AnimatedDefaultTextStyle(duration:const Duration(milliseconds: animationDelayMilliseconds),curve:Curves.easeOut, style: pretendard(FontWeight.w400, 16, action.boolValue||!open? Colors.white.withOpacity(open?1:0.6) : Colors.black.withOpacity(0.4)), child:Text(action.boolValue? "ON" : "OFF"),))),),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, height: (module != null && module!.type != Module.ONOFF && open)? 80 : 0, child:
                    Padding(padding: const EdgeInsets.only(left: 15, right: 15,), child: FractionallySizedBox(widthFactor: 1, heightFactor: 0.8, child:
                    MultiHitStack(children: [
                      Center(child: FractionallySizedBox(heightFactor: 0.6, widthFactor: 0.95, child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.black.withOpacity(0.2))))),
                      Center(
                        child: FractionallySizedBox(heightFactor: 0.6,widthFactor: 0.95,
                            child: ClipPath(
                              clipper: SliderDoubleClipper(fraction1: 0, fraction2: fraction),
                              child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), gradient: const LinearGradient(
                                colors: [Color(color2), Color(color1)],
                                begin: Alignment.centerLeft, end: Alignment.centerRight,
                              ))),
                            )
                        ),
                      ),
                      if(module != null && module!.type != Module.ONOFF && open)
                        CustomSlider(initFraction: fraction, right: 64.0,
                          onChange: (newFraction){
                            setState((){
                              fraction = newFraction;
                              action.doubleTarget = module!.startVal + fraction * (module!.endVal - module!.startVal);
                            });
                          }, handle: AspectRatio(aspectRatio: 1, child: FractionallySizedBox(widthFactor: 0.8, heightFactor: 0.8, child:
                          Container(decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: ColorTween(begin: const Color(color2), end: const Color(color1)).transform(fraction),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(5,5),
                              )
                            ],
                          ),)
                          )),),
                    ],),
                    )),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Container(decoration: glassDecoration(Colors.transparent, Colors.transparent, Colors.white.withOpacity(0.2), shadow: 0)),)
                  ],
                ),
              );
            });
          },
        ) );
  }
}


class SliderDoubleClipper extends CustomClipper<Path> {
  double fraction1;
  double fraction2;

  SliderDoubleClipper({this.fraction1 = 0, this.fraction2 = 1});

  @override
  Path getClip(Size size) {
    double minFraction = min(fraction1, fraction2);
    double maxFraction = max(fraction1, fraction2);
    Path path = Path();
    path.moveTo(size.width * minFraction, 0);
    path.lineTo(size.width * minFraction, size.height);
    path.lineTo(size.width * maxFraction, size.height);
    path.lineTo(size.width * maxFraction, 0);
    path.lineTo(0,0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}