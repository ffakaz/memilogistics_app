import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../auth/presentation/provider/auth_provider.dart';
import '../pages/create_carrier_company_page.dart';
import '../providers/carrier_company_provider.dart';
import '../states/carrier_company_state.dart';

class CarrierProfileGate extends StatefulWidget {
  final Widget child;

  const CarrierProfileGate({super.key, required this.child});

  @override
  State<CarrierProfileGate> createState() => _CarrierProfileGateState();
}

class _CarrierProfileGateState extends State<CarrierProfileGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarrierCompanyProvider>().ensureProfileLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final role = context.watch<AuthProvider>().userRole?.toUpperCase();
    if (role == 'SHIPPER') return widget.child;

    return Consumer<CarrierCompanyProvider>(
      builder: (context, provider, _) {
        final state = provider.state;

        if (state.status == CarrierProfileStatus.initial ||
            state.status == CarrierProfileStatus.loading ||
            state.status == CarrierProfileStatus.loggedOut) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == CarrierProfileStatus.error &&
            state.company == null) {
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
                      state.error ?? 'Unable to verify your carrier profile.',
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
          return const CreateCarrierCompanyPage(
            showAppBar: false,
            isMandatory: true,
          );
        }

        return widget.child;
      },
    );
  }
}
