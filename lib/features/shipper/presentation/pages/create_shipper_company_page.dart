// lib/features/shipper/presentation/pages/create_shipper_company_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../carrier/domain/entities/address.dart';
import '../../domain/entities/shipper_company.dart';
import '../providers/shipper_company_provider.dart';
import '../widgets/shipper_company_form.dart';

/// Create Shipper Company Page
///
/// Page for creating a new shipper company profile.
/// Used when shippers first register and need to complete their profile.
class CreateShipperCompanyPage extends StatelessWidget {
  final bool showAppBar;
  final bool isMandatory;

  const CreateShipperCompanyPage({
    super.key,
    this.showAppBar = true,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: const Text('Create Shipper Profile'))
          : null,
      body: Consumer<ShipperCompanyProvider>(
        builder: (context, provider, _) {
          final state = provider.state;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isMandatory) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Complete your shipper profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your verified business profile is required before creating or managing shipments.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (state.error != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                ShipperCompanyForm(
                  isLoading: state.isLoading,
                  submitLabel: isMandatory
                      ? 'Complete Profile'
                      : 'Create Profile',
                  onSubmit:
                      ({
                        required firstName,
                        required lastName,
                        required companyName,
                        required businessName,
                        required phoneNumber,
                        required street,
                        required city,
                        required state,
                        required country,
                        required postalCode,
                      }) async {
                        final company = ShipperCompany(
                          id: 0,
                          firstName: firstName,
                          lastName: lastName,
                          companyName: companyName,
                          businessName: businessName,
                          companyEmail: '',
                          address: Address(
                            street: street,
                            city: city,
                            state: state,
                            zip: postalCode,
                            country: country,
                            phoneNumber: phoneNumber,
                          ),
                        );

                        await provider.createShipperCompany(company);

                        if (!context.mounted) return;

                        final currentState = provider.state;
                        if (currentState.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Shipper company created successfully',
                              ),
                            ),
                          );

                          // If embedded (no app bar), trigger a rebuild of parent
                          // Otherwise, pop the navigation
                          if (showAppBar) {
                            Navigator.pop(context);
                          }
                        }
                      },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
