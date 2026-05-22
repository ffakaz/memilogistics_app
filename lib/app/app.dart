import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_guard.dart';
import 'app_providers.dart';

import 'package:memilogistics_app/core/di/service_locator.dart';
import 'package:memilogistics_app/core/router/app_router.dart';
import 'package:memilogistics_app/core/theme/app_theme.dart';

import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';
import 'package:memilogistics_app/features/user/presentation/provider/user_provider.dart';

class MemiLogisticsApp extends StatelessWidget {
  const MemiLogisticsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,

      child: Consumer4<AuthProvider, UserProvider, CarrierCompanyProvider, ShipperCompanyProvider>(
        builder: (
          context,
          authProvider,
          userProvider,
          carrierCompanyProvider,
          shipperCompanyProvider,
          _,
        ) {

          if (!authProvider.initialized) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return MaterialApp(
            debugShowCheckedModeBanner: false,

            title: 'Memi Logistics',

            theme: AppTheme.lightTheme,

            darkTheme: AppTheme.darkTheme,

            navigatorKey:
                locator<AppRouter>().navigatorKey,

            onGenerateRoute:
                locator<AppRouter>().onGenerateRoute,

            home: AppGuard.resolveHome(
              authProvider: authProvider,
              userProvider: userProvider,
            ),
          );
        },
      ),
    );
  }
}