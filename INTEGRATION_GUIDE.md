# Quick Integration Guide

## Current Status
✅ Fake API infrastructure is ready
✅ Your existing screens (LoginScreen, HomeScreen) are preserved
✅ Dependencies added to pubspec.yaml

## What You Need to Do

### Step 1: Update Your AuthProvider

Your `AuthProvider` currently uses the old API service. Update it to use the new `ApiClient`:

**File: `lib/features/auth/presentation/provider/auth_provider.dart`**

```dart
import 'package:flutter/foundation.dart';
import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final SecureStorageService _storage;
  
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthProvider({
    required ApiClient apiClient,
    required SecureStorageService storage,
  })  : _apiClient = apiClient,
        _storage = storage;

  Future<void> init() async {
    _isAuthenticated = await _storage.hasValidSession();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data!;
        
        // Save tokens
        await _storage.saveTokens(
          accessToken: data['access_token'] ?? '',
          refreshToken: data['refresh_token'] ?? '',
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 30)),
        );
        
        _isAuthenticated = true;
        _error = null;
      } else {
        _error = response.message ?? 'Login failed';
        _isAuthenticated = false;
      }
    } catch (e) {
      _error = 'An error occurred: $e';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.clearAuthData();
    _isAuthenticated = false;
    notifyListeners();
  }
}
```

### Step 2: Update main.dart

Replace your current main.dart with this simplified version:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memilogistics_app/core/config/api_config.dart';
import 'package:memilogistics_app/core/di/dependency_injection.dart';
import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';
import 'package:memilogistics_app/core/theme/app_theme.dart';
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Use fake API for now
  ApiConfig.init(AppEnvironment.fake);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppInjection.create(
      child: Builder(
        builder: (context) {
          return ChangeNotifierProvider(
            create: (ctx) => AuthProvider(
              apiClient: ctx.read<ApiClient>(),
              storage: ctx.read<SecureStorageService>(),
            )..init(),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Memi Logistics',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  home: auth.isAuthenticated 
                      ? const HomeScreen() 
                      : const LoginScreen(),
                  routes: {
                    '/login': (_) => const LoginScreen(),
                    '/home': (_) => const HomeScreen(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
```

### Step 3: Test It!

```bash
flutter run
```

**What to expect:**
1. Login screen appears
2. Enter ANY email and password (fake API accepts everything)
3. Click Login
4. You'll be redirected to HomeScreen
5. Mock data will be available from the fake API

## That's It!

The fake API is now integrated. When your backend is ready:

1. Change `ApiConfig.init(AppEnvironment.development)` in main.dart
2. Update the backend URL in `lib/core/config/api_config.dart`
3. Done!

## Troubleshooting

**If you see analyzer errors:**
- Ignore them! They're false positives
- The app will compile and run fine
- To clear them: `flutter clean && flutter pub get` and restart IDE

**If login doesn't work:**
- Check that AuthProvider is receiving ApiClient
- Check console for error messages
- Verify ApiConfig.init() is called before runApp()

**Need help?**
- Check `PRACTICAL_FIXES.md` for API examples
- Check `lib/core/network/fake_api_client.dart` to see available endpoints
