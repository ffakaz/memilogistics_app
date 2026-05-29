// Simplified Shipment Details screen — keeps behavior but fixes analyzer warnings
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final int shipmentId;
  const ShipmentDetailsScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          final shipment = provider.getShipmentById(widget.shipmentId);
          if (shipment == null) return const Center(child: Text('Shipment not found'));

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 160,
                pinned: true,
                backgroundColor: const Color(0xFF2C3E50),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(shipment.trackingNumber ?? 'Shipment'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusBadge(shipment.status),
                      const SizedBox(height: 12),
                      Text('Origin: ${_formatLocation(shipment.origin)}'),
                      const SizedBox(height: 8),
                      Text('Destination: ${_formatLocation(shipment.destination)}'),
                      const SizedBox(height: 8),
                      Text('Pickup: ${_formatDate(shipment.pickupDate)}'),
                      const SizedBox(height: 8),
                      Text('Status: ${_getStatusLabel(shipment.status)}'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          final shipment = provider.getShipmentById(widget.shipmentId);
          if (shipment != null && _canUpdateStatus(shipment)) {
            return FloatingActionButton.extended(
              onPressed: () => _showUpdateStatusDialog(shipment),
              backgroundColor: const Color(0xFF2C3E50),
              icon: const Icon(Icons.update),
              label: const Text('Update Status'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusBadge(ShipmentStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ShipmentStatus.pending:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.pending;
        break;
      case ShipmentStatus.accepted:
        bgColor = Colors.lightBlue.shade100;
        textColor = Colors.lightBlue.shade900;
        icon = Icons.check;
        break;
      case ShipmentStatus.assigned:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.assignment_turned_in;
        break;
      case ShipmentStatus.pickedUp:
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        icon = Icons.inventory;
        break;
      case ShipmentStatus.inTransit:
        bgColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade900;
        icon = Icons.local_shipping;
        break;
      case ShipmentStatus.arrivedAtDestination:
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        icon = Icons.place;
        break;
      case ShipmentStatus.delivered:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case ShipmentStatus.completed:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18, color: textColor), const SizedBox(width: 8), Text(_getStatusLabel(status), style: TextStyle(color: textColor, fontWeight: FontWeight.w600))]),
    );
  }

  bool _canUpdateStatus(Shipment shipment) {
    return shipment.status != ShipmentStatus.pending && shipment.status != ShipmentStatus.completed;
  }

  void _showUpdateStatusDialog(Shipment shipment) {
    final nextStatuses = _getNextPossibleStatuses(shipment.status);
    if (nextStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No status updates available')));
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Shipment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current: ${_getStatusLabel(shipment.status)}', style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            ...nextStatuses.map((s) => ListTile(title: Text(_getStatusLabel(s)), onTap: () {
                  Navigator.pop(context);
                  _updateStatus(shipment, s);
                })),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
      ),
    );
  }

  List<ShipmentStatus> _getNextPossibleStatuses(ShipmentStatus current) {
    switch (current) {
      case ShipmentStatus.assigned:
        return [ShipmentStatus.pickedUp];
      case ShipmentStatus.pickedUp:
        return [ShipmentStatus.inTransit];
      case ShipmentStatus.inTransit:
        return [ShipmentStatus.arrivedAtDestination];
      case ShipmentStatus.arrivedAtDestination:
        return [ShipmentStatus.delivered];
      case ShipmentStatus.delivered:
        return [ShipmentStatus.completed];
      default:
        return [];
    }
  }

  Future<void> _updateStatus(Shipment shipment, ShipmentStatus newStatus) async {
    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(shipment.id!, newStatus);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated successfully!')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  String _getStatusLabel(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Pending';
      case ShipmentStatus.accepted:
        return 'Accepted';
      case ShipmentStatus.assigned:
        return 'Assigned';
      case ShipmentStatus.pickedUp:
        return 'Picked Up';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.arrivedAtDestination:
        return 'Arrived at Destination';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatLocation(String? address) {
    if (address == null || address.isEmpty) return 'Unknown';
    return address.split(' ').map((w) => w.isEmpty ? w : (w[0].toUpperCase() + w.substring(1).toLowerCase())).join(' ');
  }
}
