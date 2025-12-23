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

    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            if (leading != null) leading!,
            Expanded(
              child: Center(
                child: showLogo
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // const SimIcon(),
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
              ),
            ),
            if (actions != null) 
              Row(children: actions!.take(3).toList()),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // Hauteur totale = statusBar + toolbar + padding vertical
    // On utilise une hauteur fixe approximative pour la statusBar (24-48px typique)
    // Le MediaQuery sera disponible au moment du build
    return const Size.fromHeight(kToolbarHeight + 16.0 + 30.0);
  }
}