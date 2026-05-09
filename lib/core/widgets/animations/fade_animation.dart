import 'package:flutter/material.dart';

class FadeAnimation extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeAnimation({super.key, required this.child, this.duration = const Duration(milliseconds: 300)});

  @override
  Widget build(BuildContext context) => AnimatedOpacity(opacity: 1, duration: duration, child: child);
}
