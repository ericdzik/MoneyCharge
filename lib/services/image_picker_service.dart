import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );

    return picked != null ? File(picked.path) : null;
  }

  static void showPickerSheet({
    required BuildContext context,
    required Function(File) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _tile(
              icon: Icons.photo_library,
              label: "Galerie",
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(ImageSource.gallery);
                if (file != null) onSelected(file);
              },
            ),
            _tile(
              icon: Icons.camera_alt,
              label: "Appareil photo",
              onTap: () async {
                Navigator.pop(context);
                final file = await pickImage(ImageSource.camera);
                if (file != null) onSelected(file);
              },
            ),
          ],
        ),
      ),
    );
  }

  static ListTile _tile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }
}
