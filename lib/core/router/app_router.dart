// lib/core/router/app_router.dart
//
// Centralised router.
// Reads [RouteConstants] (your existing route_constants.dart) for route names.
// Features register their screens via [AppRouter.registerRoutes] in their
// own DI modules — this file never imports feature code directly.

import 'package:flutter/material.dart';
import 'package:memilogistics_app/core/secure_storage/secure_storage_service.dart';
import 'package:memilogistics_app/core/utils/constants/route_constants.dart';

class AppRouter {
  AppRouter({required SecureStorageService storageService})
      : _storage = storageService;

  final SecureStorageService _storage;

  /// Shared navigator key. Pass to [MaterialApp.navigatorKey].
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root_navigator');

  /// Feature route registry: routeName → page builder.
  /// Features call [AppRouter.registerRoutes] in their DI modules.
  /// The builder function receives the route arguments (if any).
  static final Map<String, Widget Function(dynamic args)> _registry = {};

  static void registerRoutes(Map<String, Widget Function(dynamic args)> routes) =>
      _registry.addAll(routes);

  // ── onGenerateRoute ───────────────────────────────────────────────────────

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? RouteConstants.splash;

    final builder = _registry[name];
    if (builder != null) {
      return _pageWithArgs(settings, builder);
    }

    switch (name) {
      case RouteConstants.splash:
        return _page(settings, (_) => _SplashGate(router: this));
      default:
        return _page(settings, (_) => const _NotFoundPage());
    }
  }

  static MaterialPageRoute<dynamic> _page(
    RouteSettings s,
    WidgetBuilder b,
  ) =>
      MaterialPageRoute(settings: s, builder: b);

  static MaterialPageRoute<dynamic> _pageWithArgs(
    RouteSettings s,
    Widget Function(dynamic args) b,
  ) =>
      MaterialPageRoute(settings: s, builder: (_) => b(s.arguments));

  // ── Auth guard ────────────────────────────────────────────────────────────

  /// Determine first route after the splash gate.
  Future<String> resolveInitialRoute() async {
    final ok = await _storage.hasValidSession();
    return ok ? RouteConstants.home : RouteConstants.login;
  }

  /// Called by [AuthDioInterceptor] when the refresh cycle fails.
  Future<void> handleSessionExpired() async {
    await _storage.clearAuthData();
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      RouteConstants.login,
      (_) => false,
      arguments: {'reason': 'session_expired'},
    );
  }

  // ── Convenience helpers ───────────────────────────────────────────────────

  Future<T?> push<T>(String route, {Object? args}) =>
      navigatorKey.currentState!
          .pushNamed<T>(route, arguments: args);

  Future<T?> replace<T>(String route, {Object? args}) =>
      navigatorKey.currentState!
          .pushReplacementNamed<T, void>(route, arguments: args);

  void popToRoot() => navigatorKey.currentState
      ?.pushNamedAndRemoveUntil(RouteConstants.home, (_) => false);

  void pop<T>([T? result]) => navigatorKey.currentState?.pop(result);
}

// ── Splash gate (auth redirect) ───────────────────────────────────────────

class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.router});
  final AppRouter router;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final route = await widget.router.resolveInitialRoute();
    if (mounted) Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text('404 — Page not found.')),
      );
}