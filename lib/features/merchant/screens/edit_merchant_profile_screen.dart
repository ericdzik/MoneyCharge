import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/core/widgets/custom_button.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/features/merchant/models/merchant_auth_model.dart';
import 'package:locacharge/features/merchant/widgets/opening_hours_selector.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/services/storage_service.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/constants/app_dimensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:locacharge/core/widgets/profile_avatar.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';

class EditMerchantProfileScreen extends StatefulWidget {
  final MerchantAuthModel merchant;

  const EditMerchantProfileScreen({Key? key, required this.merchant}) : super(key: key);

  @override
  State<EditMerchantProfileScreen> createState() => _EditMerchantProfileScreenState();
}

class _EditMerchantProfileScreenState extends State<EditMerchantProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  // late TextEditingController _openingHoursController; // Remplacé
  Map<String, dynamic> _openingHours = {};
  late TextEditingController _otherServiceController;

  // Gestion des services
  final List<String> _predefinedServices = ['Recharge crédit', 'Transfert d'argent', 'Carte SIM'];
  Map<String, bool> _selectedServices = {};
  // String _customService = ''; // Retiré, _otherServiceController.text est la source de vérité

  // Gestion du stock des services
  final List<String> _stockStatusOptions = ['Disponible', 'Faible', 'Épuisé'];
  Map<String, String> _serviceStockStatus = {};

  // Gestion des images
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();
  List<String> _imageUrls = [];
  File? _profileImageFile;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController(text: widget.merchant.businessName);
    _phoneController = TextEditingController(text: widget.merchant.phone);
    _addressController = TextEditingController(text: widget.merchant.address);
    // _openingHoursController = TextEditingController(text: widget.merchant.openingHours ?? '');
    if (widget.merchant.openingHours != null) {
      _openingHours = widget.merchant.openingHours!;
    }
    if (widget.merchant.imageUrls != null) {
      _imageUrls = (widget.merchant.imageUrls as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    }
    _otherServiceController = TextEditingController();

    // Initialiser _selectedServices et _customService
    for (var service in _predefinedServices) {
      _selectedServices[service] = widget.merchant.services?.contains(service) ?? false;
    }
    // Vérifier si un service personnalisé existe
    widget.merchant.services?.forEach((service) {
      if (!_predefinedServices.contains(service)) {
        _selectedServices['Autre'] = true; // Cocher "Autre"
        _otherServiceController.text = service; // Remplir le champ "Autre"
        // _customService = service; // Retiré
      }
    });
    if (_selectedServices['Autre'] == null) { // S'assurer que "Autre" a une entrée
        _selectedServices['Autre'] = false;
    }


    // Initialiser _serviceStockStatus avec validation et normalisation de la casse améliorée
    final initialStockStatus = widget.merchant.serviceStockStatus ?? {};
    initialStockStatus.forEach((service, statusFromFirestore) {
      final String statusTrimmedLower = statusFromFirestore.trim().toLowerCase();
      print("[EditProfile] DEBUG - Service: '$service', Status Firestore brut: '$statusFromFirestore', TrimmedLower: '$statusTrimmedLower'");

      String? foundOption;
      for (var option in _stockStatusOptions) {
        if (option.toLowerCase() == statusTrimmedLower) {
          foundOption = option;
          break;
        }
      }

      if (foundOption != null) {
        _serviceStockStatus[service] = foundOption;
        if (foundOption != statusFromFirestore) { // Log si une normalisation (casse ou trim) a eu lieu
           print("[EditProfile] INFO - Service: '$service', Statut Firestore: '$statusFromFirestore' -> Normalisé en: '$foundOption'.");
        }
      } else {
        _serviceStockStatus[service] = _stockStatusOptions.first; // Valeur par défaut
        if (statusFromFirestore.isNotEmpty) { // Ne pas logger pour les chaînes vides initiales
            print("[EditProfile] ALERTE - Service: '$service', Statut Firestore INCONNU: '$statusFromFirestore'. Remplacé par défaut: '${_stockStatusOptions.first}'.");
        }
      }
    });
    // S'assurer que tous les services sélectionnés ont une entrée de stock
    _updateStockStatusMapWithSelectedServices();
  }

  void _updateStockStatusMapWithSelectedServices() {
    List<String> currentSelectedServices = [];
    _selectedServices.forEach((serviceName, isSelected) {
      if (isSelected) {
        if (serviceName == 'Autre' && _otherServiceController.text.isNotEmpty) {
          currentSelectedServices.add(_otherServiceController.text);
        } else if (serviceName != 'Autre') {
          currentSelectedServices.add(serviceName);
        }
      }
    });

    // Conserver les statuts existants, ajouter les nouveaux services avec un statut par défaut
    Map<String, String> newStockStatus = {};
    for (var service in currentSelectedServices) {
      newStockStatus[service] = _serviceStockStatus[service] ?? _stockStatusOptions.first; // 'Disponible' par défaut
    }
    // Retirer les services qui ne sont plus sélectionnés, sauf s'ils avaient un statut défini (facultatif, mais plus propre)
    // _serviceStockStatus.removeWhere((key, value) => !currentSelectedServices.contains(key));
    // Pour cette version, on fusionne simplement :
    _serviceStockStatus = newStockStatus;

  }

  List<String> _getSelectedServiceNamesForStock() {
    List<String> names = [];
    _selectedServices.forEach((serviceName, isSelected) {
      if (isSelected) {
        if (serviceName == 'Autre') {
          if (_otherServiceController.text.trim().isNotEmpty) {
            names.add(_otherServiceController.text.trim());
          }
        } else {
          names.add(serviceName);
        }
      }
    });
    return names;
  }


  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    // _openingHoursController.dispose();
    _otherServiceController.dispose();
    super.dispose();
  }

  void _saveProfile() async { // Rendre async
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Construire la liste finale des services
      List<String> finalServices = [];
      _selectedServices.forEach((serviceName, isSelected) {
        if (isSelected) {
          if (serviceName == 'Autre') {
            if (_otherServiceController.text.trim().isNotEmpty) {
              finalServices.add(_otherServiceController.text.trim());
            }
          } else {
            finalServices.add(serviceName);
          }
        }
      });

      // S'assurer que la map de stock est à jour avec les services finaux
      Map<String, String> finalServiceStockStatus = {};
      for (var service in finalServices) {
        finalServiceStockStatus[service] = _serviceStockStatus[service] ?? _stockStatusOptions.first;
      }


      bool success = await authProvider.updateMerchantProfile(
        businessName: _businessNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        openingHours: _openingHours,
        services: finalServices,
        serviceStockStatus: finalServiceStockStatus,
        imageUrls: _imageUrls,
        profileImageFile: _profileImageFile != null ? XFile(_profileImageFile!.path) : null,
      );

      if (mounted) { // Vérifier si le widget est toujours monté avant d'utiliser BuildContext
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès !'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.error ?? 'Erreur lors de la mise à jour du profil.'),
              backgroundColor: Colors.red, // Utilisation de Colors.red directement
            ),
          );
        }
      }
    }
  }

  Widget _buildOpeningHoursSummary() {
    if (_openingHours.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text('Aucun horaire défini.'),
      );
    }

    List<String> days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    List<Widget> summary = [];

    for (var day in days) {
      if (_openingHours.containsKey(day) && _openingHours[day] is Map) {
        final hoursMap = _openingHours[day];
        summary.add(
          Text('$day: ${hoursMap['open']} - ${hoursMap['close']}'),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summary,
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_imageUrls.isEmpty) {
      return const Text('Aucune image pour le moment.');
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            CachedNetworkImage(
              imageUrl: _imageUrls[index],
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _imageUrls.removeAt(index);
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadImages() async {
    setState(() {
      _isUploading = true;
    });
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          // Proposer un recadrage pour chaque image
          final CroppedFile? cropped = await ImageCropper().cropImage(
            sourcePath: file.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Recadrer l\'image',
                toolbarColor: AppColors.primary,
                toolbarWidgetColor: Colors.white,
                lockAspectRatio: false,
              ),
              IOSUiSettings(
                title: 'Recadrer l\'image',
                aspectRatioLockEnabled: false,
              ),
            ],
          );

          final XFile toUpload = cropped != null ? XFile(cropped.path) : file;
          final imageUrl = await _storageService.uploadImage(toUpload, widget.merchant.id);
          if (imageUrl != null) {
            setState(() {
              _imageUrls.add(imageUrl);
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la sélection d'images: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Modifier le Profil',
        showLogo: false,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ProfileAvatar(
                imageUrl: widget.merchant.profileImageUrl,
                imageFile: _profileImageFile,
                onImageSelected: (file) {
                  setState(() {
                    _profileImageFile = file;
                  });
                },
                placeholderIcon: Icons.business,
              ),
              const SizedBox(height: AppDimensions.paddingXL),
              Text(
                'Informations du Commerce',
                style: AppTextStyles.h2.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Email (non modifiable)
              Text('Email: ${widget.merchant.email}', style: AppTextStyles.body1),
              const SizedBox(height: AppDimensions.paddingL),

              CustomTextField(
                controller: _businessNameController,
                labelText: 'Nom du commerce',
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),

              CustomTextField(
                controller: _phoneController,
                labelText: 'Téléphone',
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),

              CustomTextField(
                controller: _addressController,
                labelText: 'Adresse',
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),

              Text(
                'Horaires d\'ouverture',
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ElevatedButton.icon(
                icon: const Icon(Icons.timer_outlined),
                label: const Text('Modifier les horaires'),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => OpeningHoursSelector(
                      initialHours: _openingHours,
                      onHoursChanged: (newHours) {
                        setState(() {
                          _openingHours = newHours;
                        });
                      },
                    ),
                  );
                },
              ),
              _buildOpeningHoursSummary(),
              const SizedBox(height: AppDimensions.paddingXL),

              // Section Images
              Text('Images de la boutique', style: AppTextStyles.h2.copyWith(fontSize: 20)),
              const SizedBox(height: AppDimensions.paddingS),
              _buildImageGallery(),
              const SizedBox(height: AppDimensions.paddingM),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo_outlined),
                label: const Text('Ajouter des images'),
                onPressed: _isUploading ? null : _pickAndUploadImages,
              ),
              if (_isUploading) const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: AppDimensions.paddingXL),

              // Section Services
              Text('Services Proposés', style: AppTextStyles.h2.copyWith(fontSize: 20)),
              const SizedBox(height: AppDimensions.paddingS),
              ..._predefinedServices.map((service) {
                return CheckboxListTile(
                  title: Text(service),
                  value: _selectedServices[service],
                  onChanged: (bool? value) {
                    setState(() {
                      _selectedServices[service] = value ?? false;
                      _updateStockStatusMapWithSelectedServices(); // Mettre à jour la map de stock
                    });
                  },
                  activeColor: AppColors.primary,
                );
              }).toList(),
              CheckboxListTile(
                title: const Text('Autre'),
                value: _selectedServices['Autre'],
                onChanged: (bool? value) {
                  setState(() {
                    _selectedServices['Autre'] = value ?? false;
                    if (!(_selectedServices['Autre']!)) { // Si "Autre" est décoché, effacer le texte
                        _otherServiceController.clear();
                        // _customService = ''; // Retiré
                    }
                    _updateStockStatusMapWithSelectedServices();
                  });
                },
                activeColor: AppColors.primary,
              ),
              if (_selectedServices['Autre'] == true)
                Padding(
                  padding: const EdgeInsets.only(left: AppDimensions.paddingL, right: AppDimensions.paddingM, bottom: AppDimensions.paddingM),
                  child: CustomTextField(
                    controller: _otherServiceController,
                    labelText: 'Précisez le service "Autre"',
                    hintText: 'Ex: Réparation téléphone',
                    // onChanged n'est pas supporté par CustomTextField, la valeur sera lue depuis le controller
                    // La mise à jour de _customService se fera via le controller avant la sauvegarde si nécessaire
                    // ou lors du changement de la checkbox "Autre"
                  ),
                ),
              const SizedBox(height: AppDimensions.paddingL),

              // Section Stock des Services
              if (_selectedServices.containsValue(true)) // Afficher seulement si au moins un service est sélectionné
                Text('Statut du Stock des Services', style: AppTextStyles.h2.copyWith(fontSize: 20)),
              const SizedBox(height: AppDimensions.paddingS),
              ..._getSelectedServiceNamesForStock().map((serviceName) {
                 if (serviceName.isEmpty) return const SizedBox.shrink(); // Ne pas afficher si le nom du service est vide (cas de "Autre" non rempli)
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.paddingM),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Stock pour "$serviceName"',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    value: _serviceStockStatus[serviceName] ?? _stockStatusOptions.first,
                    items: _stockStatusOptions.map((String status) {
                      return DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _serviceStockStatus[serviceName] = newValue;
                        });
                      }
                    },
                  ),
                );
              }).toList(),
              const SizedBox(height: AppDimensions.paddingXL),

              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: authProvider.isLoading ? 'Sauvegarde...' : 'Sauvegarder les modifications',
                    onPressed: authProvider.isLoading ? null : _saveProfile,
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
