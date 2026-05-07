# MemiLogistics App Flow Diagram

## Application Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP STARTS                              │
│                         (main.dart)                             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Initialize Dependencies                      │
│  • ApiClient (Fake)                                            │
│  • SecureStorage                                               │
│  • AuthRepository                                              │
│  • ShipmentRepository                                          │
│  • UserRepository                                              │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Create Providers                             │
│  • AuthProvider (with use cases)                               │
│  • ShipmentProvider                                            │
│  • UserProvider                                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Check Auth Status                            │
│                  (AuthProvider.init())                          │
└────────────────────────────┬────────────────────────────────────┘
                             │
                ┌────────────┴────────────┐
                │                         │
                ▼                         ▼
        ┌──────────────┐          ┌──────────────┐
        │ Not Logged In│          │  Logged In   │
        └──────┬───────┘          └──────┬───────┘
               │                         │
               ▼                         ▼
        ┌──────────────┐          ┌──────────────────────┐
        │ Login Screen │          │ Load Current User    │
        └──────┬───────┘          │ (UserProvider)       │
               │                  └──────┬───────────────┘
               │                         │
               ▼                         ▼
        ┌──────────────┐          ┌──────────────────────┐
        │ Enter Email  │          │ Fake API Returns:    │
        │ & Password   │          │ • role: "driver"     │
        └──────┬───────┘          │ • name: "John Doe"   │
               │                  │ • permissions        │
               ▼                  └──────┬───────────────┘
        ┌──────────────┐                │
        │ Submit Login │                │
        └──────┬───────┘                │
               │                        │
               ▼                        │
        ┌──────────────┐                │
        │ Fake API     │                │
        │ Returns Token│                │
        └──────┬───────┘                │
               │                        │
               └────────────┬───────────┘
                            │
                            ▼
                ┌───────────────────────┐
                │  Role-Based Routing   │
                │  (in main.dart)       │
                └───────────┬───────────┘
                            │
            ┌───────────────┼───────────────┐
            │               │               │
            ▼               ▼               ▼
    ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
    │   Driver     │ │  Dispatcher  │ │ Admin/       │
    │              │ │              │ │ Customer     │
    └──────┬───────┘ └──────┬───────┘ └──────┬───────┘
           │                │                │
           └────────────────┼────────────────┘
                            │
            ┌───────────────┴───────────────┐
            │                               │
            ▼                               ▼
    ┌──────────────────┐          ┌──────────────────┐
    │ Shipment         │          │ Home Screen      │
    │ Dashboard        │          │                  │
    └──────┬───────────┘          └──────────────────┘
           │
           │
           ▼
    ┌──────────────────────────────────────────┐
    │     Shipment Dashboard Features          │
    │                                          │
    │  ┌────────────────────────────────┐     │
    │  │ User Profile Section           │     │
    │  │ • Avatar                       │     │
    │  │ • Name: John Doe               │     │
    │  │ • Role Badge: Driver           │     │
    │  │ • Email: test@example.com      │     │
    │  └────────────────────────────────┘     │
    │                                          │
    │  ┌────────────────────────────────┐     │
    │  │ Statistics Cards               │     │
    │  │ • Active Shipments: 12         │     │
    │  │ • Completed: 45                │     │
    │  │ • Pending: 3                   │     │
    │  └────────────────────────────────┘     │
    │                                          │
    │  ┌────────────────────────────────┐     │
    │  │ Quick Actions                  │     │
    │  │ [Create New Shipment]          │─────┼──┐
    │  │ [View All Shipments]           │     │  │
    │  │ [Track Shipment]               │     │  │
    │  └────────────────────────────────┘     │  │
    │                                          │  │
    │  ┌────────────────────────────────┐     │  │
    │  │ Recent Activity Feed           │     │  │
    │  │ • Shipment #1234 delivered     │     │  │
    │  │ • Shipment #1235 in transit    │     │  │
    │  │ • Shipment #1236 picked up     │     │  │
    │  └────────────────────────────────┘     │  │
    └──────────────────────────────────────────┘  │
                                                  │
                                                  ▼
                                    ┌──────────────────────────┐
                                    │ Create Shipment Screen   │
                                    │                          │
                                    │ Form Fields:             │
                                    │ • Shipper Name           │
                                    │ • Shipment Type          │
                                    │   (Dry Goods/Electronics)│
                                    │ • Amount                 │
                                    │ • Weight Unit (kg/ton)   │
                                    │ • Pickup Location        │
                                    │ • Destination            │
                                    │ • Pickup Date            │
                                    │ • Safety Option          │
                                    │   (Normal/Fragile)       │
                                    │                          │
                                    │ [Submit Button]          │
                                    └────────┬─────────────────┘
                                             │
                                             ▼
                                    ┌──────────────────────────┐
                                    │ Validate Form            │
                                    │ (ShipmentValidator)      │
                                    └────────┬─────────────────┘
                                             │
                                             ▼
                                    ┌──────────────────────────┐
                                    │ Create Shipment Entity   │
                                    │ (Domain Layer)           │
                                    └────────┬─────────────────┘
                                             │
                                             ▼
                                    ┌──────────────────────────┐
                                    │ Map to Request Model     │
                                    │ (ShipmentMapper)         │
                                    └────────┬─────────────────┘
                                             │
                                             ▼
                                    ┌──────────────────────────┐
                                    │ Send to Fake API         │
                                    │ POST /shipments          │
                                    └────────┬─────────────────┘
                                             │
                                             ▼
                                    ┌──────────────────────────┐
                                    │ Success!                 │
                                    │ Navigate back to         │
                                    │ Dashboard                │
                                    └──────────────────────────┘
