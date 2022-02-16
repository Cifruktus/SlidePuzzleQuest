
import 'dart:math';
import 'dart:ui' as ui;
import 'package:slide_puzzle/puzzle/models/image_align.dart';
import 'package:slide_puzzle/puzzle/view/background.dart';
import 'package:slide_puzzle/puzzle/view/hovering_builder.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide_puzzle/puzzle/cubit/puzzle_cubit.dart';
import 'package:slide_puzzle/puzzle/models/int_pos.dart';

class SlideGame extends StatefulWidget {
  final List<IntPos> positions;
  final double cellSize;
  final ui.Image image;
  final bool finished;
  final Size size;

  const SlideGame(
      {Key? key,
      required this.positions,
      required this.cellSize,
      required this.image,
      required this.finished,
      required this.size})
      : super(key: key);

  @override
  _SlideGameState createState() => _SlideGameState();
}

class _SlideGameState extends State<SlideGame> with TickerProviderStateMixin {
  static const Duration transitionDuration = Duration(milliseconds: 270);
  static const Curve transitionCurve = Curves.ease;

  static const int gridSize = 4;

//  static const double physModelCellSize = 20;
  static const double cellSize = 80;
  static const double cellPadding = 20;

  static double get cellSpace => cellSize + cellPadding;

  late AnimationController controller;

  late List<IntPos> cellTransition;
  Duration? transitionStart;
  Duration? hideTransitionStart;
  Duration? showTransitionStart;
  Duration time = const Duration();

