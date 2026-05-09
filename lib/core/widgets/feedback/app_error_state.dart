import 'package:flutter/material.dart';

class AppErrorState extends StatelessWidget {
  final String message;

  const AppErrorState({super.key, this.message = 'Something went wrong.'});

  @override
  Widget build(BuildContext context) => Center(child: Text(message, style: const TextStyle(color: Colors.red)));
}
