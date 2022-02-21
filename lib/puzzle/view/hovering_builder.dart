import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'package:slide_puzzle/puzzle/models/int_pos.dart';

class HoveringBuilder extends StatefulWidget {
  final Widget Function(BuildContext, Offset, bool, bool) builder;
  final VoidCallback? onTap;
  final void Function(IntPos dir)? onSlide;
  final bool displace;
  final double maxDistance;
  final double maxDistanceForTap;
  final double timeSpeed;
  final double gestireSlideDistance;
  final TickerProvider vsync;

  const HoveringBuilder({
    Key? key,
    required this.builder,
    this.maxDistance = 40,
    this.maxDistanceForTap = 50,
    this.timeSpeed = 0.4,
    this.gestireSlideDistance = 15,
    this.onTap,
    this.onSlide,
    this.displace = true,
    required this.vsync,
  }) : super(key: key);

  @override
  _HoveringBuilderState createState() => _HoveringBuilderState();
}

class _HoveringBuilderState extends State<HoveringBuilder> {
  static const maxError = 0.7;
  static const maxDelayBetweenClickEvents = 300;

  late AnimationController controller;

  bool hover = false;
  bool pressed = false;

  double get maxDistance => widget.maxDistance;

  int lastEventTriggered = 0;

  Duration t = const Duration();
  Offset pos = const Offset(0, 0);
  Offset velocity = const Offset(0, 0);
  Offset addedImpulse = const Offset(0, 0);

  Offset? dragDownPos;
  Offset? pointerPos;
  Offset? tapDownPos;

  int get timestamp => DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: widget.vsync,
      duration: const Duration(days: 1), // how to avoid this hack?
    );

    controller.addListener(() {
      setState(() {
        var dt = min((controller.lastElapsedDuration! - t).inMilliseconds / 1000.0, 0.1) * widget.timeSpeed;
        t = controller.lastElapsedDuration!;

        velocity += (Offset.zero - pos); // linear force to the center

       // velocity += Offset(-400,0) *
       //     (1 / ((maxDistance * 1.01 - pos.dx)));

        velocity += addedImpulse;
        addedImpulse = const Offset(0, 0);

        pos += velocity * dt;

        pos = Offset.fromDirection(pos.direction, min(pos.distance, maxDistance));


        velocity = velocity * 0.7; //Offset.lerp(velocity, Offset.zero, min(dt * 20, 1))!;

       // pos = Offset(min(maxDistance, max(-maxDistance, pos.dx)), min(maxDistance, max(-maxDistance, pos.dy)));

        if (pos.distance < maxError && velocity.distance < maxError && addedImpulse == Offset.zero) {
          controller.stop();
          t = Duration.zero;
        }
      });
    });

    controller.forward();
  }

  void onHoverUpdate(PointerHoverEvent data) {
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.android) {
      return;
    }
    addedImpulse += data.delta * 2;
    if (!controller.isAnimating) controller.forward();
  }

  void onDragDown(DragDownDetails data) {
    dragDownPos = data.localPosition;
    tapDownPos = data.localPosition;
    pointerPos = data.localPosition;


  }

  void onDragUp(DragEndDetails data) {
    dragDownPos = null;
    if ((pointerPos! - tapDownPos!).distance < widget.maxDistanceForTap) {
      if (lastEventTriggered + maxDelayBetweenClickEvents > timestamp) return;
      lastEventTriggered = timestamp;

      widget.onTap?.call();
    }
  }

  void onDragCancel() {
    dragDownPos = null;
  }

  void onDragUpdate(DragUpdateDetails data) {
    if (dragDownPos == null) return;
    pointerPos = data.localPosition;

    addedImpulse += data.delta * 5;
    if (!controller.isAnimating) controller.forward();

    var relativeDrag = dragDownPos! - data.localPosition;
    if ((relativeDrag).distance > widget.gestireSlideDistance) {
      var normalized = relativeDrag / relativeDrag.distance;
      widget.onSlide?.call(
        IntPos(normalized.dx.round(), normalized.dy.round()),
      );
      lastEventTriggered = timestamp;
      dragDownPos = data.localPosition;
    }
  }

  void onEnter(_){
    setState(() {
      hover = true;
    });
  }

  void onExit(_){
    setState(() {
      hover = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var content = MouseRegion(
      onEnter: onEnter,
      onExit: onExit,
      onHover: onHoverUpdate,
      child: GestureDetector(
        onPanEnd: onDragUp,
        onPanDown: onDragDown,
        onPanUpdate: onDragUpdate,
        onPanCancel: onDragCancel,
        child: widget.builder(context, pos, hover, pressed),
      ),
    );

    return widget.displace
        ? Padding(
            padding: EdgeInsets.only(
              left: widget.maxDistance + pos.dx,
              top: widget.maxDistance + pos.dy,
            ),
            child: content,
          )
        : content;
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}