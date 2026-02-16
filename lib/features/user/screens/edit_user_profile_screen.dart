import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/utils/responsive_helper.dart';
import 'package:locacharge/core/widgets/profile_avatar.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/features/merchant/widgets/opening_hours_selector.dart';
import 'package:locacharge/services/storage_service.dart';

class EditUserProfileScreen extends StatefulWidget {
  const EditUserProfileScreen({super.key});

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs communs
  late TextEditingController _nameController; // Nom complet ou Business Name
  late TextEditingController _phoneController;
  late TextEditingController _addressController; // Utilisé par Merchant
  late TextEditingController _otherServiceController; // Utilisé par Merchant

  // État Merchant
  Map<String, dynamic> _openingHours = {};
  final List<String> _predefinedServices = [
    'Recharge crédit',
    'Transfert d\'argent',
    'Carte SIM',
  ];
  final Map<String, bool> _selectedServices = {};
  final List<String> _stockStatusOptions = ['Disponible', 'Faible', 'Épuisé'];
  Map<String, String> _serviceStockStatus = {};
  List<String> _imageUrls = [];
  bool _isUploading = false;

  // Gestion des images
  File? _imageFile; // Photo de profil
  final ImagePicker _picker = ImagePicker();
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userType = authProvider.userType;

    // Initialisation par défaut
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _otherServiceController = TextEditingController();

