import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
                    ProfileAvatar(
                      imageUrl: user.profileImageUrl,
                      imageFile: _imageFile,
                      onImageSelected: (file) {
                        setState(() {
                          _imageFile = file;
                        });
                      },
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
