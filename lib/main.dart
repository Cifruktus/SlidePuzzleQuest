import 'dart:async';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/puzzle/view/page.dart';

Future<void> main() async {
  //timeDilation = 2.5;

  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          highlightColor: const Color(0xffffc600)
      ),
      home: PuzzlePage.route(context),
    );
  }
}
