import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../../core/widgets/premium_card.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import 'package:intl/intl.dart';

/// Premium Shipment Details Screen
/// Beautiful, detailed view of shipment with timeline and tracking
class PremiumShipmentDetailsScreen extends StatelessWidget {
  final Shipment shipment;

  const PremiumShipmentDetailsScreen({
    Key? key,
    required this.shipment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with Gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primaryBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedStatusChip(status: shipment.status),
                        const SizedBox(height: AppTheme.spacing16),
                        Text(
                          shipment.trackingNumber ?? 'N/A',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: AppTheme.spacing8),
                        Text(
                          shipment.shipmentItem ?? 'N/A',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withAlpha((0.9 * 255).round()),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Share shipment
                },
                icon: const Icon(Icons.share_rounded, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  // More options
                },
                icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacing24),

                // Route Card
                _buildRouteCard(context),

                const SizedBox(height: AppTheme.spacing16),

                // Shipment Details Card
                _buildDetailsCard(context),

                const SizedBox(height: AppTheme.spacing16),

                // Timeline Card
                _buildTimelineCard(context),

                const SizedBox(height: AppTheme.spacing24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteCard(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.route_rounded,
                color: AppTheme.electricOrange,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Route Information',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          _RouteTimeline(
            origin: shipment.origin,
            destination: shipment.destination,
            status: shipment.status,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Shipment Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          _DetailRow(
            icon: Icons.scale_rounded,
            label: 'Weight',
            value: '${shipment.weightKg.toStringAsFixed(1)} kg',
          ),
          const Divider(height: AppTheme.spacing20),
          _DetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Pickup Date',
            value: shipment.pickupDate != null
                ? DateFormat('MMMM dd, yyyy').format(shipment.pickupDate!)
                : 'To be determined',
          ),
          if (shipment.estimatedDeliveryDate != null) ...[
            const Divider(height: AppTheme.spacing20),
            _DetailRow(
              icon: Icons.event_rounded,
              label: 'Estimated Delivery',
              value: DateFormat('MMMM dd, yyyy').format(shipment.estimatedDeliveryDate!),
            ),
          ],
          const Divider(height: AppTheme.spacing20),
          _DetailRow(
            icon: shipment.fragile
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline_rounded,
            label: 'Fragile',
            value: shipment.fragile ? 'Yes - Handle with care' : 'No',
            valueColor: shipment.fragile
                ? AppTheme.statusCancelled
                : AppTheme.statusDelivered,
          ),
          if (shipment.description != null && shipment.description!.isNotEmpty) ...[
            const Divider(height: AppTheme.spacing20),
            _DetailRow(
              icon: Icons.description_rounded,
              label: 'Description',
              value: shipment.description!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline_rounded,
                color: AppTheme.statusInTransit,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                'Delivery Timeline',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),
          _DeliveryTimeline(status: shipment.status),
        ],
      ),
    );
  }
}

class _RouteTimeline extends StatelessWidget {
  final String origin;
  final String destination;
  final ShipmentStatus status;

  const _RouteTimeline({
    Key? key,
    required this.origin,
    required this.destination,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isInTransit = status == ShipmentStatus.inTransit;
    final isDelivered = status == ShipmentStatus.delivered;

    return Column(
      children: [
        _RoutePoint(
          icon: Icons.trip_origin_rounded,
          location: origin,
          label: 'Origin',
          isActive: true,
          isCompleted: true,
        ),
        _RouteConnector(
          isActive: isInTransit || isDelivered,
          isCompleted: isDelivered,
        ),
        _RoutePoint(
          icon: Icons.location_on_rounded,
          location: destination,
          label: 'Destination',
          isActive: isDelivered,
          isCompleted: isDelivered,
        ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final IconData icon;
  final String location;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _RoutePoint({
    Key? key,
    required this.icon,
    required this.location,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacing12),
          decoration: BoxDecoration(
            gradient: isActive
                ? AppTheme.orangeGradient
                : LinearGradient(
                    colors: [
                      AppTheme.lightGray.withAlpha((0.3 * 255).round()),
                      AppTheme.lightGray.withAlpha((0.2 * 255).round()),
                    ],
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: Border.all(
              color: isActive
                  ? AppTheme.electricOrange
                  : AppTheme.lightGray.withAlpha((0.5 * 255).round()),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : AppTheme.darkGray,
            size: 24,
          ),
        ),
        const SizedBox(width: AppTheme.spacing16),
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
                location,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isActive ? AppTheme.charcoal : AppTheme.darkGray,
                    ),
              ),
            ],
          ),
        ),
        if (isCompleted)
          Icon(
            Icons.check_circle_rounded,
            color: AppTheme.statusDelivered,
            size: 24,
          ),
      ],
    );
  }
}

