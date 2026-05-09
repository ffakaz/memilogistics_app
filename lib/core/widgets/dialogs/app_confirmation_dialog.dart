import 'package:flutter/material.dart';
class AppConfirmationDialog {
  static Future<bool?> show(BuildContext context, {required String title, String? message}) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: message == null ? null : Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('OK')),
        ],
      ),
    );
  }
}
