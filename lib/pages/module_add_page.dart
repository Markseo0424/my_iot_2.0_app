import "dart:async";
import "dart:ui";

import "package:flutter/material.dart";
import "package:myiot/components/constants.dart";
import "package:myiot/components/colors.dart";
import "package:flutter_svg/flutter_svg.dart";

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
    moduleNameController = TextEditingController(text: widget.module.moduleName);
    moduleIdController = TextEditingController(text: widget.module.moduleId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: 30,
        left: 15,
        right: 15,
      ),
      child:
        Column(
          children: [
            Align(alignment: Alignment.topLeft, child: IconButton(
              onPressed: () {
                widget.addOverPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                Timer(Duration(milliseconds: 50), (){widget.addPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
              },
              icon: SvgPicture.asset(
                "asset/icon/back.svg",
                color: Color(white),
              )
                ,iconSize: 30,
            ),),
            Container(height: 105, child: Align(alignment: Alignment.bottomCenter, child: Text(widget.isModuleNew? "ADD MODULE" : "EDIT MODULE", style: TextStyle(
              color: Color(white),
              fontFamily: "pretendard",
              fontWeight: FontWeight.w700,
              fontSize:40,
              height: 36/40,
            ),),),),
            Container(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("Module name", style: TextStyle(
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
              Container(
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
                    colors: [Color(white).withOpacity(0.15), Color(white).withOpacity(0.05)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(white).withOpacity(0.3),
                  )
              ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Align(alignment: Alignment.centerLeft,
                    child: TextField(
                      controller: moduleNameController,
                      style: pretendard(FontWeight.w700, 24, Color(white)),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],),
            Container(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("Module ID", style: TextStyle(
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
              Container(
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
                    colors: [Color(white).withOpacity(0.15), Color(white).withOpacity(0.05)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(white).withOpacity(0.3),
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Align(alignment: Alignment.centerLeft,
                  child: TextField(
                    controller: moduleIdController,
                    enabled: widget.isModuleNew,
                    style: pretendard(FontWeight.w700, 24, Color(widget.isModuleNew? white : fadeOut)),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),),
            ],),
            Container(height: 90, child: Align(alignment: Alignment.bottomCenter, child: Stack(children:[
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
              Container(
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
                  widget.module.moduleName = moduleNameController.value.text;
                  widget.module.moduleId = moduleIdController.value.text;
                  if(widget.isModuleNew) {
                    widget.moduleList.comp.add(widget.module);
                    widget.addOverPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                    Timer(Duration(milliseconds: 50), () {widget.addPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                  }
                  else if(!widget.isModuleNew) {
                    widget.addOverPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                    Timer(Duration(milliseconds: 50), () {widget.addPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                  }
                },
                child: Container(height: 60, decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(color2).withOpacity(0.5), Color(color1).withOpacity(0.5)],
                    begin: Alignment.bottomLeft, end: Alignment.topRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Color(white).withOpacity(0.3),
                  )
            ),child: Center(child: Text(widget.isModuleNew? "GET MODULE" : "EDIT MODULE", style: TextStyle(
                color: Color(white),
                fontFamily: "pretendard",
                fontWeight: FontWeight.w700,
                fontSize:24,
                height: 26/24,
            ),),),),
              ),
            ],),),),
            if(!widget.isModuleNew)
              Container(height: 90, child: Align(alignment: Alignment.bottomCenter, child: Stack(children:[
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
                Container(
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
                    widget.moduleList.comp.remove(widget.module);
                    widget.addOverPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                    Timer(Duration(milliseconds: 50), () {widget.addPageController.animateTo(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
                  },
                  child: Container(height: 60, decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(black).withOpacity(0.8), Color(black).withOpacity(0.5)],
                        begin: Alignment.bottomLeft, end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(white).withOpacity(0.3),
                      )
                  ),child: Center(child: Text("DELETE MODULE", style: TextStyle(
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