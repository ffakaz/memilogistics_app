// lib/features/carrier/presentation/pages/carrier_company_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/carrier_company.dart';
import '../providers/carrier_company_provider.dart';
import '../widgets/carrier_profile_avatar.dart';
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
      context.read<CarrierCompanyProvider>().ensureProfileLoaded(
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrier Profile')),
      body: Consumer<CarrierCompanyProvider>(
        builder: (context, provider, _) {
          final state = provider.state;

          if (state.isLoading && state.company == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null && state.company == null) {
            return _MessageState(
              icon: Icons.cloud_off,
              title: 'Profile unavailable',
              message: state.error!,
              actionLabel: 'Retry',
              onAction: () => provider.ensureProfileLoaded(forceRefresh: true),
            );
          }

          final company = state.company;
          if (company == null) {
            return _MessageState(
              icon: Icons.business_outlined,
              title: 'Create carrier profile',
              message:
                  'A carrier company profile is required before dashboard tools are enabled.',
              actionLabel: 'Create Profile',
              onAction: () {
                provider.clearError();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateCarrierCompanyPage(),
                  ),
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.ensureProfileLoaded(forceRefresh: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileHeader(company: company),
                const SizedBox(height: 16),
                _InfoSection(
                  title: 'Company',
                  children: [
                    _InfoRow(label: 'Company name', value: company.companyName),
                    _InfoRow(
                      label: 'Company email',
                      value: company.companyEmail,
                    ),
                    _InfoRow(
                      label: 'Phone',
                      value: company.address.phoneNumber,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoSection(
                  title: 'Address',
                  children: [
                    _InfoRow(label: 'Street', value: company.address.street),
                    _InfoRow(label: 'City', value: company.address.city),
                    _InfoRow(label: 'State', value: company.address.state),
                    _InfoRow(label: 'Country', value: company.address.country),
                    _InfoRow(label: 'ZIP', value: company.address.zip),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      provider.clearError();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditCarrierCompanyPage(company: company),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit Profile'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final CarrierCompany company;

  const _ProfileHeader({required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CarrierProfileAvatar(profile: company, size: 72),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.companyName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.companyEmail,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(company.address.phoneNumber),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final safeValue = value.trim().isEmpty ? 'Not provided' : value.trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              safeValue,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 18),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}
