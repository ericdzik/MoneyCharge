import 'package:flutter/material.dart';

import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/constants/app_colors.dart';

/// Shared shell for auth screens (no AppBar) that keeps a consistent
/// background, SafeArea, scrolling, and card layout.
class AuthShell extends StatelessWidget {
  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.card,
    this.bottom,
    this.secondary,
    this.accentGradient,
    this.heroBackground,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget card;
  final Widget? bottom;
  final Widget? secondary;
  final List<Color>? accentGradient;
  final String? heroBackground;

  @override
  Widget build(BuildContext context) {
    final gradientColors = accentGradient ?? const [
      Color.fromRGBO(0, 91, 55, 0.78),
      Color.fromRGBO(0, 91, 55, 0.74),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              heroBackground ?? 'assets/splash/25.png',
              fit: BoxFit.cover,
              cacheWidth: 1080,
              cacheHeight: 1920,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
            ),
          ),
          Positioned(
            left: -60,
            top: -40,
            child: _glowCircle(140, AppColors.white.withOpacity(0.08)),
          ),
          Positioned(
            right: -40,
            top: 120,
            child: _glowCircle(100, AppColors.yellow.withOpacity(0.10)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingM,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Center(child: _HeroIcon(icon: icon)),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.white.withOpacity(0.92),
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  card,
                  if (bottom != null) ...[
                    const SizedBox(height: 20),
                    bottom!,
                  ],
                  if (secondary != null) ...[
                    const SizedBox(height: 12),
                    secondary!,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color, blurRadius: 30, spreadRadius: 10),
        ],
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 40,
        color: AppColors.primary,
      ),
    );
  }
}
