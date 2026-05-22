import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../carrier/domain/entities/address.dart';
import '../../domain/entities/shipper_company.dart';
import '../providers/shipper_company_provider.dart';
import '../widgets/shipper_company_form.dart';

class EditShipperCompanyPage extends StatelessWidget {
  final ShipperCompany company;

  const EditShipperCompanyPage({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Consumer<ShipperCompanyProvider>(
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
                      color: Theme.of(
                        context,
                      ).colorScheme.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ShipperCompanyForm(
                  initialCompany: company,
                  isLoading: state.isLoading,
                  submitLabel: 'Update Profile',
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
                        final updatedCompany = company.copyWith(
                          firstName: firstName,
                          lastName: lastName,
                          companyName: companyName,
                          businessName: businessName,
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

                        await provider.updateShipperCompany(updatedCompany);

                        if (!context.mounted) return;
                        if (provider.state.error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Profile updated')),
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
