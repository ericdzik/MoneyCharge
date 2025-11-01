import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/core/widgets/profile_avatar.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_colors.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickAndCropImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Optimisation de la qualité
      );

      if (pickedFile != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          compressFormat: ImageCompressFormat.jpg,
          compressQuality: 85, // Réduit de 100 à 85 pour éviter les fichiers trop lourds
          maxWidth: 1024, // Limite la taille maximale
          maxHeight: 1024,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Recadrer l\'image',
              toolbarColor: AppColors.primary,
              toolbarWidgetColor: Colors.white,
              hideBottomControls: false,
              lockAspectRatio: true, // Verrouille le ratio 1:1
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du recadrage de l\'image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// 💾 Sauvegarde du profil avec gestion d'erreur améliorée
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.updateUserProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          imageFile: _imageFile != null ? XFile(_imageFile!.path) : null,
        );

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profil mis à jour avec succès !'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else {
            // Gestion des erreurs spécifiques
            String errorMessage = authProvider.error ?? 'Erreur lors de la mise à jour.';

            if (errorMessage.contains('permission') || errorMessage.contains('403')) {
              errorMessage = 'Erreur de permissions. Vérifiez vos règles Firebase Storage.';
            } else if (errorMessage.contains('network') || errorMessage.contains('Unable to resolve')) {
              errorMessage = 'Problème de connexion. Vérifiez votre réseau.';
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur inattendue s\'est produite: $e'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Utilisateur non trouvé.'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar avec recadrage
              ProfileAvatar(
                imageUrl: user.profileImageUrl,
                imageFile: _imageFile,
                onImageSelected: (_) => _pickAndCropImage(),
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Nom complet
              CustomTextField(
                controller: _nameController,
                labelText: 'Nom complet',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Téléphone
              CustomTextField(
                controller: _phoneController,
                labelText: 'Numéro de téléphone',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Email
              CustomTextField(
                controller: TextEditingController(text: user.email),
                labelText: 'Email (non modifiable)',
                enabled: false,
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Bouton Sauvegarde
              CustomButton(
                text: authProvider.isLoading
                    ? 'Sauvegarde...'
                    : 'Sauvegarder',
                onPressed:
                authProvider.isLoading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}