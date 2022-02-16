import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

@immutable
class IntPos extends Equatable {
  final int x;
  final int y;

  IntPos normalize(){
    if (x == 0) return IntPos(0, y > 0 ? 1 : -1);
    if (y == 0) return IntPos(x > 0 ? 1 : -1, 0);
    throw Exception("vector can't be normalized");
  }

  get isNormalized => (x == 0 && (y == 1 || y == -1)) || (y == 0 && (x == 1 || x == -1));

  const IntPos(this.x, this.y);

  IntPos operator -  (IntPos other) => IntPos(x - other.x,y - other.y);
  IntPos operator + (IntPos other) => IntPos(x + other.x,y + other.y);

  @override
  List<Object?> get props => [x, y];

  Offset toOffset() => Offset(x.toDouble(), y.toDouble());
}
