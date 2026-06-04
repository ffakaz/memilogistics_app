import 'package:flutter/material.dart';

import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/carrier/presentation/screens/carrier_dashboard_refactored.dart';
import 'package:memilogistics_app/features/carrier/presentation/widgets/carrier_profile_gate.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';

import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';

import 'package:memilogistics_app/features/shipment/presentation/screens/shipment_dashboard_screen.dart';
import 'package:memilogistics_app/features/shipper/presentation/widgets/shipper_profile_gate.dart';

import 'package:memilogistics_app/features/user/presentation/provider/user_provider.dart';

class AppGuard {
  static Widget resolveHome({
    required AuthProvider authProvider,
    required UserProvider userProvider,
    CarrierCompanyProvider? carrierCompanyProvider,
    ShipperCompanyProvider? shipperCompanyProvider,
  }) {
    if (!authProvider.isLoggedIn) {
      return const LoginScreen();
    }

    if (authProvider.userRole?.toUpperCase() == 'CARRIER') {
      return const CarrierProfileGate(child: CarrierDashboardRefactored());
    }

    return const ShipperProfileGate(child: ShipmentDashboardScreen());
  }
}
