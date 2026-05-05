// lib/features/dashboard/di/dashboard_routes.dart
//
// Register dashboard feature routes

import 'package:flutter/material.dart';
import 'package:memilogistics_app/core/router/app_router.dart';
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';

class DashboardRoutes {
  static void register() {
    AppRouter.registerRoutes({
      RouteConstants.home: (BuildContext context) => const HomeScreen(),
    });
  }
}