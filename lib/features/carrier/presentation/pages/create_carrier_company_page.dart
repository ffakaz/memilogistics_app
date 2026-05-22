// lib/features/carrier/presentation/pages/create_carrier_company_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/carrier_company.dart';

import '../providers/carrier_company_provider.dart';

import '../widgets/carrier_company_form.dart';

class CreateCarrierCompanyPage extends StatelessWidget {
  final bool showAppBar;
  final bool isMandatory;

  const CreateCarrierCompanyPage({
    super.key,
    this.showAppBar = true,
    this.isMandatory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(title: const Text('Create Carrier Profile'))
          : null,
      body: Consumer<CarrierCompanyProvider>(
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
                    'Complete your carrier profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your company profile is required before accessing carrier dashboard tools.',
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

                CarrierCompanyForm(
                  isLoading: state.isLoading,
                  submitLabel: isMandatory
                      ? 'Complete Profile'
                      : 'Create Profile',
                  onSubmit:
                      ({
                        required companyName,
                        required companyEmail,
                        required phoneNumber,
                        required street,
                        required city,
                        required state,
                        required country,
                        required postalCode,
                      }) async {
                        final company = CarrierCompany(
                          id: 0,
                          companyName: companyName,
                          companyEmail: companyEmail,
                          address: Address(
                            street: street,
                            city: city,
                            state: state,
                            zip: postalCode,
                            country: country,
                            phoneNumber: phoneNumber,
                          ),
                        );

                        await provider.createCarrierCompany(company);

                        if (!context.mounted) return;

                        final currentState = provider.state;
                        if (currentState.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Carrier company created successfully',
                              ),
                            ),
                          );

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
