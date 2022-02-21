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

  const PuzzleHint({Key? key, required this.board}) : super(key: key);

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
      return StoryButton(
        key: storyButtonKey,
        data: data,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomIconButton(
              //color: Colors.green,
              icon: const Icon(Icons.remove_red_eye_rounded),
              onClick: () {
                var puzzle = context.read<PuzzleCubit>();
                puzzle.setBoardHidden(!puzzle.state.puzzleHidden);
              },
            ),
            CustomIconButton(
              //color: Colors.green,
              icon: const Icon(Icons.volume_up_rounded),

             //onClick: () {
             //  var puzzle = context.read<PuzzleCubit>();
             //  puzzle.setBoardHidden(!puzzle.state.puzzleHidden);
             // },
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.black26)],
            border: Border.all(
              width: 1,
              color: Colors.white70,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            //color: Colors.black38,
            //backgroundBlendMode: BlendMode.hardLight,
            //color: Colors.deepPurple.withAlpha(120),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: lines.map((line) => Row(children: line)).toList(),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            StoryButton(
              key: storyButtonKey,
              data: data,
            ),
            CustomIconButton(
              //color: Colors.green,
              icon: Text("i", style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 24,
              ),), // todo
              onClick: () {
                showAboutPage(context);
              },
            ),
          ],
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
        boxShadow: [
          BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.black26)
        ],
        border: Border.all(
          width: 1,
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
                side: BorderSide(
                  color: Colors.white70,
                  width: 1,
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
        return CustomMarkdownDialog(
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
