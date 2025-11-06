import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';
import '../utils/responsive_utils.dart';

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final Border? border;
  final double? minHeight;
  final double? maxWidth;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
    this.border,
    this.minHeight,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer le padding adaptatif
    EdgeInsetsGeometry adaptivePadding =
        padding ??
        EdgeInsets.all(
          ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.paddingM
              : AppDimensions.paddingL,
        );

    // Déterminer la marge adaptative
    EdgeInsetsGeometry adaptiveMargin =
        margin ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.paddingS
              : AppDimensions.paddingM,
          vertical: ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.paddingXS
              : AppDimensions.paddingS,
        );

    // Déterminer le rayon de bordure adaptatif
    BorderRadius adaptiveBorderRadius =
        borderRadius ??
        BorderRadius.circular(
          ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.radiusS
              : AppDimensions.radiusM,
        );

    // Déterminer l'ombre adaptative
    BoxShadow adaptiveShadow =
        shadow ??
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: ResponsiveUtils.isSmallScreen(context) ? 6 : 10,
          offset: Offset(0, ResponsiveUtils.isSmallScreen(context) ? 2 : 4),
        );

    // Déterminer la largeur maximale adaptative
    double? adaptiveMaxWidth =
        maxWidth ?? ResponsiveUtils.adaptiveMaxWidth(context);

    return Container(
      margin: adaptiveMargin,
      constraints: BoxConstraints(
        minHeight: minHeight ?? ResponsiveUtils.adaptiveCardHeight(context),
        maxWidth: adaptiveMaxWidth,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: adaptiveBorderRadius,
        boxShadow: [adaptiveShadow],
        border: border,
      ),
      child: Padding(padding: adaptivePadding, child: child),
    );
  }
}

// Widget spécialisé pour les cartes de contenu avec scroll
class ResponsiveScrollCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final BoxShadow? shadow;
  final Border? border;
  final double? maxHeight;
  final double? maxWidth;

  const ResponsiveScrollCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.borderRadius,
    this.shadow,
    this.border,
    this.maxHeight,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    // Déterminer le padding adaptatif
    EdgeInsetsGeometry adaptivePadding =
        padding ??
        EdgeInsets.all(
          ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.paddingM
              : AppDimensions.paddingL,
        );

    // Déterminer la marge adaptative
    EdgeInsetsGeometry adaptiveMargin =
        margin ??
        EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.paddingS
              : AppDimensions.paddingM,
          vertical: ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.paddingXS
              : AppDimensions.paddingS,
        );

    // Déterminer le rayon de bordure adaptatif
    BorderRadius adaptiveBorderRadius =
        borderRadius ??
        BorderRadius.circular(
          ResponsiveUtils.isSmallScreen(context)
              ? AppDimensions.radiusS
              : AppDimensions.radiusM,
        );

    // Déterminer l'ombre adaptative
    BoxShadow adaptiveShadow =
        shadow ??
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: ResponsiveUtils.isSmallScreen(context) ? 6 : 10,
          offset: Offset(0, ResponsiveUtils.isSmallScreen(context) ? 2 : 4),
        );

    // Déterminer la largeur maximale adaptative
    double? adaptiveMaxWidth =
        maxWidth ?? ResponsiveUtils.adaptiveMaxWidth(context);

    // Déterminer la hauteur maximale adaptative
    double? adaptiveMaxHeight =
        maxHeight ??
        (ResponsiveUtils.isSmallScreen(context)
            ? ResponsiveUtils.screenHeight(context) * 0.6
            : ResponsiveUtils.screenHeight(context) * 0.7);

    return Container(
      margin: adaptiveMargin,
      constraints: BoxConstraints(
        maxWidth: adaptiveMaxWidth,
        maxHeight: adaptiveMaxHeight,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: adaptiveBorderRadius,
        boxShadow: [adaptiveShadow],
        border: border,
      ),
      child: ClipRRect(
        borderRadius: adaptiveBorderRadius,
        child: SingleChildScrollView(padding: adaptivePadding, child: child),
      ),
    );
  }
}
