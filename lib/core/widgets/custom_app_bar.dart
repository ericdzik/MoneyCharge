import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
// import '../constants/app_text_styles.dart'; // Pas nécessaire si le style est hérité du thème
import 'dart:ui';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = true,
    this.bottom,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Si une couleur de fond solide est fournie, utiliser une AppBar simple (sans blur/clip)
    if (backgroundColor != null) {
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: leading,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLogo) ...[
              const SimIcon(),
              const SizedBox(width: AppDimensions.paddingS),
            ],
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ) ??
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
            ),
          ],
        ),
        actions: actions?.take(3).toList(),
        bottom: bottom,
      );
    }

    // Sinon, utiliser la version glassmorphism existante
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AppBar(
          backgroundColor: Colors.white.withOpacity(0.15),
          elevation: 0,
          leading: leading,
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLogo) ...[
                const SimIcon(),
                const SizedBox(width: AppDimensions.paddingS),
              ],
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ) ??
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
              ),
            ],
          ),
          actions: actions?.take(3).toList(),
          shape: const Border(
            bottom: BorderSide(color: Color(0x33FFFFFF), width: 1),
          ),
          bottom: bottom,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.appBarHeight);
}

class SimIcon extends StatelessWidget {
  const SimIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 18,
      decoration: BoxDecoration(
        color: AppColors.secondary, // Orange
        borderRadius: BorderRadius.circular(3),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 3,
            right: 3,
            child: Container(
              width: 8,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary, // Vert
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
