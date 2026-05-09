import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(padding: EdgeInsets.zero, children: const [DrawerHeader(child: Text('Menu')), ListTile(title: Text('Home'))]));
  }
}
