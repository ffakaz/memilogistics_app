// lib/features/carrier/presentation/screens/completed_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../widgets/lifecycle_shipment_card.dart';

/// Screen 7: Completed Shipments
/// Shows shipments with COMPLETED status
/// Read-only archive
class CompletedShipmentsScreen extends StatefulWidget {
  const CompletedShipmentsScreen({super.key});

  @override
  State<CompletedShipmentsScreen> createState() =>
      _CompletedShipmentsScreenState();
}

class _CompletedShipmentsScreenState extends State<CompletedShipmentsScreen> {
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

  List<Shipment> _filterCompletedShipments(List<Shipment> shipments) {
    return shipments
        .where((s) => s.status == ShipmentStatus.completed)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Shipments'),
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
          final completedShipments = _filterCompletedShipments(allShipments);

          if (completedShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.done_all,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Completed Shipments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Finished shipments are archived here',
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
              itemCount: completedShipments.length,
              itemBuilder: (context, index) {
                final shipment = completedShipments[index];
                return LifecycleShipmentCard(
                  shipment: shipment,
                  subtitle: 'Paid • Delivered • Finished',
                  showActionButton: false, // Read-only
                );
              },
            ),
          );
        },
      ),
    );
  }
}
