import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/shipper_company.dart';
import '../providers/shipper_company_provider.dart';
import '../widgets/shipper_profile_avatar.dart';
import 'create_shipper_company_page.dart';
import 'edit_shipper_company_page.dart';

class ShipperCompanyPage extends StatefulWidget {
  const ShipperCompanyPage({super.key});

  @override
  State<ShipperCompanyPage> createState() => _ShipperCompanyPageState();
}

class _ShipperCompanyPageState extends State<ShipperCompanyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipperCompanyProvider>().ensureProfileLoaded(
        forceRefresh: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<ShipperCompanyProvider>(
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
              icon: Icons.account_circle_outlined,
              title: 'Create your shipper profile',
              message:
                  'A business profile is required before shipment tools are enabled.',
              actionLabel: 'Create Profile',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateShipperCompanyPage(),
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
                  title: 'Business',
                  children: [
                    _InfoRow(label: 'Company', value: company.companyName),
                    _InfoRow(
                      label: 'Business name',
                      value: company.businessName,
                    ),
                    _InfoRow(label: 'Email', value: company.companyEmail),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoSection(
                  title: 'Contact',
                  children: [
                    _InfoRow(label: 'Full name', value: company.fullName),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditShipperCompanyPage(company: company),
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
  final ShipperCompany company;

  const _ProfileHeader({required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ShipperProfileAvatar(profile: company, size: 72),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.fullName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    company.companyName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (company.companyEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      company.companyEmail,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
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
