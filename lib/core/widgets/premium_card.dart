import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Premium Card Widget with soft shadows and modern design
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const PremiumCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding ??
          const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.cardWhite) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusLarge,
        ),
        boxShadow: boxShadow ?? AppTheme.softShadow,
        border: border,
      ),
      child: child,
    );

    if (onTap != null) {
      return Padding(
        padding: margin ??
            const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing8,
            ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(
              borderRadius ?? AppTheme.radiusLarge,
            ),
            child: content,
          ),
        ),
      );
    }

    return Padding(
      padding: margin ??
          const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
      child: content,
    );
  }
}

/// Statistic Card for Dashboard
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      gradient: LinearGradient(
        colors: [
          color.withAlpha((0.1 * 255).round()),
          color.withAlpha((0.05 * 255).round()),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.darkGray,
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.spacing4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.darkGray,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppTheme.spacing8),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightGray,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Gradient Card with overlay
class GradientCard extends StatelessWidget {
  final Widget child;
  final Gradient gradient;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GradientCard({
    Key? key,
    required this.child,
    required this.gradient,
    this.padding,
    this.margin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      gradient: gradient,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: child,
    );
  }
}
