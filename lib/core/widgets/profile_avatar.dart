import 'dart:io';
import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_colors.dart';
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
    final img = imageFile != null
        ? FileImage(imageFile!)
        : imageUrl != null && imageUrl!.isNotEmpty
        ? NetworkImage(imageUrl!)
        : null;

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundImage: img as ImageProvider?,
            child: img == null
                ? Icon(Icons.person, size: radius, color: Colors.grey)
                : null,
          ),

          // Camera button
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
}
