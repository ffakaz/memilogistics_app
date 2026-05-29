import 'package:flutter/material.dart';
import 'package:memilogistics_app/app/app.dart';
import 'package:memilogistics_app/bootstrap.dart';
import 'package:memilogistics_app/core/config/api_config.dart';
import 'package:memilogistics_app/core/di/service_locator.dart';
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';

Future<void> main() async {
  await initApp(env: AppEnvironment.development);

  // Ensure auth state is restored before the app UI mounts to avoid
  // race conditions where providers trigger network calls before
  // tokens are loaded from secure storage.
  await locator<AuthProvider>().init();

  runApp(const MemiLogisticsApp());
}
