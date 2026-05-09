import 'package:flutter/material.dart';

class AppStreamBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncWidgetBuilder<T> builder;

  const AppStreamBuilder({super.key, required this.stream, required this.builder});

  @override
  Widget build(BuildContext context) => StreamBuilder<T>(stream: stream, builder: builder);
}
