import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:slide_puzzle/puzzle/cubit/puzzle_cubit.dart';

import 'levels.dart';
import 'models/int_pos.dart';

bool cheatButtonIsPressed = false; // todo use stateful widget instead of static var

void onKeyEvent(KeyEvent event, BuildContext context) {
  var e = event;

  if (e is KeyUpEvent) {
    if (e.logicalKey == LogicalKeyboardKey.keyG) {
      cheatButtonIsPressed = false;
      return;
    }
  }

  if (e is! KeyDownEvent) return;

  if (e.logicalKey == LogicalKeyboardKey.arrowRight || e.logicalKey == LogicalKeyboardKey.keyD) {
    context.read<PuzzleCubit>().move(direction: const IntPos(1, 0));
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.arrowLeft || e.logicalKey == LogicalKeyboardKey.keyA) {
    context.read<PuzzleCubit>().move(direction: const IntPos(-1, 0));
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.arrowDown || e.logicalKey == LogicalKeyboardKey.keyS) {
    context.read<PuzzleCubit>().move(direction: const IntPos(0, 1));
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.arrowUp || e.logicalKey == LogicalKeyboardKey.keyW) {
    context.read<PuzzleCubit>().move(direction: const IntPos(0, -1));
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.keyG) {
    cheatButtonIsPressed = true;
    return;
  }

  if (!cheatButtonIsPressed) return;

  if (e.logicalKey == LogicalKeyboardKey.digit1) {
    context.read<PuzzleCubit>().setPositions(levelKey1);
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.digit2) {
    context.read<PuzzleCubit>().setPositions(levelKey2);
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.digit3) {
    context.read<PuzzleCubit>().setPositions(levelKey3);
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.digit4) {
    context.read<PuzzleCubit>().setPositions(levelKey4);
    return;
  }

  if (e.logicalKey == LogicalKeyboardKey.digit5) {
    context.read<PuzzleCubit>().setPositions(levelKey5);
    return;
  }
}