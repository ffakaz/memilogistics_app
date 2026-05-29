import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/status_chip.dart';
import '../widgets/premium_card.dart';
import '../widgets/premium_load_board_card.dart';
import '../../features/shipment/domain/entities/shipment.dart';
import 'package:intl/intl.dart';

/// Premium Shipment Card Widget
/// Modern, interactive card for displaying shipment information
/// 
/// Use PremiumLoadBoardCard for the ultra-modern design
/// This widget is kept for backward compatibility
class ShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback? onTap;
  final VoidCallback? onOfferTap;
  final bool showOfferButton;
  final bool useModernDesign;

  const ShipmentCard({
    Key? key,
    required this.shipment,
    this.onTap,
    this.onOfferTap,
    this.showOfferButton = false,
    this.useModernDesign = true, // Default to modern design
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the new ultra-premium design by default
    if (useModernDesign) {
      return PremiumLoadBoardCard(
        shipment: shipment,
        onTap: onTap,
        onOfferTap: onOfferTap,
        showOfferButton: showOfferButton,
      );
    }

    // Legacy design (kept for compatibility)
    return _LegacyShipmentCard(
      shipment: shipment,
      onTap: onTap,
      onOfferTap: onOfferTap,
      showOfferButton: showOfferButton,
    );
  }
}

/// Legacy Shipment Card Design
class _LegacyShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback? onTap;
  final VoidCallback? onOfferTap;
  final bool showOfferButton;

  const _LegacyShipmentCard({
    Key? key,
    required this.shipment,
    this.onTap,
    this.onOfferTap,
    this.showOfferButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      borderRadius: 20,
      boxShadow: AppTheme.mediumShadow,
      gradient: LinearGradient(
        colors: [
          Colors.white.withAlpha((0.98 * 255).round()),
          AppTheme.backgroundLight.withAlpha((0.98 * 255).round()),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tracking Number, Icon & Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing8),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withAlpha((0.12 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.trackingNumber ?? 'N/A',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Row(
                      children: [
                        Text(
                          shipment.shipmentItem ?? 'General Cargo',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.darkGray,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Text(
                          '•',
                          style: TextStyle(color: AppTheme.lightGray),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Text(
                          shipment.createdAt != null
                              ? _timeAgo(shipment.createdAt!)
                              : 'Posted recently',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.lightGray,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              AnimatedStatusChip(status: shipment.status),
            ],
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Origin / Destination visualizer
          const SizedBox(height: AppTheme.spacing8),
          _RouteVisualizer(
            origin: shipment.origin,
            destination: shipment.destination,
          ),

          const SizedBox(height: AppTheme.spacing16),

          // Info chips
          const SizedBox(height: AppTheme.spacing12),
          Wrap(
            spacing: AppTheme.spacing8,
            runSpacing: AppTheme.spacing8,
            children: [
              _InfoChip(
                icon: Icons.scale_rounded,
                label: '${shipment.weightKg.toStringAsFixed(1)} kg',
              ),
              _InfoChip(
                icon: Icons.calendar_today_rounded,
                label: shipment.estimatedDeliveryDate != null
                    ? DateFormat('MMM dd').format(shipment.estimatedDeliveryDate!)
                    : (shipment.pickupDate != null
                        ? DateFormat('MMM dd').format(shipment.pickupDate!)
                        : 'TBD'),
              ),
              _InfoChip(
                icon: shipment.fragile
                    ? Icons.warning_amber_rounded
                    : Icons.shield_outlined,
                label: shipment.fragile ? 'Fragile' : 'Standard',
              ),
              _InfoChip(
                icon: Icons.inventory_2_rounded,
                label: shipment.shipmentItem ?? 'General',
              ),
            ],
          ),

          // Offer Button (for carriers)
          if (showOfferButton && onOfferTap != null) ...[
            const SizedBox(height: AppTheme.spacing16),
            _GradientButton(
              onTap: onOfferTap!,
              label: 'Submit Offer',
              icon: Icons.local_shipping_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inDays >= 1) return 'Posted ${diff.inDays}d ago';
  if (diff.inHours >= 1) return 'Posted ${diff.inHours}h ago';
  if (diff.inMinutes >= 1) return 'Posted ${diff.inMinutes}m ago';
  return 'Posted just now';
}

class _RouteVisualizer extends StatelessWidget {
  final String origin;
  final String destination;

  const _RouteVisualizer({Key? key, required this.origin, required this.destination}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left visual column
        Column(
          children: [
            // Origin dot
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withAlpha((0.18 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            // Connector
            Container(
              width: 2,
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.withAlpha(180), AppTheme.primaryBlue.withAlpha(120)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Destination pin
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.statusCancelled,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.statusCancelled.withAlpha((0.18 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: AppTheme.spacing12),
        // Textual column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Origin', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.darkGray)),
              const SizedBox(height: AppTheme.spacing4),
              Text(origin, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: AppTheme.spacing12),
              Text('Destination', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.darkGray)),
              const SizedBox(height: AppTheme.spacing4),
              Text(destination, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({Key? key, required this.icon, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing12, vertical: AppTheme.spacing8),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.lightGray.withAlpha((0.25 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withAlpha((0.08 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: AppTheme.primaryBlue),
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _GradientButton({Key? key, required this.onTap, required this.label, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing16),
          decoration: BoxDecoration(
            gradient: AppTheme.orangeGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: AppTheme.mediumShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: AppTheme.spacing8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact Shipment Card for lists
class CompactShipmentCard extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback? onTap;

  const CompactShipmentCard({
    Key? key,
    required this.shipment,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacing12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing8),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shipment.trackingNumber ?? 'N/A',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  '${shipment.origin} → ${shipment.destination}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkGray,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing8),
          StatusChip(
            status: shipment.status,
            showIcon: false,
            fontSize: 10,
          ),
        ],
      ),
    );
  }
}

