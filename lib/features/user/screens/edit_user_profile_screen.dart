import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
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

  Future<void> _pickAndCropImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l’image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          hideBottomControls: true,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Recadrer l’image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _imageFile = File(croppedFile.path);
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCropImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndCropImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.updateUserProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        imageFile: _imageFile != null ? XFile(_imageFile!.path) : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Profil mis à jour avec succès !'
                : authProvider.error ?? 'Erreur lors de la mise à jour.'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
        if (success) Navigator.of(context).pop();
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
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (user.profileImageUrl != null
                          ? NetworkImage(user.profileImageUrl!)
                          : null) as ImageProvider?,
                      child: _imageFile == null &&
                          user.profileImageUrl == null
                          ? const Icon(Icons.person, size: 60)
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
                          onPressed: _showImageSourceSheet,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.paddingXL),
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
                text: authProvider.isLoading
                    ? 'Sauvegarde...'
                    : 'Sauvegarder',
                onPressed: authProvider.isLoading ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
