import 'package:flutter/material.dart';

class AppAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppAppbar({super.key, required this.title});

  @override
  Widget build(BuildContext context) => AppBar(title: Text(title));

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
