import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.person_add,
                        color: AppColors.onPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Créer un compte',
                      style: AppTextStyles.h1.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rejoignez LocaCharge et accédez à tous nos services',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Formulaire
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Nom complet',
                  hintText: 'Votre nom complet',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  hintText: 'votre@email.com',
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

                // Conditions d'utilisation
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
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
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'J\'accepte les '),
                              TextSpan(
                                text: 'conditions d\'utilisation',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: ' et la '),
                              TextSpan(
                                text: 'politique de confidentialité',
                                style: TextStyle(
                                  color: AppColors.primary,
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
                          : 'Créer mon compte',
                      onPressed: (authProvider.isLoading || !_acceptTerms)
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
                    Flexible( // Make text flexible
                      child: Text(
                        'Déjà un compte ? ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.end, // Align if it wraps
                      ),
                    ),
                    const SizedBox(width: AppDimensions.paddingXS), // Add minimal spacing
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: Flexible( // Make tappable text flexible
                        child: Text(
                          'Se connecter',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Séparateur
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 32),

                // Boutons d'inscription alternative
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool useColumnLayout = constraints.maxWidth < 320; // Threshold for social buttons

                    if (useColumnLayout) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // Inscription avec Google
                            },
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                            label: const Text('Google'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.paddingS),
                          OutlinedButton.icon(
                            onPressed: () {
                              // Inscription avec Facebook
                            },
                            icon: const Icon(Icons.facebook, size: 24),
                            label: const Text('Facebook'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Inscription avec Google
                              },
                              icon: const Icon(Icons.g_mobiledata, size: 24),
                              label: const Text('Google'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Inscription avec Facebook
                              },
                              icon: const Icon(Icons.facebook, size: 24),
                              label: const Text('Facebook'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
                ),
                const SizedBox(height: 32),

                // Footer
                Text(
                  '© 2024 LocaCharge - Tous droits réservés',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions d\'utilisation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.registerUser(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      // Après l'inscription, Firebase connecte automatiquement l'utilisateur.
      // AuthProvider devrait refléter cet état via authStateChanges.
      if (authProvider.isAuthenticated) {
        // Rediriger vers la page d'accueil ou une page de vérification d'email si nécessaire
        Navigator.pushReplacementNamed(context, AppRoutes.home);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Vous êtes connecté.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Erreur d\'inscription.'),
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
