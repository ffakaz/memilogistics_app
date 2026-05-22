// lib/features/carrier/presentation/pages/edit_carrier_company_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/address.dart';
import '../../domain/entities/carrier_company.dart';

import '../providers/carrier_company_provider.dart';

import '../widgets/carrier_company_form.dart';

class EditCarrierCompanyPage extends StatelessWidget {
  final CarrierCompany company;

  const EditCarrierCompanyPage({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Carrier Company')),

      body: Consumer<CarrierCompanyProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [
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
                  initialCompany: company,
                  submitLabel: 'Update Profile',

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
                        final updatedCompany = CarrierCompany(
                          id: company.id,
                          companyName: companyName,
                          companyEmail: companyEmail,
                          address: Address(
                            id: company.address.id,
                            street: street,
                            city: city,
                            state: state,
                            zip: postalCode,
                            country: country,
                            phoneNumber: phoneNumber,
                          ),
                        );

                        await provider.updateCarrierCompany(updatedCompany);

                        if (!context.mounted) {
                          return;
                        }

                        final currentState = provider.state;

                        if (currentState.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Carrier company updated successfully',
                              ),
                            ),
                          );

                          Navigator.pop(context);
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
