import 'package:daytistics_app/shared/widgets/styled_text.dart';
import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
PreferredSizeWidget StyledAppBar({
  required String title,
}) {
  return AppBar(
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 4),
        StyledTitle(title),
      ],
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: () {},
      ),
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  );
}
