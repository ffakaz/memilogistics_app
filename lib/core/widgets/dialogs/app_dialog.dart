import 'package:flutter/material.dart';

class AppDialog {
  static Future<void> show(BuildContext context, Widget child) async {
    return showDialog(context: context, builder: (_) => AlertDialog(content: child));
  }
}
