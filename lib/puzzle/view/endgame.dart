import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:slide_puzzle/puzzle/view/widgets.dart';

import '../cringe.dart';

class Endgame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 500,
      ),
      child: CustomContainer(
        child: CustomMarkdownBody(
          data: credits,
        ),
      ),
    );
  }
}
