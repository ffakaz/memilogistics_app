import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../shipment/presentation/providers/shipment_provider.dart';
import '../../../payment/presentation/providers/payment_provider.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../../shipment_offer/presentation/widgets/shipment_offer_dialog.dart';
import '../../../shipment/domain/enums/shipment_status.dart';

/// Carrier Dashboard - Tabbed view for shipment lifecycle management
class CarrierDashboardScreen extends StatefulWidget {
  const CarrierDashboardScreen({Key? key}) : super(key: key);

  @override
  State<CarrierDashboardScreen> createState() => _CarrierDashboardScreenState();
}

class _CarrierDashboardScreenState extends State<CarrierDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<Tab> _tabs = const [
    Tab(text: 'Offerable'),
    Tab(text: 'Assigned'),
    Tab(text: 'Picked Up'),
    Tab(text: 'In Transit'),
    Tab(text: 'Delivered'),
    Tab(text: 'Payment'),
    Tab(text: 'Completed'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Preload some data
      final prov = context.read<ShipmentProvider>();
      prov.getAvailableShipments();
      prov.getMyShipments();
      prov.getCarrierAssignedShipments();
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
      appBar: AppBar(
        title: const Text('Carrier Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _tabs,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OfferableTab(),
          _StatusListTab(status: ShipmentStatus.assigned),
          _StatusListTab(status: ShipmentStatus.pickedUp),
          _StatusListTab(status: ShipmentStatus.inTransit),
          _StatusListTab(status: ShipmentStatus.delivered),
          _StatusListTab(status: ShipmentStatus.paymentPending),
          _StatusListTab(status: ShipmentStatus.completed),
        ],
      ),
    );
  }
}

class _OfferableTab extends StatefulWidget {
  @override
  State<_OfferableTab> createState() => _OfferableTabState();
}

class _OfferableTabState extends State<_OfferableTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ShipmentProvider>();
      // start with first page
      prov.loadShipmentsPaginated(page: 0, size: 20, append: false);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        // load next page
        context.read<ShipmentProvider>().loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery(Shipment s, String q) {
    if (q.isEmpty) return true;
    final low = q.toLowerCase();
    final tn = (s.trackingNumber ?? '').toLowerCase();
    final origin = (s.origin).toLowerCase();
    final dest = (s.destination).toLowerCase();
    return tn.contains(low) || origin.contains(low) || dest.contains(low);
  }

  bool _statusAllowed(Shipment s) {
    // Offerable statuses are PENDING and ACCEPTED, and shipment must be unassigned
    final allowed = s.status == ShipmentStatus.pending || s.status == ShipmentStatus.accepted;
    final unassigned = s.assignedCarrierId == null;
    return allowed && unassigned;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShipmentProvider>(builder: (context, prov, _) {
      if (prov.isLoading && prov.shipments.isEmpty) return const Center(child: CircularProgressIndicator());

      var list = prov.shipments.where(_statusAllowed).toList();

      final query = _searchController.text.trim();
      if (query.isNotEmpty) list = list.where((s) => _matchesQuery(s, query)).toList();

      if (_filter == 'Pending') list = list.where((s) => s.status == ShipmentStatus.pending).toList();
      if (_filter == 'Accepted') list = list.where((s) => s.status == ShipmentStatus.accepted).toList();

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by tracking, origin, destination'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _filter,
                  items: const [DropdownMenuItem(value: 'All', child: Text('All offerable')), DropdownMenuItem(value: 'Pending', child: Text('Pending')), DropdownMenuItem(value: 'Accepted', child: Text('Accepted'))],
                  onChanged: (v) => setState(() => _filter = v ?? 'All'),
                ),
              ],
            ),
          ),
          Expanded(
              child: RefreshIndicator(
              onRefresh: () => prov.loadShipmentsPaginated(page: 0, size: 20, append: false),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                itemCount: list.length + (prov.hasMorePages ? 1 : 0),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= list.length) {
                    // loading indicator for pagination
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final s = list[index];
                  return _CarrierLoadCard(
                    shipment: s,
                    // override make offer to open real dialog
                    key: ValueKey('offer-${s.id}'),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _StatusListTab extends StatefulWidget {
  final ShipmentStatus status;
  const _StatusListTab({Key? key, required this.status}) : super(key: key);

  @override
  State<_StatusListTab> createState() => _StatusListTabState();
}

class _StatusListTabState extends State<_StatusListTab> {
  late Future<List<Shipment>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = context.read<ShipmentProvider>().getMyShipmentsByStatus(status: widget.status);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Shipment>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        final shipments = snapshot.data ?? [];
        if (shipments.isEmpty) return const Center(child: Text('No shipments'));
        // Render specialized views for delivered/payment/completed
        if (widget.status == ShipmentStatus.delivered) {
          return RefreshIndicator(
            onRefresh: () async => setState(() => _load()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shipments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _DeliveredCard(shipment: shipments[index]),
            ),
          );
        }

        if (widget.status == ShipmentStatus.paymentPending) {
          return RefreshIndicator(
            onRefresh: () async => setState(() => _load()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shipments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _PaymentPendingCard(shipment: shipments[index]),
            ),
          );
        }

        if (widget.status == ShipmentStatus.completed) {
          return RefreshIndicator(
            onRefresh: () async => setState(() => _load()),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: shipments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _CompletedCard(shipment: shipments[index]),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _load()),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: shipments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _CarrierLifecycleCard(shipment: shipments[index]),
          ),
        );
      },
    );
  }
}

