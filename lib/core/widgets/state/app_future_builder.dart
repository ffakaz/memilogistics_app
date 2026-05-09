import 'package:flutter/material.dart';

class AppFutureBuilder<T> extends StatelessWidget {
  final Future<T> future;
  final AsyncWidgetBuilder<T> builder;

  const AppFutureBuilder({super.key, required this.future, required this.builder});

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(future: future, builder: builder);
}
