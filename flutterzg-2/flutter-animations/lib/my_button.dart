import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  MyButton({Key key, this.click, this.text}) : super(key: key);

  VoidCallback click;
  Widget text;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid ? RaisedButton(
      onPressed: click,
      child: text,
    ) : CupertinoButton(
      onPressed: click,
      child: text,
    );
  }
}
