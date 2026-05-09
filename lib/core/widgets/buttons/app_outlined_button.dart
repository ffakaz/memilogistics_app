import 'package:flutter/material.dart';

class AppOutlinedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const AppOutlinedButton({super.key, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onPressed, child: child);
  }
}
