import "dart:math";

import "package:flutter/material.dart";
import "package:myiot/components/colors.dart";
import "package:myiot/components/constants.dart";
import "package:myiot/gist/clip_shadow_path.dart";
import "package:flutter_svg/flutter_svg.dart";

class CustomAppBar extends StatefulWidget {
  final double height;
  final double radius;
  final bool isHorizontal;
  final double page;
  final PageController controller;

  const CustomAppBar({Key?key, required this.height, required this.radius, required this.isHorizontal, required this.page, required this.controller}): super(key:key);

  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    if(widget.isHorizontal) {
      return Stack(
        children: [
          ClipShadowPath(
            shadow: BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0,0),
            ),
            clipper: AppbarClipper(radius: widget.radius + 5),
            child:
            Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: Color(white),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0,0),
                  )
                ],
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(padding: EdgeInsets.only(top: 5), child:
                Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children:
                [
                  IconButton(
                    onPressed: () {
                      moveToPage(0);
                    },
                    icon: SvgPicture.asset("asset/icon/dashboard.svg", color: Color(fadeOut)),
                    iconSize: widget.height*0.4,
                  ),
                  Text(
                    "Modules",
                    style: TextStyle(
                      color: Color(fadeOut),
                      height: 0.6,
                      fontSize: widget.height/5,
                      fontFamily: "pretendard",
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ]),),
              ),
              Container(width: widget.radius*2,),
              Expanded(
                  child: Padding(padding: EdgeInsets.only(top: 5), child:
                  Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children:
                  [
                    IconButton(
                      onPressed: () {
                        moveToPage(1);
                      },
                      icon: SvgPicture.asset("asset/icon/event.svg", color: Color(fadeOut)),
                      iconSize: widget.height*0.4,
                    ),
                    Text(
                      "Schedules",
                      style: TextStyle(
                        color: Color(fadeOut),
                        height: 0.6,
                        fontSize: widget.height/5,
                        fontFamily: "pretendard",
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ]),),
              ),
            ],
          ),  //faded
          Row(
            children: [
              Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      moveToPage(0);
                    },
                    child:
                    ClipPath(
                      clipper: AppbarButtonClipper(page: widget.page),
                      child:
                      Padding(padding: EdgeInsets.only(top: 5), child:
                      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children:
                      [
                        IconButton(
                          onPressed: () {
                            moveToPage(0);
                          },
                          icon: SvgPicture.asset("asset/icon/dashboard.svg", color: Color(black)),
                          iconSize: widget.height*0.4,
                        ),
                        Text(
                          "Modules",
                          style: TextStyle(
                            color: Color(black),
                            height: 0.6,
                            fontSize: widget.height/5,
                            fontFamily: "pretendard",
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ]),),
                    )
                  )
              ),
              Container(width: widget.radius*2,),
              Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      moveToPage(1);
                    },
                    child:
                    ClipPath(
                      clipper: AppbarButtonClipper(page: -1 + widget.page),
                      child:
                      Padding(padding: EdgeInsets.only(top: 5), child:
                      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children:
                      [
                        IconButton(
                          onPressed: () {
                            moveToPage(1);
                          },
                          icon: SvgPicture.asset("asset/icon/event.svg", color: Color(black)),
                          iconSize: widget.height*0.4,
                        ),
                        Text(
                          "Schedules",
                          style: TextStyle(
                            color: Color(black),
                            height: 0.6,
                            fontSize: widget.height/5,
                            fontFamily: "pretendard",
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ]),),
                    ),
                  )
              ),
            ],
          ),  //colored
        ],
      );
    }
    else {
      return Container(
        width: widget.height*2,
        decoration: BoxDecoration(
            color: Color(white),
            borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0,0),
              )
            ]
        ),
      );
    }
  }

  void moveToPage(int page) {
    widget.controller.animateToPage(page, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);
  }
}

class AppbarClipper extends CustomClipper<Path> {
  double radius;

  AppbarClipper({this.radius = 0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(size.width/2 + radius, 0);
    path.addArc(Rect.fromCenter(center: Offset(size.width/2,0), width: radius*2, height: radius*2), 0, pi);
    path.lineTo(0,0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class AppbarButtonClipper extends CustomClipper<Path> {
  final double page;

  AppbarButtonClipper({required this.page});

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addRRect(RRect.fromLTRBR(0 + size.width * page, 0, size.width + size.width * page, size.height, Radius.circular(size.height/2)));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}