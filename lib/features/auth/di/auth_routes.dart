// lib/features/auth/di/auth_routes.dart
//
// Register auth feature routes

import 'package:memilogistics_app/core/router/app_router.dart';
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';

class AuthRoutes {
  static void register() {
    AppRouter.registerRoutes({
      RouteConstants.login: (_) => const LoginScreen(),
    });
  }
}