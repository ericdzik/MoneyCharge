import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/services/image_picker_service.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double radius;
  final IconData placeholderIcon;
  final void Function(File) onImageSelected;

  const ProfileAvatar({
    Key? key,
    this.imageUrl,
    this.imageFile,
    required this.onImageSelected,
    this.radius = 60,
    this.placeholderIcon = Icons.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ImageProvider? backgroundImage;
    if (imageFile != null) {
      backgroundImage = FileImage(imageFile!);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(imageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: backgroundImage,
            child: backgroundImage == null
                ? Icon(placeholderIcon, size: radius)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  ImagePickerService.showImageSourceSheet(
                    context: context,
                    onImageSelected: onImageSelected,
                    cropStyle: CropStyle.circle,
                    lockAspectRatio: true,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}