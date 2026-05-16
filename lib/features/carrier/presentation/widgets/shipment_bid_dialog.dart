// lib/features/carrier/presentation/widgets/shipment_bid_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../shipment/domain/entities/shipment.dart';

class ShipmentBidDialog extends StatefulWidget {
  final Shipment shipment;

  const ShipmentBidDialog({super.key, required this.shipment});

  @override
  State<ShipmentBidDialog> createState() => _ShipmentBidDialogState();
}

class _ShipmentBidDialogState extends State<ShipmentBidDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _daysController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _daysController.dispose();
    _notesController.dispose();
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
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      color: Colors.blue,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Submit Your Bid',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Shipment #${widget.shipment.id}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                // Route Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.shipment.origin.shortLabel,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_downward,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.shipment.weight} ${widget.shipment.weightUnit.displayName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.flag, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.shipment.destination.shortLabel,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Input
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Your Bid Price *',
                    hintText: 'Enter amount in USD',
                    prefixIcon: const Icon(Icons.attach_money),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    helperText:
                        'Competitive pricing increases acceptance chances',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a bid price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Estimated Delivery Days
                TextFormField(
                  controller: _daysController,
                  decoration: InputDecoration(
                    labelText: 'Estimated Delivery Days *',
                    hintText: 'Number of days',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter estimated delivery days';
                    }
                    final days = int.tryParse(value);
                    if (days == null || days <= 0) {
                      return 'Please enter a valid number of days';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Notes (Optional)
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Additional Notes (Optional)',
                    hintText: 'Any special conditions or information',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitBid,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
                            'Submit Bid',
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
        ),
      ),
    );
  }

  Future<void> _submitBid() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Implement bid submission logic
      // final bidData = {
      //   'shipment_id': widget.shipment.id,
      //   'proposed_price': double.parse(_priceController.text),
      //   'estimated_delivery_days': int.parse(_daysController.text),
      //   'notes': _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      // };

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Bid Submitted Successfully!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Bid: \$${_priceController.text} | ${_daysController.text} days',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit bid: ${e.toString()}'),
            backgroundColor: Colors.red,
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
