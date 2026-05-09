import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const _storageKey = 'user.selected_role';

  void _selectRole(BuildContext context, String role) async {
    final storage = context.read<SecureStorageService>();
    await storage.write(key: _storageKey, value: role);

    // For now, route all roles into the shipment dashboard flow. Home
    // (multi-tab) screen is disabled while backend integration is pending.
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Which role best describes you? You can change this later.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'shipper'),
              child: const Text('Shipper'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'carrier'),
              child: const Text('Carrier'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _selectRole(context, 'admin'),
              child: const Text('Admin (internal)'),
            ),
          ],
        ),
      ),
    );
  }
}
