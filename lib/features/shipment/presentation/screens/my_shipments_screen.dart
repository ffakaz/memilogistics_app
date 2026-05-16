// lib/features/shipment/presentation/screens/my_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';
import 'shipment_detail_screen.dart';
import '../../../bid/presentation/screens/bid_review_screen.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      final role = userProvider.currentUser?.profile.role.toString().split('.').last;
      context.read<ShipmentProvider>().getMyShipments(role: role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final role = userProvider.currentUser?.profile.role.toString().split('.').last ?? 'unknown';
    final isCarrier = role.toLowerCase() == 'carrier';

    return Scaffold(
      appBar: AppBar(
        title: Text(isCarrier ? 'My Active Shipments' : 'My Posted Shipments'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All')),
              const PopupMenuItem(value: 'pending', child: Text('Posted')),
              const PopupMenuItem(value: 'assigned', child: Text('Accepted')),
              const PopupMenuItem(value: 'inTransit', child: Text('In Transit')),
              const PopupMenuItem(value: 'delivered', child: Text('Delivered')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ShipmentProvider>().getMyShipments(role: role);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.getMyShipments(role: role);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter shipments based on role and selected filter
          List<Shipment> filteredShipments = provider.shipments;

          // Role-based filtering
          if (isCarrier) {
            // Carrier sees accepted and active shipments
            filteredShipments = filteredShipments.where((s) =>
              s.status == ShipmentStatus.assigned ||
              s.status == ShipmentStatus.pickedUp ||
              s.status == ShipmentStatus.inTransit ||
              s.status == ShipmentStatus.arrivedAtDestination ||
              s.status == ShipmentStatus.delivered
            ).toList();
          }
          // Shipper sees all their posted shipments (no additional filter needed)

          // Status filter
          if (_selectedFilter != 'all') {
            final statusMap = {
              'pending': ShipmentStatus.pending,
              'assigned': ShipmentStatus.assigned,
              'inTransit': ShipmentStatus.inTransit,
              'delivered': ShipmentStatus.delivered,
            };
            final filterStatus = statusMap[_selectedFilter];
            if (filterStatus != null) {
              filteredShipments = filteredShipments
                  .where((s) => s.status == filterStatus)
                  .toList();
            }
          }

          if (filteredShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No shipments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isCarrier
                        ? 'Accept shipments from the load board'
                        : 'Post a new shipment to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.getMyShipments(role: role),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredShipments.length,
              itemBuilder: (context, index) {
                return _buildShipmentCard(
                  context,
                  filteredShipments[index],
                  provider,
                  isCarrier,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShipmentCard(
    BuildContext context,
    Shipment shipment,
    ShipmentProvider provider,
    bool isCarrier,
  ) {
    final statusColor = _getStatusColor(shipment.status);
    final statusText = _getStatusText(shipment.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          provider.setActiveShipment(shipment);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ShipmentDetailScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shipment #${shipment.id ?? 'N/A'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Route
              Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment.origin.shortLabel,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.flag, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      shipment.destination.shortLabel,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),

              if (shipment.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  shipment.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],

              const SizedBox(height: 12),

              // Created date
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'Posted: ${_formatDate(shipment.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),

              // Bid count for shippers
              if (!isCarrier && shipment.status == ShipmentStatus.pending) ...[
                const SizedBox(height: 12),
                _buildBidCountSection(context, shipment),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBidCountSection(BuildContext context, Shipment shipment) {
    // TODO: Get actual bid count from BidProvider
    final bidCount = _getMockBidCount(shipment.id!);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                '$bidCount ${bidCount == 1 ? 'bid' : 'bids'} received',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          if (bidCount > 0)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BidReviewScreen(shipment: shipment),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Review Bids',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // Mock bid count - TODO: Replace with actual data from BidProvider
  int _getMockBidCount(String shipmentId) {
    // Simulate different bid counts for different shipments
    final random = shipmentId.hashCode % 5;
    return random;
  }

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.orange;
      case ShipmentStatus.assigned:
        return Colors.blue;
      case ShipmentStatus.pickedUp:
      case ShipmentStatus.inTransit:
        return Colors.purple;
      case ShipmentStatus.arrivedAtDestination:
        return Colors.teal;
      case ShipmentStatus.delivered:
        return Colors.green;
      case ShipmentStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'POSTED';
      case ShipmentStatus.assigned:
        return 'ACCEPTED';
      case ShipmentStatus.pickedUp:
        return 'PICKED UP';
      case ShipmentStatus.inTransit:
        return 'IN TRANSIT';
      case ShipmentStatus.arrivedAtDestination:
        return 'ARRIVED';
      case ShipmentStatus.delivered:
        return 'DELIVERED';
      case ShipmentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
