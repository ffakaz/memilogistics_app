# Shipment Feature Fix Guide

## Problem Analysis

The Dart compiler cannot resolve shipment domain imports during compilation, even though:
- All files exist and are syntactically correct
- getDiagnostics shows no errors
- File structure follows Flutter best practices

This is likely caused by:
1. Circular dependency issues
2. Missing barrel export files
3. Dart analysis server cache corruption
4. Import path resolution problems

## Solution Steps

### Step 1: Create Barrel Export Files

Barrel files consolidate exports and help prevent circular dependencies.

#### 1.1 Create Domain Barrel Export

Create `lib/features/shipment/domain/domain.dart`:

```dart
// Entities
export 'entities/location.dart';
export 'entities/shipment.dart';

// Enums
export 'enums/safety_option.dart';
export 'enums/shipment_type.dart';
export 'enums/weight_unit.dart';

// Repositories
export 'repositories/shipment_repository.dart';
```

#### 1.2 Create Data Barrel Export

Create `lib/features/shipment/data/data.dart`:

```dart
// Models
export 'models/shipment_request_model.dart';

// Mappers
export 'mappers/shipment_mapper.dart';

// Services
export 'services/shipment_api_service_adapter.dart';

// Repositories
export 'repositories/shipment_repository_impl.dart';
```

#### 1.3 Create Presentation Barrel Export

Create `lib/features/shipment/presentation/presentation.dart`:

```dart
// Providers
export 'providers/shipment_provider.dart';

// Screens
export 'screens/create_shipment_screen.dart';
```

#### 1.4 Create Validators Barrel Export

Create `lib/features/shipment/validators/validators.dart`:

```dart
export 'shipment_validator.dart';
```

#### 1.5 Create Main Shipment Barrel Export

Create `lib/features/shipment/shipment.dart`:

```dart
// Domain layer
export 'domain/domain.dart';

// Data layer
export 'data/data.dart';

// Presentation layer
export 'presentation/presentation.dart';

// Validators
export 'validators/validators.dart';
```

### Step 2: Update Internal Imports

#### 2.1 Update shipment_repository_impl.dart

```dart
import '../../domain/domain.dart';
import '../services/shipment_api_service_adapter.dart';
import '../mappers/shipment_mapper.dart';

class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentApiServiceAdapter apiService;

  ShipmentRepositoryImpl({
    required this.apiService,
  });

  @override
  Future<void> createShipment(Shipment shipment) async {
    final request = shipment.toRequestModel();

    await apiService.createShipment(
      body: request.toJson(),
      accessToken: 'YOUR_ACCESS_TOKEN',
    );
  }
}
```

#### 2.2 Update shipment_provider.dart

```dart
import 'package:flutter/material.dart';
import '../../domain/domain.dart';

class ShipmentProvider extends ChangeNotifier {
  final ShipmentRepository repository;

  ShipmentProvider({
    required this.repository,
  });

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> createShipment({
    required String shipperName,
    required ShipmentType shipmentType,
    required double amount,
    required WeightUnit unit,
    required String pickup,
    required String destination,
    required DateTime pickupDate,
    required SafetyOption safetyOption,
  }) async {
    _setLoading(true);

    try {
      final shipment = Shipment(
        shipperName: shipperName,
        shipmentType: shipmentType,
        amount: amount,
        unit: unit,
        pickupLocation: Location(address: pickup),
        destinationLocation: Location(address: destination),
        pickupDate: pickupDate,
        safetyOption: safetyOption,
      );

      await repository.createShipment(shipment);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

#### 2.3 Update create_shipment_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/domain.dart';
import '../../validators/validators.dart';
import '../providers/shipment_provider.dart';

// Rest of the file remains the same
```

#### 2.4 Update shipment_mapper.dart

```dart
import '../../domain/domain.dart';
import '../models/shipment_request_model.dart';

extension ShipmentMapper on Shipment {
  ShipmentRequestModel toRequestModel() {
    return ShipmentRequestModel(
      shipperName: shipperName,
      shipmentType: shipmentType.name,
      amount: amount,
      unit: unit.name,
      pickupLocation: pickupLocation.address,
      destinationLocation: destinationLocation.address,
      pickupDate: pickupDate.toIso8601String(),
      safetyOption: safetyOption.name,
    );
  }
}
```

### Step 3: Update main.dart

Replace the commented shipment imports with the barrel import:

```dart
/// SHIPMENT FEATURE
import 'package:memilogistics_app/features/shipment/shipment.dart';
```

Uncomment the shipment dependencies and provider sections.

### Step 4: Deep Clean and Rebuild

```bash
# Stop the running app first (press 'q')

# Remove all build artifacts
flutter clean

# Clear Dart analysis cache
rm -rf .dart_tool

# Clear pub cache (optional but recommended)
dart pub cache clean

# Get dependencies fresh
flutter pub get

# Verify no analysis errors
flutter analyze
```

### Step 5: Restart IDE

1. Close VS Code or your IDE completely
2. Reopen the project
3. Wait for Dart analysis to complete (watch bottom status bar)
4. Check for any remaining errors

### Step 6: Try Running

```bash
flutter run -d edge
```

## Alternative Solution: Simplify Shipment Feature

If barrel exports don't work, try simplifying the feature:

### Option A: Inline Everything in One File

