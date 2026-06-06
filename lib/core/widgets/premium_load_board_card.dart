import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../../features/shipment/domain/entities/shipment.dart';
import '../../features/shipment/domain/enums/shipment_status.dart';

/// Ultra-Premium Load Board Card
/// Enterprise-grade logistics card inspired by Uber Freight, Convoy, Flexport
class PremiumLoadBoardCard extends StatefulWidget {
  final Shipment shipment;
  final VoidCallback? onTap;
  final VoidCallback? onOfferTap;
  final bool showOfferButton;
  final bool isLoadBoard;

  const PremiumLoadBoardCard({
    Key? key,
    required this.shipment,
    this.onTap,
    this.onOfferTap,
    this.showOfferButton = false,
    this.isLoadBoard = true,
  }) : super(key: key);

  @override
  State<PremiumLoadBoardCard> createState() => _PremiumLoadBoardCardState();
}

class _PremiumLoadBoardCardState extends State<PremiumLoadBoardCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacing16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppTheme.backgroundLight.withAlpha((0.5 * 255).round()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withAlpha((0.08 * 255).round()),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withAlpha((0.04 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
            border: Border.all(
              color: AppTheme.lightGray.withAlpha((0.15 * 255).round()),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Subtle background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.02,
                    child: CustomPaint(painter: _GridPatternPainter()),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      if (widget.shipment.description != null &&
                          widget.shipment.description!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          widget.shipment.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.darkGray),
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                      ],
                      const SizedBox(height: AppTheme.spacing20),
                      _buildRouteSection(context),
                      const SizedBox(height: AppTheme.spacing20),
                      _buildInfoChips(context),
                      const SizedBox(height: AppTheme.spacing12),
                      _buildScheduleRow(context),
                      if (widget.showOfferButton &&
                          widget.onOfferTap != null) ...[
                        const SizedBox(height: AppTheme.spacing20),
                        _buildOfferButton(context),
                      ],
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shipment icon with gradient
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryBlue.withAlpha((0.8 * 255).round()),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlue.withAlpha((0.25 * 255).round()),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: 26,
          ),
        ),
        const SizedBox(width: AppTheme.spacing16),
        // Tracking info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.shipment.trackingNumber ??
                          'SHIP-${widget.shipment.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: AppTheme.charcoal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withAlpha(
                        (0.08 * 255).round(),
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 12,
                          color: AppTheme.primaryBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.shipment.shipmentItem ?? 'General Cargo',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    '•',
                    style: TextStyle(color: AppTheme.lightGray, fontSize: 12),
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: AppTheme.darkGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.shipment.createdAt != null
                        ? _timeAgo(widget.shipment.createdAt!)
                        : 'Posted recently',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.darkGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              // Assigned carrier (if any)
              if (widget.shipment.assignedCarrierName != null &&
                  widget.shipment.assignedCarrierName!.trim().isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacing8),
                Row(
                  children: [
                    const Icon(
                      Icons.business,
                      size: 14,
                      color: AppTheme.darkGray,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Assigned to ${widget.shipment.assignedCarrierName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        // Status badge
        _buildStatusBadge(context),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final statusConfig = _getStatusConfig(widget.shipment.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusConfig.color.withAlpha((0.15 * 255).round()),
            statusConfig.color.withAlpha((0.08 * 255).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusConfig.color.withAlpha((0.3 * 255).round()),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: statusConfig.color.withAlpha((0.15 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusConfig.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusConfig.color.withAlpha((0.4 * 255).round()),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            statusConfig.label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: statusConfig.color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight.withAlpha((0.4 * 255).round()),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.lightGray.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          // Route visualizer
          Column(
            children: [
              // Origin dot
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981), // Emerald green
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF10B981,
                      ).withAlpha((0.4 * 255).round()),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.circle, size: 6, color: Colors.white),
                ),
              ),
              // Animated route line
              Container(
                width: 3,
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF10B981),
                      AppTheme.primaryBlue.withAlpha((0.6 * 255).round()),
                      const Color(0xFFEF4444), // Red
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Destination marker
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444), // Red
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFFEF4444,
                      ).withAlpha((0.4 * 255).round()),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.location_on, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppTheme.spacing16),
          // Location details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origin
                Text(
                  'ORIGIN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.trip_origin,
                      size: 16,
                      color: const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.shipment.origin,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.charcoal,
                              letterSpacing: -0.3,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacing16),
                // Destination
                Text(
                  'DESTINATION',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: const Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.shipment.destination,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.charcoal,
                              letterSpacing: -0.3,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChips(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildInfoChip(
          context,
          icon: Icons.scale_rounded,
          label: '${widget.shipment.weightKg.toStringAsFixed(1)} kg',
          color: AppTheme.primaryBlue,
        ),
        _buildInfoChip(
          context,
          icon: Icons.calendar_today_rounded,
          label: widget.shipment.estimatedDeliveryDate != null
              ? DateFormat(
                  'MMM dd',
                ).format(widget.shipment.estimatedDeliveryDate!)
              : (widget.shipment.pickupDate != null
                    ? DateFormat('MMM dd').format(widget.shipment.pickupDate!)
                    : 'TBD'),
          color: AppTheme.accentOrange,
        ),
        _buildInfoChip(
          context,
          icon: widget.shipment.fragile
              ? Icons.warning_amber_rounded
              : Icons.verified_rounded,
          label: widget.shipment.fragile ? 'Fragile' : 'Standard',
          color: widget.shipment.fragile
              ? const Color(0xFFF59E0B)
              : const Color(0xFF10B981),
        ),
        if (widget.shipment.shipmentType != null)
          _buildInfoChip(
            context,
            icon: Icons.category_rounded,
            label: widget.shipment.shipmentType.toString().split('.').last,
            color: const Color(0xFF8B5CF6),
          ),
      ],
    );
  }

  Widget _buildScheduleRow(BuildContext context) {
    final pickup = widget.shipment.pickupDate != null
        ? DateFormat('MMM dd, yyyy').format(widget.shipment.pickupDate!)
        : 'N/A';
    final eta = widget.shipment.estimatedDeliveryDate != null
        ? DateFormat(
            'MMM dd, yyyy',
          ).format(widget.shipment.estimatedDeliveryDate!)
        : 'N/A';

    return Row(
      children: [
        Expanded(
          child: _buildScheduleItem(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'Pickup',
            value: pickup,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        Expanded(
          child: _buildScheduleItem(
            context,
            icon: Icons.event_available_rounded,
            label: 'Delivery',
            value: eta,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.darkGray),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.charcoal),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha((0.2 * 255).round()),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onOfferTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2196F3), // Blue
                Color(0xFF1976D2), // Darker blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF2196F3).withAlpha((0.35 * 255).round()),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0xFF2196F3).withAlpha((0.2 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Submit Transport Offer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  _StatusConfig _getStatusConfig(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return _StatusConfig(
          label: 'PENDING',
          color: const Color(0xFFF59E0B), // Amber
        );
      case ShipmentStatus.accepted:
      case ShipmentStatus.assigned:
        return _StatusConfig(
          label: 'ASSIGNED',
          color: const Color(0xFF3B82F6), // Blue
        );
      case ShipmentStatus.pickedUp:
      case ShipmentStatus.inTransit:
        return _StatusConfig(
          label: 'IN TRANSIT',
          color: const Color(0xFF8B5CF6), // Purple
        );
      case ShipmentStatus.arrivedAtDestination:
        return _StatusConfig(
          label: 'ARRIVED',
          color: const Color(0xFF06B6D4), // Cyan
        );
      case ShipmentStatus.delivered:
        return _StatusConfig(
          label: 'DELIVERED',
          color: const Color(0xFF10B981), // Green
        );
      case ShipmentStatus.paymentPending:
        return _StatusConfig(
          label: 'PAYMENT PENDING',
          color: const Color(0xFFF59E0B), // Amber
        );
      case ShipmentStatus.completed:
        return _StatusConfig(
          label: 'COMPLETED',
          color: const Color(0xFF10B981), // Green
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;

  _StatusConfig({required this.label, required this.color});
}

/// Grid pattern painter for subtle background
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightGray.withAlpha((0.3 * 255).round())
      ..strokeWidth = 0.5;

    const spacing = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
