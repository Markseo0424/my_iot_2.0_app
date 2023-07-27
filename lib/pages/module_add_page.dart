// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:myiot/components/constants.dart";
import "package:myiot/components/colors.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:myiot/types/iot_memories.dart";
import "package:myiot/types/iot_request.dart";

import "../types/module.dart";

class ModuleAddPage extends StatefulWidget {
  final PageController addPageController;
  final PageController addOverPageController;
  final Module module;
  final ModuleList moduleList;
  final bool isModuleNew;

  const ModuleAddPage({Key?key, required this.addPageController, required this.addOverPageController, required this.module, required this.isModuleNew, required this.moduleList}): super(key:key);

  @override
  State<ModuleAddPage> createState() => _ModuleAddPageState();
}

class _ModuleAddPageState extends State<ModuleAddPage> {
  TextEditingController moduleNameController = TextEditingController();
  TextEditingController moduleIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(!widget.isModuleNew) moduleNameController = TextEditingController(text: widget.module.moduleName);
    if(!widget.isModuleNew) moduleIdController = TextEditingController(text: widget.module.moduleId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            SizedBox(height: 105, child: Align(alignment: Alignment.bottomCenter, child: Text(widget.isModuleNew? "ADD MODULE" : "EDIT MODULE", style: const TextStyle(
              color: Color(white),
              fontFamily: "pretendard",
              fontWeight: FontWeight.w700,
              fontSize:40,
              height: 36/40,
            ),),),),
            const SizedBox(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("Module name", style: TextStyle(
              color: Color(white),
              fontFamily: "pretendard",
              fontWeight: FontWeight.w700,
              fontSize:20,
              height: 1,
            ),),)),),
            Stack(children:[
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
              Container(height: 60, decoration: BoxDecoration(
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
                  child: Align(alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: moduleNameController,
                      style: pretendard(FontWeight.w700, 24, const Color(white)),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],),
            const SizedBox(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("Module ID", style: TextStyle(
              color: Color(white),
              fontFamily: "pretendard",
              fontWeight: FontWeight.w700,
              fontSize:20,
              height: 1,
            ),),)),),
            Stack(children:[
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
              Container(height: 60, decoration: BoxDecoration(
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
                child: Align(alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: moduleIdController,
                    enabled: widget.isModuleNew,
                    style: pretendard(FontWeight.w700, 24, Color(widget.isModuleNew? white : fadeOut)),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),),
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
                onTap: (){
                  String newName =  moduleNameController.value.text;
                  String newID = moduleIdController.value.text;

                  if(widget.isModuleNew) {
                    bool doesIdExist = widget.moduleList.findByID(newID) != null;
                    bool doesNameExist = widget.moduleList.findByName(newName) != null;

                    IotRequest.sendNewRequest(newID, (jsonResponse) {
                      if(jsonResponse["data"]?["result"] == "OK") {
                        String newType = jsonResponse["data"]?["type"];
                        String newValue = jsonResponse["data"]?["val"];
                        newValue = newValue.split("~").join();
                        List<String> values = newValue.split("_");


                        if(newType == "onoff") {
                          widget.module.type = Module.ONOFF;
                          widget.module.onOffVal = (newValue == "ON")? true : false;
                        }
                        else if(newType == "slider") {
                          widget.module.type = Module.SLIDER;
                          widget.module.doubleVal = double.parse(values[0]);
                          widget.module.setValueRange = <double>[double.parse(values[1]), double.parse(values[2])];
                          widget.module.unit = values[3];
                          widget.module.decimal = int.parse(values[4]) == 1;
                        }
                        else if(newType == "value") {
                          widget.module.type = Module.VALUE;
                        }

                        final snackBar = SnackBar(content: Text(doesNameExist? 'Same Name! Try again.' : (doesIdExist? 'Same ID! Try again.': 'Module successfully added.')),);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);

                        if(!doesIdExist && !doesNameExist) {
                          widget.module.moduleName = newName;
                          widget.module.moduleId = newID;
                          widget.moduleList.comp.add(widget.module);
                          IotMemories.memoryUpdate();
                          widget.addOverPageController.animateToPage(1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                          Timer(const Duration(milliseconds: 50), () {widget.addPageController.animateToPage(1, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                        }
                      }
                      else {
                        const snackBar = SnackBar(content: Text('Module is not availble. Try again.'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    });
                  }
                  else {
                    Module? foundByName = widget.moduleList.findByName(newName);

                    final snackBar = SnackBar(
                      content: Text(foundByName != null && foundByName != widget.module? 'Same Name! Try again.' : 'Module successfully edited.'),);
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);

                    if(foundByName == null || foundByName == widget.module) {
                      widget.module.moduleName = newName;
                      widget.module.moduleId = newID;
                      IotMemories.memoryUpdate();
                      widget.addOverPageController.animateToPage(
                          1, duration: const Duration(
                          milliseconds: animationDelayMilliseconds),
                          curve: Curves.easeOut);
                      Timer(const Duration(milliseconds: 50), () {
                        widget.addPageController.animateToPage(1,
                            duration: const Duration(
                                milliseconds: animationDelayMilliseconds),
                            curve: Curves.easeOut);
                      });
                    }
                  }
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
            ),child: Center(child: Text(widget.isModuleNew? "GET MODULE" : "EDIT MODULE", style: const TextStyle(
                color: Color(white),
                fontFamily: "pretendard",
                fontWeight: FontWeight.w700,
                fontSize:24,
                height: 26/24,
            ),),),),
              ),
            ],),),),
            if(!widget.isModuleNew)
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
                  onTap: () {const snackBar = SnackBar(content: Text('Module successfully deleted.'),);
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  widget.moduleList.comp.remove(widget.module);
                  IotRequest.sendDeleteRequest(moduleIdController.text, (p0) {
                    if(p0["data"]?["result"] == "OK") {
                      const snackBar = SnackBar(
                          content: Text('Module is removed from server.'));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  });
                  IotMemories.memoryUpdate();
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
                  ),child: const Center(child: Text("DELETE MODULE", style: TextStyle(
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