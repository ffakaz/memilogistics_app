// lib/core/di/service_locator.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:memilogistics_app/core/network/api_client.dart';
import 'package:memilogistics_app/core/network/api_client_factory.dart';
import 'package:memilogistics_app/core/router/app_router.dart';
import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';
import 'package:memilogistics_app/features/auth/data/services/auth_api_service_real.dart';
import 'package:memilogistics_app/features/auth/data/storage/token_storage.dart';
import 'package:memilogistics_app/features/auth/data/repository/auth_repository_impl.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'package:memilogistics_app/features/auth/domain/usecases/get_current_token_usecase.dart';
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/logout_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/register_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/forgot_password_screen.dart';

import 'package:memilogistics_app/features/carrier/data/datasources/carrier_company_remote_datasource_impl.dart';
import 'package:memilogistics_app/features/carrier/data/repositories/carrier_company_repository_impl.dart';
import 'package:memilogistics_app/features/carrier/domain/usecases/create_carrier_company.dart';
import 'package:memilogistics_app/features/carrier/domain/usecases/get_carrier_company.dart';
import 'package:memilogistics_app/features/carrier/domain/usecases/update_carrier_company.dart';
import 'package:memilogistics_app/features/carrier/presentation/providers/carrier_company_provider.dart';
import 'package:memilogistics_app/features/carrier/presentation/screens/carrier_dashboard_improved.dart';

import 'package:memilogistics_app/features/shipment/data/services/shipment_api_service_real.dart';
import 'package:memilogistics_app/features/shipment/data/repositories/shipment_repository_impl.dart';
import 'package:memilogistics_app/features/shipment/presentation/screens/create_shipment_screen.dart';
import 'package:memilogistics_app/features/shipment/presentation/screens/shipment_dashboard_screen.dart';
import 'package:memilogistics_app/features/shipment/presentation/screens/my_shipments_screen.dart';
import 'package:memilogistics_app/features/shipment/presentation/screens/shipment_details_screen.dart';
import 'package:memilogistics_app/features/shipment/presentation/providers/shipment_provider.dart';

import 'package:memilogistics_app/features/payment/presentation/screens/payment_screen.dart';

import 'package:memilogistics_app/features/user/data/services/user_api_service.dart';
import 'package:memilogistics_app/features/user/data/repositories/user_repository_impl.dart';
import 'package:memilogistics_app/features/user/domain/usecases/get_current_user_usecase.dart';
import 'package:memilogistics_app/features/user/domain/usecases/update_profile_usecase.dart';
import 'package:memilogistics_app/features/user/domain/usecases/get_permissions_usecase.dart';
import 'package:memilogistics_app/features/user/presentation/providers/user_provider.dart';

import 'package:memilogistics_app/features/shipment_offer/data/services/shipment_offer_api_service.dart';
import 'package:memilogistics_app/features/shipment_offer/presentation/providers/shipment_offer_provider.dart';

import 'package:memilogistics_app/features/payment/data/services/payment_api_service.dart';
import 'package:memilogistics_app/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:memilogistics_app/features/payment/presentation/providers/payment_provider.dart';
// import 'package:memilogistics_app/features/user/presentation/screens/role_selection_screen.dart'; // REMOVED: Role selection now in registration

/// Very small service locator used by parts of the app. It intentionally
/// avoids adding an external dependency and provides only the features the
/// app uses: registering singletons and factories and retrieving them.
class _ServiceLocator {
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _factories = {};

  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }

  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }

  T get<T>() {
    if (_singletons.containsKey(T)) return _singletons[T] as T;
    final factory = _factories[T];
    if (factory != null) return factory() as T;
    throw StateError('Service of type $T is not registered in the locator');
  }
}

final _sl = _ServiceLocator();

/// Public accessor used across the app: `locator<MyType>()`.
T locator<T>() => _sl.get<T>();

