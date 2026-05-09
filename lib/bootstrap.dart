// lib/bootstrap.dart

import 'package:flutter/widgets.dart';

import 'package:memilogistics_app/core/core.dart';
import 'package:memilogistics_app/core/di/service_locator.dart';

/// Initializes early app state: bindings, environment and service locator.
/// Call this from `main()` before `runApp()`.
Future<void> initApp({AppEnvironment env = AppEnvironment.fake}) async {
  WidgetsFlutterBinding.ensureInitialized();

  ApiConfig.init(env);

  await setupLocator();
}
