import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// CORE
import 'package:memilogistics_app/core/core.dart';

/// AUTH FEATURE
import 'package:memilogistics_app/features/auth/data/services/fake_auth_api_service_adapter.dart';
import 'package:memilogistics_app/features/auth/data/storage/token_storage.dart';
import 'package:memilogistics_app/features/auth/data/repository/auth_repository_impl.dart';

import 'package:memilogistics_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/get_current_token_usecase.dart';

import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';

import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/register_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/logout_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';

/// SHIPMENT FEATURE
import 'package:memilogistics_app/features/shipment/shipment.dart';

/// USER FEATURE
import 'package:memilogistics_app/features/user/user.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  ApiConfig.init(AppEnvironment.fake);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return AppInjection.create(

      child: Builder(

        builder: (context) {

          /// CORE DEPENDENCIES

          final apiClient =
              context.read<ApiClient>();

          final secureStorage =
              context.read<FlutterSecureStorage>();

          /// AUTH DEPENDENCIES

          final authApiService =
              FakeAuthApiServiceAdapter(
            apiClient: apiClient,
          );

          final tokenStorage =
              TokenStorage(
            storage: secureStorage,
          );

          final authRepository =
              AuthRepositoryImpl(
            apiService: authApiService,
            tokenStorage: tokenStorage,
          );

          /// AUTH USE CASES

          final loginUseCase =
              LoginUseCase(authRepository);

          final registerUseCase =
              RegisterUseCase(authRepository);

          final logoutUseCase =
              LogoutUseCase(authRepository);

          final isLoggedInUseCase =
              IsLoggedInUseCase(authRepository);

          final getCurrentTokenUseCase =
              GetCurrentTokenUseCase(authRepository);

          /// SHIPMENT DEPENDENCIES

          final shipmentApiService =
              ShipmentApiServiceAdapter(
            apiClient: apiClient,
          );

          final shipmentRepository =
              ShipmentRepositoryImpl(
            apiService:
                shipmentApiService,
          );

          /// USER DEPENDENCIES

          final userApiService = UserApiService(
            apiClient: apiClient,
          );

          final userRepository = UserRepositoryImpl(
            apiService: userApiService,
          );

          /// USER USE CASES

          final getCurrentUserUseCase = GetCurrentUserUseCase(userRepository);
          final updateProfileUseCase = UpdateProfileUseCase(userRepository);
          final getPermissionsUseCase = GetPermissionsUseCase(userRepository);

          return MultiProvider(

            providers: [

              /// AUTH PROVIDER

              ChangeNotifierProvider(

                create: (_) => AuthProvider(

                  loginUseCase:
                      loginUseCase,

                  registerUseCase:
                      registerUseCase,

                  logoutUseCase:
                      logoutUseCase,

                  isLoggedInUseCase:
                      isLoggedInUseCase,

                  getCurrentTokenUseCase:
                      getCurrentTokenUseCase,

                )..init(),
              ),

              /// SHIPMENT PROVIDER

              ChangeNotifierProvider(
                create: (_) => ShipmentProvider(
                  repository: shipmentRepository,
                ),
              ),

              /// USER PROVIDER

              ChangeNotifierProvider(
                create: (_) => UserProvider(
                  getCurrentUserUseCase: getCurrentUserUseCase,
                  updateProfileUseCase: updateProfileUseCase,
                  getPermissionsUseCase: getPermissionsUseCase,
                ),
              ),
            ],

            child: Consumer2<AuthProvider, UserProvider>(

              builder: (
                context,
                auth,
                userProvider,
                _,
              ) {

                if (!auth.initialized) {

                  return const MaterialApp(

                    debugShowCheckedModeBanner:
                        false,

                    home: Scaffold(

                      body: Center(
                        child:
                            CircularProgressIndicator(),
                      ),
                    ),
                  );
                }

                // Load user after login
                if (auth.isLoggedIn && !userProvider.hasUser) {
                  userProvider.loadCurrentUser();
                }

                // Determine home screen based on role
                Widget getHomeScreen() {
                  if (!auth.isLoggedIn) {
                    return const LoginScreen();
                  }

                  final user = userProvider.currentUser;
                  if (user == null) {
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  }

                  // Route based on role
                  switch (user.profile.role) {
                    case AppRole.shipper:
                    case AppRole.carrier:
                      return const ShipmentDashboardScreen();
                    case AppRole.admin:
                      return const HomeScreen();
                  }
                }

                return MaterialApp(

                  debugShowCheckedModeBanner:
                      false,

                  title:
                      'Memi Logistics',

                  theme:
                      AppTheme.lightTheme,

                  darkTheme:
                      AppTheme.darkTheme,

                  home: getHomeScreen(),

                  routes: {

                    '/login': (_) =>
                        const LoginScreen(),

                    '/register': (_) =>
                        const RegisterScreen(),

                    '/logout': (_) =>
                        const LogoutScreen(),

                    '/home': (_) =>
                        const HomeScreen(),

                    '/dashboard': (_) =>
                        const ShipmentDashboardScreen(),

                    '/create-shipment': (_) =>
                        const CreateShipmentScreen(),
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}