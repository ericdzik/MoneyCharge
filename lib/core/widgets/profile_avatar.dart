import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/services/image_picker_service.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final void Function(File) onPick;
  final double radius;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.imageFile,
    required this.onPick,
    this.radius = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.onPrimary,
            child: ClipOval(
              child: SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: _buildImage(),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => ImagePickerService.showPickerSheet(
                context: context,
                onSelected: onPick,
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.white,
                child: Icon(Icons.camera_alt, color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: normalizeFirebaseStorageUrl(imageUrl!),
        fit: BoxFit.cover,
        placeholder: (context, url) => const SizedBox(),
        errorWidget: (context, url, error) => Icon(
          Icons.person,
          size: radius,
          color: Colors.grey,
        ),
      );
    }

    return Icon(
      Icons.person,
      size: radius,
      color: Colors.grey,
    );
  }
}
