import 'dart:core';

import 'package:flutter/material.dart';
import 'package:slide_puzzle/image_loader.dart';
import 'package:slide_puzzle/puzzle/models/level_info.dart';
import 'package:slide_puzzle/puzzle/cubit/puzzle_cubit.dart';
import 'package:equatable/equatable.dart';

// @formatter:off
var levelKey1 = <List<int>>[
  // normal
  [1, 2, 3, 4],
  [5, 6, 7, 8],
  [9, 10, 11, 12],
  [13, 14, 15, 0],
].reflect();

var levelKey2 = <List<int>>[
  // inverted
  [0, 15, 14, 13],
  [12, 11, 10, 9],
  [8, 7, 6, 5],
  [4, 3, 2, 1],
].reflect();

var levelKey3 = <List<int>>[
  // swapped columns
  [1, 3, 2, 4],
  [5, 7, 6, 8],
  [9, 11, 10, 12],
  [13, 15, 14, 0],
].reflect();

var levelKey4 = <List<int>>[
  // swapped rows
  [1, 2, 3, 4],
  [9, 10, 11, 12],
  [5, 6, 7, 8],
  [13, 14, 15, 0],
].reflect();

var levelKey5 = <List<int>>[
  // snail
  [1, 2, 3, 4],
  [12, 13, 14, 5],
  [11, 0, 15, 6],
  [10, 9, 8, 7],
].reflect();

var fakeKey1 = <List<int>>[
  // snail
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 1, 1, 1],
  [1, 1, 1, 1],
].reflect();

//// ****************** ////

var level1Hint = <List<int>>[
  // normal
  [1, 2, 3, 4],
  [5, 6, 7, 0],
  [9, 0, 0, 0],
  [0, 0, 0, 0],
].reflect();

var level2Hint = <List<int>>[
  // inverted
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 6, 5],
  [4, 3, 2, 1],
].reflect();

var level3Hint = <List<int>>[
  // swapped columns
  [1, 3, 2, 4],
  [5, 7, 0, 0],
  [9, 0, 0, 0],
  [0, 0, 0, 0],
].reflect();

var level4Hint = <List<int>>[
  // swapped rows
  [1, 2, 3, 4],
  [9, 0, 0, 0],
  [5, 0, 7, 8],
  [0, 0, 0, 0],
].reflect();

var level5Hint = <List<int>>[
  // snail
  [1, 2, 3, 4],
  [0, 0, 0, 5],
  [0, 0, 0, 6],
  [0, 0, 8, 7],
].reflect();

var level0Hint = <List<int>>[
  // snail
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
  [0, 0, 0, 0],
].reflect();

// @formatter:on

class MapKey with EquatableMixin {
  final List<List<int>> board;

  MapKey(this.board);

  @override
  List<Object?> get props {
    var props = List<Object?>.empty(growable: true);

    for (var row in board) {
      props.addAll(row);
    }

    return props;
  }
}

List<Color> levelColors = [
  Colors.deepPurple.withAlpha(120),
  Colors.deepPurple.withAlpha(120),
  Colors.deepPurple.withAlpha(120),
  Colors.deepPurple.withAlpha(120),
  Colors.deepPurple.withAlpha(120),
  Colors.deepPurple.withAlpha(120),
];

List<Level> levels = [
  Level(
    key: fakeKey1,
    hintForNext: level1Hint,
    backgroundPath: "assets/img/background/1.jpg",
    uiColor: Colors.deepPurple.withAlpha(120),
  ),
  Level(
    key: levelKey1,
    hintForNext: level2Hint,
    backgroundPath: "assets/img/background/2.jpg",
    uiColor: Colors.deepPurple.withAlpha(120),
   // text: lvl1,
  ),
  Level(
    key: levelKey2,
    hintForNext: level3Hint,
    backgroundPath: "assets/img/background/3.jpg",
    uiColor: Colors.deepPurple.withAlpha(120),
   // text: lvl2,
  ),
  Level(
    key: levelKey3,
    hintForNext: level4Hint,
    backgroundPath: "assets/img/background/4.jpg",
    uiColor: Colors.deepPurple.withAlpha(120),
   // text: lvl3,
  ),
  Level(
    key: levelKey4,
    hintForNext: level5Hint,
    backgroundPath: "assets/img/background/5.jpg",
    uiColor: Colors.deepPurple.withAlpha(120),
   // text: lvl4,
  ),
  Level(
    key: levelKey5,
    hintForNext: level0Hint,
    backgroundPath: "assets/img/background/6.jpg",
    uiColor: Colors.deepPurple.withAlpha(120),
    lastLevel: true,
    //text: lvl5,
  ),
];

var levelsMap = { for (var l in levels) MapKey(l.key) : l };

Future<LevelResources> loadLevel(int index) async {
  var level = levels[index % levels.length];
  var image = await loadImageFromAssets(level.backgroundPath);
  return LevelResources(background: image, data: level);
}

Future<LevelResources> loadLevelFromKey(List<List<int>> key) async {
  var level = levelsMap[MapKey(key)]!;
  var image = await loadImageFromAssets(level.backgroundPath);
  return LevelResources(background: image, data: level);
}
