// lib/features/shipment/presentation/screens/my_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shipment_provider.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../domain/entities/shipment.dart';

class MyShipmentsScreen extends StatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  State<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends State<MyShipmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Load shipments when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentProvider>().getMyShipments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shipments'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Transit'),
            Tab(text: 'Completed'),
          ],
        ),
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
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading shipments',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.getMyShipments(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final shipments = provider.shipments;

          if (shipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No shipments yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create your first shipment to get started',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create-shipment');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Shipment'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildShipmentList(shipments),
              _buildShipmentList(_filterByStatus(shipments, ['pending'])),
              _buildShipmentList(_filterByStatus(shipments, ['assigned', 'pickedUp', 'inTransit'])),
              _buildShipmentList(_filterByStatus(shipments, ['delivered', 'completed'])),
            ],
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

  List<Shipment> _filterByStatus(List<Shipment> shipments, List<String> statuses) {
    return shipments.where((s) {
      final statusName = s.status.name.toLowerCase();
      return statuses.any((status) => statusName.contains(status.toLowerCase()));
    }).toList();
  }

  Widget _buildShipmentList(List<Shipment> shipments) {
    if (shipments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No shipments in this category',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ShipmentProvider>().getMyShipments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: shipments.length,
        itemBuilder: (context, index) {
          final shipment = shipments[index];
          return _buildShipmentCard(shipment);
        },
      ),
    );
  }

  Widget _buildShipmentCard(Shipment shipment) {
    final statusColor = _getStatusColor(shipment.status.name);
    final statusIcon = _getStatusIcon(shipment.status.name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/shipment-details',
              arguments: shipment.id,
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with tracking number and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shipment.trackingNumber ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${shipment.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            _formatStatus(shipment.status.name),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Route information
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.trip_origin, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  shipment.pickupLocation.address,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.red[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  shipment.destinationLocation.address,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Shipment details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailChip(
                        Icons.scale,
                        '${shipment.amount} ${shipment.unit.name}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailChip(
                        Icons.calendar_today,
                        _formatDate(shipment.pickupDate),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDetailChip(
                        shipment.safetyOption.name == 'fragile'
                            ? Icons.warning
                            : Icons.check_circle,
                        shipment.safetyOption.name == 'fragile'
                            ? 'Fragile'
                            : 'Standard',
                      ),
                    ),
                  ],
                ),

                // Offers count if available
                if (shipment.offerCount > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_offer, size: 16, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        Text(
                          '${shipment.offerCount} offer${shipment.offerCount > 1 ? 's' : ''} received',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'pickedup':
      case 'picked_up':
        return Colors.purple;
      case 'intransit':
      case 'in_transit':
        return Colors.indigo;
      case 'arrivedatdestination':
      case 'arrived_at_destination':
        return Colors.teal;
      case 'delivered':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'assigned':
        return Icons.assignment_turned_in;
      case 'pickedup':
      case 'picked_up':
        return Icons.inventory;
      case 'intransit':
      case 'in_transit':
        return Icons.local_shipping;
      case 'arrivedatdestination':
      case 'arrived_at_destination':
        return Icons.place;
      case 'delivered':
        return Icons.check_circle;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  String _formatStatus(String status) {
    // Convert camelCase or snake_case to Title Case
    return status
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}
