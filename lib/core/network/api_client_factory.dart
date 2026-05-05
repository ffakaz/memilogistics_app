// lib/core/network/api_client_factory.dart
//
// Factory for creating API clients based on configuration

import 'package:memilogistics_app/core/core.dart';

class ApiClientFactory {
  static ApiClient create({
    required SecureStorageService storageService,
    required void Function() onSessionExpired,
  }) {
    if (ApiConfig.current.isFake) {
      return FakeApiClient();
    }

    return DioApiClient.create(
      storageService: storageService,
      onSessionExpired: onSessionExpired,
    );
  }
}