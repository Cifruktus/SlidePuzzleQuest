import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:slide_puzzle/puzzle/cubit/puzzle_cubit.dart';
import 'package:badges/badges.dart';
import 'package:slide_puzzle/puzzle/view/widgets.dart';

import '../cringe.dart';
import '../levels.dart';

final storyButtonKey = GlobalKey();

class PuzzleHint extends StatelessWidget {
  final List<List<int>> board;
  final bool horizontal;

  const PuzzleHint({Key? key, required this.board, this.horizontal = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = context.select((PuzzleCubit cub) => cub.state.textHistory);

    var lines = List.generate(board[0].length, (_) => List<Widget>.empty(growable: true));

    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[0].length; j++) {
        lines[j].add(HintCell(index: board[i][j] <= 0 ? "" : "${board[i][j]}"));
      }
    }

    if (board == level0Hint) {
      return StoryButton (
        key: storyButtonKey,
        data: data,
      );
    }

    var boardHint = Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.black26),
        ],
        border: Border.all(
          color: Colors.white70,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: lines.map((line) => Row(children: line, mainAxisSize: MainAxisSize.min,)).toList(),
      ),
    );

    var toolsPrimary = [
      CustomIconButton(
        //color: Colors.green,
        icon: const Icon(Icons.remove_red_eye_rounded),
        onClick: () {
          var puzzle = context.read<PuzzleCubit>();
          puzzle.setBoardHidden(!puzzle.state.puzzleHidden);
        },
      ),
      const CustomIconButton(
        icon: Icon(Icons.volume_up_rounded),
      ),
    ];

    var toolsSecondary = [
      StoryButton(
        key: storyButtonKey,
        data: data,
      ),
      CustomIconButton(
        //color: Colors.green,
        icon: const Text(
          "i",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        onClick: () {
          showAboutPage(context);
        },
      ),
    ];

    return horizontal
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: toolsPrimary,
              ),
              boardHint,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: toolsSecondary,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            verticalDirection: VerticalDirection.up,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: toolsPrimary,
              ),
              boardHint,
              Row(
                mainAxisSize: MainAxisSize.min,
                children: toolsSecondary,
              ),
            ],
          );
  }
}

class HintCell extends StatelessWidget {
  final String index;

  const HintCell({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        // backgroundBlendMode: BlendMode.hardLight,
        // color: Colors.deepPurple.withAlpha(120),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.black26)
        ],
        border: Border.all(
          color: Colors.white70,
        ),
      ),
      child: Center(
        child: Text(
          index,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final Widget icon;
  final void Function()? onClick;
  final bool badgeEnabled;

  const CustomIconButton({Key? key, required this.icon, this.onClick, this.badgeEnabled = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Badge(
        position: BadgePosition.topEnd(top: -6, end: -2),
        badgeContent: const Text(
          "!",
          style: TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
        padding: const EdgeInsets.all(6.0),
        showBadge: badgeEnabled,
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(3),
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
            minimumSize: MaterialStateProperty.all(const Size(50, 50)),
            //  maximumSize: MaterialStateProperty.all(Size(50, 50)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
                side: const BorderSide(
                  color: Colors.white70,
                )
                //  side: BorderSide(color: Colors.red),
                )),
          ),
          onPressed: onClick,
          child: icon,
        ),
      ),
    );
  }
}

class StoryButton extends StatefulWidget {
  final dynamic data;

  const StoryButton({Key? key, required this.data}) : super(key: key);

  @override
  _StoryButtonState createState() => _StoryButtonState();
}

class _StoryButtonState extends State<StoryButton> {
  bool unread = false;

  @override
  Widget build(BuildContext context) {
    return CustomIconButton(
      badgeEnabled: unread,
      icon: const Icon(Icons.textsms),
      onClick: () {
        setState(() {
          unread = false;
        });
        showLore(context);
      },
    );
  }

  @override
  void didUpdateWidget(covariant StoryButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.data != oldWidget.data) {
      unread = true;
    }
  }
}

void showAboutPage(BuildContext context) {
  context.read<PuzzleCubit>().setUiHidden(true);
  showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (c) {
        return const CustomMarkdownDialog(
          data: about,
        );
      }).then((result) {
    context.read<PuzzleCubit>().setUiHidden(false);
    context.read<PuzzleCubit>().setBoardHidden(false);
  });
}

void showLore(BuildContext context) {
  context.read<PuzzleCubit>().setUiHidden(true);
  showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (c) {
        var game = context.read<PuzzleCubit>().state.textHistory;

        var text = game.reduce((s1, s2) => "$s1 \n****\n $s2");

        return CustomMarkdownDialog(
          data: text,
          reversed: true,
        );
      }).then((result) {
    context.read<PuzzleCubit>().setUiHidden(false);
    context.read<PuzzleCubit>().setBoardHidden(false);
  });
}
