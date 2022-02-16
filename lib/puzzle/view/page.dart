import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:slide_puzzle/puzzle/cubit/puzzle_cubit.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide_puzzle/puzzle/levels.dart';
import 'package:slide_puzzle/puzzle/models/level_info.dart';
import 'package:slide_puzzle/puzzle/view/background.dart';
import 'package:slide_puzzle/puzzle/view/endgame.dart';
import 'package:slide_puzzle/puzzle/view/game.dart';
import 'package:slide_puzzle/puzzle/view/level_transition.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:slide_puzzle/puzzle/view/widgets.dart';

import '../cringe.dart';
import 'hint.dart';

bool shiftIsPressed = false;

Future<LevelResources> loadGame(BuildContext context) async {
  await precacheImage(const AssetImage('assets/img/puzzle.png'), context);
  return await loadLevel(0);
}

class PuzzlePage extends StatefulWidget {
  static Widget route(BuildContext context) {
    return FutureBuilder<LevelResources>(
      future: loadGame(context),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error"));
        }
        if (snapshot.hasData) {
          return BlocProvider(
            create: (context) => PuzzleCubit(snapshot.data!),
            child: PuzzlePage(),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => showLore(context));
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        autofocus: true,
        onKeyEvent: (e) => onKeyEvent(e, context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Align(
            child: ConstrainedBox(
              constraints: const BoxConstraints(),
              child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
                var size = Size(constraints.maxWidth, constraints.maxHeight);

                return Stack(
                  children: [
                    const _GameBackground(),
                    RepaintBoundary(child: _GameBoard(size: size)), //todo do we need repaint boundary here?
                    _TransitionButton(size: size),
                    _FinishedGame(size: size),
                    _GameToolbar(size: size),
                  ],
                );
              }),
            ),
          ),
        ));
  }

  void onKeyEvent(KeyEvent event, BuildContext context) {
    var e = event;

    if (e is KeyUpEvent) {
      if (e.logicalKey == LogicalKeyboardKey.keyG) {
        shiftIsPressed = false;
        return;
      }
    }

    if (e is! KeyDownEvent) return;

    if (e.logicalKey == LogicalKeyboardKey.keyG) {
      shiftIsPressed = true;
      return;
    }

    if (!shiftIsPressed) return;

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
}

class _GameBackground extends StatelessWidget {
  const _GameBackground();

  @override
  Widget build(BuildContext context) {
    var background = context.select((PuzzleCubit p) => p.state.level!.background);

    return Positioned.fill(
      child: GameBackground(
        image: background,
      ),
    );
  }
}

class _GameToolbar extends StatelessWidget {
  final Size size;

  const _GameToolbar({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var board = context.select((PuzzleCubit p) => p.state.level!.data.hintForNext);
    var finished = context.select((PuzzleCubit p) => p.state is PuzzleFinished);
    var hide = finished || context.select((PuzzleCubit p) => p.state.uiHidden);

    return Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: hide ? 0 : 1,
          child: IgnorePointer(
            ignoring: hide,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: PuzzleHint(board: board),
            ),
          ),
        ));
  }
}

class _GameBoard extends StatelessWidget {
  final Size size;

  static const durationToHideInTheEnd = Duration(milliseconds: 2400); //2400); //todo
  static const normalTransitionDuration = Duration(milliseconds: 100);

  const _GameBoard({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var board = context.select((PuzzleCubit p) => p.state);

    var endGameHide = board.level?.data.lastLevel ?? false;
    var uiHide = board.puzzleHidden || board.uiHidden;

    return Align(
      child: AnimatedOpacity(
        //later: why it blinks? // --> because some of the widgets use BlendMode.hardLight
        // just make animation fast so it won't be noticeable
        duration: endGameHide ? durationToHideInTheEnd : normalTransitionDuration,
        opacity: endGameHide || uiHide ? 0 : 1,
        // curve: Curves.ease,
        child: SlideGame(
          image: board.level!.background,
          positions: board.positions,
          finished: board is PuzzleFinished,
          cellSize: 10,
          size: size,
        ),
      ),
    );
  }
}

class _FinishedGame extends StatelessWidget {
  final Size size;

  const _FinishedGame({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var lastLevel = context.select((PuzzleCubit p) => p.state.level?.data.lastLevel ?? false);
    var uiHidden = context.select((PuzzleCubit p) => p.state.uiHidden);

    bool visible = lastLevel && !uiHidden;

    return Align(
      child: AnimatedOpacity( // later: optimize somehow
        duration: const Duration(milliseconds: 300),
        opacity: !uiHidden ? 1 : 0,
        curve: Curves.ease,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 3500),
          opacity: lastLevel ? 1 : 0,
          curve: Curves.easeInQuad,
          child: IgnorePointer (
            ignoring: !visible,
            child: Endgame(),
          ),
        ),
      ),
    );
  }
}

class _TransitionButton extends StatelessWidget {
  final Size size;

  const _TransitionButton({Key? key, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var isFinished = context.select((PuzzleCubit p) => p.state is PuzzleFinished);

    return Align(
      child: LevelTransition(
        gameFinished: isFinished,
        size: size,
      ),
    );
  }
}
