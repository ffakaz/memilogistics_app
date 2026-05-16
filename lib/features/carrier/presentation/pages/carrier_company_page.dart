// lib/features/carrier/presentation/pages/carrier_company_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/carrier_company_provider.dart';

import 'create_carrier_company_page.dart';
import 'edit_carrier_company_page.dart';

class CarrierCompanyPage extends StatefulWidget {
  const CarrierCompanyPage({super.key});

  @override
  State<CarrierCompanyPage> createState() => _CarrierCompanyPageState();
}

class _CarrierCompanyPageState extends State<CarrierCompanyPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarrierCompanyProvider>().getCarrierCompany();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrier Company')),

      body: Consumer<CarrierCompanyProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Text(state.error!, textAlign: TextAlign.center),
              ),
            );
          }

          final company = state.company;

          if (company == null) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateCarrierCompanyPage(),
                    ),
                  );
                },

                child: const Text('Create Carrier Company'),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Card(
              elevation: 3,

              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      company.companyName,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(company.companyEmail),

                    const SizedBox(height: 8),

                    Text(company.address.phoneNumber),

                    const Divider(height: 32),

                    const Text(
                      'Address',

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(company.address.street),

                    Text(company.address.city),

                    Text(company.address.state),

                    Text(company.address.country),

                    Text(company.address.zip),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,

                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditCarrierCompanyPage(company: company),
                            ),
                          );
                        },

                        child: const Text('Edit Company'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
