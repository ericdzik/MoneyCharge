import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/logging.dart';
import 'package:locacharge/features/auth/widgets/auth_background_widget.dart';
import 'package:locacharge/features/auth/widgets/custom_dropdown_field.dart';
import 'package:locacharge/features/merchant/widgets/opening_hours_selector.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';

class MerchantRegisterScreen extends StatefulWidget {
  const MerchantRegisterScreen({super.key});

  @override
  State<MerchantRegisterScreen> createState() => _MerchantRegisterScreenState();
}

class _MerchantRegisterScreenState extends State<MerchantRegisterScreen> {
  // Constants
  static const double _sectionTitleFontSize = 18.0;
  static const double _mapHeight = 250.0;

  // Form
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otherServiceController = TextEditingController();
  final _otherMerchantTypeController = TextEditingController();
  final PageController _pageController = PageController();

  // State
  int _currentStep = 0;
  Map<String, dynamic> _openingHours = {};
  final Map<String, bool> _selectedServices = {};
  String? _selectedMerchantType;
  String _merchantProfileType = 'fixed';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _isBusinessOwner = false;

  // Location
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  CameraPosition _cameraPosition = const CameraPosition(
    target: LatLng(5.359952, -4.008256),
    zoom: 12,
  );
  bool _isLocationPermissionGranted = false;
  bool _isFetchingInitialLocation = true;

  // Data
  final List<String> _predefinedServices = [
    'Recharge de crédit',
    'Transfert d\'argent',
    'Achat de carte SIM',
  ];

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

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    for (var service in _predefinedServices) {
      _selectedServices[service] = false;
    }
    _selectedServices['Autre'] = false;

