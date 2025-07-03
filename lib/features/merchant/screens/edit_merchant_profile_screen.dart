import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../models/merchant_auth_model.dart';
// Potentiellement d'autres imports pour LocationProvider, CheckboxListTile, DropdownButtonFormField etc.

class EditMerchantProfileScreen extends StatefulWidget {
  const EditMerchantProfileScreen({super.key});

  @override
  State<EditMerchantProfileScreen> createState() => _EditMerchantProfileScreenState();
}

class _EditMerchantProfileScreenState extends State<EditMerchantProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour les champs de texte
  late TextEditingController _businessNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _openingHoursController;

  // Variables d'état pour les services et leur stock
  List<String> _availableServices = ['Recharge crédit', 'Transfert d\'argent', 'Achat de carte SIM'];
  Map<String, bool> _selectedServices = {};
  Map<String, String> _serviceStockStatus = {}; // ex: {'Recharge crédit': 'disponible'}

  // Autres variables d'état si nécessaire
  bool _isLoading = false; // Pour l'indicateur de chargement lors de la sauvegarde

  MerchantAuthModel? _initialMerchantData;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _openingHoursController = TextEditingController();

    // Charger les données initiales après la construction du premier frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMerchantData();
    });
  }

  void _loadMerchantData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchant = authProvider.merchantProfile;

    if (merchant != null) {
      _initialMerchantData = merchant; // Conserver une copie des données initiales
      _businessNameController.text = merchant.businessName;
      _phoneController.text = merchant.phone;
      _addressController.text = merchant.address;
      _openingHoursController.text = merchant.openingHours ?? '';

      // Initialiser _selectedServices
      // D'abord, s'assurer que toutes les clés de _availableServices sont dans _selectedServices avec false
      for (var service in _availableServices) {
        _selectedServices[service] = false;
      }
      // Ensuite, mettre à true ceux qui sont dans merchant.services
      if (merchant.services != null) {
        for (String serviceName in merchant.services!) {
          if (_selectedServices.containsKey(serviceName)) {
            _selectedServices[serviceName] = true;
          }
        }
      }

      // Initialiser _serviceStockStatus
      if (merchant.serviceStockStatus != null) {
        _serviceStockStatus = Map<String, String>.from(merchant.serviceStockStatus!);
      } else {
        // Si pas de statut de stock, initialiser avec "disponible" pour les services sélectionnés
        _selectedServices.forEach((service, isSelected) {
          if (isSelected) {
            _serviceStockStatus[service] = 'disponible'; // Valeur par défaut
          }
        });
      }
      if (mounted) {
        setState(() {}); // Mettre à jour l'UI si nécessaire après le chargement des données
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _openingHoursController.dispose();
    super.dispose();
  }

  // Méthode pour charger les données initiales du marchand (sera remplie plus tard)
  void _loadMerchantData() {
    // Sera implémenté dans la prochaine étape du plan
  }

  // Méthode pour sauvegarder les modifications
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // L'ID du marchand est nécessaire pour la mise à jour.
    // Il est supposé être disponible via authProvider.merchantProfile.id ou authProvider.userId
    // Si _initialMerchantData est utilisé, il contient l'ID.
    final merchantId = _initialMerchantData?.id ?? authProvider.userId;

    if (merchantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: ID du marchand non trouvé.'), backgroundColor: Colors.red),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final List<String> selectedServicesList = _selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    // Ne conserver que les statuts de stock pour les services actuellement sélectionnés
    final Map<String, String> finalStockStatus = {};
    for (String serviceName in selectedServicesList) {
      if (_serviceStockStatus.containsKey(serviceName)) {
        finalStockStatus[serviceName] = _serviceStockStatus[serviceName]!;
      } else {
        // Si un service est sélectionné mais n'a pas de statut (ne devrait pas arriver avec l'init),
        // lui donner un statut par défaut.
        finalStockStatus[serviceName] = 'disponible';
      }
    }

    try {
      // La méthode updateMerchantProfile sera créée dans AuthProvider
      bool success = await authProvider.updateMerchantProfile(
        // uid: merchantId, // L'UID est déjà dans AuthProvider, ou peut être passé si la méthode le requiert
        businessName: _businessNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        openingHours: _openingHoursController.text,
        services: selectedServicesList,
        serviceStockStatus: finalStockStatus,
        // Les autres champs comme email, merchantType, latitude, longitude ne sont pas modifiés ici
        // ou leur modification n'est pas encore implémentée dans ce formulaire.
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès !'), backgroundColor: AppColors.success),
        );
        // Optionnel: Recharger les données ou revenir en arrière
        _loadMerchantData(); // Recharger pour voir les données à jour si on reste sur l'écran
        // Navigator.pop(context); // Si on veut revenir à l'écran précédent
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erreur lors de la mise à jour du profil.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur inattendue est survenue: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false); // Peut être utilisé pour le titre ou autre
    final merchant = _initialMerchantData ?? authProvider.merchantProfile; // Utiliser les données initiales chargées

    return Scaffold(
      appBar: AppBar(
        title: Text(merchant != null ? 'Profil: ${merchant.businessName}' : 'Modifier le Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveProfile,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Informations du Business',
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              if (merchant?.email != null) ...[
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.textSecondary),
                  title: Text(merchant!.email),
                  subtitle: const Text('Email (non modifiable)'),
                ),
                const Divider(),
              ],
              if (merchant?.merchantType != null) ...[
                ListTile(
                  leading: const Icon(Icons.storefront, color: AppColors.textSecondary),
                  title: Text(merchant!.merchantType == 'boutique' ? 'Boutique Fixe' : 'Ambulant'),
                  subtitle: const Text('Type de marchand (non modifiable)'),
                ),
                const Divider(),
              ],
              const SizedBox(height: AppDimensions.paddingM),

              CustomTextField(
                controller: _businessNameController,
                labelText: 'Nom du business',
                validator: (value) => value == null || value.isEmpty ? 'Nom requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Téléphone',
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Téléphone requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              CustomTextField(
                controller: _addressController,
                labelText: 'Adresse',
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Adresse requise' : null,
              ),
              const SizedBox(height: AppDimensions.paddingS),
              CustomTextField(
                controller: _openingHoursController,
                labelText: 'Horaires d\'ouverture',
                hintText: 'Ex: 8h00 - 20h00, Lundi-Samedi',
              ),
              const SizedBox(height: AppDimensions.paddingL),

              Text(
                'Services Proposés et Stock',
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ..._availableServices.map((serviceName) {
                bool isSelected = _selectedServices[serviceName] ?? false;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: Text(serviceName),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedServices[serviceName] = value ?? false;
                          if (value == true && !_serviceStockStatus.containsKey(serviceName)) {
                            _serviceStockStatus[serviceName] = 'disponible'; // Valeur par défaut
                          } else if (value == false) {
                            // Optionnel: supprimer le statut de stock si le service est décoché
                            // _serviceStockStatus.remove(serviceName);
                          }
                        });
                      },
                      activeColor: AppColors.primary,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0, right: 16.0, bottom: AppDimensions.paddingS),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Statut du stock pour "$serviceName"',
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          value: _serviceStockStatus[serviceName] ?? 'disponible',
                          items: ['disponible', 'faible', 'epuise'].map((String status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status.replaceFirst(status[0], status[0].toUpperCase())),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _serviceStockStatus[serviceName] = newValue!;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty ? 'Statut requis' : null,
                        ),
                      ),
                    const Divider(height: AppDimensions.paddingS),
                  ],
                );
              }).toList(),

              const SizedBox(height: AppDimensions.paddingL),

              // Affichage de la Localisation (non modifiable pour l'instant)
              Text(
                'Localisation Actuelle (Non Modifiable)',
                style: AppTextStyles.h2.copyWith(fontSize: 18),
              ),
              const SizedBox(height: AppDimensions.paddingS),
              ListTile(
                leading: const Icon(Icons.location_on, color: AppColors.textSecondary),
                title: Text(merchant?.latitude != null && merchant?.longitude != null
                    ? 'Lat: ${merchant!.latitude!.toStringAsFixed(4)}, Lng: ${merchant.longitude!.toStringAsFixed(4)}'
                    : 'Localisation non définie'),
                subtitle: const Text('Pour modifier, veuillez contacter le support (prochainement modifiable ici).'),
              ),
              const SizedBox(height: AppDimensions.paddingL),


              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                CustomButton(
                  text: 'Sauvegarder les modifications',
                  onPressed: _saveProfile,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
