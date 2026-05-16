// lib/app/routes/app_routes.dart
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';

abstract class AppRoutes {
  AppRoutes._();

  static const String splash = RouteConstants.splash;
  static const String login = RouteConstants.login;
  static const String register = RouteConstants.register;
  static const String logout = RouteConstants.logout;
  static const String home = RouteConstants.home;
  static const String dashboard = RouteConstants.dashboard;
  static const String carrierDashboard = RouteConstants.carrierDashboard;
  static const String createShipment = RouteConstants.createShipment;
  static const String selectRole = RouteConstants.selectRole;
}
