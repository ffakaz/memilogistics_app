class ApiConstants {
  ApiConstants._();

  // Backend base URL - Single source of truth
  static const String baseUrl = "https://memi-logistics-backend.onrender.com";
  static const String apiPrefix = "/api";

  // Timeouts
  // Note: Render.com free tier sleeps after 15 min inactivity
  // First request can take 30-60 seconds to wake up the server
  static const Duration connectTimeout = Duration(seconds: 90); // Increased for cold starts
  static const Duration receiveTimeout = Duration(seconds: 90); // Increased for cold starts
  static const Duration sendTimeout = Duration(seconds: 90); // Increased for cold starts
}

class AuthEndpoints {
  AuthEndpoints._();

  static const String login = "/auth/login";
  static const String register = "/auth/register";
  static const String refresh = "/auth/refresh";
  static const String logout = "/auth/logout";
  static const String forgotPassword = "/auth/forgot-password";
  static const String resetPassword = "/auth/reset-password";
}

class ShipmentEndpoints {
  ShipmentEndpoints._();

  // Core shipment operations
  static const String create = "/shipments/create";
  static const String list = "/shipments/list";
  static const String getById = "/shipments/{shipmentId}";
  static const String update = "/shipments/update/{id}";
  static const String delete = "/shipments/{shipmentId}";
  static const String dashboard = "/shipments/dashboard";
  
  // Tracking
  static const String tracking = "/shipments/tracking/{trackingNumber}";
  
  // Filtering
  static const String listByOrigin = "/shipments/list-by-origin/{origin}";
  static const String listByDestination = "/shipments/list-by-destination/{destination}";
  static const String listByFragile = "/shipments/list/fragile";
  
  // Status management
  static const String updateStatus = "/shipments/{shipmentId}/update-status";
  static const String getEvents = "/shipments/{shipmentId}/events";
  
  // Offers (Bidding) - DEPRECATED: Use ShipmentOfferEndpoints
  static const String offerShipment = "/shipments/{shipmentId}/offer-shipment";
  static const String cancelOffer = "/shipments/{shipmentOfferId}/cancel-shipment-offer";
  static const String assignCarrier = "/shipments/{shipmentId}/assign-carrier";
  
  // Payment
  static const String initiatePayment = "/shipments/{shipmentId}/initiate-payment";
  static const String confirmPayment = "/shipments/{shipmentId}/confirm-payment";
}

class ShipmentOfferEndpoints {
  ShipmentOfferEndpoints._();

  // Shipment offer operations
  static const String getMyOffers = "/shipment-offers/my-offers";
  static const String createOffer = "/shipments/{shipmentId}/offer-shipment";
  static const String cancelOffer = "/shipments/{shipmentOfferId}/cancel-shipment-offer";
  static const String assignCarrier = "/shipments/{shipmentId}/assign-carrier";
}

class LoadEndpoints {
  LoadEndpoints._();

  static const String getLoads = "/loads";
  static const String postLoad = "/loads/create";
}

/// FUTURE FEATURE: Carrier Company Management
/// 
/// These endpoints are NOT currently in the backend OpenAPI contract.
/// This is planned for future implementation when carriers need to manage
/// their company profiles, fleet information, and business details.
/// 
/// Current Status: NOT IMPLEMENTED
/// - Carrier dashboard works without these endpoints
/// - Carriers can browse loads, make offers, and update shipment status
/// - Company management is a future enhancement
/// 
/// When implementing:
/// - Coordinate with backend team on endpoint design
/// - Decide if this should be part of user profile or separate entity
/// - Consider including in carrier registration flow
class CarrierCompanyEndpoints {
  CarrierCompanyEndpoints._();

  // ⚠️ FUTURE FEATURE - Not yet available in backend
  static const String get = "/carrier/company";
  static const String create = "/carrier/company";
  static const String update = "/carrier/company";
}