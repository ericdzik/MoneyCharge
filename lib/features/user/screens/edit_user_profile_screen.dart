import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:locacharge/services/storage_service.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:locacharge/core/constants/app_colors.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({Key? key}) : super(key: key);

  @override
  _EditUserProfileScreenState createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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
      final storageService = StorageService();
      String? photoURL;

      if (_image != null) {
        photoURL = await storageService.uploadProfilePicture(
            _image!, authProvider.appUser!.uid);
      }

      final success = await authProvider.updateUserProfile(
        name: _nameController.text,
        phone: _phoneController.text,
        photoURL: photoURL,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Erreur lors de la mise à jour.'),
              backgroundColor: AppColors.error,
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
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: _image != null
                                ? FileImage(_image!)
                                : (user?.photoURL != null &&
                                        user!.photoURL!.isNotEmpty
                                    ? NetworkImage(user.photoURL!)
                                    : null) as ImageProvider?,
                            child: _image == null &&
                                    (user?.photoURL == null ||
                                        user!.photoURL!.isEmpty)
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt),
                              onPressed: _pickImage,
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
                      // Le validateur pour le téléphone peut être plus complexe,
                      // mais pour l'instant on le laisse simple.
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
    );
  }
}
