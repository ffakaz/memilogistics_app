// lib/features/shipment/presentation/screens/shipment_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/enums/shipment_status.dart';
import '../providers/shipment_provider.dart';
import '../../../../core/utils/constants/route_constants.dart';

class ShipmentDetailsScreen extends StatefulWidget {
  final int shipmentId;

  const ShipmentDetailsScreen({super.key, required this.shipmentId});

  @override
  State<ShipmentDetailsScreen> createState() => _ShipmentDetailsScreenState();
}

class _ShipmentDetailsScreenState extends State<ShipmentDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _events = [];
  bool _loadingEvents = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadShipmentEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadShipmentEvents() async {
    setState(() => _loadingEvents = true);
    try {
      final events = await context.read<ShipmentProvider>().getShipmentEvents(
        widget.shipmentId,
      );

      // Parse events from API response
      setState(() {
        _events = events.map((event) {
          return {
            'id': event['id'],
            'description': event['description'] ?? 'Status updated',
            'shipmentStatus': event['shipmentStatus'] ?? 'PENDING',
            'location': event['location'] ?? 'Unknown',
            'eventTimestamp': event['eventTimestamp'] != null
                ? DateTime.parse(event['eventTimestamp'] as String)
                : DateTime.now(),
          };
        }).toList();
        _loadingEvents = false;
      });
    } catch (e) {
      // If API fails, show empty state instead of mock data
      setState(() {
        _events = [];
        _loadingEvents = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          final shipment = provider.getShipmentById(widget.shipmentId);

          if (shipment == null) {
            return const Center(child: Text('Shipment not found'));
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(shipment),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildTabBar(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 300,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildDetailsTab(shipment),
                          _buildEventsTab(shipment),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<ShipmentProvider>(
        builder: (context, provider, _) {
          final shipment = provider.getShipmentById(widget.shipmentId);
          if (shipment != null && _canUpdateStatus(shipment)) {
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

  Widget _buildSliverAppBar(Shipment shipment) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFF2C3E50),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF2C3E50),
                const Color(0xFF34495E),
                const Color(0xFF2C3E50).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_shipping,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shipment.trackingNumber ?? 'N/A',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${shipment.id}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatusBadge(shipment.status),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2C3E50),
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: 'Details'),
          Tab(icon: Icon(Icons.timeline), text: 'Events'),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(Shipment shipment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatusTimeline(shipment),
          const SizedBox(height: 16),
          _buildShipmentInfo(shipment),
          const SizedBox(height: 16),
          _buildLocationInfo(shipment),
          const SizedBox(height: 16),
          // Add payment section for delivered shipments
          if (shipment.status == ShipmentStatus.delivered ||
              shipment.status == ShipmentStatus.completed)
            _buildPaymentSection(shipment),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildEventsTab(Shipment shipment) {
    if (_loadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No Events Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Events will appear here as the shipment progresses',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadShipmentEvents,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          return _buildEventCard(_events[index], index == _events.length - 1);
        },
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isLast) {
    final status = _parseEventStatus(event['shipmentStatus'] as String);
    final timestamp = event['eventTimestamp'] as DateTime;
    final description = event['description'] as String;
    final location = event['location'] as String;

    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 80 : 0,
      ), // Space for FAB on last item
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getStatusColor(status),
                      _getStatusColor(status).withValues(alpha: 0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(status).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _getStatusIcon(status),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _getStatusColor(status).withValues(alpha: 0.5),
                        Colors.grey.shade300,
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Event card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          description,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStatusLabel(status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatLocation(location),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatEventTimestamp(timestamp),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
      case ShipmentStatus.assigned:
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade900;
        icon = Icons.assignment_turned_in;
        break;
      case ShipmentStatus.pickedUp:
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade900;
        icon = Icons.local_shipping;
        break;
      case ShipmentStatus.inTransit:
        bgColor = Colors.indigo.shade100;
        textColor = Colors.indigo.shade900;
        icon = Icons.local_shipping;
        break;
      case ShipmentStatus.arrivedAtDestination:
        bgColor = Colors.teal.shade100;
        textColor = Colors.teal.shade900;
        icon = Icons.location_on;
        break;
      case ShipmentStatus.delivered:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
        break;
      case ShipmentStatus.completed:
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        icon = Icons.done_all;
        break;
      case ShipmentStatus.cancelled:
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(Shipment shipment) {
    final statuses = [
      ShipmentStatus.pending,
      ShipmentStatus.assigned,
      ShipmentStatus.pickedUp,
      ShipmentStatus.inTransit,
      ShipmentStatus.arrivedAtDestination,
      ShipmentStatus.delivered,
      ShipmentStatus.completed,
    ];

    final currentIndex = statuses.indexOf(shipment.status);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.timeline,
                      color: Color(0xFF2C3E50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Shipment Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ...List.generate(statuses.length, (index) {
                final status = statuses[index];
                final isCompleted = index <= currentIndex;
                final isCurrent = index == currentIndex;

                return _buildTimelineItem(
                  status: status,
                  isCompleted: isCompleted,
                  isCurrent: isCurrent,
                  isLast: index == statuses.length - 1,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required ShipmentStatus status,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF27AE60)
                    : Colors.grey.shade300,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent
                      ? const Color(0xFF2C3E50)
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                size: 16,
                color: isCompleted ? Colors.white : Colors.grey.shade500,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted
                    ? const Color(0xFF27AE60)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusLabel(status),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted
                        ? const Color(0xFF2C3E50)
                        : Colors.grey.shade600,
                  ),
                ),
                if (isCurrent)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Current Status',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShipmentInfo(Shipment shipment) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF2C3E50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Shipment Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildInfoRow(
                Icons.scale,
                'Weight',
                '${shipment.amount} ${shipment.unit.name}',
              ),
              const Divider(height: 32),
              _buildInfoRow(
                Icons.calendar_today,
                'Pickup Date',
                _formatDate(shipment.pickupDate),
              ),
              const Divider(height: 32),
              _buildInfoRow(
                shipment.safetyOption.name == 'fragile'
                    ? Icons.warning_amber
                    : Icons.check_circle_outline,
                'Safety',
                shipment.safetyOption.name == 'fragile'
                    ? 'Fragile - Handle with Care'
                    : 'Standard Handling',
              ),
              if (shipment.description != null &&
                  shipment.description!.isNotEmpty) ...[
                const Divider(height: 32),
                _buildInfoRow(
                  Icons.description,
                  'Description',
                  shipment.description!,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Shipment shipment) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF27AE60).withValues(alpha: 0.05),
              const Color(0xFFE74C3C).withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.route,
                      color: Color(0xFF2C3E50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Route Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildLocationRow(
                Icons.trip_origin,
                'Origin',
                _formatLocation(shipment.pickupLocation.address),
                const Color(0xFF27AE60),
              ),
              const SizedBox(height: 20),
              _buildLocationRow(
                Icons.location_on,
                'Destination',
                _formatLocation(shipment.destinationLocation.address),
                const Color(0xFFE74C3C),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection(Shipment shipment) {
    // Mock payment status - in real app, get from shipment.paymentRecord
    final hasPayment = shipment.status == ShipmentStatus.completed;
    final paymentStatus = hasPayment ? 'CONFIRMED' : 'PENDING';
    final agreedPrice = 150.0; // Mock price - should come from shipment offer

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              hasPayment
                  ? const Color(0xFF27AE60).withValues(alpha: 0.05)
                  : const Color(0xFFF39C12).withValues(alpha: 0.05),
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hasPayment
                          ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                          : const Color(0xFFF39C12).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      hasPayment ? Icons.check_circle : Icons.payment,
                      color: hasPayment
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFF39C12),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const Spacer(),
                  _buildPaymentStatusBadge(paymentStatus),
                ],
              ),
              const SizedBox(height: 20),

              // Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '\$${agreedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),

              if (hasPayment) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildPaymentInfoRow(Icons.payment, 'Method', 'Bank Transfer'),
                const SizedBox(height: 12),
                _buildPaymentInfoRow(
                  Icons.calendar_today,
                  'Paid on',
                  _formatDate(DateTime.now()),
                ),
                const SizedBox(height: 12),
                _buildPaymentInfoRow(
                  Icons.receipt,
                  'Transaction ID',
                  'TXN-${shipment.id}',
                ),
              ] else ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToPayment(shipment, agreedPrice),
                    icon: const Icon(Icons.payment, size: 20),
                    label: const Text('Make Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C3E50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment is required to complete this shipment',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String status) {
    final isConfirmed = status == 'CONFIRMED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isConfirmed
            ? const Color(0xFF27AE60).withValues(alpha: 0.1)
            : const Color(0xFFF39C12).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isConfirmed
              ? const Color(0xFF27AE60).withValues(alpha: 0.3)
              : const Color(0xFFF39C12).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isConfirmed ? Icons.check_circle : Icons.pending,
            size: 14,
            color: isConfirmed
                ? const Color(0xFF27AE60)
                : const Color(0xFFF39C12),
          ),
          const SizedBox(width: 6),
          Text(
            isConfirmed ? 'Confirmed' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isConfirmed
                  ? const Color(0xFF27AE60)
                  : const Color(0xFFF39C12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  void _navigateToPayment(Shipment shipment, double amount) async {
    final result = await Navigator.pushNamed(
      context,
      RouteConstants.payment,
      arguments: {
        'shipmentId': shipment.id,
        'amount': amount,
        'currency': 'USD',
      },
    );

    if (result == true && mounted) {
      // Payment was successful, refresh shipment details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Payment completed successfully!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF27AE60),
          duration: const Duration(seconds: 3),
        ),
      );

      // Refresh shipment data
      setState(() {
        // Trigger rebuild to show updated payment status
      });
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2C3E50), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Colors.orange;
      case ShipmentStatus.assigned:
        return Colors.blue;
      case ShipmentStatus.pickedUp:
        return Colors.purple;
      case ShipmentStatus.inTransit:
        return Colors.indigo;
      case ShipmentStatus.arrivedAtDestination:
        return Colors.teal;
      case ShipmentStatus.delivered:
        return Colors.green;
      case ShipmentStatus.completed:
        return const Color(0xFF27AE60);
      case ShipmentStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(ShipmentStatus status) {
    switch (status) {
      case ShipmentStatus.pending:
        return Icons.pending;
      case ShipmentStatus.assigned:
        return Icons.assignment_turned_in;
      case ShipmentStatus.pickedUp:
        return Icons.inventory;
      case ShipmentStatus.inTransit:
        return Icons.local_shipping;
      case ShipmentStatus.arrivedAtDestination:
        return Icons.place;
      case ShipmentStatus.delivered:
        return Icons.check_circle;
      case ShipmentStatus.completed:
        return Icons.done_all;
      case ShipmentStatus.cancelled:
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  ShipmentStatus _parseEventStatus(String status) {
    final normalized = status.toUpperCase().replaceAll('-', '_');
    try {
      return ShipmentStatus.values.firstWhere(
        (e) => e.backendValue == normalized,
        orElse: () => ShipmentStatus.pending,
      );
    } catch (e) {
      return ShipmentStatus.pending;
    }
  }

  String _formatEventTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
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
      return '${months[timestamp.month - 1]} ${timestamp.day}, ${timestamp.year}';
    }
  }

  bool _canUpdateStatus(Shipment shipment) {
    // Only carriers can update status after shipment is assigned
    // This is a simplified check - in production, check user role
    return shipment.status != ShipmentStatus.pending &&
        shipment.status != ShipmentStatus.completed &&
        shipment.status != ShipmentStatus.cancelled;
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
            const SizedBox(height: 16),
            const Text('Select new status:'),
            const SizedBox(height: 8),
            ...nextStatuses.map(
              (status) => ListTile(
                title: Text(_getStatusLabel(status)),
                leading: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.pop(context);
                  _updateStatus(shipment, status);
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
        return [ShipmentStatus.arrivedAtDestination];
      case ShipmentStatus.arrivedAtDestination:
        return [ShipmentStatus.delivered];
      case ShipmentStatus.delivered:
        return [ShipmentStatus.completed];
      default:
        return [];
    }
  }

  Future<void> _updateStatus(
    Shipment shipment,
    ShipmentStatus newStatus,
  ) async {
    try {
      await context.read<ShipmentProvider>().updateShipmentStatus(
        shipment.id!,
        newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
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
      case ShipmentStatus.completed:
        return 'Completed';
      case ShipmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
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

  String _formatLocation(String address) {
    if (address.isEmpty) return 'Unknown';
    return address
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