    _requestLocationPermissionAndFetch();
  }

  Future<void> _requestLocationPermissionAndFetch() async {
    appLogger.d('Tentative de récupération de la position initiale...');

    setState(() {
      _isFetchingInitialLocation = true;
    });

    if (kIsWeb) {
      appLogger.i('Plateforme Web détectée, utilisation de l\'API navigateur');

      try {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        ).timeout(const Duration(seconds: 25));

        appLogger.i(
          'Position récupérée: Lat: ${position.latitude}, Lng: ${position.longitude}',
        );

        if (mounted) {
          _isLocationPermissionGranted = true;
          final userLocation = LatLng(position.latitude, position.longitude);
          setState(() {
            _cameraPosition = CameraPosition(target: userLocation, zoom: 15);
            _onMapTapped(userLocation);
          });
        }
      } catch (e) {
        appLogger.w('Erreur lors de la récupération de la position Web: $e');
        _isLocationPermissionGranted = false;
      } finally {
        if (mounted) {
          setState(() {
            _isFetchingInitialLocation = false;
          });
        }
      }
    } else {
      try {
        appLogger.d(
          'Plateforme mobile, demande de permission de localisation...',
        );
        PermissionStatus status = await Permission.locationWhenInUse.request();
        appLogger.i('Statut de la permission: $status');

        if (status.isGranted) {
          _isLocationPermissionGranted = true;
          appLogger.d('Permission accordée, récupération de la position...');

          try {
            Position position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
              timeLimit: const Duration(seconds: 15),
            ).timeout(const Duration(seconds: 20));

            appLogger.i(
              'Position récupérée: Lat: ${position.latitude}, Lng: ${position.longitude}',
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
                _onMapTapped(userLocation);
              });
            }
          } catch (e) {
            appLogger.e('Erreur lors de la récupération de la position: $e');
          }
        } else {
          _isLocationPermissionGranted = false;
          appLogger.w('Permission de localisation refusée ou restreinte');

          if (mounted && (status.isPermanentlyDenied || status.isRestricted)) {
            appLogger.i(
              'Permission refusée définitivement, guidance vers les paramètres recommandée',
            );
          }
        }
      } catch (e) {
        appLogger.e('Erreur générale lors de la demande de permission: $e');
        _isLocationPermissionGranted = false;
      } finally {
        if (mounted) {
          setState(() {
            _isFetchingInitialLocation = false;
          });
        }
      }
    }

    appLogger.d(
      'Fin de la récupération de position. Chargement: $_isFetchingInitialLocation, Permission: $_isLocationPermissionGranted',
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
        color: Colors.black.withValues(alpha: 0.2),
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
    _otherServiceController.dispose();
    _otherMerchantTypeController.dispose();
    _pageController.dispose();
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

  // ============= Build Methods =============

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.yellow
                              : isCompleted
                              ? AppColors.success
                              : Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(Icons.check, color: Colors.white, size: 20)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepTitle(index),
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 30),
                      color: isCompleted
                          ? AppColors.success
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Business';
      case 1:
        return 'Localisation';
      case 2:
        return 'Services';
      case 3:
        return 'Sécurité';
      default:
        return '';
    }
  }

  Widget _buildCurrentStep() {
    return SizedBox(
      height: 600, // Hauteur suffisante pour le contenu le plus long
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SingleChildScrollView(child: _buildStep1()),
          SingleChildScrollView(child: _buildStep2()),
          SingleChildScrollView(child: _buildStep3()),
          SingleChildScrollView(child: _buildStep4()),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informations du Business',
          style: AppTextStyles.h2.copyWith(
            fontSize: _sectionTitleFontSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildCustomTextField(
          controller: _businessNameController,
          label: 'Nom du business',
          hint: 'Ex: Boutique Express',
          icon: Icons.store_outlined,
          validator: _validateBusinessName,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _emailController,
          label: 'Email professionnel',
          hint: 'business@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: _validateEmail,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _phoneController,
          label: 'Téléphone',
          hint: '+225 0123456789',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _addressController,
          label: 'Adresse complète',
          hint: '123 Rue du Commerce, Ville',
          icon: Icons.location_on_outlined,
          maxLines: 2,
          validator: _validateAddress,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Localisation & Type',
          style: AppTextStyles.h2.copyWith(
            fontSize: _sectionTitleFontSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildMapSection(),
        const SizedBox(height: 24),
        _buildMerchantTypeSection(),
        const SizedBox(height: 24),
        _buildProfileTypeSection(),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Services & Horaires',
          style: AppTextStyles.h2.copyWith(
            fontSize: _sectionTitleFontSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildServicesSection(),
        const SizedBox(height: 24),
        _buildOpeningHoursSection(),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sécurité & Confirmation',
          style: AppTextStyles.h2.copyWith(
            fontSize: _sectionTitleFontSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        _buildConnectionInfoSection(),
        const SizedBox(height: 24),
        _buildConfirmations(),
        const SizedBox(height: 24),
        _buildProcessInfo(),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 16, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_currentStep > 0)
            _AnimatedButton(
              onPressed: _previousStep,
              text: 'Précédent',
              icon: Icons.arrow_back,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              height: 52,
              width: 140,
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          _currentStep < 3
              ? _AnimatedButton(
                  onPressed: _nextStep,
                  text: 'Suivant',
                  icon: Icons.arrow_forward,
                  backgroundColor: AppColors.orange,
                  height: 52,
                  width: 140,
                )
              : Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    final bool isEnabled =
                        !authProvider.isLoading &&
                        _acceptTerms &&
                        _isBusinessOwner;
                    return _AnimatedButton(
                      onPressed: isEnabled ? _handleRegister : null,
                      isLoading: authProvider.isLoading,
                      text: authProvider.isLoading
                          ? 'Création...'
                          : 'Créer mon compte',
                      backgroundColor: AppColors.orange,
                      height: 52,
                      width: 180,
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Localisation sur la carte',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: _mapHeight,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _isFetchingInitialLocation
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.yellow,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chargement de la carte...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : GoogleMap(
                    initialCameraPosition: _cameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      if (_cameraPosition.target !=
                          const LatLng(5.359952, -4.008256)) {
                        controller.animateCamera(
                          CameraUpdate.newCameraPosition(_cameraPosition),
                        );
                      }
                    },
                    onTap: _onMapTapped,
                    markers: _markers,
                    myLocationButtonEnabled: true,
                    myLocationEnabled: _isLocationPermissionGranted,
                    zoomControlsEnabled: true,
                  ),
          ),
        ),
        if (!_isLocationPermissionGranted && !_isFetchingInitialLocation)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Permission de localisation refusée. La carte est centrée sur une position par défaut.',
              style: TextStyle(color: AppColors.error, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Lieu sélectionné: Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
              style: TextStyle(color: AppColors.success, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _buildMerchantTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomDropdownField<String>(
          label: 'Type de commerce',
          hint: 'Sélectionnez un type',
          icon: Icons.business_outlined,
          value: _selectedMerchantType,
          items: _merchantTypes,
          itemLabel: (item) => item,
          onChanged: (newValue) {
            setState(() {
              _selectedMerchantType = newValue;
            });
          },
          validator: (value) => value == null
              ? 'Veuillez sélectionner un type de commerce'
              : null,
        ),
        if (_selectedMerchantType == 'Autre') ...[
          const SizedBox(height: 16),
          _buildCustomTextField(
            controller: _otherMerchantTypeController,
            label: 'Précisez le type',
            hint: 'Ex: Cordonnerie',
            icon: Icons.edit_outlined,
            validator: (value) {
              if (_selectedMerchantType == 'Autre' &&
                  (value == null || value.isEmpty)) {
                return 'Veuillez préciser le type de commerce';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProfileTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quel type de marchand êtes-vous ?',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text(
                  'Boutique (Fixe)',
                  style: TextStyle(color: Colors.white),
                ),
                value: 'fixed',
                groupValue: _merchantProfileType,
                onChanged: (value) {
                  setState(() {
                    _merchantProfileType = value!;
                  });
                },
                activeColor: AppColors.yellow,
                dense: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text(
                  'Ambulant (Mobile)',
                  style: TextStyle(color: Colors.white),
                ),
                value: 'mobile',
                groupValue: _merchantProfileType,
                onChanged: (value) {
                  setState(() {
                    _merchantProfileType = value!;
                  });
                },
                activeColor: AppColors.yellow,
                dense: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOpeningHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Horaires d\'ouverture',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        _AnimatedButton(
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
          text: 'Définir les horaires',
          icon: Icons.timer_outlined,
          backgroundColor: AppColors.orange,
          width: double.infinity,
          height: 48,
        ),
        _buildOpeningHoursSummary(),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Services Proposés',
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        ..._predefinedServices.map((service) {
          return CheckboxListTile(
            title: Text(service, style: const TextStyle(color: Colors.white)),
            value: _selectedServices[service],
            onChanged: (bool? value) {
              setState(() {
                _selectedServices[service] = value ?? false;
              });
            },
            activeColor: AppColors.yellow,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),
        CheckboxListTile(
          title: const Text('Autre', style: TextStyle(color: Colors.white)),
          value: _selectedServices['Autre'],
          onChanged: (bool? value) {
            setState(() {
              _selectedServices['Autre'] = value ?? false;
              if (!(_selectedServices['Autre']!)) {
                _otherServiceController.clear();
              }
            });
          },
          activeColor: AppColors.yellow,
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (_selectedServices['Autre'] == true) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: _buildCustomTextField(
              controller: _otherServiceController,
              label: 'Précisez le service',
              hint: 'Ex: Réparation téléphone',
              icon: Icons.edit_outlined,
              validator: (value) {
                if (_selectedServices['Autre'] == true &&
                    (value == null || value.isEmpty)) {
                  return 'Veuillez préciser le service';
                }
                return null;
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConnectionInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Informations de Connexion',
          style: AppTextStyles.h2.copyWith(
            fontSize: _sectionTitleFontSize,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _passwordController,
          label: 'Mot de passe',
          hint: '••••••••',
          icon: Icons.lock_outlined,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: _validatePassword,
        ),
        const SizedBox(height: 16),
        _buildCustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirmer le mot de passe',
          hint: '••••••••',
          icon: Icons.lock_outlined,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white.withValues(alpha: 0.5),
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: _validateConfirmPassword,
        ),
      ],
    );
  }

  Widget _buildConfirmations() {
    return Column(
      children: [
        Row(
          children: [
            Checkbox(
              value: _isBusinessOwner,
              onChanged: (value) {
                setState(() {
                  _isBusinessOwner = value ?? false;
                });
              },
              activeColor: AppColors.yellow,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isBusinessOwner = !_isBusinessOwner;
                  });
                },
                child: Text(
                  'Je confirme être le propriétaire ou un représentant autorisé de ce business',
                  style: AppTextStyles.body2.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              activeColor: AppColors.yellow,
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
                    style: AppTextStyles.body2.copyWith(color: Colors.white),
                    children: [
                      const TextSpan(text: 'J\'accepte les '),
                      TextSpan(
                        text: 'conditions d\'utilisation',
                        style: TextStyle(
                          color: AppColors.yellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'politique de confidentialité',
                        style: TextStyle(
                          color: AppColors.yellow,
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
      ],
    );
  }

  Widget _buildProcessInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Processus de validation :',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildProcessStep('1', 'Soumission de votre demande'),
          _buildProcessStep('2', 'Vérification par notre équipe (24-48h)'),
          _buildProcessStep('3', 'Validation et activation de votre compte'),
          _buildProcessStep('4', 'Accès à votre dashboard marchand'),
        ],
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        FormField<String>(
          validator: validator != null
              ? (_) => validator(controller.text)
              : null,
          builder: (formFieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FocusableTextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  hint: hint,
                  icon: icon,
                  suffixIcon: suffixIcon,
                  maxLines: maxLines,
                  hasError: formFieldState.hasError,
                  onChanged: (value) {
                    formFieldState.didChange(value);
                  },
                ),
                if (formFieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8),
                    child: Text(
                      formFieldState.errorText!,
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: AuthBackgroundWidget(
          child: SafeArea(
            child: Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.1, 0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                        child: _buildCurrentStep(),
                      ),
                    ),
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessStep(String number, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.yellow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============= Validators =============

  String? _validateBusinessName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer le nom de votre business';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez entrer votre adresse';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // ============= Handlers =============

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
    _pageController.animateToPage(
      _currentStep,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        // Valider les infos business
        if (_businessNameController.text.trim().isEmpty) {
          SnackBarHelper.showError(
            context,
            'Veuillez entrer le nom de votre business',
          );
          return false;
        }
        if (_validateEmail(_emailController.text) != null) {
          SnackBarHelper.showError(context, 'Veuillez entrer un email valide');
          return false;
        }
        if (_phoneController.text.trim().isEmpty) {
          SnackBarHelper.showError(
            context,
            'Veuillez entrer votre numéro de téléphone',
          );
          return false;
        }
        if (_addressController.text.trim().isEmpty) {
          SnackBarHelper.showError(context, 'Veuillez entrer votre adresse');
          return false;
        }
        return true;

      case 1:
        // Valider localisation et type
        if (_selectedLocation == null) {
          SnackBarHelper.showWarning(
            context,
            'Veuillez sélectionner un emplacement sur la carte',
          );
          return false;
        }
        if (_selectedMerchantType == null) {
          SnackBarHelper.showError(
            context,
            'Veuillez sélectionner un type de commerce',
          );
          return false;
        }
        if (_selectedMerchantType == 'Autre' &&
            _otherMerchantTypeController.text.trim().isEmpty) {
          SnackBarHelper.showError(
            context,
            'Veuillez préciser le type de commerce',
          );
          return false;
        }
        return true;

      case 2:
        // Valider services et horaires
        bool hasService = _selectedServices.values.any((selected) => selected);
        if (!hasService) {
          SnackBarHelper.showWarning(
            context,
            'Veuillez sélectionner au moins un service',
          );
          return false;
        }
        if (_selectedServices['Autre'] == true &&
            _otherServiceController.text.trim().isEmpty) {
          SnackBarHelper.showError(
            context,
            'Veuillez préciser le service "Autre"',
          );
          return false;
        }
        if (_openingHours.isEmpty) {
          SnackBarHelper.showWarning(
            context,
            'Veuillez définir au moins un jour d\'ouverture',
          );
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  Future<void> _handleRegister() async {
    appLogger.d('Tentative d\'inscription marchand...');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      appLogger.w('Échec de la validation du formulaire');
      SnackBarHelper.showError(
        context,
        'Veuillez corriger les erreurs dans le formulaire.',
      );
      return;
    }
    appLogger.i('Validation du formulaire réussie');

    if (!_acceptTerms) {
      appLogger.w('Conditions non acceptées');
      SnackBarHelper.showWarning(
        context,
        'Veuillez accepter les conditions d\'utilisation',
      );
      return;
    }

    if (_openingHours.isEmpty) {
      appLogger.w('Horaires d\'ouverture non définis');
      SnackBarHelper.showWarning(
        context,
        'Veuillez définir au moins un jour d\'ouverture.',
      );
      return;
    }

    if (!_isBusinessOwner) {
      appLogger.w('Confirmation propriétaire manquante');
      SnackBarHelper.showWarning(
        context,
        'Veuillez confirmer être le propriétaire du business',
      );
      return;
    }

    if (_selectedLocation == null) {
      appLogger.w('Emplacement non sélectionné');
      SnackBarHelper.showWarning(
        context,
        'Veuillez sélectionner un emplacement sur la carte.',
      );
      return;
    }

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

    if (finalServices.isEmpty) {
      appLogger.w('Aucun service sélectionné');
      SnackBarHelper.showWarning(
        context,
        'Veuillez sélectionner au moins un service.',
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      String finalMerchantType;
      if (_selectedMerchantType == 'Autre') {
        finalMerchantType = _otherMerchantTypeController.text.trim();
      } else {
        finalMerchantType = _selectedMerchantType!;
      }

      appLogger.i('Envoi de la demande d\'inscription...');
      await authProvider.registerMerchant(
        businessName: _businessNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        openingHours: _openingHours,
        services: finalServices,
        password: _passwordController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        merchantType: finalMerchantType,
        profileType: _merchantProfileType,
      );

      if (!mounted) return;

      if (authProvider.error == null) {
        appLogger.i('Inscription marchand réussie');
        SnackBarHelper.showSuccess(
          context,
          'Demande d\'inscription envoyée ! Vous recevrez un email une fois votre compte validé.',
        );
        _navigateToLogin();
      } else {
        appLogger.e('Erreur lors de l\'inscription: ${authProvider.error}');
        SnackBarHelper.showError(
          context,
          authProvider.error ?? 'Erreur lors de l\'inscription.',
        );
      }
    } catch (e) {
      appLogger.e('Exception lors de l\'inscription: $e');
      if (!mounted) return;
      SnackBarHelper.showError(context, authProvider.error ?? e.toString());
    }
  }

  void _navigateToLogin() {
    appLogger.d('Navigation vers l\'écran de connexion');
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

// ============= Focusable TextField Widget =============

/// TextField avec effet de focus sur la bordure
class _FocusableTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String hint;
  final IconData icon;
  final Widget? suffixIcon;
  final int? maxLines;
  final bool hasError;
  final Function(String) onChanged;

  const _FocusableTextField({
    required this.controller,
    required this.keyboardType,
    required this.obscureText,
    required this.hint,
    required this.icon,
    required this.suffixIcon,
    required this.maxLines,
    required this.hasError,
    required this.onChanged,
  });

  @override
  State<_FocusableTextField> createState() => _FocusableTextFieldState();
}

class _FocusableTextFieldState extends State<_FocusableTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: widget.hasError
              ? AppColors.error.withValues(alpha: 0.8)
              : _isFocused
              ? AppColors.yellow.withValues(alpha: 0.8)
              : AppColors.white.withValues(alpha: 0.25),
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: AppColors.white,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
            ),
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// ============= Animated Button Widget =============

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? text;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;

  const _AnimatedButton({
    this.onPressed,
    this.isLoading = false,
    this.text,
    this.icon,
    this.width,
    this.height = 56,
    this.backgroundColor,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null || widget.isLoading
                ? null
                : LinearGradient(
                    colors: widget.backgroundColor != null
                        ? [widget.backgroundColor!, widget.backgroundColor!]
                        : [AppColors.yellow, AppColors.orange],
                  ),
            color: widget.onPressed == null || widget.isLoading
                ? Colors.grey.withValues(alpha: 0.3)
                : null,
            borderRadius: BorderRadius.circular(30),
            boxShadow: widget.onPressed != null && !widget.isLoading
                ? [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppColors.orange)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        if (widget.text != null)
                          Text(
                            widget.text!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
