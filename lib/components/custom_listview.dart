import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:myiot/components/constants.dart';

import 'multi_hit_stack.dart';

class CustomListView extends StatefulWidget {
  final List<CustomListViewElement> children;
  final void Function(int oldIndex,int newIndex) onReorder;
  final void Function(Key elementKey) onDelete;
  final void Function() onClose;
  final bool open;
  final TickerProvider vsync;
  final ValueNotifier<int> changeListener;
  final double? bottom;

  const CustomListView({Key?key, required this.children, required this.onReorder, required this.onDelete, required this.open, required this.vsync, required this.onClose, required this.changeListener, this.bottom}) : super(key:key);

  @override
  State<CustomListView> createState() => _CustomListViewState();
}

class _CustomListViewState extends State<CustomListView> {
  final List<CustomListViewElement> _children = [];
  final List<CustomListViewElement> _savedChildren = [];
  final List<AnimationController> _elementAnimationController = [];
  double width = 400;
  double height = 200;
  double zero = 0;
  bool dirty = false;

  int? tempBeginIndex;
  double? tempOrigY;
  double? tempPosY;
  CustomListViewElement? tempItem;
  CustomListViewElement? emptyItem;
  List<double>? tempAnchorList;

  @override
  void initState() {
    super.initState();
    int i = 0;
    for(var element in widget.children) {
      _children.add(element);
      _savedChildren.add(element);
      _elementAnimationController.add(AnimationController(vsync: widget.vsync, duration: const Duration(milliseconds: animationDelayMilliseconds),));
      AnimationController handle = _elementAnimationController[i];
      Timer(Duration(milliseconds: 100 * i + 10), () {handle.animateTo(0.5,curve: Curves.easeOut, duration: const Duration(milliseconds: animationDelayMilliseconds));});
      i++;
    }
    widget.changeListener.addListener(setDirty);
    //print("init");
  }

  setDirty() {
    dirty = true;
  }

  @override
  void dispose() {
    super.dispose();
    widget.changeListener.removeListener(setDirty);
    //print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    if(!widget.open){
        int i = 0;
        for(var element in _children) {
          AnimationController handle = _elementAnimationController[_savedChildren.indexOf(element)];
          Timer(Duration(milliseconds: min(
              50 * i + 10, animationDelayMilliseconds)), () {
            handle.animateTo(1, curve: Curves.easeOut,
                duration: const Duration(
                    milliseconds: animationDelayMilliseconds));
          });
          i++;
        }

        Timer(const Duration(milliseconds: animationDelayMilliseconds~/2), (){widget.onClose();});
    }
    if(dirty) {
      //print("called dirty");
      setState(() {
        for(var element2 in widget.children) {
          bool contains = false;
          for(var element in _children) {
            if(element.key == element2.key) contains = true;
            if(element.key == element2.key && (element.openHeight != element2.openHeight || element.closeHeight != element2.openHeight)) {
              element.openHeight = element2.openHeight;
              element.closeHeight = element2.closeHeight;
              element.height = element.open? element.openHeight: element.closeHeight;
            }
          }
          if(!contains){
            _children.add(element2);
            _savedChildren.add(element2);
            AnimationController handle = AnimationController(vsync: widget.vsync, duration: const Duration(milliseconds: animationDelayMilliseconds),);
            _elementAnimationController.add(handle);
            Timer(const Duration(milliseconds: 50), () {handle.animateTo(0.5, duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut);});
          }
        }
        dirty = false;
      });
    }

