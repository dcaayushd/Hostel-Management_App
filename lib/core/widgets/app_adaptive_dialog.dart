import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool> showAppConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
}) async {
  final Brightness brightness = Theme.of(context).brightness;
  final bool? confirmed = await showCupertinoDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return CupertinoTheme(
        data: CupertinoThemeData(brightness: brightness),
        child: CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            CupertinoDialogAction(
              isDestructiveAction: isDestructive,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    },
  );
  return confirmed ?? false;
}
