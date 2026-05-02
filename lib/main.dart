import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 🔹 Data Layer
import 'features/auth/data/services/fake_auth_api_services.dart';
import 'features/auth/data/storage/token_storage.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';

// 🔹 Domain UseCases
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/is_logged_in_usecase.dart';
import 'features/auth/domain/usecases/get_current_token_usecase.dart';
// 🔹 Presentation
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/login_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/logout_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/home_screen.dart';
import 'package:memilogistics_app/features/auth/presentation/screens/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Map<String, WidgetBuilder> _routes = {
  '/login': (_) => LoginScreen(),
  '/register': (_) => RegisterScreen(), // 🔥 ADD THIS
  '/logout': (_) => LogoutScreen(),
  '/home': (_) => HomeScreen(),
};

  @override
  Widget build(BuildContext context) {
    /// 🔧 Core Dependencies
    final client = http.Client();
    final secureStorage = FlutterSecureStorage();

    /// 📡 Services
    final apiService = FakeAuthApiService(
      baseUrl: 'fake', // Using fake API
      client: client,
    );

    final tokenStorage = TokenStorage(storage: secureStorage);

    /// 📦 Repository
    final authRepository = AuthRepositoryImpl(
      apiService: apiService,
      tokenStorage: tokenStorage,
    );

    /// ⚙️ UseCases
    final loginUseCase = LoginUseCase(authRepository);
    final registerUseCase = RegisterUseCase(authRepository);
    final logoutUseCase = LogoutUseCase(authRepository);
    final isLoggedInUseCase = IsLoggedInUseCase(authRepository);
    final getCurrentTokenUseCase = GetCurrentTokenUseCase(authRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            isLoggedInUseCase: isLoggedInUseCase,
            getCurrentTokenUseCase: getCurrentTokenUseCase,
          )..init(), // 🔥 initialize auth state
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth App',
        theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),

        /// 🔐 Auth entry point decides whether to show login or home
        home: const AuthGate(),

        /// 🔀 Routes
        routes: _routes,
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.initialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}
