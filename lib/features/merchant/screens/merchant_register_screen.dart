import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
// Added import for CustomAppBar
import '../widgets/opening_hours_selector.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({super.key});

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  // final _openingHoursController = TextEditingController(); // Remplacé par _openingHours
  Map<String, dynamic> _openingHours = {};
  // final _servicesController = TextEditingController(); // Ancien champ texte pour les services, sera remplacé
  late TextEditingController _otherServiceController; // Pour le service "Autre"
  late TextEditingController
      _otherMerchantTypeController; // Pour le type de commerce "Autre"

  final List<String> _predefinedServices = [
    'Recharge de crédit',
    'Transfert d\'argent',
    'Achat de carte SIM',
  ];
  final Map<String, bool> _selectedServices = {};

  String? _selectedMerchantType;
  final List<String> _merchantTypes = [
    'Boutique',
    'Kiosque',
    'La poste',
    'Banque',
    'Agence',
    'Bar & Restaurant',
    'Alimentation générale',
    'Epicerie',
    'Autre',
  ];

  // Nouveau state pour le type de marchand (fixe ou mobile)
  String _merchantProfileType = 'fixed'; // 'fixed' ou 'mobile'

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isBusinessOwner = false;

  // Map related state variables
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  // Default initial position, will be updated if location is fetched.
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(5.359952, -4.008256), // Abidjan, Côte d'Ivoire
    zoom: 12,
  );
  bool _isLocationPermissionGranted = false;
  bool _isFetchingInitialLocation = true; // To show loading indicator for map

  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAndFetch();
    _otherServiceController = TextEditingController();
    _otherMerchantTypeController = TextEditingController();
    // Initialiser _selectedServices avec tous les services prédéfinis à false
    for (var service in _predefinedServices) {
      _selectedServices[service] = false;
    }
    _selectedServices['Autre'] = false; // Ajouter l'option "Autre"
  }

  Future<void> _requestLocationPermissionAndFetch() async {
    print("[MerchantRegisterScreen] Attempting to fetch initial location...");
    setState(() {
      _isFetchingInitialLocation = true;
    });

    if (kIsWeb) {
      print(
        "[MerchantRegisterScreen] Web platform detected. Skipping permission_handler. Geolocator will use browser API.",
      );
      // Pour le web, Geolocator.getCurrentPosition() déclenchera la demande de permission du navigateur.
      // On peut supposer que la permission est accordée si getCurrentPosition réussit.
      // Ou on peut vérifier le statut après, mais c'est moins direct qu'avec permission_handler sur mobile.
      // Pour simplifier, on va tenter de récupérer la position et mettre _isLocationPermissionGranted à true si ça marche.
      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        ).timeout(const Duration(seconds: 25));

        print(
          "[MerchantRegisterScreen] Web - Position fetched: Lat: ${position.latitude}, Lng: ${position.longitude}",
        );
        if (mounted) {
          _isLocationPermissionGranted =
              true; // Supposer true si la position est obtenue
          final userLocation = LatLng(position.latitude, position.longitude);
          setState(() {
            _cameraPosition = CameraPosition(target: userLocation, zoom: 15);
            // Placer automatiquement le marqueur
            _onMapTapped(userLocation);
          });
        }
      } catch (e) {
        print(
          "[MerchantRegisterScreen] Web - Error fetching position or permission denied by browser: $e",
        );
        _isLocationPermissionGranted =
            false; // Laisser à false en cas d'erreur/refus
        // La carte utilisera la position par défaut
      } finally {
        if (mounted) {
          setState(() {
            _isFetchingInitialLocation = false;
          });
        }
      }
    } else {
      // Logique existante pour mobile (Android/iOS)
      try {
        print(
          "[MerchantRegisterScreen] Mobile - Requesting location permission...",
        );
        PermissionStatus status = await Permission.locationWhenInUse.request();
        print("[MerchantRegisterScreen] Mobile - Permission status: $status");

        if (status.isGranted) {
          _isLocationPermissionGranted = true;
          print(
            "[MerchantRegisterScreen] Mobile - Location permission granted. Fetching current position...",
          );
          try {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 15),
            ).timeout(const Duration(seconds: 20));

            print(
              "[MerchantRegisterScreen] Mobile - Position fetched: Lat: ${position.latitude}, Lng: ${position.longitude}",
            );
            if (mounted) {
              final userLocation = LatLng(
                position.latitude,
                position.longitude,
              );
              setState(() {
                _cameraPosition = CameraPosition(
                  target: userLocation,
                  zoom: 15,
                );
                // Placer automatiquement le marqueur
                _onMapTapped(userLocation);
              });
            }
          } catch (e) {
            print(
              "[MerchantRegisterScreen] Mobile - Error fetching position: $e",
            );
          }
        } else {
          _isLocationPermissionGranted = false;
          print(
            "[MerchantRegisterScreen] Mobile - Location permission denied or restricted.",
          );
          if (mounted && (status.isPermanentlyDenied || status.isRestricted)) {
            print(
              "[MerchantRegisterScreen] Mobile - Consider guiding user to app settings for location permission.",
            );
          }
        }
      } catch (e) {
        print(
          "[MerchantRegisterScreen] Mobile - General error in _requestLocationPermissionAndFetch: $e",
        );
        _isLocationPermissionGranted = false;
      } finally {
        if (mounted) {
          setState(() {
            _isFetchingInitialLocation = false;
          });
        }
      }
    }
    print(
      "[MerchantRegisterScreen] Finished _requestLocationPermissionAndFetch. _isFetchingInitialLocation: $_isFetchingInitialLocation, _isLocationPermissionGranted: $_isLocationPermissionGranted",
    );
  }

  Widget _buildOpeningHoursSummary() {
    if (_openingHours.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: Text(
          'Aucun horaire défini.',
          style: TextStyle(color: Colors.white70),
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
      if (_openingHours.containsKey(day)) {
        final hoursMap = _openingHours[day] as Map<String, dynamic>;
        summary.add(
          Text(
            '$day: ${hoursMap['open']} - ${hoursMap['close']}',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: summary,
      ),
    );
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    // _openingHoursController.dispose();
    // _servicesController.dispose(); // Ancien contrôleur
    _otherServiceController.dispose(); // Nouveau contrôleur pour "Autre"
    _otherMerchantTypeController.dispose();
    super.dispose();
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: location,
          infoWindow: InfoWindow(
            title: 'Emplacement sélectionné',
            snippet:
                'Lat: ${location.latitude.toStringAsFixed(4)}, Lng: ${location.longitude.toStringAsFixed(4)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Image de fond
          Positioned.fill(
            child: Image.asset('assets/splash/25.png', fit: BoxFit.cover),
          ),
          // Overlay bleu avec opacité
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromRGBO(30, 58, 138, 0.7), // #1E3A8A avec opacité 0.7
                    Color.fromRGBO(29, 78, 216, 0.7), // #1D4ED8 avec opacité 0.7
                  ],
                ),
              ),
            ),
          ),
          // Contenu du formulaire
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo et titre
                    Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.store,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Devenez Partenaire',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28,
                            color:
                                Colors.white, // Changer couleur pour visibilité
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rejoignez notre réseau de points de service',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors
                                .white70, // texte secondaire en blanc pâle
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Informations du business
                    Text(
                      'Informations du Business',
                      style: AppTextStyles.h2.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _businessNameController,
                      labelText: 'Nom du business',
                      hintText: 'Ex: Boutique Express',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer le nom de votre business';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email professionnel',
                      hintText: 'business@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _phoneController,
                      labelText: 'Téléphone',
                      hintText: '+225 0123456789',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      controller: _addressController,
                      labelText: 'Adresse complète',
                      hintText: '123 Rue du Commerce, Ville',
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 24),

                  // Map Section
                  Text(
                    'Localisation sur la carte',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                      child: _isFetchingInitialLocation
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: AppDimensions.paddingS),
                                  Text('Chargement de la carte...'),
                                ],
                              ),
                            )
                          : GoogleMap(
                              initialCameraPosition: _cameraPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                                // Animate camera to the fetched position if it changed from default
                                if (_cameraPosition.target !=
                                    const LatLng(5.359952, -4.008256)) {
                                  controller.animateCamera(
                                    CameraUpdate.newCameraPosition(
                                      _cameraPosition,
                                    ),
                                  );
                                }
                              },
                              onTap: _onMapTapped,
                              markers: _markers,
                              myLocationButtonEnabled: true,
                              myLocationEnabled:
                                  _isLocationPermissionGranted, // Enable blue dot if permission granted
                              zoomControlsEnabled: true,
                            ),
                    ),
                  ),
                  if (!_isLocationPermissionGranted &&
                      !_isFetchingInitialLocation)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.paddingS,
                      ),
                      child: Text(
                        'Permission de localisation refusée. La carte est centrée sur une position par défaut.',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.outOfStock,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (_selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.paddingS,
                      ),
                      child: Text(
                        'Lieu sélectionné: Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppDimensions.paddingL),
                  // End of Map Section

                  // Merchant Type Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedMerchantType,
                    decoration: InputDecoration(
                      labelText: 'Type de commerce',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                    ),
                    hint: const Text('Sélectionnez un type'),
                    items: _merchantTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMerchantType = newValue;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Veuillez sélectionner un type de commerce'
                        : null,
                  ),
                  if (_selectedMerchantType == 'Autre')
                    Padding(
                      padding: const EdgeInsets.only(
                        top: AppDimensions.paddingM,
                      ),
                      child: CustomTextField(
                        controller: _otherMerchantTypeController,
                        labelText: 'Précisez le type de commerce',
                        hintText: 'Ex: Cordonnerie',
                        validator: (value) {
                          if (_selectedMerchantType == 'Autre' &&
                              (value == null || value.isEmpty)) {
                            return 'Veuillez préciser le type de commerce';
                          }
                          return null;
                        },
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Merchant Profile Type Selection
                  Text(
                    'Quel type de marchand êtes-vous ?',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Boutique (Fixe)'),
                          value: 'fixed',
                          groupValue: _merchantProfileType,
                          onChanged: (value) {
                            setState(() {
                              _merchantProfileType = value!;
                            });
                          },
                          activeColor: AppColors.secondary,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Ambulant (Mobile)'),
                          value: 'mobile',
                          groupValue: _merchantProfileType,
                          onChanged: (value) {
                            setState(() {
                              _merchantProfileType = value!;
                            });
                          },
                          activeColor: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // End of Merchant Profile Type Selection

                  // End of Merchant Type Dropdown
                  Text(
                    'Horaires d\'ouverture',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.yellow, AppColors.orange],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Définir les horaires',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
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
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                    ),
                  ),
                  _buildOpeningHoursSummary(),
                  const SizedBox(height: 24),

                  // Section Services Proposés
                  Text(
                    'Services Proposés',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingS),
                  ..._predefinedServices.map((service) {
                    return CheckboxListTile(
                      title: Text(
                        service,
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: _selectedServices[service],
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedServices[service] = value ?? false;
                        });
                      },
                      activeColor: AppColors.secondary,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                  CheckboxListTile(
                    title: const Text(
                      'Autre',
                      style: TextStyle(color: Colors.white),
                    ),
                    value: _selectedServices['Autre'],
                    onChanged: (bool? value) {
                      setState(() {
                        _selectedServices['Autre'] = value ?? false;
                        if (!(_selectedServices['Autre']!)) {
                          _otherServiceController.clear();
                        }
                      });
                    },
                    activeColor: AppColors.secondary,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  if (_selectedServices['Autre'] == true)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.paddingXL,
                        right: AppDimensions.paddingM,
                        bottom: AppDimensions.paddingM,
                      ),
                      child: CustomTextField(
                        controller: _otherServiceController,
                        labelText: 'Précisez le service "Autre"',
                        hintText: 'Ex: Réparation téléphone',
                        validator: (value) {
                          if (_selectedServices['Autre'] == true &&
                              (value == null || value.isEmpty)) {
                            return 'Veuillez préciser le service "Autre"';
                          }
                          return null;
                        },
                      ),
                    ),
                  // Fin Section Services Proposés
                  const SizedBox(height: 24),

                  // Informations de connexion
                  Text(
                    'Informations de Connexion',
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    hintText: '••••••••',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  CustomTextField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirmer le mot de passe',
                    hintText: '••••••••',
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }
                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Vérifications
                  Row(
                    children: [
                      Checkbox(
                        value: _isBusinessOwner,
                        onChanged: (value) {
                          setState(() {
                            _isBusinessOwner = value ?? false;
                          });
                        },
                        activeColor: AppColors.secondary,
                      ),
                      Expanded(
                        child: Text(
                          'Je confirme être le propriétaire ou un représentant autorisé de ce business',
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.secondary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.body2.copyWith(
                                color: Colors.white,
                              ),
                              children: [
                                const TextSpan(text: 'J\'accepte les '),
                                TextSpan(
                                  text: 'conditions d\'utilisation',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' et la '),
                                TextSpan(
                                  text: 'politique de confidentialité',
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Bouton d'inscription
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: authProvider.isLoading
                            ? 'Création...'
                            : 'Créer mon compte marchand',
                        onPressed:
                            (authProvider.isLoading ||
                                !_acceptTerms ||
                                !_isBusinessOwner)
                            ? null
                            : _handleRegister,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Lien de connexion
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Déjà un compte ? ',
                        style: AppTextStyles.body2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: Text(
                          'Se connecter',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Informations sur le processus
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Processus de validation :',
                          style: AppTextStyles.h3.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        _buildProcessStep('1', 'Soumission de votre demande'),
                        _buildProcessStep(
                          '2',
                          'Vérification par notre équipe (24-48h)',
                        ),
                        _buildProcessStep(
                          '3',
                          'Validation et activation de votre compte',
                        ),
                        _buildProcessStep(
                          '4',
                          'Accès à votre dashboard marchand',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Logo en bas
                  Center(
                    child: Image.asset(
                      'assets/splash/24.png',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer
                  Text(
                    '© 2024 LocaCharge - Tous droits réservés',
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.onSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegister() async {
    print("[RegisterAttempt] Trying to register...");
    // Ajout d'une vérification de nullité pour le currentState du formulaire
    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      print("[RegisterAttempt] FAILED: Form validation failed or form key is null.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs dans le formulaire.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    print("[RegisterAttempt] PASSED: Form validation.");

    if (!_acceptTerms) {
      print("[RegisterAttempt] FAILED: Terms not accepted.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    print("[RegisterAttempt] PASSED: Terms accepted.");

    if (_openingHours.isEmpty) {
      print("[RegisterAttempt] FAILED: Opening hours are empty.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez définir au moins un jour d\'ouverture.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    print("[RegisterAttempt] PASSED: Opening hours defined.");

    if (!_isBusinessOwner) {
      print("[RegisterAttempt] FAILED: Not confirmed as business owner.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez confirmer être le propriétaire du business'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    print("[RegisterAttempt] PASSED: Confirmed as business owner.");

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_selectedLocation == null) {
      print("[RegisterAttempt] FAILED: Location not selected.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un emplacement sur la carte.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    print("[RegisterAttempt] PASSED: Location selected.");

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

    // Validation: s'assurer qu'au moins un service est sélectionné ou que "Autre" est rempli
    if (finalServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner au moins un service ou préciser le service "Autre".',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Déterminer le type de marchand final
      String finalMerchantType;
      if (_selectedMerchantType == 'Autre') {
        finalMerchantType = _otherMerchantTypeController.text.trim();
      } else {
        finalMerchantType = _selectedMerchantType!;
      }

      await authProvider.registerMerchant(
        businessName: _businessNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        openingHours: _openingHours,
        // services: _servicesController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(), // Ancienne méthode
        services: finalServices, // Nouvelle méthode
        password: _passwordController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        merchantType: finalMerchantType, // Utilisation de la valeur finale
        profileType: _merchantProfileType, // Ajout du type de profil
      );

      if (!mounted) return;

      // Après l'appel, vérifier l'état.
      // Pour l'inscription marchand, même si le compte Auth est créé,
      // on pourrait vouloir attendre une validation admin.
      // Pour l'instant, on considère que si pas d'erreur, c'est "envoyé".
      // L'état isAuthenticated sera mis à jour par authStateChanges si l'utilisateur est connecté.
      if (authProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Demande d\'inscription envoyée ! Vous recevrez un email une fois votre compte validé.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        // Rediriger vers la page de connexion ou une page d'attente de validation.
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Erreur lors de l\'inscription.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
