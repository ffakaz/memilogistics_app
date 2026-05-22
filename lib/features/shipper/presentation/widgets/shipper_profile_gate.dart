import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../pages/create_shipper_company_page.dart';
import '../providers/shipper_company_provider.dart';
import '../states/shipper_company_state.dart';

class ShipperProfileGate extends StatefulWidget {
  final Widget child;

  const ShipperProfileGate({super.key, required this.child});

  @override
  State<ShipperProfileGate> createState() => _ShipperProfileGateState();
}

class _ShipperProfileGateState extends State<ShipperProfileGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipperCompanyProvider>().ensureProfileLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().userRole?.toUpperCase();
    if (role == 'CARRIER') return widget.child;

    return Consumer<ShipperCompanyProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        if (state.status == ShipperProfileStatus.initial || state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == ShipperProfileStatus.error) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 42),
                    const SizedBox(height: 16),
                    Text(
                      state.error ?? 'Unable to verify your shipper profile.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () =>
                          provider.ensureProfileLoaded(forceRefresh: true),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state.isMissing) {
          return const CreateShipperCompanyPage(
            showAppBar: false,
            isMandatory: true,
          );
        }

        return widget.child;
      },
    );
  }
}
