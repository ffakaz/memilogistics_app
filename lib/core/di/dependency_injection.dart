// lib/core/di/dependency_injection.dart
//
// Registers ONLY core-layer services. Feature providers are added by each
// feature's DI module via FeatureDependencies.register([...]) in main().
//
// ── RULE: this file MUST NOT import anything from features/ ──────────────────
//
// ── HOW TO SWITCH FAKE → REAL API ────────────────────────────────────────────
// 1. ApiConfig.init(AppEnvironment.development) in main.dart
// 2. In features/auth/di/auth_di.dart:
//      swap FakeApiClient for DioApiClient (see template)
// Nothing in core/ changes at all.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import 'package:memilogistics_app/core/core.dart';

// ── Feature DI extension point ─────────────────────────────────────────────

abstract class FeatureDependencies {
  static final List<dynamic> _providers = [];

  static void register(List<dynamic> providers) =>
      _providers.addAll(providers);

  static List<dynamic> get all => List.unmodifiable(_providers);
}

// ── Root injector ──────────────────────────────────────────────────────────

class AppInjection {
  AppInjection._();

  static Widget create({required Widget child}) {
    return MultiProvider(
      providers: [
        ..._coreProviders(),
        ...FeatureDependencies.all,
      ],
      child: child,
    );
  }

  static List<dynamic> _coreProviders() {
    return [
      Provider<FlutterSecureStorage>(
        create: (_) => const FlutterSecureStorage(),
      ),
      Provider<SecureStorageService>(
        create: (ctx) => SecureStorageService(
          storage: ctx.read<FlutterSecureStorage>(),
        ),
      ),
      Provider<AppRouter>(
        create: (ctx) => AppRouter(
          storageService: ctx.read<SecureStorageService>(),
        ),
      ),
      Provider<ApiClient>(
        create: (ctx) {
          if (ApiConfig.current.isFake) {
            return FakeApiClient();
          } else {
            return DioApiClient.create(
              storageService: ctx.read<SecureStorageService>(),
              onSessionExpired: () =>
                  ctx.read<AppRouter>().handleSessionExpired(),
            );
          }
        },
      ),
    ];
  }
}