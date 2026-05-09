import 'package:flutter/material.dart';

class AppErrorDialog {
  static Future<void> show(BuildContext context, String error) async {
    return showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Error'), content: Text(error)));
  }
}
