// lib/features/carrier/presentation/screens/picked_up_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../widgets/lifecycle_shipment_card.dart';

/// Screen 3: Picked Up Shipments
/// Shows shipments with PICKED_UP status
class PickedUpShipmentsScreen extends StatefulWidget {
  const PickedUpShipmentsScreen({super.key});

  @override
  State<PickedUpShipmentsScreen> createState() =>
      _PickedUpShipmentsScreenState();
}

class _PickedUpShipmentsScreenState extends State<PickedUpShipmentsScreen> {
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

  List<Shipment> _filterPickedUpShipments(List<Shipment> shipments) {
    return shipments
        .where((s) => s.status == ShipmentStatus.pickedUp)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Picked Up Shipments'),
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

          final allShipments = [
            ...provider.assignedShipments,
            ...provider.shipments
          ];
          final pickedUpShipments = _filterPickedUpShipments(allShipments);

          if (pickedUpShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Picked Up Shipments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Picked up loads will wait here for transit',
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
              itemCount: pickedUpShipments.length,
              itemBuilder: (context, index) {
                final shipment = pickedUpShipments[index];
                return LifecycleShipmentCard(
                  shipment: shipment,
                  onAction: () => _handleStartTransit(shipment),
                  actionLabel: 'Start Transit',
                  actionIcon: Icons.navigation,
                  subtitle: 'Pickup Location: ${shipment.origin}',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleStartTransit(Shipment shipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Transit'),
        content: Text(
          'Confirm that shipment ${shipment.trackingNumber ?? shipment.id} is now in transit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Start Transit'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.inTransit,
            location: shipment.origin,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Shipment ${shipment.trackingNumber ?? shipment.id} is now in transit'),
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
