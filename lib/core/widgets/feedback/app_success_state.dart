import 'package:flutter/material.dart';

class AppSuccessState extends StatelessWidget {
  final String message;

  const AppSuccessState({super.key, this.message = 'Success!'});

  @override
  Widget build(BuildContext context) => Center(child: Text(message, style: const TextStyle(color: Colors.green)));
}
