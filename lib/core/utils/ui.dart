import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content:
          Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: error ? AppTheme.danger : AppTheme.success,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: error ? 4 : 2),
    ),
  );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'تأكيد',
  String cancelText = 'إلغاء',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: AppTheme.danger)
              : null,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