  @override
  void initState() {
    super.initState();
    cellTransition = widget.positions;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 100), // how to avoid this hack?
    );

    controller.addListener(() {
      var dt = min((controller.lastElapsedDuration! - time).inMilliseconds / 1000.0, 0.1);
      time = controller.lastElapsedDuration!;
      updatePhysics(dt);
    });

    controller.forward();
  }

  void updatePhysics(double dt) {
    if (transitionStart == null && hideTransitionStart == null && showTransitionStart == null) {
      controller.stop();
    }

    setState(() {});
  }

  @override
  void didUpdateWidget(covariant SlideGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!controller.isAnimating) controller.forward();

    if (oldWidget.positions != widget.positions) {
      // then start transition animation
      cellTransition = oldWidget.positions;
      transitionStart = controller.lastElapsedDuration!;
    }

    if (oldWidget.finished != widget.finished) {
      if (widget.finished) {
        showTransitionStart = null;
        hideTransitionStart = controller.lastElapsedDuration!;
      } else {
        hideTransitionStart = null;
        showTransitionStart = controller.lastElapsedDuration!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    double progress = transitionStart == null
        ? 1
        : (controller.lastElapsedDuration! - transitionStart!).inMilliseconds / transitionDuration.inMilliseconds;
    progress = min(1, progress);

    for (int i = 0; i < widget.positions.length; i++) {
      var pos1 = widget.positions[i];
      var index1 = pos1.x * 4 + pos1.y;

      var pos2 = cellTransition[i];
      //var index2 = pos2.x * 4 + pos2.y;

      var pos = Offset.lerp(pos2.toOffset() * cellSpace, pos1.toOffset() * cellSpace,
          transitionCurve.transform(progress))!; // todo 234234
////234
      var center = Offset(cellSpace * (boardWidth / 2 - 0.5), cellSpace * (boardWidth / 2 - 0.5));
      var distance = (pos - center).distance;
      var angle = (pos - center).direction;

      var value = 0.0;
      var valueD = 0.0;
      if (hideTransitionStart != null) {
        value = (time - hideTransitionStart! - const Duration(milliseconds: 1100)).inMilliseconds / 1500;
        value = max(value, 0);
        valueD = value / 2;
        valueD = valueD > 1 ? 1 : Curves.easeInOutCubic.transform(valueD);
        value = (value > 1 ? 1 + (value - 1) * 6 : Curves.easeInQuad.transform(value)) / 5;
      }

      if (showTransitionStart != null) {
        value = max(1 - (time - showTransitionStart! - const Duration(milliseconds: 1100)).inMilliseconds / 1500, 0);
        if (value == 0) showTransitionStart = null;

        valueD = value / 2;
        valueD = valueD > 1 ? 1 : Curves.easeInOutCubic.transform(valueD);
        value = -(value > 1 ? 1 + (value - 1) * 6 : Curves.easeInQuad.transform(value)) / 5;
      }

      var targetDistance = distance > cellSpace * 1.5 ? cellSpace * 0.75 : cellSpace * 0.3;
      distance = ui.lerpDouble(distance, targetDistance, min(valueD, 1))!;
      pos = Offset.fromDirection(angle + value * 0.5 /** (r.nextDouble() / 2 + 0.5)*/, distance) + center;

      ///234234
      children.add(buildChild(pos, index1, i + 1));
    }

    if (progress >= 1) transitionStart = null;

    return SizedBox(
      width: (cellSize + cellPadding) * gridSize - cellPadding,
      height: (cellSize + cellPadding) * gridSize - cellPadding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.25 * opacityForBgShadow()))],
              ),
            ),
          ),
          Align(
            child: CustomPaint(
              size: const Size(700, 700),
              painter: PortalEffectsPainter(time.inMilliseconds / 1000.0, opacityOfVfx()),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void tryToMoveCell(int index, int displayIndex, [IntPos? desiredDir]) {
    //todo cleanup
    var puzzle = context.read<PuzzleCubit>();
    var dir = puzzle.getMoveDir(widget.positions[displayIndex - 1]);
    if (dir != null) {
      if (desiredDir != null && dir != desiredDir) return;
      puzzle.move(widget.positions[displayIndex - 1]);
    }
  }

  double opacityOfVfx() {
    if (hideTransitionStart != null) {
      var value = max(((time - hideTransitionStart! - const Duration(milliseconds: 1800)).inMilliseconds / 1500), 0.0);
      return min(value, 1);
    }

    if (showTransitionStart != null) {
      var value = max(1 - (time - showTransitionStart!).inMilliseconds / 1500, 0.0);
      return min(value, 1);
    }

    return 0;
  }

  double opacityOfContinueButton() {
    var val = 1.0;
    if (hideTransitionStart != null) {
      val = min(
        1,
        max(
            0,
            1 -
                (controller.lastElapsedDuration! - hideTransitionStart! - const Duration(milliseconds: 3000))
                        .inMilliseconds /
                    2000),
      );
    } else if (showTransitionStart != null) {
      val = min(
        1,
        max(
            0,
            (controller.lastElapsedDuration! - showTransitionStart! - const Duration(milliseconds: 0)).inMilliseconds /
                700),
      );
    }
    return Curves.ease.transform(1 - val);
  }

  double opacityForBgShadow() {
    var val = 1.0;
    if (hideTransitionStart != null) {
      val = min(1, max(0, 1 - (controller.lastElapsedDuration! - hideTransitionStart!).inMilliseconds / 1000));
    } else if (showTransitionStart != null) {
      val = min(
          1,
          max(
              0,
              (controller.lastElapsedDuration! - showTransitionStart! - const Duration(seconds: 2)).inMilliseconds /
                  1500));
    }
    return Curves.ease.transform(val);
  }

  bool isCellHidden(int index) {
    if (hideTransitionStart != null) {
      var hideDelay = 5 - (index % 4 + index ~/ 4);
      return controller.lastElapsedDuration! - hideTransitionStart! >
          Duration(milliseconds: hideDelay * 100) + transitionDuration;
    }

    if (showTransitionStart != null) {
      var hideDelay = (index % 4 + index ~/ 4);

      return controller.lastElapsedDuration! - showTransitionStart! <
          Duration(milliseconds: hideDelay * 100) + const Duration(seconds: 2);
    }
    return false;
  }

  Widget buildChild(Offset pos, int index, int displayIndex) {
    return PuzzleCell(
      background: widget.image,
      align: ImageAlign(
        widget.size,
        pos + Offset(0, cellSpace / 2) + Offset(widget.size.width, widget.size.height) / 2 - const Offset(200, 200),
      ),
      text: displayIndex.toString(),
      position: pos,
      onTap: () => tryToMoveCell(index, displayIndex),
      onSlide: (dir) => tryToMoveCell(index, displayIndex, dir),
      // onHover: (data) => addedImpulse[index] += data.delta * 0.2,
      // onDragUpdate: (data) => addedImpulse[index] += data.delta,
      hidden: isCellHidden(index),
      cellSize: cellSize,
      vsync: this,
    );
  }
}

class PuzzleCell extends StatefulWidget {
  final double cellSize;
  final PointerHoverEventListener? onHover;
  final GestureTapCallback? onTap;
  final GestureDragUpdateCallback? onDragUpdate;
  final ui.Image background;
  final Offset position;
  final String text;
  final bool hidden;
  final TickerProvider vsync;
  final ImageAlign align;
  final void Function(IntPos dir)? onSlide;

  const PuzzleCell({
    Key? key,
    this.onHover,
    this.onTap,
    this.onDragUpdate,
    required this.background,
    required this.position,
    required this.text,
    this.hidden = false,
    required this.cellSize,
    required this.vsync,
    required this.align,
    this.onSlide,
  }) : super(key: key);

  @override
  _PuzzleCellState createState() => _PuzzleCellState();
}

class _PuzzleCellState extends State<PuzzleCell> {
  double get cellSize => widget.cellSize;

  late AnimationController hideAnimation;

  double hideVal = 0;

  @override
  void initState() {
    super.initState();

    hideAnimation = AnimationController(duration: const Duration(milliseconds: 350), vsync: widget.vsync);

    hideAnimation.value = 0;

    hideAnimation.addListener(() => setState(() {
          hideVal = hideAnimation.value;
        }));
  }

  @override
  void didUpdateWidget(covariant PuzzleCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hidden != widget.hidden) {
      if (widget.hidden) {
        hideAnimation.forward(from: 0);
      } else {
        hideAnimation.reverse(from: 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx - 16 - 8,
      top: widget.position.dy - 16 - 8,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: cell(context),
      ),
      //crossFadeState: widget.hidden ? CrossFadeState.showFirst : CrossFadeState.showSecond,
    );
  }

  Widget cell(BuildContext context) {
    var borderRadius = const BorderRadius.all(Radius.circular(50));

    return HoveringBuilder(
        vsync: widget.vsync,
        onTap: widget.onTap,
        onSlide: widget.onSlide,
        gestireSlideDistance: 45,
        maxDistance: 16,
        timeSpeed: 0.8,
        builder: (context, pos, hover, clicked) {
          return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: widget.hidden ? 0 : 1),
              duration: const Duration(milliseconds: 100),
              builder: (context, double value, child) {
                return Container(
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      boxShadow: [
                        if (value > 0)
                          BoxShadow(spreadRadius: 3, blurRadius: 3, color: Colors.black.withOpacity(0.12 * value)),
                        if (value < 1)
                          BoxShadow(spreadRadius: 6, blurRadius: 6, color: Colors.white.withOpacity(0.7 * (1 - value))),
                      ],
                    ),
                    width: cellSize,
                    height: cellSize,
                    child: CustomPaint(
                      isComplex: true,
                      painter: CellPainter(
                        align: widget.align.translate(pos * 0.6),
                        image: widget.background,
                        glow: 1 - value,
                      ),
                      child: Center(
                        child: Text(
                          widget.text,
                          style: TextStyle(color: Colors.white.withOpacity(0.7 * value), fontSize: 50),
                        ),
                      ),
                    ));
              });
        });
  }
}

