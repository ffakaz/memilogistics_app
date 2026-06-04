import 'package:flutter/material.dart';
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(child: Text('Menu')),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.popAndPushNamed(context, RouteConstants.home),
          ),
          ListTile(
            leading: const Icon(Icons.local_shipping),
            title: const Text('Carrier Dashboard'),
            onTap: () => Navigator.popAndPushNamed(context, RouteConstants.carrierDashboard),
          ),
        ],
      ),
    );
  }
}
