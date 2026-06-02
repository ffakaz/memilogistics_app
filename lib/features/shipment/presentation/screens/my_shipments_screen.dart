// lib/features/shipment/presentation/screens/my_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipment_provider.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../../../../core/utils/constants/route_constants.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use getMyShipments which calls the role-aware /shipment/my endpoint
      context.read<ShipmentProvider>().getMyShipments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh shipments when returning to this screen
    // This ensures new shipments appear after creation
    if (mounted) {
      context.read<ShipmentProvider>().getMyShipments();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<ShipmentProvider>().loadNextPage();
    }
  }

  List<Shipment> _filterShipmentsByTab(List<Shipment> shipments, int tabIndex) {
    switch (tabIndex) {
      case 0: // All
        return shipments;
      case 1: // Pending
        return shipments.where((s) => s.status == ShipmentStatus.pending).toList();
      case 2: // In Transit
        return shipments.where((s) => 
          s.status == ShipmentStatus.inTransit || 
          s.status == ShipmentStatus.pickedUp
        ).toList();
      case 3: // Completed
        return shipments.where((s) => 
          s.status == ShipmentStatus.completed || 
          s.status == ShipmentStatus.delivered
        ).toList();
      default:
        return shipments;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shipments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Transit'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShipmentList(0), // All
          _buildShipmentList(1), // Pending
          _buildShipmentList(2), // In Transit
          _buildShipmentList(3), // Completed
        ],
      ),
    );
  }

  Widget _buildShipmentList(int tabIndex) {
    return Consumer<ShipmentProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.shipments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null && provider.shipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Error loading shipments'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => provider.getMyShipments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Filter shipments based on selected tab
        final allShipments = provider.shipments;
        final filteredShipments = _filterShipmentsByTab(allShipments, tabIndex);

        if (filteredShipments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  _getEmptyMessage(tabIndex),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.getMyShipments();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemCount: filteredShipments.length + (provider.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= filteredShipments.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final Shipment shipment = filteredShipments[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Card(
                  child: ListTile(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/shipment-details',
                      arguments: shipment.id,
                    ),
                    title: Text(
                      shipment.trackingNumber ?? 'Shipment #${shipment.id}',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${shipment.origin} → ${shipment.destination}'),
                        const SizedBox(height: 4),
                        Text(
                          'Status: ${shipment.status.displayName}',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getStatusColor(shipment.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.local_offer),
                      tooltip: 'View Offers',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteConstants.shipmentOffers,
                          arguments: shipment.id,
                        );
                      },
                    ),
                    isThreeLine: true,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _getEmptyMessage(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'No shipments yet.\nCreate your first shipment to get started!';
      case 1:
        return 'No pending shipments.\nAll shipments have been assigned or completed.';
      case 2:
        return 'No shipments in transit.\nShipments will appear here once picked up.';
      case 3:
        return 'No completed shipments.\nCompleted shipments will appear here.';
      default:
        return 'No shipments found.';
    }
  }

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.orange;
      case ShipmentStatus.accepted:
        return Colors.blue;
      case ShipmentStatus.assigned:
        return Colors.purple;
      case ShipmentStatus.pickedUp:
      case ShipmentStatus.inTransit:
        return Colors.indigo;
      case ShipmentStatus.arrivedAtDestination:
        return Colors.teal;
      case ShipmentStatus.delivered:
        return Colors.green;
      case ShipmentStatus.paymentPending:
        return Colors.amber;
      case ShipmentStatus.completed:
        return Colors.green[700]!;
    }
  }
}
