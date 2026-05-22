// lib/features/shipment/data/models/create_shipment_request.dart

import 'package:json_annotation/json_annotation.dart';

part 'create_shipment_request.g.dart';

@JsonSerializable(explicitToJson: true)
class CreateShipmentRequest {
  final String origin;
  final String destination;
  final double weightKg;

  @JsonKey(toJson: _dateTimeToJson, fromJson: _dateTimeFromJson)
  final DateTime deliveryDate;

  final bool fragile;

  // Optional fields
  final String shipmentItem;
  final String? description;

  const CreateShipmentRequest({
    required this.origin,
    required this.destination,
    required this.weightKg,
    required this.deliveryDate,
    required this.fragile,
    required this.shipmentItem,
    this.description,
  });

  factory CreateShipmentRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateShipmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateShipmentRequestToJson(this);

  // DateTime serialization helpers
  static String _dateTimeToJson(DateTime dateTime) =>
      '${dateTime.year.toString().padLeft(4, '0')}-'
      '${dateTime.month.toString().padLeft(2, '0')}-'
      '${dateTime.day.toString().padLeft(2, '0')}';
  static DateTime _dateTimeFromJson(String dateTime) =>
      DateTime.parse(dateTime);
}
