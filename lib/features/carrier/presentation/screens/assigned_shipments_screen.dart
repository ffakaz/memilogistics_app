// lib/features/carrier/presentation/screens/assigned_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../widgets/lifecycle_shipment_card.dart';

/// Screen 2: Assigned Shipments
/// Shows shipments with ASSIGNED status
/// Carrier's operational workspace
class AssignedShipmentsScreen extends StatefulWidget {
  const AssignedShipmentsScreen({super.key});

  @override
  State<AssignedShipmentsScreen> createState() =>
      _AssignedShipmentsScreenState();
}

class _AssignedShipmentsScreenState extends State<AssignedShipmentsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentProvider>().getCarrierAssignedShipments();
    });
  }

  List<Shipment> _filterAssignedShipments(List<Shipment> shipments) {
    return shipments
        .where((s) => s.status == ShipmentStatus.assigned)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Shipments'),
        backgroundColor: const Color(0xFF2C3E50),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading &&
              (provider.assignedShipments.isEmpty && provider.shipments.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null &&
              provider.assignedShipments.isEmpty &&
              provider.shipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Filter from assigned shipments first, fallback to all shipments
          final allShipments = [
            ...provider.assignedShipments,
            ...provider.shipments
          ];
          final assignedShipments = _filterAssignedShipments(allShipments);

          if (assignedShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Assigned Shipments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accepted offers will move here',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignedShipments.length,
              itemBuilder: (context, index) {
                final shipment = assignedShipments[index];
                return LifecycleShipmentCard(
                  shipment: shipment,
                  onAction: () => _handlePickUp(shipment),
                  actionLabel: 'Pick Up Shipment',
                  actionIcon: Icons.local_shipping,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePickUp(Shipment shipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Up Shipment'),
        content: Text(
          'Confirm that you have picked up shipment ${shipment.trackingNumber ?? shipment.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Pick Up'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.pickedUp,
            location: shipment.origin,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shipment ${shipment.trackingNumber ?? shipment.id} picked up successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update shipment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
