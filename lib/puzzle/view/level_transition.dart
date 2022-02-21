import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:slide_puzzle/puzzle/cubit/puzzle_cubit.dart';
import 'package:slide_puzzle/puzzle/models/image_align.dart';
import 'package:slide_puzzle/puzzle/view/background.dart';
import 'package:slide_puzzle/puzzle/view/hovering_builder.dart';

class LevelTransition extends StatefulWidget {
  static const double buttonSize = 200;

  final Size size;
  final bool gameFinished;

  const LevelTransition({Key? key, required this.size, required this.gameFinished}) : super(key: key);

  @override
  _LevelTransitionState createState() => _LevelTransitionState();
}

class _LevelTransitionState extends State<LevelTransition> {
  static const enableDelay = Duration(milliseconds: 2500);
  static const disableDelay = Duration();

  bool visible = false;
  bool enabled = false;

  @override
  Widget build(BuildContext context) {
    var state = context.select((PuzzleCubit c) => c.state);
    var nextLvlImage = state is PuzzleFinished ? state.next.background : state.level!.background;

    return Visibility(
      maintainState: true,
      visible: enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 1000),
        opacity: visible ? 1 : 0,
        onEnd: () => setState(() {
          enabled = visible;
        }),
        child: LevelTransitionButton(
          align: ImageAlign(
              widget.size,
              Offset(
                (widget.size.width - LevelTransition.buttonSize) / 2,
                (widget.size.height - LevelTransition.buttonSize) / 2,
              )),
          child: Container(),
          size: LevelTransition.buttonSize,
          background: nextLvlImage,
          onPress: () {
            context.read<PuzzleCubit>().nextGame();
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant LevelTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gameFinished != widget.gameFinished) {
      Future.delayed((widget.gameFinished ? enableDelay : disableDelay) * timeDilation).then((_) {
        setState(() {
          // todo check set state after future
          enabled = true;
          visible = widget.gameFinished;
        });
      });
    }
  }
}

class LevelTransitionButton extends StatefulWidget {
  final ImageAlign align;
  final ui.Image? background;
  final Color color;
  final Widget child;
  final void Function()? onPress;
  final double size;

  const LevelTransitionButton({
    Key? key,
    required this.align,
    this.color = Colors.transparent,
    required this.child,
    this.onPress,
    this.background,
    required this.size,
  }) : super(key: key);

  @override
  State<LevelTransitionButton> createState() => _LevelTransitionButtonState();
}

class _LevelTransitionButtonState extends State<LevelTransitionButton> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPress,
      child: HoveringBuilder(
        displace: false,
        vsync: this,
        timeSpeed: 0.3,
        builder: (context, pos, _,__) {
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: const BoxDecoration(
              // image: DecorationImage.,
              borderRadius: BorderRadius.all(Radius.circular(150)),
              boxShadow: [
                // BoxShadow(
                //   //   offset: Offset(4,4),
                //     spreadRadius: 20,
                //     blurRadius: 70,
                //     color: Colors.black87),
                BoxShadow(
                    //   offset: Offset(4,4),
                    spreadRadius: 2,
                    blurRadius: 5,
                    color: Colors.white),
              ],
            ),
            child: CustomPaint(
                painter: LevelTransitionPainter(
                  pos: widget.align.translate(pos),
                  image: widget.background,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: widget.child,
                )),
          );
        },
      ),
    );
  }
}

class LevelTransitionPainter extends CustomPainter {
  final ui.Image? image;
  final ImageAlign pos;

  LevelTransitionPainter({required this.pos, this.image});

  @override
  void paint(Canvas canvas, Size size) {
    var image = this.image;
    if (image == null) return;

    //print("dc: button");
    // canvas.saveLayer(null, Paint());

    // canvas.drawPath(path, Paint()..color = Colors.red);
    var center = Offset(size.width / 2, size.height / 2);

    // var atlasSettings = pos.getAtlasSettings(Size(image.width.toDouble(), image.height.toDouble()), size, 0.5);

    // canvas.drawAtlas(
    //     image,
    //     [atlasSettings.transform],
    //     [atlasSettings.cutout],
    //     [
    //       //Colors.deepPurple.withAlpha(120)
    //     ],
    //     BlendMode.hardLight,
    //     null /* No need for cullRect */,
    //     Paint()
    //       ..blendMode);

    canvas.save();

    canvas.clipRRect(RRect.fromRectXY(
        Rect.fromCenter(
          center: center,
          height: size.height,
          width: size.width,
        ),
        200,
        200));

    canvas.drawBackgroundImage(
      image,
      pos.size,
      Paint()..blendMode = BlendMode.srcOver,
      pos.pos,
      size,
      2,
    );

    canvas.restore();

    var paint = Paint()
      ..shader = ui.Gradient.radial(center, 102, [
        Colors.transparent,
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.13),
        Colors.white.withOpacity(0.40),
        Colors.white,
      ], [
        0,
        0.3,
        0.6,
        0.8,
        1
      ]);

    canvas.drawCircle(center, 102, paint);

    //canvas.drawShadow(

    //  canvas.restore();
  }

  @override
  bool shouldRepaint(LevelTransitionPainter oldDelegate) {
    return oldDelegate.pos != pos || oldDelegate.image != image;
  }

  @override
  bool shouldRebuildSemantics(LevelTransitionPainter oldDelegate) => false;
}
