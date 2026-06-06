// lib/features/shipment/presentation/widgets/interactive_shipment_timeline.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../carrier/presentation/providers/carrier_company_provider.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';

/// Interactive Shipment Timeline Widget
/// 
/// Displays shipment lifecycle stages with visual progress tracking.
/// For assigned carriers, allows tapping on the next valid stage to progress the shipment.
/// 
/// Features:
/// - Visual timeline with completed/current/future stages
/// - Interactive for assigned carriers only
/// - Confirmation dialogs before status changes
/// - Proper role-based permissions
/// - Error handling and success feedback
/// 
/// Usage:
/// ```dart
/// InteractiveShipmentTimeline(
///   shipment: shipment,
///   onStatusUpdated: () {
///     // Refresh shipment data
///   },
/// )
/// ```
class InteractiveShipmentTimeline extends StatelessWidget {
  final Shipment shipment;
  final VoidCallback? onStatusUpdated;
  final bool enableInteraction;

  const InteractiveShipmentTimeline({
    super.key,
    required this.shipment,
    this.onStatusUpdated,
    this.enableInteraction = true,
  });

  /// Timeline stages in order
  static const List<ShipmentStatus> _stages = [
    ShipmentStatus.pending,
    ShipmentStatus.accepted,
    ShipmentStatus.assigned,
    ShipmentStatus.pickedUp,
    ShipmentStatus.inTransit,
    ShipmentStatus.arrivedAtDestination,
    ShipmentStatus.delivered,
    ShipmentStatus.paymentPending,
    ShipmentStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, CarrierCompanyProvider>(
      builder: (context, authProvider, carrierProvider, _) {
        final role = authProvider.userRole?.toUpperCase();
        final carrierCompanyId = carrierProvider.state.company?.id;
        final isAssignedCarrier = role == 'CARRIER' &&
            shipment.assignedCarrierId != null &&
            carrierCompanyId != null &&
            shipment.assignedCarrierId == carrierCompanyId;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.timeline,
                      size: 20,
                      color: Color(0xFF2C5E78),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Shipment Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C5E78),
                      ),
                    ),
                    if (isAssignedCarrier && enableInteraction) ...[
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 14,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap to advance',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                _buildTimeline(context, isAssignedCarrier),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeline(BuildContext context, bool isAssignedCarrier) {
    final currentIndex = _stages.indexOf(shipment.status);

    return Column(
      children: List.generate(_stages.length, (index) {
        final stage = _stages[index];
        final isCompleted = index < currentIndex;
        final isCurrent = index == currentIndex;
        final isNext = index == currentIndex + 1;
        final isInteractive = isAssignedCarrier &&
            enableInteraction &&
            isNext &&
            _canProgressToStage(stage);

        return Column(
          children: [
            _buildStageRow(
              context,
              stage,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isInteractive: isInteractive,
            ),
            if (index < _stages.length - 1)
              _buildConnectorLine(isCompleted || isCurrent),
          ],
        );
      }),
    );
  }

