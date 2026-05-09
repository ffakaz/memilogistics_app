import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// CORE
import 'package:memilogistics_app/core/core.dart';
import 'package:memilogistics_app/bootstrap.dart' as bootstrap;

/// Features (screens)
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/register_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/logout_screen.dart';
// HomeScreen disabled — removed from imports to avoid accidental use.
import 'package:memilogistics_app/features/shipment/shipment.dart';
import 'package:memilogistics_app/features/user/presentation/screens/role_selection_screen.dart';
import 'package:memilogistics_app/features/user/presentation/screens/role_decider.dart';

/// Locator
import 'package:memilogistics_app/core/di/service_locator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Providers (types used by the root MultiProvider)
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';
import 'package:memilogistics_app/features/user/presentation/providers/user_provider.dart';

void main() async {
  await bootstrap.initApp(env: AppEnvironment.fake);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // Use the locator to provide singletons to the widget tree. We register
    // the same core services and ChangeNotifier instances in `setupLocator()`.
    return MultiProvider(
      providers: [
        Provider<FlutterSecureStorage>.value(value: locator<FlutterSecureStorage>()),
        Provider<SecureStorageService>.value(value: locator<SecureStorageService>()),
        Provider<AppRouter>.value(value: locator<AppRouter>()),
        Provider<ApiClient>.value(value: locator<ApiClient>()),

        ChangeNotifierProvider<AuthProvider>.value(value: locator<AuthProvider>()..init()),
        ChangeNotifierProvider<ShipmentProvider>.value(value: locator<ShipmentProvider>()),
        ChangeNotifierProvider<UserProvider>.value(value: locator<UserProvider>()),
      ],
      child: Consumer2<AuthProvider, UserProvider>(
        builder: (context, auth, userProvider, _) {
          if (!auth.initialized) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          if (auth.isLoggedIn && !userProvider.hasUser) {
            userProvider.loadCurrentUser();
          }

          Widget getHomeScreen() {
            if (!auth.isLoggedIn) return const LoginScreen();
            return const RoleDecider();
          }

          final router = locator<AppRouter>();

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Memi Logistics',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            navigatorKey: router.navigatorKey,
            onGenerateRoute: router.onGenerateRoute,
            home: getHomeScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/logout': (_) => const LogoutScreen(),
              // '/home' intentionally removed — users MUST select role first.
              '/dashboard': (_) => const ShipmentDashboardScreen(),
              '/select-role': (_) => const RoleSelectionScreen(),
              '/create-shipment': (_) => const CreateShipmentScreen(),
            },
          );
        },
      ),
    );
  }
}