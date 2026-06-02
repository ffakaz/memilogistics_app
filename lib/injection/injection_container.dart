import 'package:flutter/material.dart';
// flutter_secure_storage intentionally not used here; use SecureStorageService from core
import 'package:provider/provider.dart';

// Core
import 'package:memilogistics_app/core/core.dart';

// Auth — data layer
import 'package:memilogistics_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:memilogistics_app/features/auth/data/services/auth_api_service_real.dart';
import 'package:memilogistics_app/features/auth/data/storage/token_storage.dart';

// Auth — use cases
import 'package:memilogistics_app/features/auth/domain/usecases/get_current_token_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/register_usecase.dart';

// Auth — presentation
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';

// ShipmentOffer — data layer
import 'package:memilogistics_app/features/shipment_offer/data/services/shipment_offer_api_service.dart';

// ShipmentOffer — presentation
import 'package:memilogistics_app/features/shipment_offer/presentation/providers/shipment_offer_provider.dart';

// Payment — data layer
import 'package:memilogistics_app/features/payment/data/services/payment_api_service.dart';
import 'package:memilogistics_app/features/payment/data/repositories/payment_repository_impl.dart';

// Payment — presentation
import 'package:memilogistics_app/features/payment/presentation/providers/payment_provider.dart';

// Shipment — data layer
import 'package:memilogistics_app/features/shipment/data/services/shipment_api_service_real.dart';
import 'package:memilogistics_app/features/shipment/data/repositories/shipment_repository_impl.dart';
import 'package:memilogistics_app/features/shipment/domain/usecases/get_dashboard_information.dart';

// Shipment — presentation
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';

// User — data layer
import 'package:memilogistics_app/features/user/data/services/user_api_service.dart';
import 'package:memilogistics_app/features/user/data/repositories/user_repository_impl.dart';

// User — use cases
import 'package:memilogistics_app/features/user/domain/usecases/get_current_user_usecase.dart';
import 'package:memilogistics_app/features/user/domain/usecases/update_profile_usecase.dart';
import 'package:memilogistics_app/features/user/domain/usecases/get_permissions_usecase.dart';

// User — presentation
import 'package:memilogistics_app/features/user/presentation/providers/user_provider.dart';

class InjectionContainer extends StatelessWidget {
  const InjectionContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // ── Core ──────────────────────────────────────────────────────────────
    final apiClient = context.read<ApiClient>();
    final secureStorage = context.read<SecureStorageService>();

    // ── Auth — data layer ─────────────────────────────────────────────────
    final authApiService = AuthApiServiceReal(apiClient);
    final tokenStorage = TokenStorage(storage: secureStorage);
    final authRepository = AuthRepositoryImpl(
      apiService: authApiService,
      tokenStorage: tokenStorage,
    );

    // ── Auth — use cases ──────────────────────────────────────────────────
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final isLoggedInUseCase = IsLoggedInUseCase(authRepository);
    final getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

    // ── Shipment dependencies ─────────────────────────────────────────────
    final shipmentApiService = ShipmentApiServiceReal(apiClient);
    final shipmentRepository = ShipmentRepositoryImpl(
      apiService: shipmentApiService,
      tokenStorage: tokenStorage,
    );
    final getDashboardInformationUseCase = GetDashboardInformation(
      shipmentRepository,
    );

    // ── ShipmentOffer dependencies ────────────────────────────────────────
    final shipmentOfferApiService = ShipmentOfferApiService(apiClient);

    // ── Payment dependencies ──────────────────────────────────────────────
    final paymentApiService = PaymentApiService(apiClient);
    final paymentRepository = PaymentRepositoryImpl(paymentApiService);

    // ── User dependencies ─────────────────────────────────────────────────
    final userApiService = UserApiService(apiClient: apiClient);
    final userRepository = UserRepositoryImpl(apiService: userApiService);
    final getCurrentUserUseCase = GetCurrentUserUseCase(userRepository);
    final updateProfileUseCase = UpdateProfileUseCase(userRepository);
    final getPermissionsUseCase = GetPermissionsUseCase(userRepository);

    // ── Provider tree ─────────────────────────────────────────────────────
    return MultiProvider(
      providers: [
        // Auth provider carries all auth use cases
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            isLoggedInUseCase: isLoggedInUseCase,
            getCurrentTokenUseCase: getCurrentTokenUseCase,
          ),
        ),

        // ShipmentOffer provider
        ChangeNotifierProvider<ShipmentOfferProvider>(
          create: (_) => ShipmentOfferProvider(shipmentOfferApiService, tokenStorage),
        ),

        // Payment provider
        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(paymentRepository),
        ),

        // Shipment provider
        ChangeNotifierProvider<ShipmentProvider>(
          create: (_) => ShipmentProvider(
            repository: shipmentRepository,
            getDashboardInformationUseCase: getDashboardInformationUseCase,
          ),
        ),

        // User provider
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            getCurrentUserUseCase: getCurrentUserUseCase,
            updateProfileUseCase: updateProfileUseCase,
            getPermissionsUseCase: getPermissionsUseCase,
          ),
        ),
      ],
      child: child,
    );
  }
}