/// Setup function that registers core services used by the app. This mirrors
/// the wiring that previously appeared in `main.dart` but keeps it in one
/// place so other modules can rely on the locator.
Future<void> setupLocator() async {
  // Secure storage
  final flutterSecureStorage = const FlutterSecureStorage();
  _sl.registerSingleton<FlutterSecureStorage>(flutterSecureStorage);

  final secureStorageService = SecureStorageService(
    storage: flutterSecureStorage,
  );
  _sl.registerSingleton<SecureStorageService>(secureStorageService);

  // Router
  final appRouter = AppRouter(storageService: secureStorageService);
  _sl.registerSingleton<AppRouter>(appRouter);
  AppRouter.registerRoutes({
    RouteConstants.login: (_) => const LoginScreen(),
    RouteConstants.register: (_) => const RegisterScreen(),
    RouteConstants.forgotPassword: (_) => const ForgotPasswordScreen(),
    RouteConstants.logout: (_) => const LogoutScreen(),
    RouteConstants.home: (_) => const HomeScreen(),
    RouteConstants.dashboard: (_) => const ShipmentDashboardScreen(),
    RouteConstants.carrierDashboard: (_) => const CarrierDashboardImproved(),
    RouteConstants.createShipment: (_) => const CreateShipmentScreen(),
    RouteConstants.myShipments: (_) => const MyShipmentsScreen(), // ADDED
    RouteConstants.shipmentDetails: (args) {
      final shipmentId = args as int;
      return ShipmentDetailsScreen(shipmentId: shipmentId);
    },
    RouteConstants.payment: (args) {
      final params = args as Map<String, dynamic>;
      return PaymentScreen(
        shipmentId: params['shipmentId'] as int,
        amount: params['amount'] as double,
        currency: params['currency'] as String? ?? 'USD',
      );
    },
    // RouteConstants.selectRole: (_) => const RoleSelectionScreen(), // REMOVED: Role now selected during registration
  });

  // API client
  final apiClient = ApiClientFactory.create(
    storageService: secureStorageService,
    onSessionExpired: () => appRouter.handleSessionExpired(),
  );
  _sl.registerSingleton<ApiClient>(apiClient);

  // AUTH wiring
  final authApiService = AuthApiServiceReal(apiClient);
  final tokenStorage = TokenStorage(storage: flutterSecureStorage);
  final authRepository = AuthRepositoryImpl(
    apiService: authApiService,
    tokenStorage: tokenStorage,
  );

  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final isLoggedInUseCase = IsLoggedInUseCase(authRepository);
  final getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

  final authProvider = AuthProvider(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    isLoggedInUseCase: isLoggedInUseCase,
    getCurrentTokenUseCase: getCurrentTokenUseCase,
  );
  _sl.registerSingleton<AuthProvider>(authProvider);

  // Shipment wiring
  final shipmentApiService = ShipmentApiServiceReal(apiClient);
  final shipmentRepository = ShipmentRepositoryImpl(
    apiService: shipmentApiService,
    tokenStorage: tokenStorage,
  );
  final shipmentProvider = ShipmentProvider(repository: shipmentRepository);
  _sl.registerSingleton<ShipmentProvider>(shipmentProvider);

  // User wiring
  final userApiService = UserApiService(apiClient: apiClient);
  final userRepository = UserRepositoryImpl(apiService: userApiService);
  final getCurrentUserUseCase = GetCurrentUserUseCase(userRepository);
  final updateProfileUseCase = UpdateProfileUseCase(userRepository);
  final getPermissionsUseCase = GetPermissionsUseCase(userRepository);

  final userProvider = UserProvider(
    getCurrentUserUseCase: getCurrentUserUseCase,
    updateProfileUseCase: updateProfileUseCase,
    getPermissionsUseCase: getPermissionsUseCase,
  );
  _sl.registerSingleton<UserProvider>(userProvider);

  // Carrier wiring
  final carrierRemoteDataSource = CarrierCompanyRemoteDataSourceImpl(apiClient: apiClient);
  final carrierRepository = CarrierCompanyRepositoryImpl(carrierRemoteDataSource);
  final createCarrierCompanyUseCase = CreateCarrierCompany(carrierRepository);
  final getCarrierCompanyUseCase = GetCarrierCompany(carrierRepository);
  final updateCarrierCompanyUseCase = UpdateCarrierCompany(carrierRepository);

  final carrierProvider = CarrierCompanyProvider(
    createCarrierCompanyUseCase: createCarrierCompanyUseCase,
    getCarrierCompanyUseCase: getCarrierCompanyUseCase,
    updateCarrierCompanyUseCase: updateCarrierCompanyUseCase,
  );
  _sl.registerSingleton<CarrierCompanyProvider>(carrierProvider);

  // ShipmentOffer wiring
  final shipmentOfferApiService = ShipmentOfferApiService(apiClient);
  final shipmentOfferProvider = ShipmentOfferProvider(shipmentOfferApiService);
  _sl.registerSingleton<ShipmentOfferProvider>(shipmentOfferProvider);

  // Payment wiring
  final paymentApiService = PaymentApiService(apiClient);
  final paymentRepository = PaymentRepositoryImpl(paymentApiService);
  final paymentProvider = PaymentProvider(paymentRepository);
  _sl.registerSingleton<PaymentProvider>(paymentProvider);
}
