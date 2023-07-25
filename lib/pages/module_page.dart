import 'dart:math';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:myiot/components/constants.dart';
import 'package:myiot/components/custom_grid.dart';
import 'package:myiot/components/colors.dart';
import 'package:myiot/components/custom_slider.dart';
import 'package:flutter/material.dart';

import '../types/module.dart';

class ModulePage extends StatefulWidget {
  final double page;
  final bool isEditable;
  final ModuleList moduleList;
  final ValueNotifier<int> moduleChangeListener;
  final void Function(Module editModule) onEditModule;

  const ModulePage({
    required this.page,
    Key? key, required this.isEditable, required this.moduleList, required this.moduleChangeListener, required this.onEditModule,
  }) : super(key:key);

  @override
  State<ModulePage> createState() => _ModulePageState();
}

class _ModulePageState extends State<ModulePage> {
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
      body: ValueListenableBuilder<int> (
        valueListenable: widget.moduleChangeListener,
        builder: (context, _, __) {
          return Stack(
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
                        "MODULES",
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
                    isSquare: true,
                    page: widget.page,
                    reOrderable: widget.isEditable,
                    atDispose: (reorderList){
                      widget.moduleList.reOrder(reorderList);
                    },
                    children: renderModules()),
              ),
            ],
          );
        },
      )
    );
  }

  GridElement renderModule({Key? key, Widget? child, int width = 1, BoxDecoration? decoration, required void Function() onEditModule}){
    bool hover = false;
    return GridElement(
        key: key,
        width: width,
        child: StatefulBuilder(builder: (context, setState) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
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
            onTap: widget.isEditable? () {
              onEditModule();
            } : null,
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

  GridElement renderOnOffModule({String moduleName = "", String moduleId = "", bool onOff = false, void Function(bool)? onTap, required void Function() onEditModule}) {
    return renderModule(
      onEditModule: onEditModule,
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
          onTap: !widget.isEditable? (){
            //print("click $moduleName");
            if(onTap != null) onTap(onOff);
          } : null,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(children: [
                  IconButton(
                    onPressed: () {
                      //print("click $moduleName");
                      if(!widget.isEditable) {if(onTap != null) onTap(onOff);}
                      else onEditModule();
                    },
                    icon: SvgPicture.asset(
                      'asset/icon/power.svg',
                      color: const Color(white),
                    ),
                    iconSize: 100,
                  ),
                  AnimatedOpacity(
                      opacity: onOff? 0 : 1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, child:
                  IconButton(
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {
                      //print("click $moduleName");
                      if(!widget.isEditable) {if(onTap != null) onTap(onOff);}
                      else onEditModule();
                    },
                    icon: SvgPicture.asset(
                      'asset/icon/power.svg',
                      color: const Color(black).withOpacity(0.3),
                    ),
                    iconSize: 100,
                  )),
                ],),
                AnimatedDefaultTextStyle(
                  style: TextStyle(
                    fontFamily: "pretendard",
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    height: 0.9,
                    color: onOff? const Color(white) : const Color(black),
                  ),
                  duration: const Duration(milliseconds: animationDelayMilliseconds),
                  curve: Curves.easeOut,
                  child: Text(moduleName,),
                ),
                AnimatedDefaultTextStyle(
                  style: TextStyle(
                      fontFamily: "pretendard",
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      height: 1.5,
                      color: onOff? const Color(white) : const Color(subBlack)
                  ),
                  duration: const Duration(milliseconds: animationDelayMilliseconds),
                  curve: Curves.easeOut,
                  child: Text(
                    "id : $moduleId",
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  GridElement renderSliderModule({String moduleName = "", String moduleId = "", String unit = "", double value = 0, double startVal = 0, double endVal = 100, bool decimal = false, void Function(double fraction)? onStartChange, void Function(double fraction)? onChange, void Function(double fraction)? onEndChange, required void Function() onEditModule}) {
    Color handleColor = gradientPicker(color2, color1, (value - startVal)/(endVal - startVal),);

    return renderModule(
      onEditModule: (){
        onEditModule();
      },
      width: 2,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Row(
                children:[
                  Expanded(child:
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text("${decimal? value.toStringAsFixed(1): value.round()}$unit",
                        style: TextStyle(
                          fontFamily: "pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 60,
                          height: 0.8,
                          color: const Color(black),
                        ),
                      ),
                    ),
                  )
                  ),
                  Expanded(child: Padding(
                    padding: EdgeInsets.only(left:15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          moduleName,
                          style: TextStyle(
                            fontFamily: "pretendard",
                            fontWeight: FontWeight.w700,
                            fontSize: 30,
                            height: 0.9,
                            color: const Color(black),
                          ),
                        ),
                        Text(
                          "id : $moduleId",
                          style: TextStyle(
                              fontFamily: "pretendard",
                              fontWeight: FontWeight.w400,
                              fontSize: 15,
                              height: 2,
                              color: const Color(subBlack)
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Center(
                      child: Container(
                        height: 30,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          color: Color(fadeOut),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: ClipPath (
                      clipper: SliderClipper(fraction: (value - startVal)/(endVal - startVal),),
                      child: Center(
                        child: Container(
                          height: 30,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                            gradient: LinearGradient(
                              colors: [Color(color2), Color(color1),],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ),
                    )
                  ),
                  CustomSlider(
                    moduleChangeListener : widget.moduleChangeListener,
                    left: 25,
                    right: 75,
                    handle: Container(width:50,height:50,decoration: BoxDecoration(
                      color: handleColor,
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54.withOpacity(0.2),
                          offset: const Offset(5, 5),
                          blurRadius: 5,
                          spreadRadius: -5,
                        ),
                      ],
                    ),),
                    initFraction: (value - startVal)/(endVal - startVal),
                    onStartChange: (fraction) {
                      if(onStartChange != null) onStartChange(fraction);
                    },
                    onChange: (fraction) {
                      if(onChange != null) onChange(fraction);
                    },
                    onEndChange: (fraction) {
                      if(onEndChange != null) onEndChange(fraction);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  GridElement renderValueModule({String moduleName = "", String moduleId = "", String unit = "", double value = 0, double startVal = 0, double endVal = 100, bool decimal = false, required void Function() onEditModule}) {
    double nowFraction = (value - startVal) / (endVal - startVal);
    return renderModule(
      onEditModule: (){
        onEditModule();
      },
      child: Stack(
        children: [
          ClipPath(
            clipper: ValueModuleClipper(fraction: 1, startAngle: pi - pi/10,sweepAngle: pi + 2 * pi / 10),
            child:
            Center(
                child:
                FractionallySizedBox(
                    widthFactor: 0.65,
                    heightFactor: 0.65,
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(400),
                          border: const GradientBoxBorder(
                            gradient: SweepGradient(
                              colors: [Color(fadeOut), Color(fadeOut)],
                              startAngle: pi/2 - pi/10,
                              endAngle: 3*pi/2 + pi/10,
                              tileMode: TileMode.repeated,
                            ),
                            width: 10,
                          ),
                        ),
                      ),
                    )
                )
            ),
          ),
          TweenAnimationBuilder(
              tween: Tween<double>(begin: 0,end: nowFraction),
              duration: const Duration(milliseconds: animationDelayMilliseconds),
              curve: Curves.easeOut,
              builder: (_, double fraction,__){
                return ClipPath(
                  clipper: ValueModuleClipper(fraction: fraction, startAngle: pi - pi/10,sweepAngle: pi + 2 * pi / 10),
                  child:
                  Center(
                      child:
                      FractionallySizedBox(
                          widthFactor: 0.65,
                          heightFactor: 0.65,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(400),
                                border: const GradientBoxBorder(
                                  gradient: SweepGradient(
                                    colors: [Color(color2), Color(color1)],
                                    startAngle: pi/2 - pi/10,
                                    endAngle: 3*pi/2 + pi/10,
                                    tileMode: TileMode.repeated,
                                  ),
                                  width: 10,
                                ),
                              ),
                            ),
                          )
                      )
                  ),
                );
              }
          ),
          Center(
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text("${decimal? value.toStringAsFixed(1): value.round()}$unit",
                      style: TextStyle(
                        fontFamily: "pretendard",
                        fontWeight: FontWeight.w500,
                        fontSize: 35,
                        height: 0.8,
                        color: const Color(black),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        moduleName,
                        style: const TextStyle(
                          fontFamily: "pretendard",
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                          height: 0.9,
                          color: Color(black),
                        ),
                      ),
                      Text(
                        "id : $moduleId",
                        style: const TextStyle(
                            fontFamily: "pretendard",
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            height: 1.5,
                            color: Color(subBlack)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<GridElement> renderModules() {
    return widget.moduleList.comp.map((module) {
      if(module.type == Module.ONOFF) {
        return renderOnOffModule(moduleName: module.moduleName, moduleId: module.moduleId, onOff: module.value,
            onEditModule: (){
              widget.onEditModule(module);
            },
            onTap: (nowValue) {
              setState(() {
                module.setValue = !nowValue;
                module.sendRequest();
              });
            });
      }
      else if(module.type == Module.SLIDER) {
        return renderSliderModule(moduleName: module.moduleName, moduleId: module.moduleId, value: module.value, unit: module.unit, startVal: module.startVal, endVal: module.endVal, decimal: module.decimal,
          onEditModule: (){
            widget.onEditModule(module);
          },
          onChange: (fraction) {
            setState(() {
              module.setValue = (module.endVal - module.startVal) * fraction + module.startVal;
            });
          },
          onEndChange: (fraction) {
            setState(() {
              module.setValue = (module.endVal - module.startVal) * fraction + module.startVal;
              module.sendRequest();
            });
          },);
      }
      else if(module.type == Module.VALUE) {
        return renderValueModule(moduleName: module.moduleName, moduleId: module.moduleId, value: module.value, unit: module.unit, startVal: module.startVal, endVal: module.endVal, decimal: module.decimal,
          onEditModule: (){
            widget.onEditModule(module);
          },);
      }
      else {
        return renderModule(
          onEditModule: (){},
            child: Container()
        );
      }
    }).toList();
  }

  Color gradientPicker(int primary, int secondary, double fraction) {
    int alpha = ((primary ~/ 0x1000000) + (((secondary - primary) ~/ 0x1000000) * fraction)).round();
    int red = ((primary ~/ 0x10000) % 0x100 * (1 - fraction) + ((secondary ~/ 0x10000) % 0x100 * fraction)).round();
    int green = ((primary ~/ 0x100) % 0x100 * (1 - fraction) + ((secondary ~/ 0x100) % 0x100 * fraction)).round();
    int blue = ((primary) % 0x100 * (1 - fraction) + ((secondary) % 0x100 * fraction)).round();
    return Color(alpha * 0x1000000 + red * 0x10000 + green * 0x100 + blue);
  }
}

class SliderClipper extends CustomClipper<Path> {
  double fraction;

  SliderClipper({this.fraction = 0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width * fraction, size.height);
    path.lineTo(size.width * fraction, 0);
    path.lineTo(0,0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ValueModuleClipper extends CustomClipper<Path> {
  double fraction;
  double startAngle;
  double sweepAngle;

  ValueModuleClipper({this.fraction = 0, this.startAngle = pi, this.sweepAngle = 0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    Rect rect = Rect.fromLTRB(0,0,size.width,size.height);
    //path.lineTo(size.width * cos(startAngle), size.width * sin(startAngle));
    path.addArc(rect, startAngle, fraction * sweepAngle);
    path.lineTo(size.width/2, size.height/2);

    //path.transform((Matrix4.identity()..translate(size.width/2, size.height/2)).storage);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}