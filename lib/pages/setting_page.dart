import "dart:async";
import "dart:convert";
import "dart:ui";

import "package:flutter/material.dart";
import "package:myiot/components/constants.dart";
import "package:myiot/components/colors.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:myiot/components/multi_hit_stack.dart";
import "package:myiot/types/iot_memories.dart";
import "package:myiot/types/iot_request.dart";

import "../types/module.dart";

class SettingPage extends StatefulWidget {
  final PageController addPageController;
  final PageController addOverPageController;
  final double? page;
  final IotMemories memories;

  const SettingPage({Key?key, required this.addPageController, required this.addOverPageController, required this.page, required this.memories,}): super(key:key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController serverUrlController = TextEditingController();
  double scale = 1;
  double vT = 0;
  double hT = 0;
  double angle = 0;

  bool changeAvailable = false;

  @override
  void initState() {
    super.initState();
    serverUrlController = TextEditingController(text: widget.memories.serverUrl);
    serverUrlController.addListener(atEditText);
  }

  atEditText() {
    setState(() {
      changeAvailable = false;
    });
  }

  @override
  void dispose() {
    serverUrlController.removeListener(atEditText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    scale = 2 * MediaQuery.of(context).size.width/300;
    vT = 350 * ((scale - 1)* 0.2+1) - MediaQuery.of(context).size.width + MediaQuery.of(context).size.height/2;
    hT = 40 * scale * (1 - (widget.page??0) * 2);
    angle = -0.15 + 3*(widget.page??0)/4;

    return MultiHitStack(
      children: [
        Padding(
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
                Container(height: 105, child: Align(alignment: Alignment.bottomCenter, child: Text("SETTINGS", style: TextStyle(
                  color: Color(white),
                  fontFamily: "pretendard",
                  fontWeight: FontWeight.w700,
                  fontSize:40,
                  height: 36/40,
                ),),),),
                Container(height: 55, child: Align(alignment: Alignment.bottomLeft, child: Padding(padding: EdgeInsets.only(left:5, bottom:5), child: Text("Server URL", style: TextStyle(
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
                          controller: serverUrlController,
                          style: pretendard(FontWeight.w700, 24, Color(white)),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                      IotRequest.sendValidRequest(useCustomIp: true, customIp: serverUrlController.text.split(":")[0], customPort: int.parse(serverUrlController.text.split(":")[1]), (jsonResponse) {
                        if(jsonResponse["data"]?["result"] == "OK"){
                          setState(() {
                            changeAvailable = true;
                            const snackBar = SnackBar(content: Text("Server URL is available."),);
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          });
                        }
                        else {
                          const snackBar = SnackBar(content: Text("ERROR! Server URL is not available."),);
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      });
                    },
                    child: Container(height: 60, decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(color1).withOpacity(0.5), Color(color1).withOpacity(0.5)],
                        begin: Alignment.bottomLeft, end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(white).withOpacity(0.3),
                      )
                ),child: Center(child: Text("CHECK CONNECTION", style: TextStyle(
                    color: Color(white),
                    fontFamily: "pretendard",
                    fontWeight: FontWeight.w700,
                    fontSize:24,
                    height: 26/24,
                ),),),),
                  ),
                ],),),),
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
                    onTap: changeAvailable? (){
                      setState(() {
                        widget.memories.serverUrl = serverUrlController.text;
                        IotMemories.memoryUpdate();
                        IotRequest.setServerAddress(widget.memories.serverUrl);
                        final snackBar = SnackBar(content: Text("Server URL is successfully changed."),);
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        widget.addPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
                        Timer(Duration(milliseconds: 50), () => widget.addOverPageController.animateToPage(1, duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut));
                      });
                    } : null,
                    child: AnimatedContainer(duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, height: 60, decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(changeAvailable? color2 : fadeOut).withOpacity(0.5), Color(changeAvailable? color1 : fadeOut).withOpacity(0.5)],
                          begin: Alignment.bottomLeft, end: Alignment.topRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Color(white).withOpacity(0.3),
                        )
                    ),child: Center(child: AnimatedDefaultTextStyle(duration: Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut,
                      style: TextStyle(
                        color: Color(changeAvailable? white: black).withOpacity(changeAvailable? 1: 0.3),
                        fontFamily: "pretendard",
                        fontWeight: FontWeight.w700,
                        fontSize:24,
                        height: 26/24,
                      ),
                      child: Text("CHANGE URL"),
                    ),),),
                  ),
                ],),),),
              ],
            )
        ),
      ],
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

class ScreenClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height+200);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return true;
  }

}