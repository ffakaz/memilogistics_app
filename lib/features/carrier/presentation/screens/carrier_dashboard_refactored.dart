// lib/features/carrier/presentation/screens/carrier_dashboard_refactored.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment_offer/presentation/providers/shipment_offer_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment_offer/domain/entities/shipment_offer.dart';
import '../../presentation/providers/carrier_company_provider.dart';
import '../../../shipment_offer/presentation/widgets/shipment_offer_dialog.dart';
import '../pages/edit_carrier_company_page.dart';
import '../widgets/carrier_profile_avatar.dart';
import '../widgets/lifecycle_shipment_card.dart';
import '../../../../core/utils/constants/route_constants.dart';

/// Profile menu actions enum
enum _CarrierProfileAction { view, edit, logout }

/// Main Carrier Dashboard - Refactored & Complete
/// Combines clean tabbed UI with full business logic
/// Features: Statistics, Assigned shipments with progress, Load board, My offers, Profile
class CarrierDashboardRefactored extends StatefulWidget {
  const CarrierDashboardRefactored({super.key});

  @override
  State<CarrierDashboardRefactored> createState() =>
      _CarrierDashboardRefactoredState();
}

class _CarrierDashboardRefactoredState
    extends State<CarrierDashboardRefactored>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String? _filterStatus;

  final List<String> _tabs = [
    'Offerable',
    'Assigned',
    'Picked Up',
    'In Transit',
    'Arrived',
    'Delivered',
    'Payment',
    'Completed',
    'My Offers',
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentProvider>().getAvailableShipments();
      context.read<ShipmentProvider>().getCarrierAssignedShipments();
      context.read<ShipmentOfferProvider>().loadMyOffers();
      context.read<CarrierCompanyProvider>().ensureProfileLoaded();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ShipmentProvider>().loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carrier Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          _buildProfileButton(),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF2C5E78),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2C5E78),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOfferableTab(),
          _buildAssignedTab(),
          _buildPickedUpTab(),
          _buildInTransitTab(),
          _buildArrivedTab(),
          _buildDeliveredTab(),
          _buildPaymentPendingTab(),
          _buildCompletedTab(),
          _buildMyOffersTab(),
        ],
      ),
    );
  }

  Widget _buildProfileButton() {
    return Consumer<CarrierCompanyProvider>(
      builder: (context, provider, _) {
        final company = provider.state.company;

        return PopupMenuButton<_CarrierProfileAction>(
          tooltip: 'Profile menu',
          offset: const Offset(0, 52),
          onSelected: (action) async {
            switch (action) {
              case _CarrierProfileAction.view:
                Navigator.pushNamed(context, RouteConstants.carrierProfile);
                break;
              case _CarrierProfileAction.edit:
                if (company != null) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCarrierCompanyPage(company: company),
                    ),
                  );
                }
                break;
              case _CarrierProfileAction.logout:
                await context.read<AuthProvider>().logout();
                if (mounted) {
                  context.read<CarrierCompanyProvider>().clearProfile();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteConstants.login,
                    (_) => false,
                  );
                }
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _CarrierProfileAction.view,
              child: const ListTile(
                leading: Icon(Icons.business_outlined),
                title: Text('View Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: _CarrierProfileAction.edit,
              child: const ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit Profile'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: _CarrierProfileAction.logout,
              child: const ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CarrierProfileAvatar(profile: company, size: 42),
          ),
        );
      },
    );
  }

  // Offerable Tab with Statistics
  Widget _buildOfferableTab() {
    return Consumer2<ShipmentProvider, ShipmentOfferProvider>(
      builder: (context, shipmentProvider, offerProvider, _) {
        final filteredShipments = _filterOfferableShipments(shipmentProvider.shipments);
        
        return Column(
          children: [
            if (shipmentProvider.isDashboardLoading ||
                shipmentProvider.shipments.isNotEmpty ||
                shipmentProvider.assignedShipments.isNotEmpty)
              _buildStatisticsCards(shipmentProvider),
            _buildAssignedToYouSection(shipmentProvider),
            _buildSearchAndFilter(),
            Expanded(
              child: filteredShipments.isEmpty
                  ? _buildEmptyState(
                      icon: Icons.local_offer,
                      title: 'No Offerable Loads',
                      subtitle: 'Available shipments will appear here',
                    )
                  : RefreshIndicator(
                      onRefresh: () async => _loadInitialData(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredShipments.length,
                        itemBuilder: (context, index) {
                          final shipment = filteredShipments[index];
                          return _buildOfferableShipmentCard(shipment);
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatisticsCards(ShipmentProvider provider) {
    final offerableCount = provider.shipments
        .where((s) => s.assignedCarrierId == null)
        .length;
    final activeCount = provider.assignedShipments
        .where((s) => s.status != ShipmentStatus.completed && 
                      s.status != ShipmentStatus.delivered)
        .length;
    final deliveredCount = provider.assignedShipments
        .where((s) => s.status == ShipmentStatus.delivered)
        .length;
    final completedCount = provider.assignedShipments
        .where((s) => s.status == ShipmentStatus.completed)
        .length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              Icons.local_offer,
              offerableCount.toString(),
              'Offerable Loads',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.local_shipping,
              activeCount.toString(),
              'Active Loads',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.check_circle,
              deliveredCount.toString(),
              'Delivered',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              Icons.done_all,
              completedCount.toString(),
              'Completed',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String count, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey.shade700),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedToYouSection(ShipmentProvider provider) {
    final assignedShipments = provider.assignedShipments
        .where((s) => s.status != ShipmentStatus.completed)
        .toList();

    if (assignedShipments.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned to you',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: assignedShipments.length,
              itemBuilder: (context, index) {
                return _buildAssignedShipmentCard(assignedShipments[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedShipmentCard(Shipment shipment) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shipment.trackingNumber ?? 'TRK-${shipment.id}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${shipment.origin} -> ${shipment.destination}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressIndicator(shipment),
          const Spacer(),
          Text(
            'Pickup: ${shipment.pickupDate != null ? DateFormat('MMM dd, hh:mm a').format(shipment.pickupDate!) : '-'}',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(Shipment shipment) {
    final stages = [
      ShipmentStatus.assigned,
      ShipmentStatus.pickedUp,
      ShipmentStatus.inTransit,
      ShipmentStatus.arrivedAtDestination,
      ShipmentStatus.delivered,
      ShipmentStatus.paymentPending,
      ShipmentStatus.completed,
    ];

    final currentIndex = stages.indexOf(shipment.status);

    return Row(
      children: List.generate(13, (index) {
        if (index.isOdd) {
          return Container(
            width: 6,
            height: 2,
            color: index ~/ 2 <= currentIndex
                ? const Color(0xFF2C5E78)
                : Colors.grey.shade300,
          );
        }

        final stageIndex = index ~/ 2;
        final isCompleted = stageIndex < currentIndex;
        final isCurrent = stageIndex == currentIndex;
        final isClickable = stageIndex == currentIndex ||
            (currentIndex >= 0 && stageIndex == currentIndex + 1);

        return GestureDetector(
          onTap: isClickable
              ? () => _handleProgressTap(shipment, stages[stageIndex])
              : null,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isCurrent
                  ? const Color(0xFF2C5E78)
                  : Colors.grey.shade300,
              border: Border.all(
                color: isCurrent ? const Color(0xFF2C5E78) : Colors.transparent,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : isCurrent
                    ? Container(
                        margin: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      )
                    : null,
          ),
        );
      }),
    );
  }

  Future<void> _handleProgressTap(Shipment shipment, ShipmentStatus targetStatus) async {
    // Only allow progression to next status
    final currentStatus = shipment.status;
    
    if (currentStatus == ShipmentStatus.assigned &&
        targetStatus == ShipmentStatus.pickedUp) {
      await _handlePickUp(shipment);
    } else if (currentStatus == ShipmentStatus.pickedUp &&
        targetStatus == ShipmentStatus.inTransit) {
      await _handleStartTransit(shipment);
    } else if (currentStatus == ShipmentStatus.inTransit &&
        targetStatus == ShipmentStatus.arrivedAtDestination) {
      await _handleMarkArrived(shipment);
    } else if (currentStatus == ShipmentStatus.arrivedAtDestination &&
        targetStatus == ShipmentStatus.delivered) {
      await _handleMarkDelivered(shipment);
    } else if (currentStatus == ShipmentStatus.paymentPending &&
        targetStatus == ShipmentStatus.completed) {
      await _handleConfirmPayment(shipment);
    }
  }

  Widget _buildOfferableShipmentCard(Shipment shipment) {
    return Consumer<ShipmentOfferProvider>(
      builder: (context, offerProvider, _) {
        final hasSubmitted =
            offerProvider.hasSubmittedOfferForShipment(shipment.id ?? 0);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BUSINESS CRITICAL: Shipment Item prominently displayed
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C5E78).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        shipment.shipmentItem ?? 'General Cargo',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C5E78),
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (shipment.fragile)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, size: 14, color: Colors.red.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'FRAGILE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Tracking Number
                Text(
                  shipment.trackingNumber ?? 'TRK-${shipment.id}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                // Route
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shipment.origin,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.flag, size: 16, color: Colors.red.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        shipment.destination,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Weight and Delivery Date
                Row(
                  children: [
                    Icon(Icons.scale, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${shipment.weightKg.toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      shipment.estimatedDeliveryDate != null
                          ? DateFormat('MMM dd').format(shipment.estimatedDeliveryDate!)
                          : 'TBD',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: shipment.status == ShipmentStatus.pending
                            ? Colors.orange.shade50
                            : Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: shipment.status == ShipmentStatus.pending
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ),
                      child: Text(
                        shipment.status.displayName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: shipment.status == ShipmentStatus.pending
                              ? Colors.orange.shade700
                              : Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: hasSubmitted ? null : () => _showOfferDialog(shipment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasSubmitted
                          ? Colors.green
                          : const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: hasSubmitted ? 0 : 2,
                    ),
                    icon: Icon(
                      hasSubmitted ? Icons.check_circle : Icons.local_offer,
                      size: 18,
                    ),
                    label: Text(
                      hasSubmitted ? 'Offer Submitted' : 'Submit Offer',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Shipment> _filterOfferableShipments(List<Shipment> shipments) {
    return shipments.where((s) {
      // CRITICAL: Only show unassigned shipments in offerable section
      if (s.assignedCarrierId != null) return false;
      
      // CRITICAL: Show shipments that are PENDING or ACCEPTED (not yet assigned)
      if (s.status != ShipmentStatus.pending && 
          s.status != ShipmentStatus.accepted) {
        return false;
      }

      // Status filter (null or 'All' means show all)
      if (_filterStatus != null && _filterStatus != 'All') {
        final statusMatch =
            (_filterStatus == 'Pending' && s.status == ShipmentStatus.pending) ||
            (_filterStatus == 'Accepted' && s.status == ShipmentStatus.accepted);
        if (!statusMatch) return false;
      }

      // Search filter
      if (_searchQuery.isEmpty) return true;

      final query = _searchQuery.toLowerCase();
      return (s.trackingNumber ?? '').toLowerCase().contains(query) ||
          (s.shipmentItem ?? '').toLowerCase().contains(query) ||
          s.origin.toLowerCase().contains(query) ||
          s.destination.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, size: 20),
              hintText: 'Search shipments...',
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF2C5E78), width: 2),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          // Filter Chips - Scrollable to prevent overflow
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  label: 'All',
                  isSelected: _filterStatus == null,
                  onTap: () => setState(() => _filterStatus = null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Pending',
                  isSelected: _filterStatus == 'Pending',
                  onTap: () => setState(() => _filterStatus = 'Pending'),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'Accepted',
                  isSelected: _filterStatus == 'Accepted',
                  onTap: () => setState(() => _filterStatus = 'Accepted'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C5E78) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2C5E78) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  // Other tabs
  Widget _buildAssignedTab() => _buildLifecycleTab(
        ShipmentStatus.assigned,
        'No Assigned Shipments',
        'Accepted offers will move here',
        Icons.assignment,
        onAction: _handlePickUp,
        actionLabel: 'Pick Up Shipment',
        actionIcon: Icons.local_shipping,
      );

  Widget _buildPickedUpTab() => _buildLifecycleTab(
        ShipmentStatus.pickedUp,
        'No Picked Up Shipments',
        'Picked up loads will wait here',
        Icons.inventory_2,
        onAction: _handleStartTransit,
        actionLabel: 'Start Transit',
        actionIcon: Icons.navigation,
      );

  Widget _buildInTransitTab() => _buildLifecycleTab(
        ShipmentStatus.inTransit,
        'No In Transit Shipments',
        'Shipments on the road will appear here',
        Icons.local_shipping,
        onAction: _handleMarkArrived,
        actionLabel: 'Mark Arrived',
        actionIcon: Icons.location_on,
        showSecondary: true,
        onSecondaryAction: _handleUpdateLocation,
        secondaryLabel: 'Update Location',
        secondaryIcon: Icons.my_location,
      );

  Widget _buildArrivedTab() => _buildLifecycleTab(
        ShipmentStatus.arrivedAtDestination,
        'No Arrived Shipments',
        'Shipments that have arrived at destination',
        Icons.place,
        onAction: _handleMarkDelivered,
        actionLabel: 'Mark Delivered',
        actionIcon: Icons.check_circle,
      );

  Widget _buildDeliveredTab() => _buildLifecycleTab(
        ShipmentStatus.delivered,
        'No Delivered Shipments',
        'Waiting for shipper payment',
        Icons.check_circle,
        showAction: false,
      );

  Widget _buildPaymentPendingTab() => _buildLifecycleTab(
        ShipmentStatus.paymentPending,
        'No Payment Pending',
        'Payment confirmations appear here',
        Icons.payment,
        onAction: _handleConfirmPayment,
        actionLabel: 'Confirm Payment',
        actionIcon: Icons.check_circle,
      );

  Widget _buildCompletedTab() => _buildLifecycleTab(
        ShipmentStatus.completed,
        'No Completed Shipments',
        'Finished shipments are archived here',
        Icons.done_all,
        showAction: false,
      );

  // My Offers Tab
  Widget _buildMyOffersTab() {
    return Consumer<ShipmentOfferProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.offers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.offers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.local_offer_outlined,
            title: 'No Offers Yet',
            subtitle: 'Your submitted offers will appear here',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadMyOffers();
            _loadInitialData();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.offers.length,
            itemBuilder: (context, index) {
              final offer = provider.offers[index];
              return _buildOfferCard(offer);
            },
          ),
        );
      },
    );
  }

  Widget _buildOfferCard(ShipmentOffer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  offer.shipmentTrackingNumber.isNotEmpty
                      ? offer.shipmentTrackingNumber
                      : 'Shipment #${offer.shipmentId}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.attach_money, size: 18, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Your Offer: ETB ${offer.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Submitted: ${DateFormat('MMM dd, yyyy').format(offer.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifecycleTab(
    ShipmentStatus status,
    String emptyTitle,
    String emptySubtitle,
    IconData emptyIcon, {
    Function(Shipment)? onAction,
    String? actionLabel,
    IconData? actionIcon,
    bool showAction = true,
    bool showSecondary = false,
    Function(Shipment)? onSecondaryAction,
    String? secondaryLabel,
    IconData? secondaryIcon,
  }) {
    return Consumer<ShipmentProvider>(
      builder: (context, provider, _) {
        final shipments = provider.assignedShipments
            .where((s) => s.status == status)
            .toList();

        if (shipments.isEmpty) {
          return _buildEmptyState(
            icon: emptyIcon,
            title: emptyTitle,
            subtitle: emptySubtitle,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadInitialData(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shipments.length,
            itemBuilder: (context, index) {
              final shipment = shipments[index];
              return LifecycleShipmentCard(
                shipment: shipment,
                onAction: showAction && onAction != null
                    ? () => onAction(shipment)
                    : null,
                actionLabel: actionLabel,
                actionIcon: actionIcon,
                showActionButton: showAction,
                showSecondaryAction: showSecondary,
                onSecondaryAction: onSecondaryAction != null
                    ? () => onSecondaryAction(shipment)
                    : null,
                secondaryActionLabel: secondaryLabel,
                secondaryActionIcon: secondaryIcon,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // Action handlers
  void _showOfferDialog(Shipment shipment) {
    showDialog(
      context: context,
      builder: (context) => ShipmentOfferDialog(shipment: shipment),
    );
  }

  Future<void> _handlePickUp(Shipment shipment) async {
    final confirm = await _showConfirmDialog(
      'Pick Up Shipment',
      'Confirm that you have picked up this shipment?',
    );
    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.pickedUp,
            location: shipment.origin,
          );
      _showSuccess('Shipment picked up successfully');
      _loadInitialData();
    } catch (e) {
      _showError('Failed to update: $e');
    }
  }

  Future<void> _handleStartTransit(Shipment shipment) async {
    final confirm = await _showConfirmDialog(
      'Start Transit',
      'Confirm that this shipment is now in transit?',
    );
    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.inTransit,
            location: shipment.origin,
          );
      _showSuccess('Shipment is now in transit');
      _loadInitialData();
    } catch (e) {
      _showError('Failed to update: $e');
    }
  }

  Future<void> _handleUpdateLocation(Shipment shipment) async {
    // Implementation similar to in_transit_shipments_screen.dart
    final locationController = TextEditingController();
    final location = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Location'),
        content: TextField(
          controller: locationController,
          decoration: const InputDecoration(
            labelText: 'Current Location',
            hintText: 'e.g., Mekelle',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, locationController.text),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (location == null || location.isEmpty) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.inTransit,
            location: location,
          );
      _showSuccess('Location updated');
    } catch (e) {
      _showError('Failed to update location: $e');
    }
  }

  Future<void> _handleMarkArrived(Shipment shipment) async {
    final confirm = await _showConfirmDialog(
      'Mark Arrived at Destination',
      'Confirm arrival at ${shipment.destination}?',
    );
    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.arrivedAtDestination,
            location: shipment.destination,
          );
      _showSuccess('Shipment marked as arrived at destination');
      _loadInitialData();
    } catch (e) {
      _showError('Failed to mark as arrived: $e');
    }
  }

  Future<void> _handleMarkDelivered(Shipment shipment) async {
    final confirm = await _showConfirmDialog(
      'Mark Delivered',
      'Confirm delivery to customer at ${shipment.destination}?',
    );
    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.delivered,
            location: shipment.destination,
          );
      _showSuccess('Shipment marked as delivered');
      _loadInitialData();
    } catch (e) {
      _showError('Failed to mark as delivered: $e');
    }
  }

  Future<void> _handleConfirmPayment(Shipment shipment) async {
    final confirm = await _showConfirmDialog(
      'Confirm Payment',
      'Confirm that you have received payment?',
    );
    if (confirm != true) return;

    try {
      // Use Payment API instead of status update
      final paymentProvider = context.read<PaymentProvider>();
      final success = await paymentProvider.confirmPayment(
        shipmentId: shipment.id!,
        transactionId: '', // Transaction ID can be empty or provided by carrier
      );

      if (success) {
        _showSuccess('Payment confirmed - Shipment completed');
        _loadInitialData();
      } else {
        _showError('Failed to confirm payment: ${paymentProvider.error}');
      }
    } catch (e) {
      _showError('Failed to confirm payment: $e');
    }
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
