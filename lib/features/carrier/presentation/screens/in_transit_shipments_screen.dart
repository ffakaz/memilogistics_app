// lib/features/carrier/presentation/screens/in_transit_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../widgets/lifecycle_shipment_card.dart';

/// Screen 4: In Transit Shipments
/// Shows shipments with IN_TRANSIT status
class InTransitShipmentsScreen extends StatefulWidget {
  const InTransitShipmentsScreen({super.key});

  @override
  State<InTransitShipmentsScreen> createState() =>
      _InTransitShipmentsScreenState();
}

class _InTransitShipmentsScreenState extends State<InTransitShipmentsScreen> {
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

  List<Shipment> _filterInTransitShipments(List<Shipment> shipments) {
    return shipments
        .where((s) => s.status == ShipmentStatus.inTransit)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In Transit Shipments'),
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
          final inTransitShipments = _filterInTransitShipments(allShipments);

          if (inTransitShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No In Transit Shipments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shipments on the road will appear here',
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
              itemCount: inTransitShipments.length,
              itemBuilder: (context, index) {
                final shipment = inTransitShipments[index];
                return LifecycleShipmentCard(
                  shipment: shipment,
                  onAction: () => _handleMarkArrived(shipment),
                  actionLabel: 'Mark Arrived',
                  actionIcon: Icons.place,
                  subtitle: 'Destination: ${shipment.destination}',
                  showSecondaryAction: true,
                  secondaryActionLabel: 'Update Location',
                  secondaryActionIcon: Icons.my_location,
                  onSecondaryAction: () => _handleUpdateLocation(shipment),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleUpdateLocation(Shipment shipment) async {
    final locationController = TextEditingController();

    final location = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Location'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shipment: ${shipment.trackingNumber ?? shipment.id}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Current Location',
                hintText: 'e.g., Mekelle, Bahir Dar',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
          ],
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated to: $location'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleMarkArrived(Shipment shipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark Arrived at Destination'),
        content: Text(
          'Confirm arrival of shipment ${shipment.trackingNumber ?? shipment.id} at ${shipment.destination}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Arrival'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            ShipmentStatus.arrivedAtDestination,
            location: shipment.destination,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Shipment ${shipment.trackingNumber ?? shipment.id} marked as arrived at destination'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark as arrived: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

}