    return LayoutBuilder(builder: (context, constraints) {
      width = constraints.maxWidth;
      height = constraints.maxHeight;
      return SingleChildScrollView(
        child: MultiHitStack(
            children: [
              Container(height:maxHeight(height, widget.bottom??0),),
              ..._savedChildren.map((element) {
                int savedIndex = _savedChildren.indexOf(element);

                if(tempItem != null && tempItem == element) {
                  element = emptyItem!;
                }

                int index = _children.indexOf(element);

                double dx = 0;
                bool dragging = false;

                if(!_children.contains(element)) return const IgnorePointer();
                return StatefulBuilder(builder: (context, setStateBuilder) {
                  return AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds),curve: Curves.easeOut,
                      height: element.height,
                      transform: Matrix4.identity()..translate(
                          zero,
                          getHeight(index)),
                      child: AnimatedBuilder(
                        animation: _elementAnimationController[savedIndex],
                        builder: (context,_) {
                          return Container(
                            transform: Matrix4.identity()..translate(
                              Tween<double>(begin: width, end : -width,).animate(_elementAnimationController[savedIndex]).value,
                            ),
                            child: AnimatedContainer(
                              transform: Matrix4.identity()..translate( - 50 * log(-dx/50+1)),
                              duration: Duration(milliseconds: dragging? 0 : animationDelayMilliseconds),
                              curve: Curves.elasticOut,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: (){
                                  setState(() {
                                    element.open = !element.open;
                                    element.height = element.open? element.openHeight: element.closeHeight;
                                    if(element.onTap != null) element.onTap!();
                                  });
                                },
                                onLongPressStart: (_) {
                                  tempItem = element;
                                  emptyItem = CustomListViewElement.singleHeight(height: element.height, child: Container());
                                  tempBeginIndex = _children.indexOf(tempItem!);
                                  tempAnchorList = getAnchorList(tempBeginIndex!);
                                  tempPosY = getHeight(index);
                                  tempOrigY = getHeight(index);
                                  setState(() {
                                    _children[tempBeginIndex!] = emptyItem!;
                                  });
                                },
                                onLongPressMoveUpdate: (info) {
                                  setState(() {
                                    tempPosY = tempOrigY! + info.offsetFromOrigin.dy;
                                    replaceEmpty(getIndexFromAnchorList(tempPosY!));
                                  });
                                },
                                onLongPressEnd: (_) {
                                  setState(() {
                                    int newIndex = getIndexFromAnchorList(tempPosY!);
                                    _children[newIndex] = tempItem!;
                                    widget.onReorder(tempBeginIndex!, newIndex);
                                    tempItem = null;
                                    emptyItem = null;
                                    tempBeginIndex = null;
                                    tempAnchorList = null;
                                    tempPosY = null;
                                    tempOrigY = null;
                                  });
                                },
                                onHorizontalDragStart: (info) {
                                  setStateBuilder((){
                                    dragging = true;
                                  });
                                },
                                onHorizontalDragUpdate: (info) {
                                  if(info.delta.dx + dx < 0) {
                                    setStateBuilder(() {
                                      dx += info.delta.dx;
                                    });
                                  }
                                  else {
                                    setStateBuilder(() {
                                      dx = 0;
                                    });
                                  }
                                },
                                onHorizontalDragEnd: (info) {
                                  if(dx < -100) {
                                    _elementAnimationController[savedIndex].animateTo(1,duration: Duration(milliseconds: animationDelayMilliseconds), curve:Curves.easeOut);
                                    Timer(Duration(milliseconds: animationDelayMilliseconds), () {
                                      setState((){
                                        //print("remove in children");
                                        _children.remove(element);
                                        widget.onDelete(element.key!);
                                      });
                                    });
                                  }
                                  else {
                                    setState(() {
                                      dragging = false;
                                      dx = 0;
                                    });
                                  }
                                },
                                child: element,
                              ),
                            ),
                          );
                        },
                      )
                  );
                });
              }),
              if(tempItem != null)
                Container(transform: Matrix4.identity()..translate(zero, tempPosY!), child: Opacity(opacity: 0.5, child: Transform.scale(scale: 1.05,child: tempItem,)),),

            ]
        ),
      );
    });
  }

  double getHeight(int index) {
    double height = 0;
    for(int i = 0; i < index; i++) {
      height += _children[i].height;
    }
    return height;
  }

  List<double> getAnchorList(int index) {
    double height = 0;
    List<double> anchorList = [0];
    for(int i = 0; i < _children.length; i++) {
      if(i != index) {
        height += _children[i].height;
        anchorList.add(height);
      }
    }
    return anchorList;
  }

  int getIndexFromAnchorList(double position) {
    int index = 0;
    double distance = double.infinity;
    int i = 0;
    for(double anchor in tempAnchorList??[]){
      if((anchor - position).abs() < distance) {
        distance = (anchor - position).abs();
        index = i;
      }
      i++;
    }
    return index;
  }

  void replaceEmpty(int newIndex) {
    if(_children.contains(emptyItem!)) {
      _children.remove(emptyItem);
      _children.insert(newIndex, emptyItem!);
    }
  }

  double maxHeight(double minHeight, double margin) {
    double height = 0;

    if(_children.isNotEmpty) {
      CustomListViewElement lastChild = _children.last;
      height = getHeight(_children.indexOf(lastChild)) + lastChild.height;
    }

    return max(height + margin, minHeight);
  }

}

class CustomListViewElement extends StatelessWidget {
  final Widget child;
  double height;
  double closeHeight;
  double openHeight;
  bool open = false;

  final void Function()? onTap;


  CustomListViewElement({Key?key, required this.child, required this.closeHeight, required this.openHeight, this.onTap}) : height = closeHeight, super(key:key);
  CustomListViewElement.singleHeight({Key?key, required this.child, required this.height, this.onTap}) : closeHeight = height, openHeight = height, super(key:key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(duration: const Duration(milliseconds: animationDelayMilliseconds), curve: Curves.easeOut, height: height, child: child,);
  }
}


