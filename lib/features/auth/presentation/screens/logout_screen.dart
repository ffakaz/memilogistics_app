import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Logout')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await auth.logout();

            if (!context.mounted) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
