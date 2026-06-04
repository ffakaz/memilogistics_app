// Simplified Shipment Details screen — keeps behavior but fixes analyzer warnings
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../payment/presentation/screens/payment_screen.dart';
import '../../../payment/presentation/widgets/payment_summary_card.dart';
import '../../../payment/presentation/states/payment_state.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';
import '../widgets/interactive_shipment_timeline.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'in_transit_screen.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final int shipmentId;
  const ShipmentDetailsScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<List<Map<String, dynamic>>>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ShipmentProvider>().loadShipmentDetail(widget.shipmentId);
        // Load shipment events for timeline
        _eventsFuture = context.read<ShipmentProvider>().getShipmentEvents(
          widget.shipmentId,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          final activeShipment = provider.activeShipment;
          final shipment = activeShipment?.id == widget.shipmentId
              ? activeShipment
              : provider.getShipmentById(widget.shipmentId);
          if (shipment == null) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Shipment not found'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () =>
                        provider.loadShipmentDetail(widget.shipmentId),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadShipmentDetail(widget.shipmentId),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 160,
                  pinned: true,
                  backgroundColor: const Color(0xFF2C3E50),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      shipment.trackingNumber ?? 'Shipment',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(shipment.status),
                        const SizedBox(height: 12),
                        Text('Origin: ${_formatLocation(shipment.origin)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Destination: ${_formatLocation(shipment.destination)}',
                        ),
                        const SizedBox(height: 8),
                        Text('Item: ${_formatValue(shipment.shipmentItem)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Weight: ${shipment.weightKg.toStringAsFixed(1)} kg',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Handling: ${shipment.fragile ? 'Fragile' : 'Standard'}',
                        ),
                        const SizedBox(height: 8),
                        Text('Pickup: ${_formatDate(shipment.pickupDate)}'),
                        const SizedBox(height: 8),
                        Text(
                          'Delivery: ${_formatDate(shipment.estimatedDeliveryDate)}',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Assigned Carrier: ${_formatValue(shipment.assignedCarrierName)}',
                        ),
                        if (shipment.assignedCarrierCompany != null && shipment.assignedCarrierCompany!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Company: ${_formatValue(shipment.assignedCarrierCompany)}'),
                          ),
                        if (shipment.assignedCarrierPhone != null && shipment.assignedCarrierPhone!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Phone: ${_formatValue(shipment.assignedCarrierPhone)}'),
                          ),
                        if (shipment.description?.trim().isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 8),
                          Text('Description: ${shipment.description!.trim()}'),
                        ],
                        const SizedBox(height: 8),
                        Text('Status: ${_getStatusLabel(shipment.status)}'),
                        const SizedBox(height: 16),
                        // Interactive Timeline - allows assigned carrier to progress shipment
                        InteractiveShipmentTimeline(
                          shipment: shipment,
                          onStatusUpdated: () {
                            // Refresh shipment data after status update
                            context.read<ShipmentProvider>().loadShipmentDetail(widget.shipmentId);
                            setState(() {
                              _eventsFuture = context.read<ShipmentProvider>().getShipmentEvents(widget.shipmentId);
                            });
                          },
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Shipment Timeline',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: _eventsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  'Failed to load timeline: ${snapshot.error}',
                                ),
                              );
                            }
                            final events = snapshot.data ?? [];
                            if (events.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('No events yet'),
                              );
                            }

                            // Sort events by timestamp ascending
                            events.sort((a, b) {
                              DateTime ta = _parseEventTime(a);
                              DateTime tb = _parseEventTime(b);
                              return ta.compareTo(tb);
                            });

                            return Column(
                              children: events.map((e) {
                                final dt = _parseEventTime(e);
                                final label = _eventLabel(e);
                                final desc = _eventDescription(e);
                                return ListTile(
                                  dense: true,
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                  title: Text(label),
                                  subtitle: desc != null ? Text(desc) : null,
                                  trailing: Text(
                                    _formatDateTime(dt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        // Carrier action buttons (Pick Up / Start Transit / Update Location / Mark Delivered)
                        Builder(
                          builder: (context) {
                            final role = context.watch<AuthProvider>().userRole?.toUpperCase();
                            final carrierCompanyId = context.read<CarrierCompanyProvider>().state.company?.id;
                            final isAssignedCarrier = shipment.assignedCarrierId != null && carrierCompanyId != null && shipment.assignedCarrierId == carrierCompanyId;

                            if (role == 'CARRIER' && isAssignedCarrier) {
                              if (shipment.status == ShipmentStatus.assigned) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await context.read<ShipmentProvider>().updateShipmentStatus(shipment.id!, ShipmentStatus.pickedUp);
                                      setState(() { _eventsFuture = context.read<ShipmentProvider>().getShipmentEvents(widget.shipmentId); });
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade700),
                                    child: const Text('Pick Up Shipment'),
                                  ),
                                );
                              }

                              if (shipment.status == ShipmentStatus.pickedUp) {
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await context.read<ShipmentProvider>().updateShipmentStatus(shipment.id!, ShipmentStatus.inTransit);
                                      setState(() { _eventsFuture = context.read<ShipmentProvider>().getShipmentEvents(widget.shipmentId); });
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
                                    child: const Text('Start Transit'),
                                  ),
                                );
                              }

                              if (shipment.status == ShipmentStatus.inTransit) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => InTransitScreen(shipment: shipment)),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade700),
                                        child: const Text('Open Tracking / Update Location'),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          await context.read<ShipmentProvider>().updateShipmentStatus(shipment.id!, ShipmentStatus.delivered);
                                          setState(() { _eventsFuture = context.read<ShipmentProvider>().getShipmentEvents(widget.shipmentId); });
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700),
                                        child: const Text('Mark Delivered'),
                                      ),
                                    ),
                                  ],
                                );
                              }
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        // Payment summary (if available)
                        Consumer<PaymentProvider>(
                          builder: (context, paymentProv, _) {
                            final state = paymentProv.state;
                            if (state is PaymentInitiated) {
                              return PaymentSummaryCard(
                                paymentRecord: state.paymentRecord,
                              );
                            }
                            if (state is PaymentConfirmed) {
                              return PaymentSummaryCard(
                                paymentRecord: state.paymentRecord,
                              );
                            }
                            if (state is PaymentRecordLoaded &&
                                state.paymentRecord != null) {
                              return PaymentSummaryCard(
                                paymentRecord: state.paymentRecord!,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 8),
                        // Payment actions (shipper initiates, carrier confirms)
                        Consumer3<
                          ShipmentProvider,
                          PaymentProvider,
                          AuthProvider
                        >(
                          builder: (context, shipmentProv, paymentProv, authProv, _) {
                            final role = authProv.userRole?.toUpperCase();
                            // current shipment reference
                            final s = shipment;

                            // Shipper can initiate payment when status == delivered
                            if (role == 'SHIPPER' &&
                                s.status == ShipmentStatus.delivered) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: paymentProv.isLoading
                                      ? null
                                      : () async {
                                          final res =
                                              await Navigator.push<bool?>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PaymentScreen(
                                                    shipmentId: s.id!,
                                                    amount: s.amount ?? 0.0,
                                                  ),
                                                ),
                                              );
                                          if (res == true) {
                                            // Show standardized success message
                                            if (mounted)
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Payment initiated successfully. Waiting for carrier confirmation.',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            await shipmentProv
                                                .loadShipmentDetail(s.id!);
                                            setState(() {
                                              _eventsFuture = shipmentProv
                                                  .getShipmentEvents(
                                                    widget.shipmentId,
                                                  );
                                            });
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                  child: const Text('Initiate Payment'),
                                ),
                              );
                            }

                            // Carrier can confirm payment after the shipper initiates it.
                            final carrierCompanyId = context.read<CarrierCompanyProvider>().state.company?.id;
                            final isAssignedCarrierForPayment = role == 'CARRIER' && carrierCompanyId != null && s.assignedCarrierId == carrierCompanyId;
                            if (isAssignedCarrierForPayment && s.status == ShipmentStatus.paymentPending) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: paymentProv.isLoading
                                      ? null
                                      : () async {
                                          try {
                                            final success = await paymentProv
                                                .confirmPayment(
                                                  shipmentId: s.id!,
                                                  transactionId: '',
                                                );
                                            if (success) {
                                              await shipmentProv
                                                  .loadShipmentDetail(s.id!);
                                              setState(() {
                                                _eventsFuture = shipmentProv
                                                    .getShipmentEvents(
                                                      widget.shipmentId,
                                                    );
                                              });
                                              if (mounted)
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Payment confirmed successfully. Shipment completed.',
                                                    ),
                                                  ),
                                                );
                                            }
                                          } catch (e) {
                                            if (mounted)
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Failed to confirm payment: $e',
                                                  ),
                                                ),
                                              );
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade700,
                                  ),
                                  child: paymentProv.isLoading
                                      ? const SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text('Confirm Payment'),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
          floatingActionButton: Consumer2<ShipmentProvider, AuthProvider>(
        builder: (context, provider, authProvider, _) {
          final activeShipment = provider.activeShipment;
          final shipment = activeShipment?.id == widget.shipmentId
              ? activeShipment
              : provider.getShipmentById(widget.shipmentId);
          final role = authProvider.userRole?.toUpperCase();
          final carrierCompanyId = context.read<CarrierCompanyProvider>().state.company?.id;
          final isAssignedCarrier = shipment != null && shipment.assignedCarrierId != null && carrierCompanyId != null && shipment.assignedCarrierId == carrierCompanyId;
          if (role == 'CARRIER' && shipment != null && _canUpdateStatus(shipment) && isAssignedCarrier) {
            return FloatingActionButton.extended(
              onPressed: () => _showUpdateStatusDialog(shipment),
              backgroundColor: const Color(0xFF2C3E50),
              icon: const Icon(Icons.update),
              label: const Text('Update Status'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStatusBadge(ShipmentStatus status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ShipmentStatus.pending:
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
        icon = Icons.pending;
        break;
      case ShipmentStatus.accepted:
        bgColor = Colors.lightBlue.shade100;
        textColor = Colors.lightBlue.shade900;
        icon = Icons.check;
        break;
      case ShipmentStatus.assigned:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.assignment_turned_in;
        break;
      case ShipmentStatus.pickedUp:
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        icon = Icons.inventory;
        break;
      case ShipmentStatus.inTransit:
        bgColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade900;
        icon = Icons.local_shipping;
        break;
      case ShipmentStatus.arrivedAtDestination:
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        icon = Icons.place;
        break;
      case ShipmentStatus.delivered:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case ShipmentStatus.paymentPending:
        bgColor = Colors.amber.shade100;
        textColor = Colors.amber.shade900;
        icon = Icons.payments;
        break;
      case ShipmentStatus.completed:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.done_all;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: textColor),
          const SizedBox(width: 8),
          Text(
            _getStatusLabel(status),
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  bool _canUpdateStatus(Shipment shipment) {
    return shipment.status == ShipmentStatus.assigned ||
        shipment.status == ShipmentStatus.pickedUp ||
        shipment.status == ShipmentStatus.inTransit ||
        shipment.status == ShipmentStatus.arrivedAtDestination;
  }

  void _showUpdateStatusDialog(Shipment shipment) {
    final nextStatuses = _getNextPossibleStatuses(shipment.status);
    if (nextStatuses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No status updates available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Shipment Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ${_getStatusLabel(shipment.status)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            ...nextStatuses.map(
              (s) => ListTile(
                title: Text(_getStatusLabel(s)),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(shipment, s);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<ShipmentStatus> _getNextPossibleStatuses(ShipmentStatus current) {
    switch (current) {
      case ShipmentStatus.assigned:
        return [ShipmentStatus.pickedUp];
      case ShipmentStatus.pickedUp:
        return [ShipmentStatus.inTransit];
      case ShipmentStatus.inTransit:
        return [ShipmentStatus.delivered];
      default:
        return [];
    }
  }

  Future<void> _updateStatus(
    Shipment shipment,
    ShipmentStatus newStatus,
  ) async {
    try {
      String location = '';
      switch (newStatus) {
        case ShipmentStatus.pickedUp:
          location = shipment.pickupLocation?.address ?? shipment.origin;
          break;
        case ShipmentStatus.inTransit:
          location = 'On route'; // TODO: replace with GPS-derived location
          break;
        case ShipmentStatus.delivered:
          location = shipment.destinationLocation?.address ?? shipment.destination;
          break;
        default:
          location = shipment.destinationLocation?.address ?? shipment.destination;
      }

      await context.read<ShipmentProvider>().updateShipmentStatus(
        shipment.id!,
        newStatus,
        location: location,
      );
      // Refresh timeline after successful status update
      setState(() {
        _eventsFuture = context.read<ShipmentProvider>().getShipmentEvents(
          widget.shipmentId,
        );
      });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  String _getStatusLabel(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return 'Pending';
      case ShipmentStatus.accepted:
        return 'Accepted';
      case ShipmentStatus.assigned:
        return 'Assigned';
      case ShipmentStatus.pickedUp:
        return 'Picked Up';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.arrivedAtDestination:
        return 'Arrived at Destination';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.paymentPending:
        return 'Payment Pending';
      case ShipmentStatus.completed:
        return 'Completed';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '—';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatValue(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? 'N/A' : trimmed;
  }

  String _formatLocation(String? address) {
    if (address == null || address.isEmpty) return 'Unknown';
    return address
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : (w[0].toUpperCase() + w.substring(1).toLowerCase()),
        )
        .join(' ');
  }

  static DateTime _parseEventTime(Map<String, dynamic> e) {
    final keys = [
      'eventTimestamp',
      'createdAt',
      'timestamp',
      'occurredAt',
      'time',
    ];
    for (final k in keys) {
      final v = e[k];
      if (v == null) continue;
      try {
        return DateTime.parse(v as String).toLocal();
      } catch (_) {}
      try {
        if (v is int) return DateTime.fromMillisecondsSinceEpoch(v).toLocal();
      } catch (_) {}
    }
    return DateTime.now();
  }

  static String _eventLabel(Map<String, dynamic> e) {
    return (e['shipmentStatus'] ??
            e['status'] ??
            e['eventType'] ??
            e['type'] ??
            e['label'] ??
            'Event')
        .toString();
  }

  static String? _eventDescription(Map<String, dynamic> e) {
    return (e['description'] ?? e['details'] ?? e['message'])?.toString();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
