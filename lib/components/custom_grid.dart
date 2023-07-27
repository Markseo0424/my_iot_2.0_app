// ignore_for_file: must_be_immutable

import 'dart:math';
import 'package:flutter/material.dart';


class CustomGrid extends StatefulWidget {
  final List<GridElement> elements = [
    GridElement(boxColor: Colors.red, boxText: "빨강", width: 2,),
    GridElement(boxColor: Colors.orange, boxText: "주황",),
    GridElement(boxColor: Colors.yellow, boxText: "노랑", width: 2,),
    GridElement(boxColor: Colors.green, boxText: "초록",),
    GridElement(boxColor: Colors.blue, boxText: "파랑",),
  ];

  final double page;
  final List<GridElement>? children;
  final bool reOrderable;
  final void Function(List<int> reorderedElement)? atReorder;

  final int? hNum;
  final int? vNum;
  final double? hGridStandard;
  final double? vGridStandard;
  final bool isSquare;

  CustomGrid({
    Key?key,
    this.children,
    required this.page,
    required this.reOrderable,
    this.atReorder, this.hNum, this.vNum, this.hGridStandard, this.vGridStandard, required this.isSquare,
  }): super(key:key);

  @override
  State<CustomGrid> createState() => _CustomGridState();
}

class _CustomGridState extends State<CustomGrid> {
  List<GridElement> elements = [];

  final List<GridElement> _elements = [];

  int hNum = 2;
  int vNum = 1;
  double hGridStandard = 200;
  double vGridStandard = 100;
  double hGrid = 200;
  double vGrid = 100;
  double maxHeight = 100;

  GridElement? tempElement;
  GridElement? blankElement;

  List<double>? tempOrigin;
  List<double>? tempCoord;
  List<List<double>>? tempPivots;