    if (userType == UserType.merchant) {
      final merchant = authProvider.merchantProfile;
      if (merchant != null) {
        _nameController.text = merchant.businessName;
        _phoneController.text = merchant.phone;
        _addressController.text = merchant.address;

        if (merchant.openingHours != null) {
          _openingHours = merchant.openingHours!;
        }

        if (merchant.imageUrls != null) {
          _imageUrls =
              (merchant.imageUrls as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [];
        }

        // Init services
        for (var service in _predefinedServices) {
          _selectedServices[service] =
              merchant.services?.contains(service) ?? false;
        }
        merchant.services?.forEach((service) {
          if (!_predefinedServices.contains(service)) {
            _selectedServices['Autre'] = true;
            _otherServiceController.text = service;
          }
        });
        if (_selectedServices['Autre'] == null)
          _selectedServices['Autre'] = false;

        // Init stock avec normalisation stricte
        final initialStockStatus = merchant.serviceStockStatus ?? {};
        initialStockStatus.forEach((service, statusFromFirestore) {
          // Normaliser la valeur pour qu'elle corresponde exactement à une option
          final normalizedStatus = _normalizeStockStatus(statusFromFirestore);
          _serviceStockStatus[service] = normalizedStatus;
        });
        _updateStockStatusMapWithSelectedServices();
      }
    } else {
      // User normal
      final user = authProvider.appUserProfile;
      if (user != null) {
        _nameController.text = user.name;
        _phoneController.text = user.phone;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _otherServiceController.dispose();
    super.dispose();
  }

  /// Normalise le statut de stock pour qu'il corresponde exactement à une option valide
  String _normalizeStockStatus(String status) {
    final trimmedLower = status.trim().toLowerCase();

    // Chercher une correspondance exacte (insensible à la casse)
    for (var option in _stockStatusOptions) {
      if (option.toLowerCase() == trimmedLower) {
        return option; // Retourner l'option avec la bonne casse
      }
    }

    // Si aucune correspondance, retourner la première option par défaut
    return _stockStatusOptions.first;
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

    Map<String, String> newStockStatus = {};
    for (var service in currentSelectedServices) {
      newStockStatus[service] =
          _serviceStockStatus[service] ?? _stockStatusOptions.first;
    }
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
      SnackBarHelper.showError(context, "Erreur lors du recadrage : $e");
    }
  }

  Future<void> _pickAndUploadImages() async {
    setState(() {
      _isUploading = true;
    });
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        for (var file in pickedFiles) {
          // Crop optionnel pour la galerie ? On va dire non pour l'instant pour simplifier, ou simple crop
          final CroppedFile? cropped = await ImageCropper().cropImage(
            sourcePath: file.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Recadrer',
                toolbarColor: AppColors.primary,
                toolbarWidgetColor: Colors.white,
                lockAspectRatio: false,
              ),
              IOSUiSettings(title: 'Recadrer', aspectRatioLockEnabled: false),
            ],
          );

          final XFile toUpload = cropped != null ? XFile(cropped.path) : file;
          // Note context: merchant.id est nécessaire
          final merchantId = authProvider.merchantProfile?.id;
          if (merchantId != null) {
            final imageUrl = await _storageService.uploadImage(
              toUpload,
              merchantId,
            );
            if (imageUrl != null) {
              setState(() {
                _imageUrls.add(imageUrl);
              });
            }
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(context, "Erreur upload: $e");
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = false;

      try {
        if (authProvider.userType == UserType.merchant) {
          // Logic Merchant
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

          Map<String, String> finalServiceStockStatus = {};
          for (var service in finalServices) {
            finalServiceStockStatus[service] =
                _serviceStockStatus[service] ?? _stockStatusOptions.first;
          }

          success = await authProvider.updateMerchantProfile(
            businessName: _nameController
                .text, // _nameController joue le rôle de businessNameController
            phone: _phoneController.text,
            address: _addressController.text,
            openingHours: _openingHours,
            services: finalServices,
            serviceStockStatus: finalServiceStockStatus,
            imageUrls: _imageUrls,
            profileImageFile: _imageFile != null
                ? XFile(_imageFile!.path)
                : null,
          );
        } else {
          // Logic User
          success = await authProvider.updateUserProfile(
            name: _nameController.text,
            phone: _phoneController.text,
            imageFile: _imageFile != null ? XFile(_imageFile!.path) : null,
          );
        }

        if (!mounted) return;

        if (success) {
          SnackBarHelper.showSuccess(context, 'Profil mis à jour !');
          Navigator.of(context).pop();
        } else {
          SnackBarHelper.showError(
            context,
            authProvider.error ?? 'Erreur lors de la mise à jour.',
          );
        }
      } catch (e) {
        if (!mounted) return;
        SnackBarHelper.showError(context, "Erreur: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userType = authProvider.userType;
    final isMerchant = userType == UserType.merchant;

    // Récupération de l'image de profil
    String? profileImageUrl;
    String? email;
    if (isMerchant) {
      profileImageUrl = authProvider.merchantProfile?.profileImageUrl;
      email = authProvider.merchantProfile?.email;
    } else {
      profileImageUrl = authProvider.appUserProfile?.profileImageUrl;
      email = authProvider.appUserProfile?.email;
    }

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
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: ResponsiveHelper.getPadding(
              context,
              extraSmall: 16,
              medium: 24,
            ),
            left: ResponsiveHelper.getHorizontalMargin(context),
            right: ResponsiveHelper.getHorizontalMargin(context),
            bottom: ResponsiveHelper.getPadding(
              context,
              extraSmall: 16,
              medium: 24,
            ),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar commun
                ProfileAvatar(
                  imageUrl: profileImageUrl,
                  imageFile: _imageFile,
                  onPick: (File rawFile) async {
                    await _cropImage(rawFile);
                  },
                ),
                SizedBox(
                  height: ResponsiveHelper.getPadding(
                    context,
                    extraSmall: 24,
                    medium: 32,
                  ),
                ),

                // Champs communs (ou presque, le label change)
                CustomTextField(
                  controller: _nameController,
                  labelText: isMerchant ? 'Nom du commerce' : 'Nom complet',
                  validator: FormValidators.required('Ce champ est requis'),
                ),
                SizedBox(
                  height: ResponsiveHelper.getPadding(
                    context,
                    extraSmall: 12,
                    medium: 16,
                  ),
                ),

                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Numéro de téléphone',
                  keyboardType: TextInputType.phone,
                  validator: FormValidators.required('Ce champ est requis'),
                ),
                SizedBox(
                  height: ResponsiveHelper.getPadding(
                    context,
                    extraSmall: 12,
                    medium: 16,
                  ),
                ),

                // Email (Read-only)
                CustomTextField(
                  controller: TextEditingController(text: email ?? ''),
                  labelText: 'Email (non modifiable)',
                  enabled: false,
                ),
                SizedBox(
                  height: ResponsiveHelper.getPadding(
                    context,
                    extraSmall: 12,
                    medium: 16,
                  ),
                ),

                // Champs spécifiques Marchand
                if (isMerchant) ..._buildMerchantFields(context),

                SizedBox(
                  height: ResponsiveHelper.getPadding(
                    context,
                    extraSmall: 24,
                    medium: 32,
                  ),
                ),

                // Bouton de sauvegarde
                CustomButton(
                  text: authProvider.isLoading
                      ? 'Sauvegarde...'
                      : 'Sauvegarder',
                  onPressed: authProvider.isLoading ? null : _saveProfile,
                  // height: ResponsiveHelper.getButtonHeight(context), // Optionnel si CustomButton gère déjà
                ),
                SizedBox(
                  height: ResponsiveHelper.getPadding(
                    context,
                    extraSmall: 24,
                    medium: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMerchantFields(BuildContext context) {
    return [
      CustomTextField(
        controller: _addressController,
        labelText: 'Adresse',
        maxLines: 2,
        validator: FormValidators.required('L\'adresse est requise'),
      ),
      SizedBox(
        height: ResponsiveHelper.getPadding(
          context,
          extraSmall: 12,
          medium: 16,
        ),
      ),

      Text(
        'Horaires d\'ouverture',
        style: AppTextStyles.h2.copyWith(
          fontSize: ResponsiveHelper.getFontSize(context, baseSize: 18),
        ),
      ),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        icon: Icon(
          Icons.timer_outlined,
          size: ResponsiveHelper.getIconSize(context, baseSize: 20),
        ),
        label: Text(
          'Modifier les horaires',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
          ),
        ),
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
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getPadding(
              context,
              extraSmall: 10,
              medium: 12,
            ),
            horizontal: 16,
          ),
        ),
      ),
      _buildOpeningHoursSummary(),

      SizedBox(
        height: ResponsiveHelper.getPadding(
          context,
          extraSmall: 20,
          medium: 24,
        ),
      ),

      // Galerie Images
      Text(
        'Images de la boutique',
        style: AppTextStyles.h2.copyWith(
          fontSize: ResponsiveHelper.getFontSize(context, baseSize: 18),
        ),
      ),
      const SizedBox(height: 8),
      _buildImageGallery(),
      const SizedBox(height: 8),
      ElevatedButton.icon(
        icon: Icon(
          Icons.add_a_photo_outlined,
          size: ResponsiveHelper.getIconSize(context, baseSize: 20),
        ),
        label: Text(
          'Ajouter des images',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
          ),
        ),
        onPressed: _isUploading ? null : _pickAndUploadImages,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: ResponsiveHelper.getPadding(
              context,
              extraSmall: 10,
              medium: 12,
            ),
            horizontal: 16,
          ),
        ),
      ),
      if (_isUploading)
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: LoadingIndicator.small(),
        ),

      SizedBox(
        height: ResponsiveHelper.getPadding(
          context,
          extraSmall: 20,
          medium: 24,
        ),
      ),

      // Services
      Text(
        'Services Proposés',
        style: AppTextStyles.h2.copyWith(
          fontSize: ResponsiveHelper.getFontSize(context, baseSize: 18),
        ),
      ),
      const SizedBox(height: 8),
      ..._predefinedServices.map((service) {
        return CheckboxListTile(
          title: Text(
            service,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
            ),
          ),
          value: _selectedServices[service],
          onChanged: (bool? value) {
            setState(() {
              _selectedServices[service] = value ?? false;
              _updateStockStatusMapWithSelectedServices();
            });
          },
          activeColor: AppColors.primary,
          dense: context.isExtraSmall,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
        );
      }),
      CheckboxListTile(
        title: Text(
          'Autre',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
          ),
        ),
        value: _selectedServices['Autre'],
        onChanged: (bool? value) {
          setState(() {
            _selectedServices['Autre'] = value ?? false;
            if (!(_selectedServices['Autre']!)) {
              _otherServiceController.clear();
            }
            _updateStockStatusMapWithSelectedServices();
          });
        },
        activeColor: AppColors.primary,
        dense: context.isExtraSmall,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
      if (_selectedServices['Autre'] == true)
        Padding(
          padding: EdgeInsets.only(
            left: 12,
            bottom: ResponsiveHelper.getPadding(
              context,
              extraSmall: 8,
              medium: 12,
            ),
          ),
          child: CustomTextField(
            controller: _otherServiceController,
            labelText: 'Précisez le service',
            hintText: 'Ex: Réparation téléphone',
          ),
        ),

      SizedBox(
        height: ResponsiveHelper.getPadding(
          context,
          extraSmall: 20,
          medium: 24,
        ),
      ),

      // Stock
      if (_selectedServices.containsValue(true))
        Text(
          'Statut du Stock',
          style: AppTextStyles.h2.copyWith(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 18),
          ),
        ),
      const SizedBox(height: 8),
      ..._getSelectedServiceNamesForStock().map((serviceName) {
        if (serviceName.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(
            bottom: ResponsiveHelper.getPadding(
              context,
              extraSmall: 8,
              medium: 12,
            ),
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Stock pour "$serviceName"',
              labelStyle: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              ),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: ResponsiveHelper.getPadding(
                  context,
                  extraSmall: 10,
                  medium: 14,
                ),
              ),
            ),
            value:
                _serviceStockStatus[serviceName] ?? _stockStatusOptions.first,
            items: _stockStatusOptions.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      baseSize: 14,
                    ),
                  ),
                ),
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
      }),
    ];
  }

  Widget _buildOpeningHoursSummary() {
    if (_openingHours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(
          'Aucun horaire défini.',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
            color: Colors.grey,
          ),
        ),
      );
    }

    List<String> days = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    List<Widget> summary = [];

    for (var day in days) {
      if (_openingHours.containsKey(day) && _openingHours[day] is Map) {
        final hoursMap = _openingHours[day];
        summary.add(
          Text(
            '$day: ${hoursMap['open']} - ${hoursMap['close']}',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
            ),
          ),
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
      return Text(
        'Aucune image pour le moment.',
        style: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
          color: Colors.grey,
        ),
      );
    }

    // Grille adaptative
    int crossAxisCount = 3;
    if (context.isExtraSmall) crossAxisCount = 2;
    if (context.isTablet) crossAxisCount = 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => const LoadingIndicator.small(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imageUrls.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
