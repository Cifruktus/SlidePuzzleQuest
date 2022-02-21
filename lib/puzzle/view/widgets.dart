import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class CustomMarkdownDialog extends StatefulWidget {
  final bool reversed;
  final String data;

  const CustomMarkdownDialog({Key? key, required this.data, this.reversed = false}) : super(key: key);

  @override
  State<CustomMarkdownDialog> createState() => _CustomMarkdownDialogState();
}

class _CustomMarkdownDialogState extends State<CustomMarkdownDialog> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        side: BorderSide(color: Colors.white70),
      ),
      backgroundColor: Colors.black26,
      elevation: 3,
      contentTextStyle: const TextStyle(color: Colors.white),
      content: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
            scrollbars: false
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 420,
                    maxWidth: 400,
                  ),
                  child: RawScrollbar(
                     controller: _scrollController,
                    thumbColor: Colors.white,
                    radius: const Radius.circular(20),
                    isAlwaysShown: true,
                    thickness: 5,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      reverse: widget.reversed,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CustomMarkdownBody(
                        data: widget.data,
                      ),
                    ),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    child: const Text("Ok"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                      padding: MaterialStateProperty.all(const EdgeInsets.all(5)),
                      //  maximumSize: MaterialStateProperty.all(Size(50, 50)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(
                            color: Colors.white70,
                          )
                          )),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomMarkdownBody extends StatelessWidget {
  static final MarkdownStyleSheet styleSheet = MarkdownStyleSheet(
      textScaleFactor: 1.2,
      p: const TextStyle(color: Colors.white),
      h1: const TextStyle(color: Colors.white),
      a: const TextStyle(color: Color(0xFF6AC3FF)),
      horizontalRuleDecoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            width: 5.0,
            color: Colors.white,
          ),
        ),
      ));

  final String data;

  const CustomMarkdownBody({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      onTapLink: (text, String? href, title) {
        _launchURL(href);
      },
      data: data,
      styleSheet: styleSheet,
    );
  }

  void _launchURL(String? url) async {
    if (!await launch(url!)) throw 'Could not launch $url';
  }
}

class CustomContainer extends StatelessWidget {
  final Widget child;

  const CustomContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [BoxShadow(blurRadius: 2, offset: Offset(1, 1), color: Colors.black26)],
        border: Border.all(
          color: Colors.white70,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(10),
      child: child,
    );
  }
}
