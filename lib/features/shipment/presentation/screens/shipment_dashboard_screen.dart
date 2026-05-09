// lib/features/shipment/presentation/screens/shipment_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memilogistics_app/features/user/user.dart';
import 'package:memilogistics_app/core/widgets/core_widgets.dart';
import '../providers/shipment_provider.dart';

class ShipmentDashboardScreen extends StatefulWidget {
  const ShipmentDashboardScreen({super.key});

  @override
  State<ShipmentDashboardScreen> createState() => _ShipmentDashboardScreenState();
}

class _ShipmentDashboardScreenState extends State<ShipmentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/logout');
            },
          ),
        ],
      ),
      body: Consumer2<UserProvider, ShipmentProvider>(
        builder: (context, userProvider, shipmentProvider, _) {
          final user = userProvider.currentUser;

          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Card (clean, muted)
                AppCard(
                  child: Row(
                    children: [
                      AppAvatar(
                        url: user?.profile.avatarUrl,
                        initials: user?.profile.initials ?? '?',
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.profile.name ?? 'Loading...',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              user?.profile.email ?? '',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            if (user != null)
                              Chip(
                                label: Text(user.profile.role.toString().split('.').last.toUpperCase()),
                                backgroundColor: Colors.grey.shade100,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Quick Stats (responsive)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 600;
                    if (isNarrow) {
                      return Column(
                        children: [
                          _buildStatCard('Active Shipments', '12', Icons.local_shipping, Colors.blue),
                          const SizedBox(height: 12),
                          _buildStatCard('Completed', '45', Icons.check_circle, Colors.green),
                          const SizedBox(height: 12),
                          _buildStatCard('Pending', '8', Icons.pending, Colors.orange),
                          const SizedBox(height: 12),
                          _buildStatCard('Total', '65', Icons.inventory, Colors.purple),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Active Shipments',
                                '12',
                                Icons.local_shipping,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Completed',
                                '45',
                                Icons.check_circle,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Pending',
                                '8',
                                Icons.pending,
                                Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                'Total',
                                '65',
                                Icons.inventory,
                                Colors.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SectionTitle('Quick Actions'),
                const SizedBox(height: AppSpacing.md),

                _buildActionButton(
                  context,
                  'Create New Shipment',
                  Icons.add_circle,
                  Colors.blue,
                  () {
                    Navigator.pushNamed(context, '/create-shipment');
                  },
                ),

                const SizedBox(height: 12),

                _buildActionButton(
                  context,
                  'View All Shipments',
                  Icons.list,
                  Colors.green,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Shipment list coming soon!')),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _buildActionButton(
                  context,
                  'Track Shipment',
                  Icons.location_on,
                  Colors.orange,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Tracking coming soon!')),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                const SectionTitle('Recent Activity'),
                const SizedBox(height: AppSpacing.md),

                _buildActivityItem(
                  'Shipment #12345 created',
                  '2 hours ago',
                  Icons.add_circle_outline,
                  Colors.blue,
                ),
                _buildActivityItem(
                  'Shipment #12344 delivered',
                  '5 hours ago',
                  Icons.check_circle_outline,
                  Colors.green,
                ),
                _buildActivityItem(
                  'Shipment #12343 in transit',
                  '1 day ago',
                  Icons.local_shipping_outlined,
                  Colors.orange,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-shipment');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Shipment'),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return StatsCard(label: title, value: value);
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AppOutlinedButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[850]),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[500]),
        ),
      ),
    );
  }
}
