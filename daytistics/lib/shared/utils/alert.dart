import 'package:flutter/material.dart';

void showErrorAlert(BuildContext context, String message) {
  showDialog<AlertDialog>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('An error occurred '),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
