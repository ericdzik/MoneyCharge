import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/ad_provider.dart';
import '../../../providers/auth_provider.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({Key? key}) : super(key: key);

  @override
  _CreateAdScreenState createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _urlController = TextEditingController();
  XFile? _image;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addAd() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner une image.'),
          ),
        );
        return;
      }

      final adProvider = Provider.of<AdProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final merchantId = authProvider.merchantProfile?.id;

      if (merchantId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur: Impossible de trouver votre identifiant de marchand.'),
          ),
        );
        return;
      }

      final success = await adProvider.addAd(
        title: _titleController.text,
        description: _descriptionController.text,
        image: _image!,
        url: _urlController.text,
        merchantId: merchantId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Publicité ajoutée avec succès !'),
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(adProvider.error ?? 'Erreur lors de l\'ajout de la publicité.'),
            ),
          );
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Créer une publicité',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Titre',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _image == null
                  ? const Text('Aucune image sélectionnée.')
                  : Image.file(File(_image!.path)),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    text: 'Téléverser',
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                  CustomButton(
                    text: 'Prendre une photo',
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              CustomTextField(
                controller: _urlController,
                labelText: 'URL de destination',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une URL de destination.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32.0),
              Consumer<AdProvider>(
                builder: (context, adProvider, child) {
                  return CustomButton(
                    text: adProvider.isLoading ? 'Ajout en cours...' : 'Ajouter',
                    onPressed: adProvider.isLoading ? null : _addAd,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
