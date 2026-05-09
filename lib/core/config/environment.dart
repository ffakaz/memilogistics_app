// lib/core/config/environment.dart
/// Lightweight environment helper. Use this to check the current running
/// environment in places where behavior should change (logging, analytics).
enum Environment { development, staging, production, test }

class EnvironmentConfig {
  final Environment environment;
  final String name;

  EnvironmentConfig._({required this.environment, required this.name});

  static late EnvironmentConfig current;

  static void init({required Environment environment, String? name}) {
    current = EnvironmentConfig._(environment: environment, name: name ?? environment.toString());
  }

  bool get isProduction => environment == Environment.production;
  bool get isDevelopment => environment == Environment.development;
}
