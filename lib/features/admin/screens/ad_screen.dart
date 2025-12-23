import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/providers/ad_provider.dart';

class AdScreen extends StatefulWidget {
  const AdScreen({super.key});

  @override
  _AdScreenState createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
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
        SnackBarHelper.showWarning(
          context,
          'Veuillez sélectionner une image.',
        );
        return;
      }

      final adProvider = Provider.of<AdProvider>(context, listen: false);
      final success = await adProvider.addAd(
        title: _titleController.text,
        description: _descriptionController.text,
        image: _image!,
        url: _urlController.text,
      );

      if (mounted) {
        if (success) {
          SnackBarHelper.showSuccess(
            context,
            'Publicité ajoutée avec succès !',
          );
          Navigator.of(context).pop();
        } else {
          SnackBarHelper.showError(
            context,
            adProvider.error ?? 'Erreur lors de l\'ajout de la publicité.',
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
        title: 'Ajouter une publicité',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
