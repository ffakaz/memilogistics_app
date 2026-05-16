import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

// Core
import 'package:memilogistics_app/core/core.dart';

// Auth — data layer
import 'package:memilogistics_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:memilogistics_app/features/auth/data/services/fake_auth_api_service_adapter.dart';
import 'package:memilogistics_app/features/auth/data/storage/token_storage.dart';

// Auth — use cases
import 'package:memilogistics_app/features/auth/domain/usecases/get_current_token_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/register_usecase.dart';

// Auth — presentation
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';

// Shipment & User features
// Shipment & User features (not wired yet)

class InjectionContainer extends StatelessWidget {
  const InjectionContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ── Core ──────────────────────────────────────────────────────────────
    final apiClient      = context.read<ApiClient>();
    final secureStorage  = context.read<FlutterSecureStorage>();

    // ── Auth — data layer ─────────────────────────────────────────────────
    final authApiService = FakeAuthApiServiceAdapter(apiClient: apiClient);
    final tokenStorage   = TokenStorage(storage: secureStorage);
    final authRepository = AuthRepositoryImpl(
      apiService:   authApiService,
      tokenStorage: tokenStorage,
    );

    // ── Auth — use cases ──────────────────────────────────────────────────
    final loginUseCase           = LoginUseCase(authRepository);
    final registerUseCase        = RegisterUseCase(authRepository);
    final logoutUseCase          = LogoutUseCase(authRepository);
    final isLoggedInUseCase      = IsLoggedInUseCase(authRepository);
    final getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

    // ── Shipment dependencies ─────────────────────────────────────────────
    // TODO: wire ShipmentRepository, ShipmentUseCases

    // ── User dependencies ─────────────────────────────────────────────────
    // TODO: wire UserRepository, UserUseCases

    // ── Provider tree ─────────────────────────────────────────────────────
    return MultiProvider(
      providers: [
        // Auth provider carries all auth use cases
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            loginUseCase:           loginUseCase,
            registerUseCase:        registerUseCase,
            logoutUseCase:          logoutUseCase,
            isLoggedInUseCase:      isLoggedInUseCase,
            getCurrentTokenUseCase: getCurrentTokenUseCase,
          ),
        ),

        // Shipment provider
        // ChangeNotifierProvider<ShipmentProvider>(
        //   create: (_) => ShipmentProvider(...),
        // ),

        // User provider
        // ChangeNotifierProvider<UserProvider>(
        //   create: (_) => UserProvider(...),
        // ),
      ],
      child: child,
    );
  }
}