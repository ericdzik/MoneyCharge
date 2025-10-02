import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;
  final double borderRadius;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = true,
    this.bottom,
    this.backgroundColor,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.appBarTheme.titleTextStyle?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ) ??
        const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        );

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(borderRadius),
        bottomRight: Radius.circular(borderRadius),
      ),
      child: AppBar(
        backgroundColor: backgroundColor ?? AppColors.primary,
        elevation: 0,
        leading: leading,
        centerTitle: true,
        title: showLogo
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SimIcon(),
                  const SizedBox(width: AppDimensions.paddingS),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: titleStyle,
                    ),
                  ),
                ],
              )
            : Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
        actions: actions?.take(3).toList(),
        bottom: bottom,
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
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 3, right: 3),
          child: Container(
            width: 8,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
      ),
    );
  }
}