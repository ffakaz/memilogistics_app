// lib/features/carrier/presentation/screens/payment_pending_shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../widgets/lifecycle_shipment_card.dart';

/// Screen 6: Payment Pending Shipments
/// Shows shipments with PAYMENT_PENDING status
/// Carrier can confirm payment receipt
class PaymentPendingShipmentsScreen extends StatefulWidget {
  const PaymentPendingShipmentsScreen({super.key});

  @override
  State<PaymentPendingShipmentsScreen> createState() =>
      _PaymentPendingShipmentsScreenState();
}

class _PaymentPendingShipmentsScreenState
    extends State<PaymentPendingShipmentsScreen> {
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

  List<Shipment> _filterPaymentPendingShipments(List<Shipment> shipments) {
    return shipments
        .where((s) => s.status == ShipmentStatus.paymentPending)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Pending'),
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
          final paymentPendingShipments =
              _filterPaymentPendingShipments(allShipments);

          if (paymentPendingShipments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No Payment Pending Shipments',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Carrier payment confirmations appear here',
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
              itemCount: paymentPendingShipments.length,
              itemBuilder: (context, index) {
                final shipment = paymentPendingShipments[index];
                return LifecycleShipmentCard(
                  shipment: shipment,
                  onAction: () => _handleConfirmPayment(shipment),
                  actionLabel: 'Confirm Payment',
                  actionIcon: Icons.check_circle,
                  subtitle: 'Payment Initiated by Shipper',
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleConfirmPayment(Shipment shipment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Confirm that you have received payment for shipment ${shipment.trackingNumber ?? shipment.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Receipt'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Use Payment API instead of status update
      final paymentProvider = context.read<PaymentProvider>();
      final success = await paymentProvider.confirmPayment(
        shipmentId: shipment.id!,
        transactionId: '', // Transaction ID can be empty or provided by carrier
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Payment confirmed - Shipment ${shipment.trackingNumber ?? shipment.id} completed'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to confirm payment: ${paymentProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
