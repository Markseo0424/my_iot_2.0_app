import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:myiot/components/constants.dart';
import 'package:myiot/components/custom_appbar.dart';
import 'package:myiot/components/multi_hit_stack.dart';
import 'package:myiot/pages/module_add_page.dart';
import 'package:myiot/pages/module_page.dart';
import 'package:myiot/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myiot/pages/setting_page.dart';
import 'package:myiot/types/iot_action.dart';
import 'package:myiot/types/iot_condition.dart';

import '../pages/schedule_add_page.dart';
import '../pages/schedule_page.dart';
import '../types/module.dart';
import '../types/schedule.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin{
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


  Schedule paramSchedule = Schedule("", IotConditionList([]), IotActionList([]));
  bool isScheduleNew = true;

  Module paramModule = Module(moduleName: "", moduleId: "", type: Module.ONOFF);
  bool isModuleNew = true;

  ValueNotifier<int> moduleChangeListener = ValueNotifier(1);

  final PageController pageController = PageController();
  final PageController addPageController = PageController(initialPage: 1);
  final PageController addPageOverController = PageController(initialPage: 1);

  double vT = -200;
  double hT = 0;
  double scale = 1;
  double angle = -0.15;
  bool scrollable = false;
  double appbarHeight = 80;
  double appbarRadius = 50;
  bool moduleEditable = false;
  bool scheduleEditable = false;

  double? page;
  int memorizePage = 0;
  double? addPage;

  @override
  void initState() {
    super.initState();
    pageController.addListener(pageListener);
    addPageController.addListener(addPageListener);
  }

  pageListener() {
    setState(() {
      page = pageController.page;
      if((page??0) % 1 != 0) {
        moduleEditable = false;
        scheduleEditable = false;
      }
      memorizePage = (page??0).round();
    });
  }

  addPageListener() {
    setState(() {
      addPage = addPageController.page;
      if((addPage??0) != 1) {
        if(pageController.hasClients)
          pageController.jumpToPage(memorizePage);
        moduleEditable = false;
        scheduleEditable = false;
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.removeListener(pageListener);
    addPageController.removeListener(addPageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scale = 2 * MediaQuery.of(context).size.width/300;
    vT = 350 * ((scale - 1)* 0.2+1) - MediaQuery.of(context).size.width - MediaQuery.of(context).size.height/2;
    hT = 40 * scale * (1 - (page??0) * 2);
    angle = -0.15 + 3*(page??0)/4;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: MultiHitStack(
            clipBehavior: Clip.none,
            children: [
              PageView(
                controller: addPageController,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  Stack(
                    children: [
                      Container(color: const Color(white)),
                      Container(
                        transform: Matrix4.identity()
                          ..translate(hT,vT + MediaQuery.of(context).size.height),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 0),
                          curve: Curves.easeOut,
                          scale: scale,
                          child: AnimatedRotation(
                            curve: Curves.easeOut,
                            turns: angle,
                            duration: const Duration(milliseconds: 0),
                            child: Center(
                              child: UnconstrainedBox(
                                child: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(150),
                                    ),
                                    gradient: LinearGradient(
                                      colors: <Color>[Color(color1), Color(color2)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        transform: Matrix4.identity()
                          ..translate(-hT,vT),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 0),
                          curve: Curves.easeOut,
                          scale: scale,
                          child: AnimatedRotation(
                            curve: Curves.easeOut,
                            turns: angle-0.2,
                            duration: const Duration(milliseconds: 0),
                            child: Center(
                              child: UnconstrainedBox(
                                child: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(150),
                                    ),
                                    gradient: LinearGradient(
                                      colors: <Color>[Color(color1), Color(color2)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(color: const Color(0xFFEBEBEB)),
                      Container(
                        transform: Matrix4.identity()
                          ..translate(hT,vT),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 0),
                          curve: Curves.easeOut,
                          scale: scale,
                          child: AnimatedRotation(
                            curve: Curves.easeOut,
                            turns: angle,
                            duration: const Duration(milliseconds: 0),
                            child: Center(
                              child: UnconstrainedBox(
                                child: Container(
                                  width: 300,
                                  height: 300,
                                  decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(150),
                                    ),
                                    gradient: LinearGradient(
                                      colors: <Color>[Color(color1), Color(color2)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Expanded(child: PageView(
                            scrollDirection: Axis.horizontal,
                            controller: pageController,
                            children: [
                              ModulePage(page: (page??0),isEditable: moduleEditable, moduleList: moduleList,moduleChangeListener: moduleChangeListener, onEditModule: (module) {
                                //print("edit mdule");
                                paramModule = module;
                                isModuleNew = false;
                                addPageController.animateToPage(2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                                Timer(Duration(milliseconds: 50), () {addPageOverController.animateToPage(2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                              }),
                              SchedulePage(page: -1 + (page??0),isEditable: scheduleEditable, scheduleList: scheduleList,onEditSchedule: (schedule) {
                                paramSchedule = schedule;
                                isScheduleNew = false;
                                addPageController.animateToPage(2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                                Timer(Duration(milliseconds: 50), () {addPageOverController.animateToPage(2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                              },),
                            ],
                          ),),
                          CustomAppBar(height: 80, radius: 50, isHorizontal: true, page: (page??0), controller: pageController,),
                        ],
                      ),
                      Container(
                        height: 150,
                        margin: const EdgeInsets.only(
                          bottom: 30,
                          left: 15,
                          right: 15,
                        ),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: PopupMenuButton<int>(
                            icon: SvgPicture.asset(
                              'asset/icon/more.svg',
                              color: const Color(white),
                            ),
                            iconSize: 50,
                            onSelected: (value) {
                              if(value == 0) {
                                setState(() {
                                  moduleEditable = !moduleEditable;
                                  scheduleEditable = !scheduleEditable;
                                });
                              }
                              else if(value == 2) {
                                scheduleList.evaluateSchedules(moduleChangeListener);
                              }
                              else {
                                addPageController.animateToPage(0,duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                                Timer(Duration(milliseconds: 50), () => addPageOverController.animateToPage(0,duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut));
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<int>> [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text('${moduleEditable || scheduleEditable? "save" : "edit"} ${(page??0)==0? "MODULES": "SCHEDULES"}', style: pretendard(FontWeight.w700, 16, Color(black)),),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text('settings', style: pretendard(FontWeight.w700, 16, Color(black))),
                              ),
                              if((page??0) == 1)
                                PopupMenuItem<int>(
                                  value: 2,
                                  child: Text('evaluate schedules', style: pretendard(FontWeight.w700, 16, Color(black))),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(color: Color(white),),
                ],
              ),
              Positioned(
                bottom: appbarHeight - appbarRadius + MediaQuery.of(context).size.height * ((addPage??1)-1),
                left: 0,
                right: 0,
                child:
                  Transform.translate(
                  offset: Offset(0,260 * ((addPage??1)-1)),
                  child:
                  Transform.scale(
                    scale: (1 + 6 * max(0,(addPage??1)-1)) * ((addPage == 1 || addPage == null)? 1 : 1 + max(0,addPage!-1) * (sqrt(MediaQuery.of(context).size.width/300)-1)),
                    child: Center(
                      child:
                      GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if(memorizePage == 0) {
                            paramModule = Module(moduleId: "", moduleName: "", type: 0);
                            isModuleNew = true;
                          }
                          else {
                            paramSchedule = Schedule("", IotConditionList([]),
                                IotActionList([]));
                            isScheduleNew = true;
                          }
                          addPageController.animateTo(MediaQuery.of(context).size.height*2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                          Timer(Duration(milliseconds: 50), () {addPageOverController.animateTo(MediaQuery.of(context).size.height*2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                        },
                        child: Container(
                          width: appbarRadius*2,
                          height: appbarRadius*2,
                          transform: Matrix4.identity()..translate(appbarRadius,appbarRadius)..rotateZ(-pi*(page??0))..translate(-appbarRadius,-appbarRadius),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(appbarRadius),
                              gradient: const LinearGradient(
                                colors: [Color(color1), Color(color2)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                transform: GradientRotation(pi/4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: Offset(0,0),
                                ),
                              ],
                            ),
                            child: Transform.translate(offset: Offset(0,((page??0) == 1? 1 : -1) * 80*((addPage??1)-1)), child:
                            Center(
                              child: IconButton(
                                onPressed: () {
                                  if(memorizePage == 0) {
                                    paramModule = Module(moduleId: "", moduleName: "", type: 0);
                                    isModuleNew = true;
                                  }
                                  else {
                                    paramSchedule = Schedule("", IotConditionList([]),
                                      IotActionList([]));
                                    isScheduleNew = true;
                                  }
                                  addPageController.animateToPage(2, duration:Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                                  Timer(Duration(milliseconds: 50), () {addPageOverController.animateToPage(2, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                                },
                                icon: SvgPicture.asset("asset/icon/add.svg",
                                  color: const Color(white),),
                                iconSize: appbarRadius*1.2 / (1 + 6*max(0,(addPage??1)-1)),
                              ),
                            ),),
                          ),
                        ),
                      ),
                    ),
                  )),
              ),
              PageView(
                  controller: addPageOverController,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  children: [
                    SettingPage(addPageController: addPageController, addOverPageController: addPageOverController, page: page),
                    Container(),
                    if(memorizePage == 0) ModuleAddPage(addPageController: addPageController, addOverPageController: addPageOverController, moduleList: moduleList, module:  paramModule, isModuleNew: isModuleNew,)
                    else ScheduleAddPage(addPageController: addPageController, addOverPageController: addPageOverController, moduleList: moduleList,scheduleList: scheduleList, schedule: paramSchedule, isScheduleNew: isScheduleNew,),
                  ],
              ),
            ],
        ),
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
}