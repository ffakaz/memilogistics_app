import 'package:flutter/material.dart';

class AppBottomSheet {
  static Future<T?> show<T>(BuildContext context, Widget child) async {
    return showModalBottomSheet<T>(context: context, builder: (_) => child);
  }
}
