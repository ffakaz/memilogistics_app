# Dart Analyzer Cache Issue - Fix Guide

## Problem
The Dart analyzer is showing "Undefined class" errors for shipment domain classes (Shipment, ShipmentType, WeightUnit, SafetyOption, etc.) even though:
- All files exist and are correctly defined
- Barrel exports are properly configured
- Imports use absolute package paths

This is a **stale analyzer cache issue** - the analyzer hasn't picked up the changes.

## Verification
All files are correct:
✅ `lib/features/shipment/domain/entities/shipment.dart` - exists
✅ `lib/features/shipment/domain/entities/location.dart` - exists
✅ `lib/features/shipment/domain/enums/shipment_type.dart` - exists
✅ `lib/features/shipment/domain/enums/weight_unit.dart` - exists
✅ `lib/features/shipment/domain/enums/safety_option.dart` - exists
✅ `lib/features/shipment/domain/domain.dart` - barrel export configured
✅ `lib/features/shipment/shipment.dart` - top-level barrel export configured
✅ All imports use absolute paths: `package:memilogistics_app/features/shipment/domain/domain.dart`

## Solution Options

### Option 1: Automated Script (Recommended)
Run the provided PowerShell script:
```powershell
.\clear_cache_and_run.ps1
```

This script will:
1. Remove `.dart_tool` directory
2. Remove `build` directory
3. Remove `.flutter-plugins` file
4. Remove `.flutter-plugins-dependencies` file
5. Run `flutter clean`
6. Run `flutter pub get`
7. Run `flutter run -d edge`

### Option 2: Manual Steps
If the script doesn't work, run these commands manually:

```powershell
# Step 1: Remove cache directories
Remove-Item -Recurse -Force .dart_tool
Remove-Item -Recurse -Force build
Remove-Item -Force .flutter-plugins
Remove-Item -Force .flutter-plugins-dependencies

# Step 2: Clean Flutter
flutter clean

# Step 3: Get packages
flutter pub get

# Step 4: Run the app
flutter run -d edge
```

### Option 3: IDE Restart
If the above doesn't work:
1. Close VS Code completely
2. Run the manual steps above
3. Reopen VS Code
4. Wait for Dart Analysis to complete (check bottom status bar)
5. Try running the app

### Option 4: Dart Analysis Server Restart
In VS Code:
1. Press `Ctrl+Shift+P` (Command Palette)
2. Type "Dart: Restart Analysis Server"
3. Press Enter
4. Wait for analysis to complete

### Option 5: Try Running Anyway
Sometimes the analyzer shows errors but the app compiles fine:
```powershell
flutter run -d edge
```

The Flutter compiler may succeed even if the analyzer shows errors.

## Expected Behavior After Fix
After clearing the cache:
- All "Undefined class" errors should disappear
- The app should compile successfully
- When you log in with a user that has role "driver" or "dispatcher", you should be routed to the Shipment Dashboard
- Test credentials: `test@example.com` / `password`

## Test User Roles
The fake API returns different roles based on email:
- `test@example.com` → role: "driver" → routes to Shipment Dashboard
- `admin@example.com` → role: "admin" → routes to Home Screen
- Any other email → role: "customer" → routes to Home Screen

To test the shipment dashboard, use `test@example.com` with password `password`.

## Architecture Verification
The shipment feature follows clean architecture with proper barrel exports:

```
lib/features/shipment/
├── shipment.dart (top-level barrel export)
├── domain/
│   ├── domain.dart (domain barrel export)
│   ├── entities/
│   │   ├── shipment.dart
│   │   └── location.dart
│   ├── enums/
│   │   ├── shipment_type.dart
│   │   ├── weight_unit.dart
│   │   └── safety_option.dart
│   └── repositories/
│       └── shipment_repository.dart
├── data/
│   ├── data.dart (data barrel export)
│   ├── models/
│   │   └── shipment_request_model.dart
│   ├── mappers/
│   │   └── shipment_mapper.dart
│   ├── services/
│   │   └── shipment_api_service_adapter.dart
│   └── repositories/
│       └── shipment_repository_impl.dart
├── presentation/
│   ├── presentation.dart (presentation barrel export)
│   ├── providers/
│   │   └── shipment_provider.dart
│   └── screens/
│       ├── create_shipment_screen.dart
│       └── shipment_dashboard_screen.dart
└── validators/
    ├── validators.dart (validators barrel export)
    └── shipment_validator.dart
```

All imports use absolute package paths for better compiler resolution.

## If Still Not Working
If none of the above solutions work:
1. Check that Flutter SDK is properly installed: `flutter doctor`
2. Ensure you're using a compatible Flutter version
3. Try creating a new Flutter project and copying the code over
4. Check for any antivirus software blocking file operations

## Notes
- The deprecation warnings about `withOpacity`, `groupValue`, and `onChanged` are just warnings, not errors
- These warnings don't prevent the app from running
- They can be addressed later by updating to newer Flutter APIs
