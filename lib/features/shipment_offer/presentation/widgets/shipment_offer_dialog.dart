// lib/features/shipment_offer/presentation/widgets/shipment_offer_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shipment/domain/entities/shipment.dart';
// shipment_status import removed — we check assignedCarrierId instead of status
import '../../../carrier/presentation/providers/carrier_company_provider.dart';
import '../providers/shipment_offer_provider.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';

/// Dialog for carriers to submit a shipment offer
/// Simplified from ShipmentBidDialog - only requires price
class ShipmentOfferDialog extends StatefulWidget {
  final Shipment shipment;

  const ShipmentOfferDialog({super.key, required this.shipment});

  @override
  State<ShipmentOfferDialog> createState() => _ShipmentOfferDialogState();
}

class _ShipmentOfferDialogState extends State<ShipmentOfferDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Submit Offer',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Shipment Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.shipment.trackingNumber ?? 'Shipment #${widget.shipment.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          if (widget.shipment.fragile)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.orange),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Fragile',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Route Information
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.trip_origin, size: 14, color: Colors.blue),
                                    const SizedBox(width: 6),
                                    Text(
                                      'ORIGIN',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.shipment.origin,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward, size: 20, color: Colors.grey.shade400),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: Colors.red),
                                    const SizedBox(width: 6),
                                    Text(
                                      'DESTINATION',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.shipment.destination,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const Divider(height: 24),
                      
                      // Shipment Details Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailChip(
                              Icons.scale,
                              'Weight',
                              '${widget.shipment.weightKg} kg',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailChip(
                              Icons.local_shipping,
                              'Type',
                              widget.shipment.shipmentType?.displayName ?? 'Standard',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (widget.shipment.pickupDate != null)
                        _buildDetailChip(
                          Icons.calendar_today,
                          'Pickup Date',
                          _formatDate(widget.shipment.pickupDate!),
                        ),
                      const SizedBox(height: 8),
                      if (widget.shipment.estimatedDeliveryDate != null)
                        _buildDetailChip(
                          Icons.event_available,
                          'Est. Delivery',
                          _formatDate(widget.shipment.estimatedDeliveryDate!),
                        ),
                      
                      // Additional Details
                      if (widget.shipment.description != null && 
                          widget.shipment.description!.isNotEmpty) ...[
                        const Divider(height: 24),
                        Text(
                          'Description:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.shipment.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Input
                const Text(
                  'Your Offer Price',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: const Text('ETB', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                    hintText: 'Enter your offer price (ETB)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an offer price';
                    }
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Please enter a valid number';
                    }
                    if (price <= 0) {
                      return 'Price must be greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the amount you would charge for this shipment',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),

                // Action Buttons (stacked for full-width submit)
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitOffer,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Submit Offer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate shipment is still unassigned
    if (widget.shipment.assignedCarrierId != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This shipment is no longer available for offers (already assigned).',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.pop(context);
      }
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final price = double.parse(_priceController.text);

      // Get carrier company provider to fetch carrier company ID
      final carrierProvider = context.read<CarrierCompanyProvider>();

      // Ensure carrier profile is loaded
      if (carrierProvider.state.company == null) {
        print('📋 Carrier profile not loaded, fetching...');
        await carrierProvider.getCarrierCompany();
      }

      final carrierCompanyId = carrierProvider.state.company?.id;

      // Validate carrier profile exists
      if (carrierCompanyId == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please create your carrier company profile first before submitting offers.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      print('📋 Submitting offer with Carrier Company ID: $carrierCompanyId');
      print('📋 Shipment ID: ${widget.shipment.id}');
      print('📋 Shipment Status: ${widget.shipment.status.displayName}');
      print('📋 Price: ETB ${price.toStringAsFixed(2)}');

      // Call API to submit offer with carrier company ID
      await context.read<ShipmentOfferProvider>().createOffer(
        widget.shipment.id!,
        carrierCompanyId,
        price,
      );

      // Update local shipment offers cache optimistically so the shipper
      // review screen (which reads from ShipmentProvider.offersCache) sees
      // the newly created offer immediately without an extra refresh.
      try {
        context.read<ShipmentProvider>().addOptimisticOffer(
          shipmentId: widget.shipment.id!,
          price: price,
        );
      } catch (_) {
        // Non-fatal: if ShipmentProvider isn't available in this context
        // just ignore and rely on the backend refresh path.
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Your offer has been submitted successfully. The shipper will review your offer and notify you once a decision is made.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error submitting offer: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit offer: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
