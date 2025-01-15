import 'package:flutter/material.dart';

void pushAndClearHistory(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<Widget>(builder: (BuildContext context) => page),
    (Route<dynamic> route) => false,
  );
}
