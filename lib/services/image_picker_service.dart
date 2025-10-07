import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locacharge/core/constants/app_colors.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickAndCropImage({
    required BuildContext context,
    required ImageSource source,
    CropStyle cropStyle = CropStyle.circle,
    bool lockAspectRatio = true,
  }) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return null;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l’image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: lockAspectRatio,
          cropStyle: cropStyle,
        ),
        IOSUiSettings(
          title: 'Recadrer l’image',
          aspectRatioLockEnabled: lockAspectRatio,
          doneButtonTitle: 'Valider',
          cancelButtonTitle: 'Annuler',
          cropStyle: cropStyle,
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  static void showImageSourceSheet({
    required BuildContext context,
    required Function(File) onImageSelected,
    CropStyle cropStyle = CropStyle.circle,
    bool lockAspectRatio = true,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickAndCropImage(
                    context: context,
                    source: ImageSource.gallery,
                    cropStyle: cropStyle,
                    lockAspectRatio: lockAspectRatio,
                  );
                  if (file != null) {
                    onImageSelected(file);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final file = await pickAndCropImage(
                    context: context,
                    source: ImageSource.camera,
                    cropStyle: cropStyle,
                    lockAspectRatio: lockAspectRatio,
                  );
                  if (file != null) {
                    onImageSelected(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}