import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class CachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final bool isCircle;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.isCircle = false,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorWidget(context);
    }

    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: Colors.grey.shade200,
            child: Center(
              child: SizedBox(
                width: _getLoaderSize(context),
                height: _getLoaderSize(context),
                child: CircularProgressIndicator(
                  strokeWidth: context.isExtraSmall ? 1.5 : 2,
                ),
              ),
            ),
          ),
      errorWidget: (context, url, error) => _buildErrorWidget(context),
      fadeInDuration: const Duration(milliseconds: 300),
    );

    if (isCircle) {
      return ClipOval(child: imageWidget);
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context, baseRadius: borderRadius),
        ),
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  double _getLoaderSize(BuildContext context) {
    // Adapter la taille du loader en fonction de la taille de l'image
    if (width != null && width! < 60) {
      return context.isExtraSmall ? 14 : 16;
    }
    return context.isExtraSmall ? 18 : 20;
  }

  double _getIconSize(BuildContext context) {
    if (width != null && width! < 40) {
      return context.isExtraSmall ? 14 : 16;
    }
    if (width != null && width! < 80) {
      return context.isExtraSmall ? 20 : 24;
    }
    return ResponsiveHelper.getIconSize(context, baseSize: 24);
  }

  Widget _buildErrorWidget(BuildContext context) {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade200,
          child: Icon(
            Icons.image_not_supported,
            color: Colors.grey.shade400,
            size: _getIconSize(context),
          ),
        );
  }
}
