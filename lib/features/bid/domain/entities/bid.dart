// lib/features/bid/domain/entities/bid.dart

import 'bid_status.dart';

class Bid {
  final String id;
  final String shipmentId;
  final String carrierId;
  final String carrierCompanyName;
  final double proposedPrice;
  final String currency;
  final int estimatedDeliveryDays;
  final String? notes;
  final BidStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  const Bid({
    required this.id,
    required this.shipmentId,
    required this.carrierId,
    required this.carrierCompanyName,
    required this.proposedPrice,
    required this.currency,
    required this.estimatedDeliveryDays,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.rejectedAt,
    this.rejectionReason,
  });

  Bid copyWith({
    String? id,
    String? shipmentId,
    String? carrierId,
    String? carrierCompanyName,
    double? proposedPrice,
    String? currency,
    int? estimatedDeliveryDays,
    String? notes,
    BidStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
  }) {
    return Bid(
      id: id ?? this.id,
      shipmentId: shipmentId ?? this.shipmentId,
      carrierId: carrierId ?? this.carrierId,
      carrierCompanyName: carrierCompanyName ?? this.carrierCompanyName,
      proposedPrice: proposedPrice ?? this.proposedPrice,
      currency: currency ?? this.currency,
      estimatedDeliveryDays: estimatedDeliveryDays ?? this.estimatedDeliveryDays,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  bool get isPending => status == BidStatus.pending;
  bool get isAccepted => status == BidStatus.accepted;
  bool get isRejected => status == BidStatus.rejected;
  bool get isWithdrawn => status == BidStatus.withdrawn;
}
