import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';
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
            if (context.mounted) {
              context.read<ShipperCompanyProvider>().clearProfile();
              context.read<CarrierCompanyProvider>().clearProfile();
            }

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
