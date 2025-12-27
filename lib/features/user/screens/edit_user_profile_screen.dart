import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/core/widgets/profile_avatar.dart';
import 'package:locacharge/providers/auth_provider.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUserProfile;

    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// ✅ Reçoit le fichier brut → Crop
  Future<void> _cropImage(File file) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recadrer l\'image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: false,
            lockAspectRatio: true,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: 'Recadrer l\'image',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioPickerButtonHidden: true,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        "Erreur lors du recadrage : $e",
      );
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.updateUserProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          imageFile: _imageFile != null ? XFile(_imageFile!.path) : null,
        );

        if (!mounted) return;

        if (success) {
          SnackBarHelper.showSuccess(
            context,
            'Profil mis à jour !',
          );
          Navigator.of(context).pop();
        } else {
          SnackBarHelper.showError(
            context,
            authProvider.error ?? 'Erreur inconnue',
          );
        }
      } catch (e) {
        if (!mounted) return;
        SnackBarHelper.showError(
          context,
          "Erreur: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUserProfile;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Modifier le Profil',
        showLogo: false,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.background,
        child: user == null
            ? const Center(child: Text('Utilisateur non trouvé.'))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileAvatar(
                  imageUrl: user.profileImageUrl,
                  imageFile: _imageFile,
                  onPick: (File rawFile) async {
                    await _cropImage(rawFile);
                  },
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nom complet',
                  validator: FormValidators.required('Entrez votre nom'),
                ),
                const SizedBox(height: AppDimensions.paddingM),
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Numéro de téléphone',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppDimensions.paddingM),
                CustomTextField(
                  controller: TextEditingController(text: user.email),
                  labelText: 'Email (non modifiable)',
                  enabled: false,
                ),
                const SizedBox(height: AppDimensions.paddingXL),
                CustomButton(
                  text: authProvider.isLoading ? 'Sauvegarde...' : 'Sauvegarder',
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}