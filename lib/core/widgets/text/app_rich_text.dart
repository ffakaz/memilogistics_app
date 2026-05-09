import 'package:flutter/material.dart';

class AppRichText extends StatelessWidget {
  final TextSpan textSpan;

  const AppRichText({super.key, required this.textSpan});

  @override
  Widget build(BuildContext context) => RichText(text: textSpan);
}
