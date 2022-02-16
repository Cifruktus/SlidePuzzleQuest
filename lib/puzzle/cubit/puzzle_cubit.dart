import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:slide_puzzle/puzzle/levels.dart';
import 'package:slide_puzzle/puzzle/models/int_pos.dart';
import 'package:slide_puzzle/puzzle/models/level_info.dart';

import '../text_constructor.dart';

part 'puzzle_state.dart';

const freeCellIndex = 0;
const boardWidth = 4;
const boardHeight = 4;

class PuzzleCubit extends Cubit<PuzzleState> {
  factory PuzzleCubit(LevelResources initialLevel) {
    var board = generateBoard(boardWidth, boardHeight)..shuffleBoard();
    var positions = board.getCellPositions();
    var text = levelText([], initialLevel.data);
    return PuzzleCubit._(board, positions, initialLevel, text);
  }

  PuzzleCubit._(List<List<int>> board, List<IntPos> pos, LevelResources level, List<String> text)
      : super(
          PuzzleState(
            board: board,
            positions: board.getCellPositions(),
            gameNumber: 0,
            level: level,
            puzzleHidden: false,
            uiHidden: true,
            textHistory: text,
          ),
        );

  IntPos? getMoveDir(IntPos pos) {
    var free = findFreeCell(state.board)!;

    bool onTheSameLine = free.x == pos.x || free.y == pos.y;
    if (!onTheSameLine) return null;

    return (pos - free).normalize();
  }

  void move(IntPos pos) async {
    if (state is PuzzleFinished) return;

    var free = findFreeCell(state.board)!;

    bool onTheSameLine = free.x == pos.x || free.y == pos.y;
    if (!onTheSameLine) return;

    var movement = (pos - free).normalize(); // todo use getMoveDir
    var currentPos = free;

    var board = copyBoard(state.board);

    while (currentPos != pos) {
      var next = currentPos + movement;
      board[currentPos.x][currentPos.y] = board[next.x][next.y];
      currentPos = next;
    }
    board[currentPos.x][currentPos.y] = freeCellIndex;

    emit(state.copyWith(
      board: board,
      positions: board.getCellPositions(),
    ));

    if (!levelsMap.containsKey(MapKey(board))) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100)); // to wait animations to finish

    emit(PuzzleFinished(
      board: board,
      positions: board.getCellPositions(),
      gameNumber: state.gameNumber,
      level: state.level,
      next: await loadLevelFromKey(board),
      hidden: state.puzzleHidden,
      uiHidden: state.uiHidden,
      history: state.history,
      textHistory: state.textHistory,
    ));
  }

  void setPositions(List<List<int>> board) async {
    emit(state.copyWith(
      board: board,
      positions: board.getCellPositions(),
      gameNumber: state.gameNumber,
    ));
  }

  void nextGame() async {
    var state = this.state;

    if (state is PuzzleFinished) {
      var board = generateBoard(boardWidth, boardHeight)..shuffleBoard();
      var nextHistory = [...state.history, state.level!.data];
      var newDataInTextHistory = levelText(nextHistory, state.next.data);
      var previousBackground = state.level!.background;

      emit(PuzzleState(
        board: board,
        positions: board.getCellPositions(),
        gameNumber: state.gameNumber + 1,
        level: state.next,
        puzzleHidden: state.puzzleHidden,
        uiHidden: state.uiHidden,
        history: nextHistory,
        textHistory: newDataInTextHistory.isEmpty ? state.textHistory : [...state.textHistory, ...newDataInTextHistory],
      ));

      Future.delayed(const Duration(seconds: 5)).then((_) {
        previousBackground.dispose();
      });
    }
  }

  void setBoardHidden(bool hidden) {
    emit(state.copyWith(puzzleHidden: hidden));
  }

  void setUiHidden(bool hidden) {
    emit(state.copyWith(uiHidden: hidden));
  }
}

List<List<int>> generateBoard(int w, int h) {
  return List.generate(
      w,
      (iW) => List.generate(h, (iH) {
            return (iH == h - 1) && (iW == w - 1) ? freeCellIndex : iW + iH * h + 1;
          }));
}

extension BoardExtention on List<List<int>> {
  get board => this;

  void shuffleBoard() {
    var r = Random();

    var freeCell = const IntPos(boardWidth - 1, boardHeight - 1);

    // there is a better way to shuffle:
    // https://developerslogblog.wordpress.com/2020/04/01/how-to-shuffle-an-slide-puzzle/
    for (int i = 0; i < 200; i++) {
      var movement = r.nextBool() ? const IntPos(1, 0) : const IntPos(0, 1);
      if (r.nextBool()) movement = IntPos(-movement.x, -movement.y);

      var target = freeCell + movement;

      if (target.x < 0 || target.y < 0 || target.x >= boardWidth || target.y >= boardHeight) {
        movement = IntPos(-movement.x, -movement.y);
      }
      target = freeCell + movement;

      board[freeCell.x][freeCell.y] = board[target.x][target.y];
      freeCell = target;
      board[target.x][target.y] = freeCellIndex;
    }
  }

  List<IntPos> getCellPositions() {
    List<IntPos> positions = List.filled(length * this[0].length - 1, const IntPos(-1, -1));
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        if (board[i][j] == freeCellIndex) continue;
        positions[board[i][j] - 1] = IntPos(i, j);
      }
    }
    return positions;
  }

  List<List<int>> reflect() {
    List<List<int>> reflected = generateBoard(board[0].length, board.length);
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        reflected[j][i] = board[i][j];
      }
    }
    return reflected;
  }

  bool isSolved() {
    var ref = generateBoard(boardWidth, boardHeight);

    for (int i = 0; i < board.length; i++) {
      if (!listEquals(ref[i], board[i])) return false;
    }
    return true;
  }
}

IntPos? findFreeCell(List<List<int>> board) {
  for (int i = 0; i < board.length; i++) {
    for (int j = 0; j < board[0].length; j++) {
      if (board[i][j] == freeCellIndex) return IntPos(i, j);
    }
  }
  return null;
}

List<List<int>> copyBoard(List<List<int>> ref) {
  return List.generate(ref.length, (i) => List.from(ref[i]));
}
