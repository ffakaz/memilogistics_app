// lib/features/shipment/data/models/paginated_shipment_response.dart

import 'shipment_model.dart';

/// Paginated response model matching backend Spring Boot Page structure
class PaginatedShipmentResponse {
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;
  final int size;
  final List<ShipmentModel> content;
  final int number;
  final int numberOfElements;
  final bool empty;

  const PaginatedShipmentResponse({
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
    required this.size,
    required this.content,
    required this.number,
    required this.numberOfElements,
    required this.empty,
  });

  factory PaginatedShipmentResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedShipmentResponse(
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      first: json['first'] as bool? ?? true,
      last: json['last'] as bool? ?? true,
      size: json['size'] as int? ?? 0,
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => ShipmentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      number: json['number'] as int? ?? 0,
      numberOfElements: json['numberOfElements'] as int? ?? 0,
      empty: json['empty'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalElements': totalElements,
      'totalPages': totalPages,
      'first': first,
      'last': last,
      'size': size,
      'content': content.map((e) => e.toJson()).toList(),
      'number': number,
      'numberOfElements': numberOfElements,
      'empty': empty,
    };
  }

  /// Check if there are more pages to load
  bool get hasMore => !last;

  /// Get the next page number
  int get nextPage => number + 1;

  /// Check if this is the first page
  bool get isFirstPage => first;

  /// Check if this is the last page
  bool get isLastPage => last;
}
