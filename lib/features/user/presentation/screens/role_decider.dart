import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';

class RoleDecider extends StatefulWidget {
  const RoleDecider({super.key});

  @override
  State<RoleDecider> createState() => _RoleDeciderState();
}

class _RoleDeciderState extends State<RoleDecider> {
  static const _storageKey = 'user.selected_role';

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final storage = context.read<SecureStorageService>();
    final has = await storage.containsKey(_storageKey);
    if (!mounted) return;

    if (!has) {
      Navigator.of(context).pushReplacementNamed('/select-role');
      return;
    }

    await storage.read(_storageKey);
    if (!mounted) return;

    // Home screen not used currently — route everyone into shipment dashboard
    Navigator.of(context).pushReplacementNamed('/dashboard');
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
