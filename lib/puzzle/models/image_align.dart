
import 'package:flutter/cupertino.dart';
import 'package:equatable/equatable.dart';

@immutable
class ImageAlign extends Equatable {
  final Size size;
  final Offset pos;
  final CenterPoint centerPoint;

  ImageAlign translate(Offset offset) {
    return ImageAlign(size, pos + offset, centerPoint: centerPoint);
  }

  const ImageAlign(this.size, this.pos, {this.centerPoint = CenterPoint.center});

  @override
  List<Object?> get props => [size, pos, centerPoint];

 // AtlasSettings getAtlasSettings(Size imageSize, Size componentSize, [double scaleMultiplier = 1]) {
//
 //   var scale = size.height / imageSize.height;
//
 //   var transform = RSTransform.fromComponents(
 //     rotation: 0.0,
 //     scale: 1 * scale * scaleMultiplier,
 //     anchorX: 0,//imageSize.width / 2,
 //     anchorY: 0,
 //     translateX: 0,
 //     translateY: 0,
 //   );
//
 //   var rect = Rect.fromLTWH(
 //     (pos.dx - componentSize.width / 2 / scaleMultiplier) / scale,
 //     (pos.dy - componentSize.height / 2 / scaleMultiplier) / scale,
 //     componentSize.width / scale / scaleMultiplier,
 //     componentSize.height / scale / scaleMultiplier,
 //   );
//
 //   return AtlasSettings(transform, rect);
 // }
}

@immutable
class AtlasSettings {
  final RSTransform transform;
  final Rect cutout;

  const AtlasSettings(this.transform, this.cutout);
}

enum CenterPoint {
  center, topLeft
}