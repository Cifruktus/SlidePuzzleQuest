import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:slide_puzzle/puzzle/view/level_transition.dart';

class GameBackground extends StatefulWidget {
  final ui.Image image;

  const GameBackground({Key? key, required this.image}) : super(key: key);

  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground> with TickerProviderStateMixin {
  ui.Image? mask;
  ui.Image? overlay;
  ui.Image? imageFrom;

  ui.Image get imageTo => widget.image;

  late AnimationController controller;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
      lowerBound: 0,
      upperBound: 1,
    );

    controller.addListener(() {
      setState(() {
        progress = controller.value;
      });
    });

    controller.forward(from: 1);
  }

  @override
  void didUpdateWidget(covariant GameBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.image == widget.image) return;

    imageFrom = oldWidget.image;
    controller.reset();
    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return RepaintBoundary(
        child: CustomPaint(
          isComplex: true,
          foregroundPainter: BackgroundPainter(
            imageTo: imageTo,
            imageFrom: imageFrom,
            pos: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
            progress: Curves.easeIn.transform(progress),
          ),
          child: Container(),
          // child: Image.asset("assets/img/2.webp"),
        ),
      );
    });
  }
}

class BackgroundPainter extends CustomPainter {
  static const double glowDist = 20;

  final ui.Image? imageTo;
  final ui.Image? imageFrom;
  final Offset pos;
  final double progress;

  BackgroundPainter({required this.pos, required this.progress, this.imageTo, this.imageFrom});

  @override
  void paint(Canvas canvas, Size size) {
    var imageFrom = this.imageFrom;
    var imageTo = this.imageTo;
    if (imageTo == null) return;

    //print("dc: background");

    if (imageFrom == null || progress == 1) {
      canvas.drawBackgroundImage(
        imageTo,
        size,
        Paint()
          ..blendMode = BlendMode.srcOver
          ..filterQuality = FilterQuality.medium,
      );
      return;
    }

    var transitionSize = LevelTransition.buttonSize + progress * 4000;

    //canvas.saveLayer(null, Paint());

    canvas.drawCircle(pos, transitionSize / 2, Paint());

    canvas.drawBackgroundImage(
      imageTo,
      size,
      Paint()
        ..blendMode = BlendMode.srcIn
        ..filterQuality = FilterQuality.low,
    );

    canvas.drawBackgroundImage(
        imageFrom,
        size,
        Paint()
          ..blendMode = BlendMode.dstATop
          ..filterQuality = FilterQuality.low);

    final paint = Paint()
      ..shader = ui.Gradient.radial(
        pos,
        transitionSize / 2 + glowDist,
        [
          Colors.white.withAlpha(0),
          Colors.white.withOpacity(0.05),
          Colors.white.withOpacity(0.2),
          Colors.white,
          Colors.white.withAlpha(0),
        ],
        [0, 0.3, 0.6, (transitionSize - glowDist * 2) / transitionSize, 1],
      );

    canvas.drawCircle(
        pos, transitionSize / 2 + glowDist * 2, paint..color = Colors.white.withOpacity(1 - (progress * progress)));

    //canvas.restore();
  }

  @override
  bool shouldRepaint(BackgroundPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(BackgroundPainter oldDelegate) => false;
}

extension CanvasExtension on Canvas {
  void drawBackgroundImage(
    ui.Image image,
    Size bgSize,
    Paint paint, [
    Offset offset = Offset.zero,
    Size? targetSize,
    double? scaleMultiplier,
  ]) {
    var aspectRatio = image.width.toDouble() / image.height.toDouble();
    var screenAspectRatio = bgSize.width / bgSize.height;

    late Rect imageRect;
    late double scale;

    if (aspectRatio > screenAspectRatio) {
      scale = image.height.toDouble() / bgSize.height;
      imageRect = Rect.fromLTWH(
        (image.width - image.height * screenAspectRatio) / 2,
        0,
        image.height.toDouble() * screenAspectRatio,
        image.height.toDouble(),
      );
    } else {
      scale = image.width.toDouble() / bgSize.width;
      imageRect = Rect.fromLTWH(
        0,
        (image.height - image.width / screenAspectRatio) / 2,
        image.width.toDouble(),
        image.width.toDouble() / screenAspectRatio,
      );
    }

    targetSize ??= bgSize;

    imageRect = Rect.fromLTWH(
      imageRect.left + offset.dx * scale,
      imageRect.top + offset.dy * scale,
      targetSize.width * scale,
      targetSize.height * scale,
    );

    if (scaleMultiplier != null) {
      imageRect = Rect.fromCenter(
        center: imageRect.center,
        height: imageRect.height * scaleMultiplier,
        width: imageRect.width * scaleMultiplier,
      );
    }

    drawImageRect(image, imageRect, Rect.fromLTWH(0, 0, targetSize.width, targetSize.height), paint);
  }
}
