class ApiConstants {
  ApiConstants._();

  // Backend base URL - Single source of truth
  static const String baseUrl = "https://memi-logistics-backend.onrender.com";
  static const String apiPrefix = "/api";

  // Timeouts
  // Note: Render.com free tier sleeps after 15 min inactivity
  // First request can take 30-60 seconds to wake up the server
  static const Duration connectTimeout = Duration(
    seconds: 90,
  ); // Increased for cold starts
  static const Duration receiveTimeout = Duration(
    seconds: 90,
  ); // Increased for cold starts
  static const Duration sendTimeout = Duration(
    seconds: 90,
  ); // Increased for cold starts
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

  // Core shipment operations - Backend uses SINGULAR "shipment" not "shipments"
  static const String create = "/shipment/create"; // POST /api/shipment/create
  static const String list = "/shipment/list"; // GET /api/shipment/list
  static const String my =
      "/shipment/my"; // GET /api/shipment/my (role-aware, filtered by JWT)
  static const String myByStatus =
      "/shipment/my/status"; // GET /api/shipment/my/status?status=PENDING
  static const String getById = "/shipment/{shipmentId}";
  static const String update = "/shipment/update/{shipmentId}";
  static const String delete = "/shipment/{shipmentId}";
  static const String dashboard = "/shipment/dashboard";
  static const String statistics =
      "/shipment/dashboard"; // backend exposes dashboard; reuse for statistics

  // Tracking
  static const String tracking = "/shipment/{trackingNumber}/track";

  // Filtering
  static const String listByOrigin = "/shipment/list-by-origin/{origin}";
  static const String listByDestination =
      "/shipment/list-by-destination/{destination}";
  static const String listByFragile = "/shipment/list/fragile";

  // Status management
  static const String updateStatus = "/shipments/{shipmentId}/update-status";
  static const String getEvents = "/shipments/{shipmentId}/events";

  // Paginated helpers
  static const String listByShipper = "/shipment/shipper";

  // Offers (Bidding) - DEPRECATED: Use ShipmentOfferEndpoints
  static const String offerShipment = "/shipment/{shipmentId}/offer-shipment";
  static const String getOffers = "/shipment/{shipmentId}/offers";
  static const String cancelOffer =
      "/shipment/{shipmentOfferId}/cancel-shipment-offer";
  static const String assignCarrier = "/shipment/{shipmentId}/assign-carrier";

  // Payment
  static const String initiatePayment =
      "/payment/{shipmentId}/initiate-payment";
  static const String confirmPayment =
      "/payment/{shipmentId}/confirm-payment";
}

class ShipmentOfferEndpoints {
  ShipmentOfferEndpoints._();

  // Shipment offer operations
  // Note: backend uses singular "/shipment" for reading offers,
  // and plural "/shipments" for offer mutations.
  // Backend automatically extracts carrier ID from JWT token
  static const String getMyOffers =
      "/shipment-offers/my-offers"; // TODO: Backend doesn't have this endpoint yet
  static const String getShipmentOffers =
      "/shipment/{shipmentId}/offers"; // GET offers for a shipment - SINGULAR

  // CREATE OFFER - Uses query parameter for price, carrier ID from JWT token
  static const String createOffer =
      "/shipments/{shipmentId}/offer-shipment"; // POST with ?price=X - PLURAL

  static const String cancelOffer =
      "/shipments/{shipmentOfferId}/cancel-shipment-offer"; // PLURAL

  // Accept offer by assigning carrier (shipper action)
  // Uses query parameter for carrierId
  static const String assignCarrier =
      "/shipments/{shipmentId}/assign-carrier"; // PLURAL

  // Reject offer (shipper action) - uses cancel endpoint
  static const String rejectOffer =
      "/shipments/{shipmentOfferId}/cancel-shipment-offer"; // PLURAL
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
  static const String get = "/carrier/profile/me";
  static const String getById = "/carrier/profile/{carrierId}";
  static const String create = "/carrier/profile/create";
  static const String update = "/carrier/profile/update";
}

class CarrierShipmentEndpoints {
  CarrierShipmentEndpoints._();

  // Get shipments assigned to the current authenticated carrier
  // GET /api/carrier/shipments/assigned
  static const String getAssignedForCurrent = "/carrier/shipments/assigned";

  // Get shipments assigned to a specific carrier by ID
  // GET /api/carrier/shipments/{carrierId}/assigned
  static const String getAssignedForCarrier =
      "/carrier/shipments/{carrierId}/assigned";
}

class ShipperCompanyEndpoints {
  ShipperCompanyEndpoints._();

  static const String get = "/shippers/profile/me";
  static const String getById = "/shippers/profile/{shipperId}";
  static const String create = "/shippers/profile/create";
  static const String update = "/shippers/profile/update";
}
