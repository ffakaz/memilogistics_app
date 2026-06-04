// lib/features/carrier/presentation/widgets/offerable_shipment_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment/domain/enums/shipment_status.dart';
import '../../../shipment_offer/presentation/providers/shipment_offer_provider.dart';
import 'package:intl/intl.dart';

/// Enhanced card for offerable loads on load board
/// Shows offer button with submission state
class OfferableShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback onMakeOffer;

  const OfferableShipmentCard({
    super.key,
    required this.shipment,
    required this.onMakeOffer,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ShipmentOfferProvider>(
      builder: (context, offerProvider, _) {
        final hasSubmitted =
            offerProvider.hasSubmittedOfferForShipment(shipment.id ?? 0);
        final isSubmitting =
            offerProvider.isSubmittingForShipment(shipment.id ?? 0);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C3E50), Color(0xFF34495E)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        shipment.trackingNumber ?? 'TRK-${shipment.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _buildStatusBadge(shipment.status),
                  ],
                ),
                const SizedBox(height: 16),

                // Route Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FROM',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shipment.origin,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            shipment.destination,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Details Grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        Icons.scale,
                        'Weight',
                        '${shipment.weightKg} kg',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.calendar_today,
                        'Pickup',
                        shipment.pickupDate != null
                            ? DateFormat('MMM dd').format(shipment.pickupDate!)
                            : 'N/A',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (shipment.fragile)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                size: 16, color: Colors.orange),
                            SizedBox(width: 4),
                            Text(
                              'Fragile',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: hasSubmitted || isSubmitting ? null : onMakeOffer,
                    icon: Icon(
                      hasSubmitted
                          ? Icons.check_circle
                          : isSubmitting
                              ? Icons.hourglass_empty
                              : Icons.local_offer,
                    ),
                    label: Text(
                      hasSubmitted
                          ? 'Offer Submitted'
                          : isSubmitting
                              ? 'Submitting...'
                              : 'Make Offer',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasSubmitted
                          ? Colors.green
                          : const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: hasSubmitted ? 0 : 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ShipmentStatus status) {
    Color color;
    switch (status) {
      case ShipmentStatus.pending:
        color = Colors.orange;
        break;
      case ShipmentStatus.accepted:
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