  @override
  void initState() {
    super.initState();
    //print("init CustomGrid");
    if(widget.children != null) {
      for(GridElement child in widget.children!){
        elements.add(child);
        _elements.add(child);
      }
    }
    else {
      for (GridElement element in widget.elements) {
        elements.add(element);
        _elements.add(element);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("build CustomGrid \n elements: ${elements.map((element) {return element.hashCode;} )} \n _elements: ${_elements.map((element) {return element.hashCode;} )}");
    if(tempElement == null) sync();

    return LayoutBuilder(builder: (context,constraints) {
      double currentWidth = constraints.maxWidth;
      double currentHeight = constraints.maxHeight;

      hNum = widget.hNum ?? max(1, currentWidth ~/ (widget.hGridStandard ?? hGridStandard));
      vNum = widget.vNum ?? max(1, currentHeight ~/ (widget.vGridStandard ?? vGridStandard));
      hGrid = currentWidth/hNum;
      vGrid = widget.isSquare? hGrid : currentHeight/vNum;

      if(tempElement == null) maxHeight = getPositionFromIndex(elements.length - 1)[1] + vGrid;
      return SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: maxHeight,
            ),
            ..._elements.map((element) {
              if(tempElement != null && element == tempElement) {
                element = blankElement!;
              }
              return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  width: hGrid * element.width,
                  height: vGrid,
                  transform: Matrix4.identity()
                    ..translate(
                        getPositionFromIndex(elements.indexOf(element))[0],
                        getPositionFromIndex(elements.indexOf(element))[1]),
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(-widget.page * 0.5)..translate(-widget.page * 200),
                    child: widget.reOrderable?
                    GestureDetector(
                      onLongPressStart: (info) {
                        int index = elements.indexOf(element);
                        tempElement = element;
                        blankElement = GridElement(width: element.width, isBlank: true,);
                        tempOrigin = getPositionFromIndex(index);
                        tempCoord = <double>[tempOrigin![0],tempOrigin![1]];
                        tempPivots = getPivotList(index, element.width);
                        setState(() {
                          elements[index] = blankElement!;
                        });
                      },
                      onLongPressMoveUpdate: (info) {
                        setState(() {
                          tempCoord![0] = tempOrigin![0] + info.offsetFromOrigin.dx;
                          tempCoord![1] = tempOrigin![1] + info.offsetFromOrigin.dy;
                          updateElements(getIndexFromPivotList(tempCoord!));
                        });
                      },
                      onLongPressEnd: (info) {
                        setState(() {
                          elements[elements.indexOf(blankElement!)] =
                          tempElement!;
                          tempElement = null;
                          blankElement = null;
                          tempCoord = null;
                          tempPivots = null;
                          reorder();
                        });
                      },
                      child: element,
                    ):
                    element,
                  )
              );
            }
            ),
            if(tempElement != null)
              Container(
                width: hGrid * tempElement!.width,
                height: vGrid,
                transform: Matrix4.identity()
                  ..translate(tempCoord![0], tempCoord![1]),
                child: Opacity(
                  opacity: 0.8,
                  child: tempElement,
                ),
              ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void reorder() {
    List<int> reorderList = [];
    for(GridElement element in elements) {
      reorderList.add(widget.children!.indexOf(element));
    }
    if(widget.atReorder != null) widget.atReorder!(reorderList);
  }

  double snapToGrid(double value, double gridSize){
    return ((value + gridSize/2) ~/ gridSize) * gridSize - ((value < -gridSize/2)? gridSize : 0.0);
  }

  List<double> getPositionFromIndex(int index) {
    int scaledIndex = 0;
    int row = 0;
    int width = 0;

    for(int i = 0; i <= index; i++) {
      width = elements[i].width;
      scaledIndex += width;
      if(scaledIndex > hNum) {
        row ++;
        scaledIndex = width;
      }
    }
    int col = scaledIndex - width;
    return <double>[col * hGrid,row * vGrid];
  }

  List<List<double>> getPivotList(int index, int tempWidth) {
    int scaledIndex = 0;
    int tempScaledIndex = 0;
    int row = 0;
    int tempRow = 0;
    int tempCol = 0;
    int width = 0;
    List<List<double>> pivotList = [<double>[0,0]];

    for(int i = 0; i < elements.length; i++) {
      if(i != index) {
        width = elements[i].width;
        scaledIndex += width;
        if(scaledIndex > hNum) {
          row ++;
          scaledIndex = width;
        }
        tempRow = row;
        tempScaledIndex = scaledIndex + tempWidth;
        if(tempScaledIndex > hNum) {
          tempRow = row + 1;
          tempScaledIndex = tempWidth;
        }
        tempCol = tempScaledIndex - tempWidth;
        pivotList.add(<double>[tempCol * hGrid,tempRow * vGrid]);
      }
    }
    return pivotList;
  }

  int getIndexFromPivotList(List<double> coord){
    num minLen = pow(hGridStandard*10,2);
    num nowLen = 0;
    int minIndex = 0;
    for(int i = 0; i < tempPivots!.length; i++) {
      nowLen = pow(tempPivots![i][0]-coord[0],2) + pow(tempPivots![i][1]-coord[1],2);
      if(nowLen <= minLen) {
        minLen = nowLen;
        minIndex = i;
      }
    }
    return minIndex;
  }

  void updateElements(int index) {
    elements.remove(blankElement!);
    elements.insert(index, blankElement!);
  }

  void sync() { //suppose one change at once
    if(widget.children == null) return;
    if(_elements.length > widget.children!.length) {
      setState(() {
        List<GridElement> removedElements = [];
        for(GridElement element in _elements) {
          if(!widget.children!.contains(element)) {
            removedElements.add(element);
          }
        }
        for(GridElement element in removedElements) {
          _elements.remove(element);
          elements.remove(element);
        }
      });
    }
    else if(_elements.length < widget.children!.length) {
      setState(() {
        for(GridElement element in widget.children!){
          if(!_elements.contains(element)) {
            _elements.add(element);
            elements.add(element);
          }
        }
      });
    }

    for(GridElement widgetElement in widget.children!) {
      for(GridElement element in elements) {
        if(widgetElement.key == element.key) {
          elements[elements.indexOf(element)] = widgetElement;
          _elements[_elements.indexOf(element)] = widgetElement;
        }
      }
    }

    /*
    for(GridElement element in _elements) {
      int index = elements.indexOf(element);
      int _index = _elements.indexOf(element);
      if(_elements[_index] != widget.children![_index]) {
        setState(() {
          _elements[_index] = widget.children![_index];
          elements[index] = _elements[_index];
        });
      }
    }
    */
  }
}

class GridElement extends StatelessWidget {
  final Color boxColor;
  final String boxText;
  final int width;
  final bool isBlank;
  Widget? child;

  GridElement({
    this.boxColor = Colors.transparent,
    this.boxText = "",
    this.width = 1,
    this.isBlank = false,
    this.child,
    Key?key,
  }): super(key:key);

  @override
  Widget build(BuildContext context) {
    if(isBlank) {
      return Container(
        color: Colors.transparent,
      );
    }
    if(child != null) {
      return child!;

    }
    return Container(
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: const BorderRadius.all(
                Radius.circular(20)
            ),
          ),
          child: Center(
            child: Text(
                boxText,
                style: const TextStyle(
                  fontFamily: "pretendard",
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: Colors.black54,
                )
            ),
          ),
    );
  }
}