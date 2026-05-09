import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const AppScaffold({super.key, required this.body, this.appBar});

  @override
  Widget build(BuildContext context) => Scaffold(appBar: appBar, body: SafeArea(child: body));
}
