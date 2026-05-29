import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_guard.dart';
import 'app_providers.dart';

import 'package:memilogistics_app/core/di/service_locator.dart';
import 'package:memilogistics_app/core/router/app_router.dart';
import 'package:memilogistics_app/core/theme/app_theme.dart';
import 'package:memilogistics_app/core/widgets/splash_screen.dart';

import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/shipper/presentation/providers/shipper_company_provider.dart';
import 'package:memilogistics_app/features/user/presentation/provider/user_provider.dart';

class MemiLogisticsApp extends StatefulWidget {
  const MemiLogisticsApp({super.key});

  @override
  State<MemiLogisticsApp> createState() => _MemiLogisticsAppState();
}

class _MemiLogisticsAppState extends State<MemiLogisticsApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    // Show splash screen first
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: SplashScreen(
          duration: const Duration(seconds: 2),
          onComplete: () {
            if (mounted) {
              setState(() {
                _showSplash = false;
              });
            }
          },
        ),
      );
    }

    // Then show main app
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