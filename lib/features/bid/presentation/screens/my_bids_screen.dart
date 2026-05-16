// lib/features/bid/presentation/screens/my_bids_screen.dart

import 'package:flutter/material.dart';
import '../../domain/entities/bid.dart';
import '../../domain/entities/bid_status.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // TODO: Load carrier's bids
    // context.read<BidProvider>().getMyBids();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get bids from BidProvider
    // For now, using mock data
    final allBids = _getMockBids();
    final filteredBids = _filterBids(allBids);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter',
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Bids')),
              const PopupMenuItem(value: 'pending', child: Text('Pending')),
              const PopupMenuItem(value: 'accepted', child: Text('Accepted')),
              const PopupMenuItem(value: 'rejected', child: Text('Rejected')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Refresh bids
              setState(() {});
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: filteredBids.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                // TODO: Refresh bids
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredBids.length,
                itemBuilder: (context, index) {
                  return _buildBidCard(filteredBids[index]);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (_selectedFilter) {
      case 'pending':
        message = 'No pending bids';
        break;
      case 'accepted':
        message = 'No accepted bids yet';
        break;
      case 'rejected':
        message = 'No rejected bids';
        break;
      default:
        message = 'No bids submitted yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit bids from the Load Board',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(Bid bid) {
    final statusColor = _getStatusColor(bid.status);
    final statusText = _getStatusText(bid.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: bid.status == BidStatus.accepted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bid #${bid.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Shipment info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        'Shipment #${bid.shipmentId}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // TODO: Show actual shipment origin/destination
                  // For now showing placeholder
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Origin', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 12, color: Colors.grey),
                      const SizedBox(width: 8),
                      const Icon(Icons.flag, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      const Text('Destination', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bid details
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.attach_money,
                    'Your Bid',
                    '\$${bid.proposedPrice.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoItem(
                    Icons.calendar_today,
                    'Delivery',
                    '${bid.estimatedDeliveryDays} days',
                    Colors.blue,
                  ),
                ),
              ],
            ),

            // Notes
            if (bid.notes != null && bid.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        bid.notes!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Status message
            const SizedBox(height: 12),
            _buildStatusMessage(bid),

            // Timestamp
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Submitted: ${_formatDate(bid.createdAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
                if (bid.updatedAt != null && bid.status != BidStatus.pending)
                  Text(
                    '${_getStatusText(bid.status)}: ${_formatDate(bid.updatedAt!)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(Bid bid) {
    IconData icon;
    Color color;
    String message;

    switch (bid.status) {
      case BidStatus.pending:
        icon = Icons.hourglass_empty;
        color = Colors.orange;
        message = 'Waiting for shipper to review your bid';
        break;
      case BidStatus.accepted:
        icon = Icons.check_circle;
        color = Colors.green;
        message = 'Congratulations! Your bid was accepted. Check My Shipments.';
        break;
      case BidStatus.rejected:
        icon = Icons.cancel;
        color = Colors.red;
        message = bid.rejectionReason ?? 'Your bid was not selected';
        break;
      case BidStatus.withdrawn:
        icon = Icons.remove_circle;
        color = Colors.grey;
        message = 'You withdrew this bid';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Bid> _filterBids(List<Bid> bids) {
    if (_selectedFilter == 'all') return bids;

    final statusMap = {
      'pending': BidStatus.pending,
      'accepted': BidStatus.accepted,
      'rejected': BidStatus.rejected,
    };

    final filterStatus = statusMap[_selectedFilter];
    if (filterStatus == null) return bids;

    return bids.where((bid) => bid.status == filterStatus).toList();
  }

  Color _getStatusColor(BidStatus status) {
    switch (status) {
      case BidStatus.pending:
        return Colors.orange;
      case BidStatus.accepted:
        return Colors.green;
      case BidStatus.rejected:
        return Colors.red;
      case BidStatus.withdrawn:
        return Colors.grey;
    }
  }

  String _getStatusText(BidStatus status) {
    switch (status) {
      case BidStatus.pending:
        return 'PENDING';
      case BidStatus.accepted:
        return 'ACCEPTED';
      case BidStatus.rejected:
        return 'REJECTED';
      case BidStatus.withdrawn:
        return 'WITHDRAWN';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Mock data for testing
  List<Bid> _getMockBids() {
    return [
      Bid(
        id: 'BID001',
        shipmentId: 'SHP001',
        carrierId: 'CAR001',
        carrierCompanyName: 'My Company',
        proposedPrice: 1200.00,
        currency: 'USD',
        estimatedDeliveryDays: 3,
        notes: 'We have experience with this route.',
        status: BidStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Bid(
        id: 'BID002',
        shipmentId: 'SHP002',
        carrierId: 'CAR001',
        carrierCompanyName: 'My Company',
        proposedPrice: 950.00,
        currency: 'USD',
        estimatedDeliveryDays: 5,
        notes: 'Best price with reliable service.',
        status: BidStatus.accepted,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        acceptedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      Bid(
        id: 'BID003',
        shipmentId: 'SHP003',
        carrierId: 'CAR001',
        carrierCompanyName: 'My Company',
        proposedPrice: 1500.00,
        currency: 'USD',
        estimatedDeliveryDays: 2,
        notes: 'Fastest delivery available.',
        status: BidStatus.rejected,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        rejectedAt: DateTime.now().subtract(const Duration(days: 1)),
        rejectionReason: 'Shipper selected a lower bid',
      ),
    ];
  }
}
