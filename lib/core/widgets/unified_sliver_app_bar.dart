import 'package:flutter/material.dart';

import 'package:locacharge/core/common.dart';

class UnifiedSliverAppBar extends StatelessWidget {
  final double opacity;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool showMenu;
  final List<Widget>? actions;

  const UnifiedSliverAppBar({
    super.key,
    required this.opacity,
    required this.title,
    this.subtitle,
    this.icon = Icons.layers_rounded,
    this.color = AppColors.primary,
    this.showMenu = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      elevation: opacity > 0.5 ? 4 : 0,
      backgroundColor: Colors.white.withOpacity(opacity),
      leading: showMenu
          ? Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1 + opacity * 0.9),
                shape: BoxShape.circle,
              ),
              child: Builder(
                builder: (ctx) => IconButton(
                  icon: Icon(
                    Icons.menu_rounded,
                    color: opacity > 0.5 ? color : Colors.white,
                  ),
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              ),
            )
          : null,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 72, bottom: 16),
        title: Opacity(
          opacity: opacity,
          child: Text(
            title,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.85),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.white.withOpacity(0.9)),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingM,
                      vertical: AppDimensions.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
