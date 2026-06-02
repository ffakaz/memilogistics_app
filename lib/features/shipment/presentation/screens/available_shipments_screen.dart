// lib/features/shipment/presentation/screens/available_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/shipment.dart';
// note: shipment_status import removed — filtering now uses assignedCarrierId
import '../providers/shipment_provider.dart';
import 'shipment_details_screen.dart';
import '../../../shipment_offer/presentation/widgets/shipment_offer_dialog.dart';

class AvailableShipmentsScreen extends StatefulWidget {
  const AvailableShipmentsScreen({super.key});

  @override
  State<AvailableShipmentsScreen> createState() =>
      _AvailableShipmentsScreenState();
}

class _AvailableShipmentsScreenState extends State<AvailableShipmentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentProvider>().getAvailableShipments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Shipments'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ShipmentProvider>().getAvailableShipments();
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
                      provider.getAvailableShipments();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

            // Show unassigned shipments (available for bidding)
            final availableShipments = provider.shipments
              .where((s) => s.assignedCarrierId == null)
              .toList();

          if (availableShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No available shipments',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new shipments',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.getAvailableShipments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: availableShipments.length,
              itemBuilder: (context, index) {
                return _buildShipmentCard(
                  context,
                  availableShipments[index],
                  provider,
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
  ) {
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
              builder: (_) => ShipmentDetailsScreen(shipmentId: shipment.id!),
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
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: const Text(
                      'POSTED',
                      style: TextStyle(
                        color: Colors.green,
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
                      shipment.origin,
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
                      shipment.destination,
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

              const SizedBox(height: 16),

              // Offer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showOfferDialog(context, shipment),
                  icon: const Icon(Icons.local_offer),
                  label: const Text('Make Offer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C3E50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOfferDialog(BuildContext context, Shipment shipment) {
    showDialog(
      context: context,
      builder: (context) => ShipmentOfferDialog(shipment: shipment),
    );
  }
}
