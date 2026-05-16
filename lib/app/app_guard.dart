import 'package:flutter/material.dart';

import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/carrier/presentation/screens/carrier_dashboard_screen.dart';
import 'package:memilogistics_app/features/shipment/presentation/screens/shipment_dashboard_screen.dart';
import 'package:memilogistics_app/features/user/domain/enums/app_role.dart';
import 'package:memilogistics_app/features/user/presentation/provider/user_provider.dart';

class AppGuard {
  const AppGuard._();

  static Widget resolveHome({
    required AuthProvider authProvider,
    required UserProvider userProvider,
  }) {
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    // Load user if not loaded
    if (!userProvider.hasUser) {
      userProvider.loadCurrentUser();
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userProvider.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Route based on user role
    switch (user.profile.role) {
      case AppRole.carrier:
        return const CarrierDashboardScreen();
      case AppRole.shipper:
        return const ShipmentDashboardScreen();
      case AppRole.admin:
        return const ShipmentDashboardScreen();
    }
  }
}
