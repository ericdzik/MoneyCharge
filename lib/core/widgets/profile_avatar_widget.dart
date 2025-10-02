import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 40.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.onPrimary,
      radius: size / 2,
      child: ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const SizedBox(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.person, color: AppColors.primary, size: size * 0.6),
                )
              : Icon(Icons.person, color: AppColors.primary, size: size * 0.6),
        ),
      ),
    );
  }
}