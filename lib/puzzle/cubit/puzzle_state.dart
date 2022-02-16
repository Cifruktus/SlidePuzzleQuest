part of 'puzzle_cubit.dart';

@immutable
class PuzzleState {
  final int gameNumber;
  final LevelResources? level; // remove "?"
  final List<List<int>> board;
  final List<IntPos> positions;
  final bool puzzleHidden;
  final bool uiHidden;
  final List<Level> history;
  final List<String> textHistory;

  List<String> get currentHistory => [...history.map((p) => p.text!), level!.data.text!];

  const PuzzleState({
    required this.board,
    required this.positions,
    required this.gameNumber,
    required this.puzzleHidden,
    required this.uiHidden,
    this.level,
    this.history = const [],
    this.textHistory = const [],
  });

  PuzzleState copyWith({
    LevelResources? next,
    int? gameNumber,
    LevelResources? level,
    List<List<int>>? board,
    List<IntPos>? positions,
    bool? puzzleHidden,
    bool? uiHidden,
    List<Level>? history,
    List<String>? textHistory,
  }) {
    return PuzzleState(
      gameNumber: gameNumber ?? this.gameNumber,
      level: level ?? this.level,
      board: board ?? this.board,
      positions: positions ?? this.positions,
      puzzleHidden: puzzleHidden ?? this.puzzleHidden,
      uiHidden: uiHidden ?? this.uiHidden,
      history: history ?? this.history,
      textHistory: textHistory ?? this.textHistory,
    );
  }
}

class PuzzleFinished extends PuzzleState {
  final LevelResources next;

  const PuzzleFinished({
    required this.next,
    required List<List<int>> board,
    required List<IntPos> positions,
    required int gameNumber,
    required LevelResources? level,
    required bool hidden,
    required bool uiHidden,
    required List<Level> history,
    required List<String> textHistory,
  }) : super(
          gameNumber: gameNumber,
          level: level,
          board: board,
          positions: positions,
          puzzleHidden: hidden,
          uiHidden: uiHidden,
          history: history,
          textHistory: textHistory,
        );

  @override
  PuzzleFinished copyWith({
    LevelResources? next,
    int? gameNumber,
    LevelResources? level,
    List<List<int>>? board,
    List<IntPos>? positions,
    bool? puzzleHidden,
    bool? uiHidden,
    List<Level>? history,
    List<String>? textHistory,
  }) {
    return PuzzleFinished(
      gameNumber: gameNumber ?? this.gameNumber,
      level: level ?? this.level,
      board: board ?? this.board,
      positions: positions ?? this.positions,
      hidden: puzzleHidden ?? this.puzzleHidden,
      uiHidden: uiHidden ?? this.uiHidden,
      next: next ?? this.next,
      history: history ?? this.history,
      textHistory: textHistory ?? this.textHistory,
    );
  }
}
