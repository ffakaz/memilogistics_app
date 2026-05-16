// lib/features/bid/presentation/screens/bid_review_screen.dart

import 'package:flutter/material.dart';
import '../../../shipment/domain/entities/shipment.dart';
import '../../domain/entities/bid.dart';
import '../../domain/entities/bid_status.dart';

class BidReviewScreen extends StatefulWidget {
  final Shipment shipment;

  const BidReviewScreen({super.key, required this.shipment});

  @override
  State<BidReviewScreen> createState() => _BidReviewScreenState();
}

class _BidReviewScreenState extends State<BidReviewScreen> {
  String _sortBy = 'price_low'; // price_low, price_high, days_low, days_high

  @override
  void initState() {
    super.initState();
    // TODO: Load bids for this shipment
    // context.read<BidProvider>().getBidsForShipment(widget.shipment.id!);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Get bids from BidProvider
    // For now, using mock data
    final bids = _getMockBids();
    final sortedBids = _sortBids(bids);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Bids'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'price_low',
                child: Text('Price: Low to High'),
              ),
              const PopupMenuItem(
                value: 'price_high',
                child: Text('Price: High to Low'),
              ),
              const PopupMenuItem(
                value: 'days_low',
                child: Text('Delivery: Fastest First'),
              ),
              const PopupMenuItem(
                value: 'days_high',
                child: Text('Delivery: Slowest First'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Shipment Summary
          _buildShipmentSummary(),

          // Bids List
          Expanded(
            child: sortedBids.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedBids.length,
                    itemBuilder: (context, index) {
                      return _buildBidCard(sortedBids[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipmentSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipment #${widget.shipment.id}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.blue),
              const SizedBox(width: 4),
              Text(widget.shipment.origin.shortLabel),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Icon(Icons.flag, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(widget.shipment.destination.shortLabel),
            ],
          ),
          if (widget.shipment.description != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.shipment.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No bids received yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Carriers will submit their bids soon',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildBidCard(Bid bid) {
    final isAccepted = bid.status == BidStatus.accepted;
    final isPending = bid.status == BidStatus.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isAccepted ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isAccepted
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with carrier name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          bid.carrierCompanyName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bid.carrierCompanyName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Bid ID: ${bid.id}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAccepted
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isAccepted ? Colors.green : Colors.red,
                      ),
                    ),
                    child: Text(
                      isAccepted ? 'ACCEPTED' : 'REJECTED',
                      style: TextStyle(
                        color: isAccepted ? Colors.green : Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Price and delivery info
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.attach_money,
                    'Bid Price',
                    '\$${bid.proposedPrice.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      bid.notes!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons (only for pending bids)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectBid(bid),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptBid(bid),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Accept Bid'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Timestamp
            const SizedBox(height: 12),
            Text(
              'Submitted: ${_formatDate(bid.createdAt)}',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<Bid> _sortBids(List<Bid> bids) {
    final sorted = List<Bid>.from(bids);
    switch (_sortBy) {
      case 'price_low':
        sorted.sort((a, b) => a.proposedPrice.compareTo(b.proposedPrice));
        break;
      case 'price_high':
        sorted.sort((a, b) => b.proposedPrice.compareTo(a.proposedPrice));
        break;
      case 'days_low':
        sorted.sort((a, b) =>
            a.estimatedDeliveryDays.compareTo(b.estimatedDeliveryDays));
        break;
      case 'days_high':
        sorted.sort((a, b) =>
            b.estimatedDeliveryDays.compareTo(a.estimatedDeliveryDays));
        break;
    }
    return sorted;
  }

  void _acceptBid(Bid bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Bid'),
        content: Text(
          'Accept bid from ${bid.carrierCompanyName} for \$${bid.proposedPrice.toStringAsFixed(2)}?\n\nThis will assign the shipment to this carrier and reject all other bids.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Call acceptBid use case
              // This should:
              // 1. Update bid status to accepted
              // 2. Update shipment status to assigned
              // 3. Reject all other bids
              // 4. Assign carrierId to shipment
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Bid accepted! ${bid.carrierCompanyName} has been assigned to this shipment.',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                ),
              );
              
              // Navigate back
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _rejectBid(Bid bid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Bid'),
        content: Text(
          'Reject bid from ${bid.carrierCompanyName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Call rejectBid use case
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Bid rejected'),
                  backgroundColor: Colors.orange,
                ),
              );
              
              setState(() {}); // Refresh UI
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Mock data for testing
  List<Bid> _getMockBids() {
    return [
      Bid(
        id: 'BID001',
        shipmentId: widget.shipment.id!,
        carrierId: 'CAR001',
        carrierCompanyName: 'Fast Freight LLC',
        proposedPrice: 1200.00,
        currency: 'USD',
        estimatedDeliveryDays: 3,
        notes: 'We have experience with this route and can guarantee on-time delivery.',
        status: BidStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Bid(
        id: 'BID002',
        shipmentId: widget.shipment.id!,
        carrierId: 'CAR002',
        carrierCompanyName: 'Express Logistics',
        proposedPrice: 950.00,
        currency: 'USD',
        estimatedDeliveryDays: 5,
        notes: 'Best price with reliable service. We have 5-star ratings.',
        status: BidStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Bid(
        id: 'BID003',
        shipmentId: widget.shipment.id!,
        carrierId: 'CAR003',
        carrierCompanyName: 'Premium Transport',
        proposedPrice: 1500.00,
        currency: 'USD',
        estimatedDeliveryDays: 2,
        notes: 'Fastest delivery with premium service and insurance included.',
        status: BidStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }
}
