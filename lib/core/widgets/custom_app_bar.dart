import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

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
    return Container(
      // Utiliser AppColors.primary directement ou un dégradé cohérent
      // Pour cet exemple, utilisons AppColors.primary directement pour simplifier
      // Si un dégradé est souhaité, assurez-vous que les deux couleurs proviennent d'AppColors
      // ou sont dérivées de manière thématique.
      // Par exemple: [AppColors.primary, Color.lerp(AppColors.primary, Colors.black, 0.2)!]
      color: AppColors.primary,
      child: AppBar(
        backgroundColor: AppColors.primary, // Assurez-vous que c'est la même couleur ou transparent si le Container gère la couleur
        elevation: 0,
        leading: leading,
        title: Row(
          children: [
            if (showLogo) ...[
              const SimIcon(),
              const SizedBox(width: AppDimensions.paddingS),
            ],
            Text(title),
          ],
        ),
        actions: actions,
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
      child: Stack(
        children: [
          Positioned(
            top: 3,
            right: 3,
            child: Container(
              width: 8,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
