import 'package:slide_puzzle/puzzle/cringe.dart';
import 'package:slide_puzzle/puzzle/models/level_info.dart';

List<String> levelText(List<Level> history, Level current) {
  var levelText = current.text;

  if (history.isEmpty) {
    return [
      intro,
      if (levelText != null) levelText,
    ];
  }

  if (history.length == 1 && current.lastLevel) {
    return [
      fromStartToEnd,
    ];
  }

  if (history.length == 1) {
    return [
      firstSolve,
      if (levelText != null) levelText,
    ];
  }

  if (current.lastLevel) {
    return [
      ending,
      if (levelText != null) levelText,
    ];
  }

  if (history.last == current) {
    return [
      solveTheSame,
      if (levelText != null) levelText,
    ];
  }

  if (history.length == 2) {
    return [
      secondSolve,
      if (levelText != null) levelText,
    ];
  }

  if (history.contains(current)) {
    return [
      solvePrevious,
      if (levelText != null) levelText,
    ];
  }

  return [
    if (levelText != null) levelText,
  ];

  // todo situation when you go to the last level instantly
}
