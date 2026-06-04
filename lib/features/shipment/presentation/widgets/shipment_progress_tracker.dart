import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/shipment_status.dart';
import '../../domain/entities/shipment.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';

/// Interactive horizontal progress tracker for shipment lifecycle
class ShipmentProgressTracker extends StatefulWidget {
  final ShipmentStatus status;
  final bool compact;
  final Shipment? shipment;

  const ShipmentProgressTracker({
    super.key,
    required this.status,
    this.compact = false,
    this.shipment,
  });

  @override
  State<ShipmentProgressTracker> createState() => _ShipmentProgressTrackerState();
}

class _ShipmentProgressTrackerState extends State<ShipmentProgressTracker> {
  bool _loading = false;
  List<Map<String, dynamic>> _events = [];

  Future<void> _performAction() async {
    final s = widget.shipment;
    if (s == null || s.id == null) return;
    final prov = context.read<ShipmentProvider>();
    final paymentProv = context.read<PaymentProvider>();

    setState(() => _loading = true);
    try {
      switch (widget.status) {
        case ShipmentStatus.assigned:
          await prov.updateShipmentStatus(s.id!, ShipmentStatus.pickedUp, location: s.origin);
          break;
        case ShipmentStatus.pickedUp:
          await prov.updateShipmentStatus(s.id!, ShipmentStatus.inTransit, location: 'On route');
          break;
        case ShipmentStatus.inTransit:
          await prov.updateShipmentStatus(s.id!, ShipmentStatus.delivered, location: s.destination);
          break;
        case ShipmentStatus.paymentPending:
          // Confirm payment via PaymentProvider
          await paymentProv.getPaymentRecord(shipmentId: s.id!);
          await paymentProv.confirmPayment(shipmentId: s.id!, transactionId: '');
          break;
        default:
          break;
      }

      // Refresh lists/details after mutation
      try {
        await prov.getCarrierAssignedShipments();
        await prov.getMyShipmentsByStatus(status: ShipmentStatus.pickedUp);
        await prov.getMyShipmentsByStatus(status: ShipmentStatus.inTransit);
        await prov.getMyShipmentsByStatus(status: ShipmentStatus.delivered);
        await prov.getMyShipmentsByStatus(status: ShipmentStatus.paymentPending);
        await prov.getMyShipmentsByStatus(status: ShipmentStatus.completed);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.shipment?.id != null) {
      _loadEvents();
    }
  }

  Future<void> _loadEvents() async {
    final id = widget.shipment?.id;
    if (id == null) return;
    try {
      final ev = await context.read<ShipmentProvider>().getShipmentEvents(id);
      if (mounted) setState(() => _events = ev);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status;
    final steps = [
      ShipmentStatus.pending,
      ShipmentStatus.accepted,
      ShipmentStatus.assigned,
      ShipmentStatus.pickedUp,
      ShipmentStatus.inTransit,
      ShipmentStatus.delivered,
      ShipmentStatus.paymentPending,
      ShipmentStatus.completed,
    ];

    final circleSize = widget.compact ? 18.0 : 40.0;
    final iconSize = widget.compact ? 12.0 : 18.0;
    final horizontalPadding = widget.compact ? 4.0 : 8.0;

    return SizedBox(
      height: widget.compact ? 28 : 96,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: steps.map((s) {
            final isCompleted = s.index < status.index;
            final isActive = s == status;
            final evt = _findEventForStatus(s);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      color: isCompleted || isActive ? Colors.blue : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        isCompleted ? Icons.check : (isActive ? Icons.radio_button_checked : Icons.circle),
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                  ),
                  if (!widget.compact) ...[
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 80,
                      child: Column(children: [
                        Text(
                          s.displayName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isCompleted || isActive ? Colors.black87 : Colors.grey[600],
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // timeline details
                        if (evt != null) ...[
                          Text(_formatEventTime(evt), style: const TextStyle(fontSize: 10, color: Colors.black54)),
                          const SizedBox(height: 2),
                          Text(_formatEventActor(evt), style: const TextStyle(fontSize: 10, color: Colors.black45)),
                        ],
                        const SizedBox(height: 6),
                        if (isActive && widget.shipment != null) _buildActionForStatus(s)
                      ]),
                    ),
                  ] else ...[
                    // compact mode: show tiny action label if active
                    if (isActive && widget.shipment != null) ...[
                      const SizedBox(height: 4),
                      _buildCompactActionLabel(s),
                    ]
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Map<String, dynamic>? _findEventForStatus(ShipmentStatus s) {
    if (_events.isEmpty) return null;
    final name = s.name.toLowerCase();
    for (final e in _events.reversed) {
      // possible keys: 'status', 'type', 'action'
      final keys = ['status', 'type', 'action', 'event', 'name'];
      for (final k in keys) {
        final v = e[k];
        if (v == null) continue;
        final vs = v.toString().toLowerCase();
        if (vs.contains(name)) return e;
      }
    }
    return null;
  }

  String _formatEventTime(Map<String, dynamic> e) {
    final ts = e['createdAt'] ?? e['timestamp'] ?? e['time'] ?? e['date'];
    if (ts == null) return '';
    try {
      if (ts is String) return DateTime.parse(ts).toLocal().toIso8601String().split('T').first;
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts).toLocal().toIso8601String().split('T').first;
    } catch (_) {}
    return ts.toString();
  }

  String _formatEventActor(Map<String, dynamic> e) {
    final a = e['actor'] ?? e['user'] ?? e['by'] ?? e['performedBy'];
    if (a == null) return '';
    return a.toString();
  }

  Widget _buildCompactActionLabel(ShipmentStatus s) {
    final label = _actionLabelForStatus(s);
    if (label == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: _loading ? null : _performAction,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(6),
        ),
        child: _loading ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }

  Widget _buildActionForStatus(ShipmentStatus s) {
    final label = _actionLabelForStatus(s);
    if (label == null) return const SizedBox.shrink();
    return SizedBox(
      height: 28,
      child: ElevatedButton(
        onPressed: _loading ? null : _performAction,
        child: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
      ),
    );
  }

  String? _actionLabelForStatus(ShipmentStatus s) {
    switch (s) {
      case ShipmentStatus.assigned:
        return 'Pick Up';
      case ShipmentStatus.pickedUp:
        return 'Start';
      case ShipmentStatus.inTransit:
        return 'Deliver';
      case ShipmentStatus.paymentPending:
        return 'Confirm';
      default:
        return null;
    }
  }
}
