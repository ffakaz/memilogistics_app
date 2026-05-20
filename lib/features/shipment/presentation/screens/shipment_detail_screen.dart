// lib/features/shipment/presentation/screens/shipment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';

class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentProvider>();
    final shipment = provider.activeShipment;

    if (shipment == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shipment Details')),
        body: const Center(child: Text('No shipment selected')),
      );
    }

    final userProvider = context.watch<UserProvider>();
    final role = userProvider.currentUser?.profile.role.toString().split('.').last ?? 'unknown';
    final isCarrier = role.toLowerCase() == 'carrier';

    return Scaffold(
      appBar: AppBar(
        title: Text('Shipment #${shipment.id ?? 'N/A'}'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            _buildStatusHeader(shipment.status),

            // Shipment Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Section
                  _buildSectionTitle('Route'),
                  const SizedBox(height: 12),
                  _buildRouteCard(shipment),
                  const SizedBox(height: 24),

                  // Description
                  if (shipment.description != null) ...[
                    _buildSectionTitle('Description'),
                    const SizedBox(height: 12),
                    _buildInfoCard(shipment.description!),
                    const SizedBox(height: 24),
                  ],

                  // Shipment Info
                  _buildSectionTitle('Shipment Information'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Type', shipment.shipmentType.displayName),
                  _buildInfoRow('Weight', '${shipment.weight} ${shipment.weightUnit.displayName}'),
                  _buildInfoRow('Safety', shipment.safetyOption.name.toUpperCase()),
                  _buildInfoRow('Pickup Date', _formatDate(shipment.pickupDate)),
                  if (shipment.createdAt != null)
                    _buildInfoRow('Posted', _formatDate(shipment.createdAt!)),
                  const SizedBox(height: 24),

                  // Status Timeline
                  _buildSectionTitle('Status Timeline'),
                  const SizedBox(height: 12),
                  _buildStatusTimeline(shipment.status),
                  const SizedBox(height: 24),

                  // Action Buttons (Role-based)
                  if (isCarrier) _buildCarrierActions(context, shipment, provider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ShipmentStatus status) {
    final statusColor = _getStatusColor(status);
    final statusText = _getStatusText(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor,
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getStatusIcon(status),
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStatusDescription(status),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRouteCard(shipment) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.location_on, color: Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Origin',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        shipment.origin.fullLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 2,
                  color: Colors.grey[300],
                ),
                const SizedBox(width: 8),
                Icon(Icons.local_shipping, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey[300],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flag, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Destination',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        shipment.destination.fullLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(ShipmentStatus currentStatus) {
    final statuses = [
      ShipmentStatus.pending,
      ShipmentStatus.assigned,
      ShipmentStatus.pickedUp,
      ShipmentStatus.inTransit,
      ShipmentStatus.arrivedAtDestination,
      ShipmentStatus.delivered,
    ];

    final currentIndex = statuses.indexOf(currentStatus);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentIndex;
            final isCurrent = index == currentIndex;

            return _buildTimelineItem(
              _getStatusText(status),
              isCompleted,
              isCurrent,
              index < statuses.length - 1,
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    bool isCompleted,
    bool isCurrent,
    bool showLine,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey[300],
                border: Border.all(
                  color: isCurrent ? Colors.blue : Colors.transparent,
                  width: 3,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCompleted ? Colors.black87 : Colors.grey[600],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarrierActions(
    BuildContext context,
    shipment,
    ShipmentProvider provider,
  ) {
    // Determine available actions based on status
    Widget? actionButton;

    switch (shipment.status) {
      case ShipmentStatus.pending:
        actionButton = _buildActionButton(
          context,
          'Accept Shipment',
          Icons.check_circle,
          Colors.green,
          () => _acceptShipment(context, shipment, provider),
        );
        break;
      case ShipmentStatus.assigned:
        actionButton = _buildActionButton(
          context,
          'Start Transit',
          Icons.local_shipping,
          Colors.blue,
          () => _updateStatus(context, shipment, provider, ShipmentStatus.inTransit),
        );
        break;
      case ShipmentStatus.inTransit:
        actionButton = _buildActionButton(
          context,
          'Mark as Delivered',
          Icons.done_all,
          Colors.green,
          () => _updateStatus(context, shipment, provider, ShipmentStatus.delivered),
        );
        break;
      default:
        actionButton = null;
    }

    if (actionButton == null) return const SizedBox.shrink();

    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 16),
        actionButton,
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Future<void> _acceptShipment(
    BuildContext context,
    shipment,
    ShipmentProvider provider,
  ) async {
    try {
      await provider.acceptShipment(shipment.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shipment accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    shipment,
    ShipmentProvider provider,
    ShipmentStatus newStatus,
  ) async {
    try {
      await provider.updateShipmentStatus(shipment.id!, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.orange;
      case ShipmentStatus.accepted:
      case ShipmentStatus.assigned:
        return Colors.blue;
      case ShipmentStatus.pickedUp:
      case ShipmentStatus.inTransit:
        return Colors.purple;
      case ShipmentStatus.arrivedAtDestination:
        return Colors.teal;
      case ShipmentStatus.delivered:
        return Colors.green;
      case ShipmentStatus.completed:
        return Colors.green.shade800;
      case ShipmentStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Icons.pending;
      case ShipmentStatus.accepted:
      case ShipmentStatus.assigned:
        return Icons.assignment_turned_in;
      case ShipmentStatus.pickedUp:
        return Icons.inventory;
      case ShipmentStatus.inTransit:
        return Icons.local_shipping;
      case ShipmentStatus.arrivedAtDestination:
        return Icons.place;
      case ShipmentStatus.delivered:
        return Icons.check_circle;
      case ShipmentStatus.completed:
        return Icons.verified;
      case ShipmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'POSTED';
      case ShipmentStatus.accepted:
        return 'ACCEPTED';
      case ShipmentStatus.assigned:
        return 'ASSIGNED';
      case ShipmentStatus.pickedUp:
        return 'PICKED UP';
      case ShipmentStatus.inTransit:
        return 'IN TRANSIT';
      case ShipmentStatus.arrivedAtDestination:
        return 'ARRIVED';
      case ShipmentStatus.delivered:
        return 'DELIVERED';
      case ShipmentStatus.completed:
        return 'COMPLETED';
      case ShipmentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String _getStatusDescription(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Waiting for carrier acceptance';
      case ShipmentStatus.accepted:
        return 'Shipment offer has been accepted';
      case ShipmentStatus.assigned:
        return 'Carrier has been assigned to this shipment';
      case ShipmentStatus.pickedUp:
        return 'Shipment has been picked up';
      case ShipmentStatus.inTransit:
        return 'Shipment is on the way';
      case ShipmentStatus.arrivedAtDestination:
        return 'Shipment has arrived';
      case ShipmentStatus.delivered:
        return 'Shipment successfully delivered';
      case ShipmentStatus.completed:
        return 'Shipment completed after payment confirmation';
      case ShipmentStatus.cancelled:
        return 'Shipment was cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
