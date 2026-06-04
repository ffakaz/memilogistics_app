// lib/features/carrier/presentation/screens/delivered_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../widgets/lifecycle_shipment_card.dart';

/// Screen 5: Delivered Shipments
/// Shows shipments with DELIVERED status
/// Carrier cannot modify shipment anymore (waiting for shipper payment)
class DeliveredShipmentsScreen extends StatefulWidget {
  const DeliveredShipmentsScreen({super.key});

  @override
  State<DeliveredShipmentsScreen> createState() =>
      _DeliveredShipmentsScreenState();
}

class _DeliveredShipmentsScreenState extends State<DeliveredShipmentsScreen> {
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

  List<Shipment> _filterDeliveredShipments(List<Shipment> shipments) {
    return shipments
        .where((s) => s.status == ShipmentStatus.delivered)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivered Shipments'),
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
          final deliveredShipments = _filterDeliveredShipments(allShipments);

          if (deliveredShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Delivered Shipments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Delivered loads wait for shipper payment',
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
              itemCount: deliveredShipments.length,
              itemBuilder: (context, index) {
                final shipment = deliveredShipments[index];
                return LifecycleShipmentCard(
                  shipment: shipment,
                  subtitle: 'Waiting for Shipper Payment',
                  showActionButton: false, // No action - waiting for shipper
                );
              },
            ),
          );
        },
      ),
    );
  }
}