class _DeliveredCard extends StatelessWidget {
  final Shipment shipment;
  const _DeliveredCard({Key? key, required this.shipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(shipment.trackingNumber ?? 'TRK-${shipment.id ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Delivered Successfully', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Waiting for Shipper Payment', style: TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _PaymentPendingCard extends StatelessWidget {
  final Shipment shipment;
  const _PaymentPendingCard({Key? key, required this.shipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentProv = context.read<PaymentProvider>();
    // Amount displayed directly from shipment.amount for now.
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(shipment.trackingNumber ?? 'TRK-${shipment.id ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Payment Initiated', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          Text('Amount: ETB ${shipment.amount ?? 0}'),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: paymentProv.isLoading
                  ? null
                  : () async {
                      try {
                        // Try to fetch payment record to obtain transaction id if required
                        await paymentProv.getPaymentRecord(shipmentId: shipment.id!);
                        // For compatibility, pass empty transaction id if not available
                        final success = await paymentProv.confirmPayment(shipmentId: shipment.id!, transactionId: '');
                        if (success) {
                          // Refresh shipments
                          await context.read<ShipmentProvider>().loadShipmentDetail(shipment.id!);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment confirmed — shipment completed')));
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to confirm payment: $e')));
                      }
                    },
              child: paymentProv.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Confirm Payment'),
            ),
          ),
        ]),
      ),
    );
  }
}

