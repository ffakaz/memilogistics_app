import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../../../auth/presentation/provider/auth_provider.dart';
import '../../../../core/utils/constants/route_constants.dart';
import '../../domain/enums/app_role.dart';

/// DEPRECATED: This screen is no longer used in the current navigation flow.
/// 
/// Role-based routing is now handled by AppGuard in app_guard.dart, which:
/// - Checks authentication status
/// - Loads user profile from backend
/// - Routes to appropriate dashboard based on user role
/// 
/// This file is kept for reference or potential future use, but is not
/// part of the active navigation flow.
/// 
/// If you need role-based routing, use AppGuard.resolveHome() instead.
class RoleDecider extends StatefulWidget {
  const RoleDecider({super.key});

  @override
  State<RoleDecider> createState() => _RoleDeciderState();
}

class _RoleDeciderState extends State<RoleDecider> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    if (!mounted) return;

    // Get providers
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();

    // Check authentication
    if (!authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(RouteConstants.login);
      return;
    }

    // Load user profile if not already loaded
    if (!userProvider.hasUser) {
      await userProvider.loadCurrentUser();
    }

    if (!mounted) return;

    final user = userProvider.currentUser;
    if (user == null) {
      // If user loading failed, go to login
      Navigator.of(context).pushReplacementNamed(RouteConstants.login);
      return;
    }

    // Route based on user role
    switch (user.profile.role) {
      case AppRole.carrier:
        Navigator.of(context).pushReplacementNamed(RouteConstants.carrierDashboard);
        break;
      case AppRole.shipper:
        Navigator.of(context).pushReplacementNamed(RouteConstants.dashboard);
        break;
      case AppRole.admin:
        Navigator.of(context).pushReplacementNamed(RouteConstants.dashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}
