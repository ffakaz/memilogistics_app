import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../../../core/widgets/shipment_card.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import 'package:provider/provider.dart';

/// Premium Dashboard Screen
/// Modern, enterprise-grade dashboard with statistics and recent shipments
class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final shipmentProvider = context.read<ShipmentProvider>();
    await Future.wait([
      shipmentProvider.getDashboardInformation(),
      shipmentProvider.getMyShipments(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final shipmentProvider = context.watch<ShipmentProvider>();
    final isShipper = authProvider.userRole == 'SHIPPER';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            // Premium App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppTheme.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacing24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacing12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.2 * 255).round()),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: const Icon(
                                  Icons.dashboard_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () {
                                  // Navigate to notifications
                                },
                                icon: Stack(
                                  children: [
                                    const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppTheme.electricOrange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Text(
                                          '3',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing16),
                          Text(
                            'Welcome back! 👋',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white.withAlpha((0.9 * 255).round()),
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing4),
                          Text(
                            isShipper ? 'Shipper Dashboard' : 'Carrier Dashboard',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Dashboard Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppTheme.spacing24),

                  // Statistics Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                    child: shipmentProvider.isDashboardLoading
                        ? _buildLoadingStats()
                        : _buildStatisticsGrid(
                            context,
                            shipmentProvider.dashboardInformation,
                            isShipper,
                          ),
                  ),

                  const SizedBox(height: AppTheme.spacing32),

                  // Quick Actions Banner
                  _buildQuickActionsBanner(context, isShipper),

                  const SizedBox(height: AppTheme.spacing32),

                  // Recent Shipments Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Shipments',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all shipments
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing16),

                  // Recent Shipments List
                  if (shipmentProvider.isLoading)
                    _buildLoadingShipments()
                  else if (shipmentProvider.shipments.isEmpty)
                    _buildEmptyState(context, isShipper)
                  else
                    _buildRecentShipments(shipmentProvider.shipments.take(3).toList()),

                  const SizedBox(height: AppTheme.spacing24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(
    BuildContext context,
    dynamic dashboardInfo,
    bool isShipper,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacing16,
      crossAxisSpacing: AppTheme.spacing16,
      childAspectRatio: 1.3,
      children: [
        StatCard(
          title: 'Pending',
          value: '${dashboardInfo.pendingShipments}',
          icon: Icons.schedule_rounded,
          color: AppTheme.statusPending,
          subtitle: 'Awaiting action',
        ),
        StatCard(
          title: 'In Transit',
          value: '${dashboardInfo.inTransitShipments}',
          icon: Icons.local_shipping_rounded,
          color: AppTheme.statusInTransit,
          subtitle: 'On the way',
        ),
        StatCard(
          title: 'Delivered',
          value: '${dashboardInfo.completedShipments}',
          icon: Icons.check_circle_rounded,
          color: AppTheme.statusDelivered,
          subtitle: 'Completed',
        ),
        StatCard(
          title: 'Fragile Items',
          value: '${dashboardInfo.fragileShipments}',
          icon: Icons.warning_amber_rounded,
          color: AppTheme.electricOrange,
          subtitle: 'Handle with care',
        ),
      ],
    );
  }

  Widget _buildQuickActionsBanner(BuildContext context, bool isShipper) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: AppTheme.orangeGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.electricOrange.withAlpha((0.3 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isShipper ? 'Need to ship something?' : 'Find loads nearby',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  isShipper
                      ? 'Create a new shipment and get competitive offers'
                      : 'Browse available shipments and make offers',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                      ),
                ),
                const SizedBox(height: AppTheme.spacing16),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to create shipment or load board
                  },
                  icon: Icon(
                    isShipper ? Icons.add_rounded : Icons.search_rounded,
                    size: 20,
                  ),
                  label: Text(isShipper ? 'Create Shipment' : 'Browse Loads'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.electricOrange,
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              isShipper ? Icons.inventory_2_rounded : Icons.local_shipping_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentShipments(List shipments) {
    return Column(
      children: shipments.map((shipment) {
        return CompactShipmentCard(
          shipment: shipment,
          onTap: () {
            // Navigate to shipment details
          },
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isShipper) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacing16),
      padding: const EdgeInsets.all(AppTheme.spacing32),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: AppTheme.lightGray,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            isShipper ? 'No shipments yet' : 'No assigned shipments',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            isShipper
                ? 'Create your first shipment to get started'
                : 'Browse the load board to find shipments',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppTheme.spacing16,
      crossAxisSpacing: AppTheme.spacing16,
      childAspectRatio: 1.3,
      children: List.generate(4, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildLoadingShipments() {
    return Column(
      children: List.generate(3, (index) => _buildLoadingCard()),
    );
  }

  Widget _buildLoadingCard() {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
          const SizedBox(height: AppTheme.spacing16),
          Container(
            width: double.infinity,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withAlpha((0.3 * 255).round()),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
        ],
      ),
    );
  }
}

