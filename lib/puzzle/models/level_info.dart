
import 'package:flutter/cupertino.dart';
import 'dart:ui' as ui;

@immutable
class LevelResources {
  final Level data;
  final ui.Image background;

  const LevelResources({required this.data, required this.background});
}

@immutable
class Level {
  final List<List<int>> key;
  final List<List<int>> hintForNext;
  final Color uiColor;
  final String backgroundPath;
  final bool lastLevel;
  final String? text;

  const Level({
    required this.hintForNext,
    required this.uiColor,
    required this.backgroundPath,
    required this.key,
    this.lastLevel = false,
    this.text,
  });
}