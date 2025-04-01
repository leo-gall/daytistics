import 'package:daytistics/config/settings.dart';
import 'package:daytistics/main.dart';
import 'package:daytistics/shared/widgets/styled/styled_text.dart';
import 'package:flutter/material.dart';

enum ToastType {
  success,
  error,
  info,
}

void showErrorDialog(BuildContext context, {required String message}) {
  showDialog<AlertDialog>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Something went wrong!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Ok'),
          ),
        ],
      );
    },
  );
}

void showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required void Function() onConfirm,
  void Function()? onCancel,
  bool popBeforeConfirm = false,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool disableOutsideClickClose = false,
}) {
  showDialog<AlertDialog>(
    context: context,
    barrierDismissible: !disableOutsideClickClose,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (onCancel != null) {
                onCancel();
              }
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              backgroundColor:
                  WidgetStateProperty.all<Color>(Colors.transparent),
            ),
            child: StyledText(
              cancelText,
              style: const TextStyle(color: ColorSettings.error),
            ),
          ),
          TextButton(
            onPressed: () {
              if (popBeforeConfirm) {
                Navigator.of(context).pop();
                onConfirm();
              } else {
                onConfirm();
                Navigator.of(context).pop();
              }
            },
            child: StyledText(confirmText),
          ),
        ],
      );
    },
  );
}

void showToast({
  required String message,
  BuildContext? context,
  ToastType type = ToastType.success,
  int duration = 1,
}) {
  final Color backgroundColor = type == ToastType.success
      ? ColorSettings.success
      : type == ToastType.error
          ? ColorSettings.error
          : ColorSettings.info;

  final snackBar = SnackBar(
    backgroundColor: backgroundColor,
    duration: Duration(seconds: duration),
    content: Text(message),
  );

  if (context != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
    );
  } else {
    DaytisticsApp.scaffoldMessengerKey.currentState?.showSnackBar(
      snackBar,
    );
  }
}

void showBottomDialog(
  BuildContext context, {
  required Widget child,
  bool minimizeSize = true,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(10),
        topRight: Radius.circular(10),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            child,
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
