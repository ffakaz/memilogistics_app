// lib/core/network/api_routes.dart

import '../../core/utils/constants/api_constants.dart';

/// Centralized API route templates aligned with OpenAPI.
class ApiRoutes {
  ApiRoutes._();

  // Auth
  static const login = AuthEndpoints.login;
  static const register = AuthEndpoints.register;
  static const refresh = AuthEndpoints.refresh;
  static const logout = AuthEndpoints.logout;

  // Shipments (singular resources)
  static const createShipment = ShipmentEndpoints.create;
  static const listShipments = ShipmentEndpoints.list;
  static const getShipment = ShipmentEndpoints.getById;
  static const deleteShipment = ShipmentEndpoints.delete;

  // Shipment offers (plural paths per OpenAPI)
  static const getMyOffers = '/shipment-offers/my-offers';
  static const createOffer = ShipmentOfferEndpoints.createOffer;
  static const getShipmentOffers = ShipmentOfferEndpoints.getShipmentOffers;
  static const cancelOffer = ShipmentOfferEndpoints.cancelOffer;
  static const assignCarrier = ShipmentOfferEndpoints.assignCarrier;
}
