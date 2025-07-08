import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart'; // Assurer l'import si Text Styles sont utilisés directement ici

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    // Le style du titre sera hérité de AppBarTheme.titleTextStyle
    return AppBar(
      backgroundColor: AppColors.primary, // Utilisation directe de la couleur primaire
      elevation: 0,
      leading: leading,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            const SimIcon(),
            const SizedBox(width: AppDimensions.paddingS),
          ],
          Text(title), // Le style est appliqué par AppBarTheme
        ],
      ),
      actions: actions,
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
