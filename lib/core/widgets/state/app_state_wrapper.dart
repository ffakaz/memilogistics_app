import 'package:flutter/material.dart';

class AppStateWrapper extends StatelessWidget {
  final Widget child;

  const AppStateWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}
