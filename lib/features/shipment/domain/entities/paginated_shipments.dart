// lib/features/shipment/domain/entities/paginated_shipments.dart

import 'shipment.dart';

/// Domain entity for paginated shipment list
class PaginatedShipments {
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool isFirst;
  final bool isLast;
  final List<Shipment> shipments;

  const PaginatedShipments({
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.isFirst,
    required this.isLast,
    required this.shipments,
  });

  /// Check if there are more pages to load
  bool get hasMore => !isLast;

  /// Get the next page number
  int get nextPage => currentPage + 1;

  /// Check if this is empty
  bool get isEmpty => shipments.isEmpty;

  /// Check if this is not empty
  bool get isNotEmpty => shipments.isNotEmpty;
}
