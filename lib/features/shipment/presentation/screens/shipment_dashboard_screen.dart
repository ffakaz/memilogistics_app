// lib/features/shipment/presentation/screens/shipment_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:memilogistics_app/core/utils/constants/route_constants.dart';
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/shipment/domain/entities/dashboard_information.dart';
import 'package:memilogistics_app/features/shipment/domain/entities/shipment.dart';
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';
import 'package:memilogistics_app/features/shipper/domain/entities/shipper_company.dart';
import 'package:memilogistics_app/features/shipper/presentation/pages/edit_shipper_company_page.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/widgets/shipper_profile_avatar.dart';

class ShipmentDashboardScreen extends StatefulWidget {
  const ShipmentDashboardScreen({super.key});

  @override
  State<ShipmentDashboardScreen> createState() =>
      _ShipmentDashboardScreenState();
}

class _ShipmentDashboardScreenState extends State<ShipmentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentProvider>()
        ..getDashboardInformation()
        ..getMyShipments();
    });
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<ShipperCompanyProvider>().ensureProfileLoaded(
        forceRefresh: true,
      ),
      context.read<ShipmentProvider>().getDashboardInformation(),
      context.read<ShipmentProvider>().getMyShipments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ShipperCompanyProvider, ShipmentProvider>(
      builder: (context, shipperProvider, shipmentProvider, _) {
        final profile = shipperProvider.state.company;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          appBar: AppBar(
            title: const Text('Dashboard'),
            actions: [
              _ProfileMenu(profile: profile),
              const SizedBox(width: 10),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _WelcomePanel(profile: profile),
                const SizedBox(height: 18),
                _SectionTitle(
                  title: 'Shipment Overview',
                  actionLabel: shipmentProvider.isDashboardLoading
                      ? 'Loading'
                      : null,
                ),
                const SizedBox(height: 12),
                _DashboardStatsGrid(
                  info: shipmentProvider.dashboardInformation,
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _QuickActions(
                  onCreateShipment: () {
                    Navigator.pushNamed(context, RouteConstants.createShipment);
                  },
                  onViewShipments: () {
                    Navigator.pushNamed(context, RouteConstants.myShipments);
                  },
                ),
                const SizedBox(height: 20),
                _SectionTitle(title: 'Recent Shipments'),
                const SizedBox(height: 12),
                _RecentShipments(
                  shipments: shipmentProvider.shipments.take(4).toList(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                Navigator.pushNamed(context, RouteConstants.createShipment),
            icon: const Icon(Icons.add),
            label: const Text('New Shipment'),
          ),
        );
      },
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  final ShipperCompany? profile;

  const _ProfileMenu({required this.profile});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ProfileAction>(
      tooltip: 'Profile menu',
      offset: const Offset(0, 52),
      onSelected: (action) async {
        switch (action) {
          case _ProfileAction.view:
            Navigator.pushNamed(context, RouteConstants.shipperProfile);
            break;
          case _ProfileAction.edit:
            final company = profile;
            if (company == null) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditShipperCompanyPage(company: company),
              ),
            );
            break;
          case _ProfileAction.logout:
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            context.read<ShipperCompanyProvider>().clearProfile();
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteConstants.login,
              (_) => false,
            );
            break;
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _ProfileAction.view,
          child: ListTile(
            leading: Icon(Icons.person_outline),
            title: Text('View Profile'),
          ),
        ),
        PopupMenuItem(
          value: _ProfileAction.edit,
          child: ListTile(
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit Profile'),
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _ProfileAction.logout,
          child: ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
        ),
      ],
      child: ShipperProfileAvatar(profile: profile, size: 42),
    );
  }
}

enum _ProfileAction { view, edit, logout }

class _WelcomePanel extends StatelessWidget {
  final ShipperCompany? profile;

  const _WelcomePanel({required this.profile});

  @override
  Widget build(BuildContext context) {
    final company = profile;
    final firstName = company?.firstName.trim().isNotEmpty == true
        ? company!.firstName.trim()
        : 'there';
    final business = company?.businessName.trim().isNotEmpty == true
        ? company!.businessName.trim()
        : company?.companyName ?? 'Your business';
    final address = company == null
        ? ''
        : [
            company.address.city,
            company.address.state,
            company.address.country,
          ].where((part) => part.trim().isNotEmpty).join(', ');

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShipperProfileAvatar(profile: company, size: 58),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, $firstName',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    business,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  if (company?.companyName.trim().isNotEmpty == true &&
                      company!.companyName != business) ...[
                    const SizedBox(height: 3),
                    Text(company.companyName),
                  ],
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(child: Text(address)),
                      ],
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

class _DashboardStatsGrid extends StatelessWidget {
  final DashboardInformation info;

  const _DashboardStatsGrid({required this.info});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        title: 'Pending',
        value: info.pendingShipments.toString(),
        icon: Icons.schedule,
        color: const Color(0xFFB26A00),
      ),
      _StatCard(
        title: 'Completed',
        value: info.completedShipments.toString(),
        icon: Icons.verified_outlined,
        color: const Color(0xFF16794C),
      ),
      _StatCard(
        title: 'Fragile',
        value: info.fragileShipments.toString(),
        icon: Icons.inventory_2_outlined,
        color: const Color(0xFF8B3A8F),
      ),
      _StatCard(
        title: 'Standard',
        value: info.nonFragileShipments.toString(),
        icon: Icons.local_shipping_outlined,
        color: const Color(0xFF1E5AA8),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns == 4 ? 1.35 : 1.2,
          children: cards,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onCreateShipment;
  final VoidCallback onViewShipments;

  const _QuickActions({
    required this.onCreateShipment,
    required this.onViewShipments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionTile(
            title: 'Create Shipment',
            subtitle: 'Open a new load',
            icon: Icons.add_box_outlined,
            onTap: onCreateShipment,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionTile(
            title: 'My Shipments',
            subtitle: 'Track active work',
            icon: Icons.list_alt_outlined,
            onTap: onViewShipments,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentShipments extends StatelessWidget {
  final List<Shipment> shipments;

  const _RecentShipments({required this.shipments});

  @override
  Widget build(BuildContext context) {
    if (shipments.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.inbox_outlined, color: Colors.grey.shade600),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No shipments yet. Create your first shipment to start tracking operations.',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: shipments.map((shipment) {
          final title = shipment.shipmentItem?.trim().isNotEmpty == true
              ? shipment.shipmentItem!
              : shipment.trackingNumber ??
                    'Shipment ${shipment.id ?? ''}'.trim();
          final lane = [
            shipment.origin,
            shipment.destination,
          ].where((part) => part.trim().isNotEmpty).join(' to ');

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
              child: const Icon(Icons.local_shipping_outlined),
            ),
            title: Text(title),
            subtitle: Text(lane.isEmpty ? shipment.status.name : lane),
            trailing: Text(
              shipment.status.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            onTap: shipment.id == null
                ? null
                : () => Navigator.pushNamed(
                    context,
                    RouteConstants.shipmentDetails,
                    arguments: shipment.id,
                  ),
          );
        }).toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;

  const _SectionTitle({required this.title, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        if (actionLabel != null)
          Text(
            actionLabel!,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
