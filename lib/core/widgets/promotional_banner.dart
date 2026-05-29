import 'package:flutter/material.dart';
import 'package:memilogistics_app/core/theme/app_theme.dart';

/// Premium promotional banner for Memi Logistics
/// Displays during registration/login with animated content
class PromotionalBanner extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const PromotionalBanner({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<PromotionalBanner> createState() => _PromotionalBannerState();
}

class _PromotionalBannerState extends State<PromotionalBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
      // Shorter, snappy entrance animations
      _controller = AnimationController(
        duration: const Duration(milliseconds: 900),
        vsync: this,
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
      );

      _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
      );

      _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.15, 0.85, curve: Curves.easeOut)),
      );

    _controller.forward();

    // Auto-dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A2463), // Navy Blue
            const Color(0xFF1E3A5F),
            const Color(0xFF2C5282),
            const Color(0xFFFF6B35).withAlpha(51), // Orange accent
          ],
          stops: const [0.0, 0.4, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          _buildBackgroundPattern(),

          // Main content with scroll
          SafeArea(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // Logo and brand
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: _buildLogo(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Main illustration
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildIllustration(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Taglines
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildTaglines(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Features
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildFeatures(),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Decorative elements
          _buildDecorativeElements(),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _LogisticsPatternPainter(),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        // Logo icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B35), // Orange
                Color(0xFFFF8C42),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withAlpha(102),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.local_shipping_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        // Brand name
        Text(
          'MEMI LOGISTICS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            inherit: true,
          ),
        ),
      ],
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
          borderRadius: BorderRadius.circular(AppTheme.radiusXXLarge),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIllustrationItem(
            Icons.warehouse_rounded,
            'Warehouse',
          ),
          _buildRouteArrow(),
          _buildIllustrationItem(
            Icons.local_shipping_rounded,
            'Transport',
          ),
          _buildRouteArrow(),
          _buildIllustrationItem(
            Icons.location_on_rounded,
            'Delivery',
          ),
        ],
      ),
    );
  }

  Widget _buildIllustrationItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6B35),
                Color(0xFFFF8C42),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withAlpha(77),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(204),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteArrow() {
    return Icon(
      Icons.arrow_forward_rounded,
      color: Colors.white.withAlpha(128),
      size: 24,
    );
  }

  Widget _buildTaglines() {
    return Column(
      children: [
        // Main tagline
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF6B35).withAlpha(51),
                const Color(0xFFFF6B35).withAlpha(26),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: const Color(0xFFFF6B35).withAlpha(77),
              width: 1,
            ),
          ),
          child: Text(
            'Fast. Secure. Intelligent Logistics.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
              inherit: true,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        // Secondary tagline
        Text(
          'Connecting Shippers and Carriers Seamlessly.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withAlpha(230),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildFeatureChip(Icons.speed_rounded, 'Fast'),
        _buildFeatureChip(Icons.security_rounded, 'Secure'),
        _buildFeatureChip(Icons.track_changes_rounded, 'Track'),
        _buildFeatureChip(Icons.verified_rounded, 'Trusted'),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF6B35),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              inherit: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return Stack(
      children: [
        // Top-right glow
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF6B35).withAlpha(77),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Bottom-left glow
        Positioned(
          bottom: -50,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0A2463).withAlpha(128),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Custom painter for logistics pattern background
class _LogisticsPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(13)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid pattern
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw route lines
    final routePaint = Paint()
      ..color = const Color(0xFFFF6B35).withAlpha(51)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.6,
        size.width * 0.9,
        size.height * 0.5,
      );

    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
