import 'dart:math';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:myiot/components/constants.dart';
import 'package:myiot/components/custom_grid.dart';
import 'package:myiot/components/colors.dart';
import 'package:myiot/components/custom_slider.dart';
import 'package:flutter/material.dart';
import 'package:myiot/types/iot_memories.dart';

import '../types/schedule.dart';

class SchedulePage extends StatefulWidget {
  final double page;
  final bool isEditable;
  final ScheduleList scheduleList;
  final void Function(Schedule clickedSchedule) onEditSchedule;
  
  const SchedulePage({
    required this.page,
    required this.isEditable,
    Key? key, required this.scheduleList, required this.onEditSchedule,
  }) : super(key:key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {

  bool mainOn = true;
  bool subOn = false;
  double currentVal = 20;
  double currentHum = 60.4;

  @override
  void initState() {
    super.initState();
    //print("init HomeScreen");
  }

  @override
  Widget build(BuildContext context) {
    //print("build HomeScreen with $mainOn, $subOn");

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            height: 150,
            transform: Matrix4.identity()..rotateZ(-widget.page*0.5)..translate(-100*widget.page),
            margin: const EdgeInsets.only(
              bottom: 30,
              left: 15,
              right: 15,
            ),
            child: const Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                    "SCHEDULES",
                    style: TextStyle(
                      fontFamily: "pretendard",
                      color: Color(white),
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                    )
                )
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 180),
            child: CustomGrid(
              isSquare: false,
              hGridStandard: 400,
              vGridStandard: 100,
              page: widget.page,
              reOrderable: widget.isEditable,
              atReorder: (reorderList){
                widget.scheduleList.reOrder(reorderList);
                IotMemories.memoryUpdate();
              },
              children: [
                ...widget.scheduleList.scheduleList.map((schedule) {
                  return renderSchedule(scheduleName: schedule.scheduleName, onOff: schedule.on, onTap: () {
                    setState(() {
                      if(widget.isEditable) {
                        widget.onEditSchedule(schedule);
                      } else {
                        schedule.on = !schedule.on;
                        IotMemories.memoryUpdate();
                      }
                    });
                  });
                }
                ).toList(),
              ],),
          ),
        ],
      ),
    );
  }

  GridElement renderModule({Key? key, Widget? child, int width = 1, BoxDecoration? decoration}){
    bool hover = false;
    return GridElement(
      key: key,
      width: width,
      child: StatefulBuilder(builder: (context, setState) {
        return GestureDetector(
          behavior: widget.isEditable? HitTestBehavior.opaque : HitTestBehavior.translucent,
          onTapDown: (_) {
            if(widget.isEditable) {
              setState((){
                hover = true;
              });
            }
          },
          onTapUp: (_) {
            if(widget.isEditable) {
              setState(() {
                hover = false;
              });
            }
          },
          onTapCancel: () {
            if(widget.isEditable) {
              setState(() {
                hover = false;
              });
            }
          },
          child:
          Stack(
            children: [
              Container(decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54.withOpacity(0.1),
                    offset: const Offset(5, 5),
                    blurRadius: 10,
                    spreadRadius: -15,
                  ),
                ],
              ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: animationDelayMilliseconds),
                      decoration: (decoration == null)? BoxDecoration(
                        color: const Color(moduleBase).withOpacity(moduleOpacity),
                      ):decoration,
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(strokeAlign: widget.isEditable? BorderSide.strokeAlignOutside : BorderSide.strokeAlignInside, width : widget.isEditable? 10 : 1, color: (hover && widget.isEditable) ? Colors.blue.withOpacity(0.5) : Colors.white.withOpacity(0.13)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              if(child != null) child,
            ],
          ),
        );
      }),
    );
  }

  GridElement renderSchedule({String scheduleName = "", bool onOff = false, void Function()? onTap}) {
    return renderModule(
      key: ValueKey<String>(scheduleName),
        width: 1,
        decoration: onOff? BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[const Color(color1).withOpacity(moduleOpacity), const Color(color2).withOpacity(moduleOpacity)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ) : BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[const Color(moduleBase).withOpacity(moduleOpacity), const Color(moduleBase).withOpacity(moduleOpacity)],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: (){
            //print("click $moduleName");
            if(onTap != null) onTap();
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child:
                  Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.only(left:40), child: AnimatedDefaultTextStyle(
                    style: TextStyle(
                      fontFamily: "pretendard",
                      fontWeight: FontWeight.w600,
                      fontSize: 40,
                      height: 1,
                      color: onOff? const Color(white) : const Color(black),
                    ),
                    duration: const Duration(milliseconds: animationDelayMilliseconds),
                    curve: Curves.easeOut,
                    child: Text(scheduleName,),
                  ))),
                  ),
                Expanded(
                  flex: 1,
                  child:
                  Padding(
                    padding: EdgeInsets.only(right:40),child:
                    Align(
                      alignment: Alignment.centerRight,
                      child: Stack(children: [
                        IconButton(
                          onPressed: () {
                            //print("click $moduleName");
                            if(onTap != null) onTap();
                          },
                          icon: SvgPicture.asset(
                            'asset/icon/power.svg',
                            color: const Color(white),
                          ),
                          iconSize:40,
                        ),
                        AnimatedOpacity(
                            opacity: onOff? 0 : 1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, child:
                        IconButton(
                          onPressed: () {
                            //print("click $moduleName");
                            if(onTap != null) onTap();
                          },
                          icon: SvgPicture.asset(
                            'asset/icon/power.svg',
                            color: const Color(black).withOpacity(0.3),
                          ),
                          iconSize: 40,
                        )),
                      ],),
                    ),
                    ),
                  ),
              ],
            ),
          ),
        )
    );
  }
}