class CellPainter extends CustomPainter {
  final double glow;
  final ImageAlign align;
  final ui.Image? image;

  CellPainter({required this.align, this.image, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    var image = this.image;
    if (image == null) return;

    //print("dc: cell $number");

    if (glow < 1) {
      canvas.clipRRect(RRect.fromRectXY(Rect.fromLTWH(0, 0, size.height, size.width), 200, 200));

      canvas.drawBackgroundImage(
        image,
        align.size,
        Paint()..color = Colors.white.withOpacity(1 - glow),
        align.pos,
        size,
        1.2,
      );

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..color = Colors.deepPurple.withAlpha(120)
          ..blendMode = BlendMode.hardLight,
      );

      var outlineShader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, size.height),
        [
          Colors.white.withOpacity(0),
          Colors.white,
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.3),
        ],
        [0, 0.3, 0.5, 1],
      );

      canvas.drawCircle(
        size.center(Offset.zero),
        size.width / 2,
        Paint()
          ..shader = outlineShader
          ..color = Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..blendMode = BlendMode.hardLight,
      );
    }

    if (glow > 0) {
      canvas.drawCircle(
        size.center(Offset.zero),
        size.width / 2,
        Paint()..color = Colors.white.withOpacity(0.8 * glow),
      );
    }
  }

  @override
  bool? hitTest(ui.Offset position) {
    var cellSize = Size(_SlideGameState.cellSpace, _SlideGameState.cellSpace);
    return (position + cellSize.center(Offset.zero)).distance < _SlideGameState.cellSpace / 2;
  }

  @override
  bool shouldRepaint(CellPainter oldDelegate) {
    return oldDelegate.glow != glow || oldDelegate.align != align || oldDelegate.glow != glow;
  }

  @override
  bool shouldRebuildSemantics(CellPainter oldDelegate) => false;
}