  Widget _buildStageRow(
    BuildContext context,
    ShipmentStatus stage, {
    required bool isCompleted,
    required bool isCurrent,
    required bool isInteractive,
  }) {
    final stageInfo = _getStageInfo(stage);

    return InkWell(
      onTap: isInteractive
          ? () => _handleStageTap(context, stage)
          : null,
      borderRadius: BorderRadius.circular(8),
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isInteractive
              ? Colors.blue.shade50.withValues(alpha: 0.5)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isInteractive
              ? Border.all(color: Colors.blue.shade200, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            _buildStageIndicator(
              stageInfo.icon,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isInteractive: isInteractive,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stageInfo.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.w600,
                      color: isCompleted || isCurrent
                          ? Colors.black87
                          : Colors.grey.shade600,
                    ),
                  ),
                  if (stageInfo.subtitle != null)
                    Text(
                      stageInfo.subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  if (isInteractive)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tap to ${stageInfo.action ?? 'advance'}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 20,
              ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5E78),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageIndicator(
    IconData icon, {
    required bool isCompleted,
    required bool isCurrent,
    required bool isInteractive,
  }) {
    Color bgColor;
    Color iconColor;

    if (isCompleted) {
      bgColor = Colors.green.shade600;
      iconColor = Colors.white;
    } else if (isCurrent) {
      bgColor = const Color(0xFF2C5E78);
      iconColor = Colors.white;
    } else if (isInteractive) {
      bgColor = Colors.blue.shade100;
      iconColor = Colors.blue.shade700;
    } else {
      bgColor = Colors.grey.shade300;
      iconColor = Colors.grey.shade600;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isCurrent
            ? Border.all(color: const Color(0xFF2C5E78), width: 3)
            : null,
        boxShadow: isInteractive
            ? [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 22,
      ),
    );
  }

  Widget _buildConnectorLine(bool isActive) {
    return Container(
      margin: const EdgeInsets.only(left: 22),
      width: 3,
      height: 24,
      color: isActive ? Colors.green.shade600 : Colors.grey.shade300,
    );
  }

  /// Check if carrier can progress to the given stage
  bool _canProgressToStage(ShipmentStatus targetStage) {
    final currentStatus = shipment.status;

    // Define valid transitions
    final validTransitions = {
      ShipmentStatus.assigned: ShipmentStatus.pickedUp,
      ShipmentStatus.pickedUp: ShipmentStatus.inTransit,
      ShipmentStatus.inTransit: ShipmentStatus.arrivedAtDestination,
      ShipmentStatus.arrivedAtDestination: ShipmentStatus.delivered,
      // Payment transitions handled separately (shipper initiates, carrier confirms)
    };

    return validTransitions[currentStatus] == targetStage;
  }

  /// Handle stage tap
  Future<void> _handleStageTap(
    BuildContext context,
    ShipmentStatus targetStage,
  ) async {
    final stageInfo = _getStageInfo(targetStage);

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(stageInfo.confirmTitle ?? 'Confirm Action'),
        content: Text(
          stageInfo.confirmMessage ??
              'Are you sure you want to update the shipment status?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2C5E78),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Update status
    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
            shipment.id!,
            targetStage,
            location: _getLocationForStage(targetStage),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(stageInfo.successMessage ?? 'Status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Trigger callback
      onStatusUpdated?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Get location for stage update
  String _getLocationForStage(ShipmentStatus stage) {
    switch (stage) {
      case ShipmentStatus.pickedUp:
      case ShipmentStatus.inTransit:
        return shipment.origin;
      case ShipmentStatus.arrivedAtDestination:
      case ShipmentStatus.delivered:
        return shipment.destination;
      default:
        return shipment.origin;
    }
  }

  /// Get stage display information
  _StageInfo _getStageInfo(ShipmentStatus stage) {
    switch (stage) {
      case ShipmentStatus.pending:
        return _StageInfo(
          icon: Icons.pending,
          title: 'Pending',
          subtitle: 'Waiting for carrier offers',
        );
      case ShipmentStatus.accepted:
        return _StageInfo(
          icon: Icons.check,
          title: 'Accepted',
          subtitle: 'Shipper reviewing offers',
        );
      case ShipmentStatus.assigned:
        return _StageInfo(
          icon: Icons.assignment_turned_in,
          title: 'Assigned',
          subtitle: 'Carrier assigned',
        );
      case ShipmentStatus.pickedUp:
        return _StageInfo(
          icon: Icons.inventory,
          title: 'Picked Up',
          subtitle: 'Shipment collected',
          action: 'mark as picked up',
          confirmTitle: 'Confirm Pick Up',
          confirmMessage:
              'Confirm that you have picked up this shipment from ${shipment.origin}?',
          successMessage: 'Shipment marked as picked up',
        );
      case ShipmentStatus.inTransit:
        return _StageInfo(
          icon: Icons.local_shipping,
          title: 'In Transit',
          subtitle: 'On the way to destination',
          action: 'start transit',
          confirmTitle: 'Start Transit',
          confirmMessage:
              'Confirm that this shipment is now in transit to ${shipment.destination}?',
          successMessage: 'Shipment is now in transit',
        );
      case ShipmentStatus.arrivedAtDestination:
        return _StageInfo(
          icon: Icons.place,
          title: 'Arrived at Destination',
          subtitle: 'Ready for delivery',
          action: 'mark arrived',
          confirmTitle: 'Confirm Arrival',
          confirmMessage:
              'Confirm arrival at ${shipment.destination}?',
          successMessage: 'Shipment marked as arrived',
        );
      case ShipmentStatus.delivered:
        return _StageInfo(
          icon: Icons.check_circle,
          title: 'Delivered',
          subtitle: 'Waiting for payment',
          action: 'mark delivered',
          confirmTitle: 'Confirm Delivery',
          confirmMessage:
              'Confirm delivery to customer at ${shipment.destination}?',
          successMessage: 'Shipment marked as delivered',
        );
      case ShipmentStatus.paymentPending:
        return _StageInfo(
          icon: Icons.payments,
          title: 'Payment Pending',
          subtitle: 'Shipper processing payment',
        );
      case ShipmentStatus.completed:
        return _StageInfo(
          icon: Icons.done_all,
          title: 'Completed',
          subtitle: 'Shipment lifecycle complete',
        );
    }
  }
}

/// Stage information model
class _StageInfo {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? action;
  final String? confirmTitle;
  final String? confirmMessage;
  final String? successMessage;

  _StageInfo({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.confirmTitle,
    this.confirmMessage,
    this.successMessage,
  });
}
