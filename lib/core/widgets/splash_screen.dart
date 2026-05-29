import 'package:flutter/material.dart';
import 'promotional_banner.dart';

/// Splash screen with promotional banner
/// Shows for 2-3 seconds during app initialization
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PromotionalBanner(
        duration: widget.duration,
        onComplete: widget.onComplete,
      ),
    );
  }
}
