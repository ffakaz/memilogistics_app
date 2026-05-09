import 'package:flutter/material.dart';

class SafePadding extends StatelessWidget {
  final Widget child;

  const SafePadding({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Padding(padding: MediaQuery.of(context).viewPadding + const EdgeInsets.all(8), child: child);
}
