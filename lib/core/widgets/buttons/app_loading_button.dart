import 'package:flutter/material.dart';

class AppLoadingButton extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final VoidCallback? onPressed;

  const AppLoadingButton({super.key, required this.isLoading, required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : child,
    );
  }
}
