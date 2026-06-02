import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../../features/shipment/domain/entities/shipment.dart';

/// Premium Offer Bottom Sheet
/// Beautiful, modern interface for making offers on shipments
class PremiumOfferSheet extends StatefulWidget {
  final Shipment shipment;
  final Function(double price) onSubmit;

  const PremiumOfferSheet({
    Key? key,
    required this.shipment,
    required this.onSubmit,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required Shipment shipment,
    required Function(double price) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PremiumOfferSheet(
        shipment: shipment,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<PremiumOfferSheet> createState() => _PremiumOfferSheetState();
}

class _PremiumOfferSheetState extends State<PremiumOfferSheet> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final price = double.parse(_priceController.text);
      await widget.onSubmit(price);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Text('Your offer has been submitted successfully. The shipper will review your offer and notify you once a decision is made.'),
                ),
              ],
            ),
            backgroundColor: AppTheme.statusDelivered,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit offer: $e'),
            backgroundColor: AppTheme.statusCancelled,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusXLarge),
          topRight: Radius.circular(AppTheme.radiusXLarge),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: AppTheme.spacing12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGray.withAlpha((0.5 * 255).round()),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            gradient: AppTheme.orangeGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Make an Offer',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacing4),
                              Text(
                                'Submit your competitive price',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.darkGray,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppTheme.spacing24),

                    // Shipment Info Card
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.confirmation_number_rounded,
                            label: 'Tracking',
                            value: widget.shipment.trackingNumber ?? 'N/A',
                          ),
                          const Divider(height: AppTheme.spacing16),
                          _InfoRow(
                            icon: Icons.inventory_2_rounded,
                            label: 'Item',
                            value: widget.shipment.shipmentItem ?? 'N/A',
                          ),
                          const Divider(height: AppTheme.spacing16),
                          _InfoRow(
                            icon: Icons.route_rounded,
                            label: 'Route',
                            value: '${widget.shipment.origin} → ${widget.shipment.destination}',
                          ),
                          const Divider(height: AppTheme.spacing16),
                          _InfoRow(
                            icon: Icons.scale_rounded,
                            label: 'Weight',
                            value: '${widget.shipment.weightKg.toStringAsFixed(1)} kg',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing24),

                    // Price Input Form
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Offer Price',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                            decoration: InputDecoration(
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(AppTheme.spacing12),
                                padding: const EdgeInsets.all(AppTheme.spacing8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.orangeGradient,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                                ),
                                child: const Icon(
                                  Icons.attach_money_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              hintText: 'Enter your price',
                              suffixText: 'ETB',
                              suffixStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.darkGray,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: AppTheme.spacing16),

                          // Pricing Tips
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing12),
                            decoration: BoxDecoration(
                              color: AppTheme.statusAssigned.withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(
                                color: AppTheme.statusAssigned.withAlpha((0.3 * 255).round()),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb_rounded,
                                  color: AppTheme.statusAssigned,
                                  size: 20,
                                ),
                                const SizedBox(width: AppTheme.spacing12),
                                Expanded(
                                  child: Text(
                                    'Competitive offers have higher chances of acceptance',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.statusAssigned,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacing24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : const Text('Submit Offer'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.darkGray,
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.darkGray,
                    ),
              ),
              const SizedBox(height: AppTheme.spacing4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

