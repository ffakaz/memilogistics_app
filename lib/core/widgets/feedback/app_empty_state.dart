import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  final String message;

  const AppEmptyState({super.key, this.message = 'Nothing here yet.'});

  @override
  Widget build(BuildContext context) => Center(child: Text(message));
}
