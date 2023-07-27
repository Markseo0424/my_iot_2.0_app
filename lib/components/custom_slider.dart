
import 'package:flutter/material.dart';
import 'package:myiot/components/constants.dart';

class CustomSlider extends StatefulWidget {
  final Widget handle;
  final double left;
  final double right;
  final double initFraction;
  final ValueNotifier<int>? moduleChangeListener;
  final void Function(double fraction)? onStartChange;
  final void Function(double fraction)? onChange;
  final void Function(double fraction)? onEndChange;

  const CustomSlider({
    required this.handle,
    this.onChange,
    this.onEndChange,
    this.onStartChange,
    this.left = 0,
    this.right = 0,
    this.initFraction = 0,
    this.moduleChangeListener,
    Key?key,
  }): super(key:key);

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double currentFraction = 0;
  double currentPosition = 0;
  double minFraction = 0;
  double maxFraction = 1;
  double sliderFactor = 1;
  bool init = true;
  bool onDrag = false;

  @override void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.moduleChangeListener != null) {
      widget.moduleChangeListener!.addListener(setDirty);
    }
  }

  setDirty() {
    setState(() {
      init = true;
    });
  }

  @override
  void dispose() {
    if(widget.moduleChangeListener != null) {
      widget.moduleChangeListener!.removeListener(setDirty);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if(init) {
        minFraction = widget.left / constraints.maxWidth;
        maxFraction = 1 - widget.right / constraints.maxWidth;
        sliderFactor = 1/(maxFraction - minFraction);

        currentFraction = (minFraction + widget.initFraction * (maxFraction - minFraction));
        currentPosition = currentFraction * constraints.maxWidth;

        init = false;
      }

      return Stack(
        children: [
          AnimatedPositioned(
              duration: Duration(milliseconds: onDrag? 0 : animationDelayMilliseconds),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              left: constraints.maxWidth * currentFraction,
              child: Center(
                child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragStart: (info){
                      onDrag = true;
                      //print("dragging start, fraction : ${(currentFraction - minFraction) * sliderFactor}");
                      if(widget.onStartChange != null) widget.onStartChange!((currentFraction - minFraction) * sliderFactor);
                    },
                    onHorizontalDragUpdate: (info){
                      //print("dragging, fraction : ${(currentFraction - minFraction) * sliderFactor}");
                      setState(() {
                        currentPosition += info.delta.dx;
                        currentFraction = currentPosition / constraints.maxWidth;
                        if(currentFraction < minFraction) {
                          currentFraction = minFraction;
                        } else if(currentFraction > maxFraction) {
                          currentFraction = maxFraction;
                        }
                        if(widget.onChange != null) widget.onChange!((currentFraction - minFraction) * sliderFactor);
                      });
                    },
                    onHorizontalDragEnd: (info){
                      onDrag = false;
                      if(widget.onEndChange != null) widget.onEndChange!((currentFraction - minFraction) * sliderFactor);
                    },
                    child: widget.handle
                ),
              )
          ),
        ],
      );
    },);
  }
}