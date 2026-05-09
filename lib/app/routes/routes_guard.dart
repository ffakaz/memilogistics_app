// lib/app/routes/routes_guard.dart
import 'package:memilogistics_app/features/auth/presentation/provider/auth_provider.dart';

class RoutesGuard {
  /// Simple guard that checks whether the user is authenticated.
  static bool canActivate(String route, AuthProvider auth) {
    // If route is login/register/public allow
    if (route == '/login' || route == '/register' || route == '/') return true;

    // Require authentication for everything else
    return auth.isLoggedIn;
  }
}