class _RouteConnector extends StatelessWidget {
  final bool isActive;
  final bool isCompleted;

  const _RouteConnector({
    Key? key,
    required this.isActive,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacing20,
        top: AppTheme.spacing8,
        bottom: AppTheme.spacing8,
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              gradient: isActive
                  ? LinearGradient(
                      colors: [
                        AppTheme.electricOrange,
                        isCompleted ? AppTheme.statusDelivered : AppTheme.statusInTransit,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                  : LinearGradient(
                      colors: [
                        AppTheme.lightGray.withAlpha((0.3 * 255).round()),
                        AppTheme.lightGray.withAlpha((0.3 * 255).round()),
                      ],
                    ),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
          const SizedBox(width: AppTheme.spacing16),
          if (isActive && !isCompleted)
            Icon(
              Icons.local_shipping_rounded,
              color: AppTheme.statusInTransit,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _DeliveryTimeline extends StatelessWidget {
  final ShipmentStatus status;

  const _DeliveryTimeline({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        title: 'Shipment Created',
        subtitle: 'Awaiting carrier assignment',
        icon: Icons.add_circle_rounded,
        isCompleted: true,
        isActive: status == ShipmentStatus.pending,
      ),
      _TimelineStep(
        title: 'Carrier Assigned',
        subtitle: 'Preparing for pickup',
        icon: Icons.assignment_turned_in_rounded,
        isCompleted: status.index >= ShipmentStatus.assigned.index,
        isActive: status == ShipmentStatus.assigned,
      ),
      _TimelineStep(
        title: 'In Transit',
        subtitle: 'On the way to destination',
        icon: Icons.local_shipping_rounded,
        isCompleted: status.index >= ShipmentStatus.inTransit.index,
        isActive: status == ShipmentStatus.inTransit,
      ),
      _TimelineStep(
        title: 'Delivered',
        subtitle: 'Successfully delivered',
        icon: Icons.check_circle_rounded,
        isCompleted: status == ShipmentStatus.delivered,
        isActive: status == ShipmentStatus.delivered,
        isLast: true,
      ),
    ];

    return Column(
      children: steps.map((step) => _TimelineItem(step: step)).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;

  const _TimelineItem({
    Key? key,
    required this.step,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: step.isCompleted
                    ? AppTheme.statusDelivered
                    : step.isActive
                        ? AppTheme.electricOrange
                        : AppTheme.lightGray.withAlpha((0.3 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step.icon,
                color: step.isCompleted || step.isActive
                    ? Colors.white
                    : AppTheme.darkGray,
                size: 20,
              ),
            ),
            if (!step.isLast)
              Container(
                width: 2,
                height: 40,
                margin: const EdgeInsets.symmetric(vertical: AppTheme.spacing4),
                color: step.isCompleted
                    ? AppTheme.statusDelivered.withAlpha((0.5 * 255).round())
                    : AppTheme.lightGray.withAlpha((0.3 * 255).round()),
              ),
          ],
        ),
        const SizedBox(width: AppTheme.spacing16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: step.isActive || step.isCompleted
                            ? AppTheme.charcoal
                            : AppTheme.darkGray,
                      ),
                ),
                const SizedBox(height: AppTheme.spacing4),
                Text(
                  step.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.darkGray,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;

  _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
    this.isLast = false,
  });
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
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
                      color: valueColor ?? AppTheme.charcoal,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

