import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;

  const AppText(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(text);
}