class PortalEffectsPainter extends CustomPainter {
  final double opacity;
  final double t;

  PortalEffectsPainter(this.t, this.opacity);

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    // print("dc: sfx");

    var t = -this.t / 3;
    var center = size.center(Offset.zero);

    var circleSize = 400.0;

    final paint1 = Paint()
      ..shader = ui.Gradient.radial(
        center,
        circleSize + sin(t * 2) * 70,
        [
          Colors.white.withOpacity(0),
          Colors.white,
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0),
        ],
        [0, 0.3, 0.5, 1],
      );

    final paint2 = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        //circleSize,
        [
          Colors.white,
          Colors.white.withOpacity(0.25),
          Colors.white.withOpacity(0),
        ],
        [0, 0.5, 1],
        TileMode.mirror,
        0 - t / 2,
        pi / 13 - t / 2, //+ t / 5
      );

    double blur = 0.05;

    final paint3 = Paint()
      ..shader = ui.Gradient.sweep(
        center,
        //circleSize,
        [
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(0),
          Colors.white.withOpacity(0),
        ],
        [0, blur, 0.5 - blur, 0.5 + blur, 1],
        TileMode.repeated,
        0 + t / 5,
        (pi * 2 / 9) + t / 5, //  - t / 2
      );

    canvas.saveLayer(null, Paint()..color = Colors.white.withOpacity(opacity));

    // c.drawPath(path, paint1);
    // c.drawCircle(center, 510, paint2..blendMode = BlendMode.srcIn);

    canvas.drawCircle(center, 510, paint1..blendMode);
    canvas.drawCircle(center, 510, paint2..blendMode = BlendMode.srcIn);
    canvas.drawCircle(center, 510, paint3..blendMode = BlendMode.srcIn);

    //  c.drawCircle(center, 510, paint1..blendMode);
    // c.drawCircle(center, 510, paint2..color = Colors.white.withOpacity(0.5));
    // c.drawCircle(center, 510, paint3..color = Colors.white.withOpacity(0.5));
    //c.drawCircle(center, 510, paint3..blendMode = BlendMode.srcIn);

    var r = Random(15);
    var angleDif = pi * 2 / 15;
    for (int i = 0; i < 15; i++) {
      drawParticle(
          canvas,
          center,
          Offset(size.width / 2 + sin(i * angleDif) * 90, size.height / 2 + cos(i * angleDif) * 90),
          (r.nextDouble() - t) % 1,
          1);
    }

    canvas.restore();
  }

  void drawParticle(Canvas canvas, Offset center, Offset pos, double t, double livetime) {
    const radius = 20.0;

    double dist = (pos - center).distance;
    double angle = (pos - center).direction;

    double angleTraveled = -t + (t * t * 2);
    double distTraveled = t * 50;

    var updatedPos = center + Offset.fromDirection(angle + angleTraveled, dist + distTraveled);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        updatedPos,
        radius,
        [
          Colors.white,
          Colors.white.withOpacity(1),
          Colors.white.withOpacity(0),
        ],
        [0, 0.5, 1],
      );

    canvas.drawCircle(updatedPos, radius, paint..color = Colors.white.withOpacity((livetime - t) / livetime));
  }

  @override
  bool shouldRepaint(PortalEffectsPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(PortalEffectsPainter oldDelegate) => false;
}

/*
class ValueAnimationBuilder extends StatefulWidget {


  @override
  _ValueAnimationBuilderState createState() => _ValueAnimationBuilderState();
}

class _ValueAnimationBuilderState extends State<ValueAnimationBuilder> {
  AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = new AnimationController();
  }

  @override
  Widget build(BuildContext context) {
    TweenAnimationBuilder

    return Container();
  }
}
*/
