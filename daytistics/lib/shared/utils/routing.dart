import 'package:flutter/material.dart';

void pushAndClearHistory(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<Widget>(builder: (context) => page),
    (route) => false,
  );
}