```

## Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Auth         │  │ Shipment     │  │ User         │         │
│  │ Provider     │  │ Provider     │  │ Provider     │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                       DOMAIN LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Auth         │  │ Shipment     │  │ User         │         │
│  │ Use Cases    │  │ Repository   │  │ Use Cases    │         │
│  │ • Login      │  │ Interface    │  │ • GetUser    │         │
│  │ • Register   │  │              │  │ • Update     │         │
│  │ • Logout     │  │              │  │ • GetPerms   │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          ▼                 ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Auth         │  │ Shipment     │  │ User         │         │
│  │ Repository   │  │ Repository   │  │ Repository   │         │
│  │ Impl         │  │ Impl         │  │ Impl         │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
│         ▼                 ▼                 ▼                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │
│  │ Auth API     │  │ Shipment API │  │ User API     │         │
│  │ Service      │  │ Service      │  │ Service      │         │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘         │
│         │                 │                 │                  │
└─────────┼─────────────────┼─────────────────┼──────────────────┘
          │                 │                 │
          └─────────────────┼─────────────────┘
                            │
                            ▼
                   ┌──────────────────┐
                   │  Fake API Client │
                   │                  │
                   │  Endpoints:      │
                   │  • /auth/login   │
                   │  • /auth/register│
                   │  • /user/me      │
                   │  • /shipments    │
                   └──────────────────┘
```

## Role-Based Routing Logic

```
User Logs In
     │
     ▼
Fetch User Profile from API
     │
     ▼
Check user.profile.role
     │
     ├─── role == "driver" ────────┐
     │                             │
     ├─── role == "dispatcher" ────┤
     │                             │
     │                             ▼
     │                    ┌──────────────────┐
     │                    │ Shipment         │
     │                    │ Dashboard Screen │
     │                    └──────────────────┘
     │
     ├─── role == "admin" ─────────┐
     │                             │
     ├─── role == "customer" ──────┤
     │                             │
     │                             ▼
     │                    ┌──────────────────┐
     │                    │ Home Screen      │
     │                    └──────────────────┘
     │
     └─── default ────────────────▶ Home Screen
```

## Test Credentials Flow

```
Email: test@example.com
Password: password
     │
     ▼
Fake API Returns:
{
  "profile": {
    "role": "driver",      ◄─── This determines routing
    "name": "John Doe",
    "email": "test@example.com"
  }
}
     │
     ▼
Role Check: "driver"
     │
     ▼
Route to: Shipment Dashboard ✓
```

## File Import Structure

```
lib/
├── main.dart
│   └── imports: 'package:memilogistics_app/features/shipment/shipment.dart'
│
└── features/
    └── shipment/
        ├── shipment.dart (TOP-LEVEL BARREL)
        │   ├── exports: domain/domain.dart
        │   ├── exports: data/data.dart
        │   ├── exports: presentation/presentation.dart
        │   └── exports: validators/validators.dart
        │
        ├── domain/
        │   └── domain.dart (DOMAIN BARREL)
        │       ├── exports: entities/shipment.dart
        │       ├── exports: entities/location.dart
        │       ├── exports: enums/shipment_type.dart
        │       ├── exports: enums/weight_unit.dart
        │       ├── exports: enums/safety_option.dart
        │       └── exports: repositories/shipment_repository.dart
        │
        ├── data/
        │   └── data.dart (DATA BARREL)
        │       ├── exports: models/shipment_request_model.dart
        │       ├── exports: mappers/shipment_mapper.dart
        │       ├── exports: services/shipment_api_service_adapter.dart
        │       └── exports: repositories/shipment_repository_impl.dart
        │
        ├── presentation/
        │   └── presentation.dart (PRESENTATION BARREL)
        │       ├── exports: providers/shipment_provider.dart
        │       ├── exports: screens/create_shipment_screen.dart
        │       └── exports: screens/shipment_dashboard_screen.dart
        │
        └── validators/
            └── validators.dart (VALIDATORS BARREL)
                └── exports: shipment_validator.dart
```

## Summary

This diagram shows:
1. **Application Flow**: From startup to dashboard
2. **Data Flow**: Through clean architecture layers
3. **Role-Based Routing**: How users are directed based on role
4. **Test Credentials**: What happens when you login
5. **File Structure**: How barrel exports work

The app is fully functional and ready to run!