Create `lib/features/shipment/shipment_simple.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:memilogistics_app/core/core.dart';

// Enums
enum ShipmentType { dryGoods, refrigerated, hazardous, fragile }
enum WeightUnit { kg, lbs }
enum SafetyOption { normal, fragile }

// Location Entity
class Location {
  final String address;
  Location({required this.address});
}

// Shipment Entity
class Shipment {
  final String shipperName;
  final ShipmentType shipmentType;
  final double amount;
  final WeightUnit unit;
  final Location pickupLocation;
  final Location destinationLocation;
  final DateTime pickupDate;
  final SafetyOption safetyOption;

  Shipment({
    required this.shipperName,
    required this.shipmentType,
    required this.amount,
    required this.unit,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupDate,
    required this.safetyOption,
  });
}

// Repository Interface
abstract class ShipmentRepository {
  Future<void> createShipment(Shipment shipment);
}

// API Service
class ShipmentApiServiceAdapter {
  final ApiClient _apiClient;

  ShipmentApiServiceAdapter({required ApiClient apiClient}) 
      : _apiClient = apiClient;

  Future<void> createShipment({
    required Map<String, dynamic> body,
    required String accessToken,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/shipments',
      data: body,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (!response.isSuccess) {
      throw Exception(response.message ?? 'Failed to create shipment');
    }
  }
}

// Repository Implementation
class ShipmentRepositoryImpl implements ShipmentRepository {
  final ShipmentApiServiceAdapter apiService;

  ShipmentRepositoryImpl({required this.apiService});

  @override
  Future<void> createShipment(Shipment shipment) async {
    await apiService.createShipment(
      body: {
        'shipper_name': shipment.shipperName,
        'shipment_type': shipment.shipmentType.name,
        'amount': shipment.amount,
        'unit': shipment.unit.name,
        'pickup_location': shipment.pickupLocation.address,
        'destination_location': shipment.destinationLocation.address,
        'pickup_date': shipment.pickupDate.toIso8601String(),
        'safety_option': shipment.safetyOption.name,
      },
      accessToken: 'YOUR_ACCESS_TOKEN',
    );
  }
}

// Provider
class ShipmentProvider extends ChangeNotifier {
  final ShipmentRepository repository;
  bool _isLoading = false;

  ShipmentProvider({required this.repository});

  bool get isLoading => _isLoading;

  Future<void> createShipment({
    required String shipperName,
    required ShipmentType shipmentType,
    required double amount,
    required WeightUnit unit,
    required String pickup,
    required String destination,
    required DateTime pickupDate,
    required SafetyOption safetyOption,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final shipment = Shipment(
        shipperName: shipperName,
        shipmentType: shipmentType,
        amount: amount,
        unit: unit,
        pickupLocation: Location(address: pickup),
        destinationLocation: Location(address: destination),
        pickupDate: pickupDate,
        safetyOption: safetyOption,
      );

      await repository.createShipment(shipment);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Validator
class ShipmentValidator {
  static String? validateShipperName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Shipper name is required';
    }
    return null;
  }

  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Invalid amount';
    }
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }
    return null;
  }
}
```

Then in main.dart, just import this one file:

```dart
import 'package:memilogistics_app/features/shipment/shipment_simple.dart';
```

### Option B: Remove Shipment Feature Entirely

If the feature continues to cause issues:

1. Delete the entire `lib/features/shipment` folder
2. Keep it disabled in main.dart
3. Focus on getting auth features stable
4. Rebuild shipment feature from scratch later

## Debugging Steps

### Check for Circular Dependencies

```bash
# Install dependency analyzer
dart pub global activate dependency_validator

# Run analysis
dart pub global run dependency_validator
```

### Check Import Paths

Verify all import paths are correct:

```bash
# Search for incorrect imports
grep -r "import.*shipment" lib/features/shipment/
```

### Check for Syntax Errors

```bash
# Run dart analyzer
dart analyze lib/features/shipment/
```

### Check File Encoding

Ensure all files are UTF-8 encoded:

```bash
# On Windows PowerShell
Get-ChildItem -Path lib/features/shipment -Recurse -Filter *.dart | 
  ForEach-Object { 
    [System.IO.File]::ReadAllText($_.FullName, [System.Text.Encoding]::UTF8) 
  }
```

## Recommended Approach

**Priority Order:**

1. ✅ **Try Step 1-6 (Barrel Exports)** - Most professional solution
2. ✅ **Try Option A (Simplified Single File)** - Quick fix
3. ✅ **Try Option B (Remove and Rebuild)** - Last resort

## Testing After Fix

Once resolved, test:

1. **Compilation:**
   ```bash
   flutter analyze
   flutter run -d edge
   ```

2. **Navigation:**
   - Login → Home → Create Shipment

3. **Form Validation:**
   - Empty fields
   - Invalid data
   - Valid submission

4. **State Management:**
   - Loading states
   - Error handling
   - Success feedback

## Prevention for Future Features

To avoid similar issues:

1. **Always use barrel exports** from the start
2. **Avoid circular dependencies** - use dependency injection
3. **Test compilation frequently** during development
4. **Keep features modular** and independent
5. **Use consistent import patterns** across the project

## Additional Resources

- [Flutter Architecture Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options)
- [Dart Package Structure](https://dart.dev/guides/libraries/create-library-packages)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

## Need Help?

If issues persist:

1. Share the exact error message
2. Run `flutter doctor -v` and share output
3. Check Flutter/Dart versions
4. Try on a fresh Flutter project to isolate the issue
5. Consider filing a bug report if it's a tooling issue

---

**Remember:** The auth features are working perfectly. The shipment feature can be added back once these steps resolve the compilation issues.