class _CompletedCard extends StatelessWidget {
  final Shipment shipment;
  const _CompletedCard({Key? key, required this.shipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(shipment.trackingNumber ?? 'TRK-${shipment.id ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Completed', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          const Text('Paid', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          const Text('Delivered', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          const Text('Finished', style: TextStyle(color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _CarrierLoadCard extends StatelessWidget {
  final Shipment shipment;
  const _CarrierLoadCard({Key? key, required this.shipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shipment.trackingNumber ?? 'TRK-${shipment.id ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${shipment.origin} → ${shipment.destination}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${shipment.weightKg} kg'),
                ElevatedButton(
                  onPressed: () => _onMakeOffer(context, shipment),
                  child: const Text('Make Offer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onMakeOffer(BuildContext context, Shipment shipment) {
    showDialog(
      context: context,
      builder: (c) => ShipmentOfferDialog(shipment: shipment),
    );
  }
}

class _CarrierLifecycleCard extends StatefulWidget {
  final Shipment shipment;
  const _CarrierLifecycleCard({Key? key, required this.shipment}) : super(key: key);

  @override
  State<_CarrierLifecycleCard> createState() => _CarrierLifecycleCardState();
}

class _CarrierLifecycleCardState extends State<_CarrierLifecycleCard> {
  String? _currentLocation;
  DateTime? _lastUpdatedAt;
  bool _loadingEvents = false;

  @override
  void initState() {
    super.initState();
    if (widget.shipment.status == ShipmentStatus.inTransit) {
      _fetchEvents();
    }
  }

  Future<void> _fetchEvents() async {
    if (widget.shipment.id == null) return;
    setState(() => _loadingEvents = true);
    try {
      final events = await context.read<ShipmentProvider>().getShipmentEvents(widget.shipment.id!);
      if (events.isNotEmpty) {
        // Find the most recent event with a location
        Map<String, dynamic>? lastWithLocation;
        for (final e in events.reversed) {
          if (e['location'] != null && (e['location'] as String).isNotEmpty) {
            lastWithLocation = e;
            break;
          }
        }
        final last = lastWithLocation ?? events.last;
        setState(() {
          _currentLocation = (last['location'] ?? '') as String?;
          final ts = last['createdAt'] ?? last['timestamp'] ?? last['time'];
          if (ts is String) {
            try {
              _lastUpdatedAt = DateTime.parse(ts).toLocal();
            } catch (_) {
              _lastUpdatedAt = null;
            }
          } else if (ts is int) {
            _lastUpdatedAt = DateTime.fromMillisecondsSinceEpoch(ts).toLocal();
          }
        });
      }
    } catch (_) {
      // ignore errors; show unknowns
    } finally {
      setState(() => _loadingEvents = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipment = widget.shipment;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(shipment.trackingNumber ?? 'TRK-${shipment.id ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text('${shipment.origin} → ${shipment.destination}'),
            const SizedBox(height: 12),
            if (shipment.status == ShipmentStatus.assigned) ...[
              Text('Status: Assigned', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                'Assigned: ${_formatAssignedDate(shipment)}',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
            ] else if (shipment.status == ShipmentStatus.pickedUp) ...[
              Text('Current Status:\nPicked Up', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Pickup Location: ${shipment.pickupLocation?.address ?? shipment.origin}'),
              const SizedBox(height: 12),
            ] else if (shipment.status == ShipmentStatus.inTransit) ...[
              Text('Current Status:\nIn Transit', style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _loadingEvents
                  ? const Text('Loading location...')
                  : Text('Current Location: ${_currentLocation ?? 'Unknown'}'),
              const SizedBox(height: 6),
              Text('Last Updated: ${_lastUpdatedAt != null ? _formatRelative(_lastUpdatedAt!) : 'Unknown'}'),
              const SizedBox(height: 12),
            ] else ...[
              Text('Status: ${shipment.status.displayName}'),
              const SizedBox(height: 12),
            ],
            _buildActionRow(context),
          ],
        ),
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return DateFormat('MMM d, yyyy').format(dt);
  }

  String _formatAssignedDate(Shipment s) {
    final dt = s.updatedAt ?? s.createdAt;
    if (dt == null) return '-';
    return DateFormat('MMM d, yyyy').format(dt.toLocal());
  }

  Widget _buildActionRow(BuildContext context) {
    final prov = context.watch<ShipmentProvider>();
    final s = widget.shipment;
    switch (s.status) {
      case ShipmentStatus.assigned:
        return ElevatedButton(
          onPressed: prov.isLoading
              ? null
              : () async {
                  try {
                    await prov.updateShipmentStatus(s.id!, ShipmentStatus.pickedUp, location: s.origin);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shipment marked as Picked Up')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
          child: prov.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Pick Up Shipment'),
        );
      case ShipmentStatus.pickedUp:
        return ElevatedButton(
          onPressed: prov.isLoading
              ? null
              : () async {
                  try {
                    await prov.updateShipmentStatus(s.id!, ShipmentStatus.inTransit, location: 'On route');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shipment started transit')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
          child: prov.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Start Transit'),
        );
      case ShipmentStatus.inTransit:
        return Row(
          children: [
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      // simple location update - in real app, gather GPS
                      try {
                        await prov.updateShipmentStatus(s.id!, ShipmentStatus.inTransit, location: 'Updated location');
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location updated')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
              child: prov.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Update Location'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      try {
                        await prov.updateShipmentStatus(s.id!, ShipmentStatus.delivered, location: s.destination);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shipment marked delivered')));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
              child: prov.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Mark Delivered'),
            ),
          ],
        );
      case ShipmentStatus.delivered:
        return const Text('Delivered — waiting for shipper payment');
      case ShipmentStatus.paymentPending:
        return ElevatedButton(
          onPressed: prov.isLoading
              ? null
              : () async {
                  try {
                    // confirm payment endpoint is handled elsewhere in repository
                    await prov.updateShipmentStatus(s.id!, ShipmentStatus.completed, location: s.destination);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment confirmed — completed')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
          child: prov.isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Confirm Payment'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
