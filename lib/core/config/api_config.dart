// lib/core/config/api_config.dart
//
// API configuration that uses ApiConstants as the single source of truth.
// Switch environments by changing [ApiConfig.current] in main().

import 'package:memilogistics_app/core/utils/constants/api_constants.dart';

enum AppEnvironment { development, staging, production }

class ApiConfig {
  const ApiConfig._({
    required this.environment,
    required this.baseUrl,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.sendTimeoutMs,
    required this.enableLogging,
  });

  final AppEnvironment environment;
  final String baseUrl;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final int sendTimeoutMs;
  final bool enableLogging;

  // ── Singleton ──────────────────────────────────────────────────────────────
  static ApiConfig? _current;

  static ApiConfig get current {
    assert(
      _current != null,
      'ApiConfig not initialised. Call ApiConfig.init() before runApp().',
    );
    return _current!;
  }

  static void init(AppEnvironment env) => _current = _build(env);

  static ApiConfig _build(AppEnvironment env) {
    // All environments use ApiConstants as single source of truth
    return ApiConfig._(
      environment: env,
      baseUrl: ApiConstants.baseUrl,
      connectTimeoutMs: ApiConstants.connectTimeout.inMilliseconds,
      receiveTimeoutMs: ApiConstants.receiveTimeout.inMilliseconds,
      sendTimeoutMs: ApiConstants.sendTimeout.inMilliseconds,
      enableLogging: env != AppEnvironment.production,
    );
  }

  // ── Computed helpers ───────────────────────────────────────────────────────
  bool get isProduction => environment == AppEnvironment.production;
  bool get isDevelopment => environment == AppEnvironment.development;

  Duration get connectTimeout => Duration(milliseconds: connectTimeoutMs);
  Duration get receiveTimeout => Duration(milliseconds: receiveTimeoutMs);
  Duration get sendTimeout => Duration(milliseconds: sendTimeoutMs);

  @override
  String toString() => 'ApiConfig(env: $environment, baseUrl: $baseUrl)';
}