// lib/features/bid/domain/entities/bid_status.dart

enum BidStatus {
  pending,
  accepted,
  rejected,
  withdrawn;

  String get displayName {
    switch (this) {
      case BidStatus.pending:
        return 'Pending';
      case BidStatus.accepted:
        return 'Accepted';
      case BidStatus.rejected:
        return 'Rejected';
      case BidStatus.withdrawn:
        return 'Withdrawn';
    }
  }

  String get description {
    switch (this) {
      case BidStatus.pending:
        return 'Awaiting shipper response';
      case BidStatus.accepted:
        return 'Bid accepted by shipper';
      case BidStatus.rejected:
        return 'Bid rejected by shipper';
      case BidStatus.withdrawn:
        return 'Bid withdrawn by carrier';
    }
  }
}
