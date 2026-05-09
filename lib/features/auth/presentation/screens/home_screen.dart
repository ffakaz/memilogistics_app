import 'package:flutter/material.dart';

/// Home and related placeholder screens are kept as tiny redirectors so other
/// modules that import these files do not break. They immediately route to
/// the shipment dashboard while the multi-tab Home flow is disabled.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class LoadBoardScreen extends StatelessWidget {
  const LoadBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted(context)) Navigator.pushReplacementNamed(context, '/dashboard');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  bool mounted(BuildContext ctx) {
    // helper to avoid referencing global mounted in stateless widget
    return ModalRoute.of(ctx) != null;
  }
}

class FleetScreen extends StatelessWidget {
  const FleetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context) != null) Navigator.pushReplacementNamed(context, '/dashboard');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ModalRoute.of(context) != null) Navigator.pushReplacementNamed(context, '/dashboard');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
