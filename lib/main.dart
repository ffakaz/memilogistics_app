import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core - Using barrel export
import 'package:memilogistics_app/core/core.dart';

// Auth Feature
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
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/register_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/logout_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API configuration for fake API during development
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
          // Get core dependencies
          final apiClient = context.read<ApiClient>();
          final secureStorage = context.read<FlutterSecureStorage>();

          // Create auth dependencies
          final authApiService = FakeAuthApiServiceAdapter(apiClient: apiClient);
          final tokenStorage = TokenStorage(storage: secureStorage);
          final authRepository = AuthRepositoryImpl(
            apiService: authApiService,
            tokenStorage: tokenStorage,
          );

          // Create use cases
          final loginUseCase = LoginUseCase(authRepository);
          final registerUseCase = RegisterUseCase(authRepository);
          final logoutUseCase = LogoutUseCase(authRepository);
          final isLoggedInUseCase = IsLoggedInUseCase(authRepository);
          final getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

          return ChangeNotifierProvider(
            create: (_) => AuthProvider(
              loginUseCase: loginUseCase,
              registerUseCase: registerUseCase,
              logoutUseCase: logoutUseCase,
              isLoggedInUseCase: isLoggedInUseCase,
              getCurrentTokenUseCase: getCurrentTokenUseCase,
            )..init(),
            child: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                if (!auth.initialized) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false,
                    home: const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Memi Logistics',
                  theme: AppTheme.lightTheme,
                  darkTheme: AppTheme.darkTheme,
                  home: auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
                  routes: {
                    '/login': (_) => const LoginScreen(),
                    '/register': (_) => const RegisterScreen(),
                    '/logout': (_) => const LogoutScreen(),
                    '/home': (_) => const HomeScreen(),
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
