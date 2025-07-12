import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/route_guards.dart';
import '../../../providers/auth_provider.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
final _passwordController = TextEditingController();

  bool _obscurePassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print('-----------------------------------------------------');
    print('[UnifiedLoginScreen._handleLogin] Attempting login for ${_emailController.text}');

    try {
      print('[UnifiedLoginScreen._handleLogin] Calling await authProvider.loginUnified...');
      await authProvider.loginUnified(
        _emailController.text,
        _passwordController.text,
      );
      print('[UnifiedLoginScreen._handleLogin] After await authProvider.loginUnified completed.');
      print('[UnifiedLoginScreen._handleLogin] Current authProvider state:');
      print('[UnifiedLoginScreen._handleLogin]   isAuthenticated: ${authProvider.isAuthenticated}');
      print('[UnifiedLoginScreen._handleLogin]   userType: ${authProvider.userType}');
      print('[UnifiedLoginScreen._handleLogin]   error: ${authProvider.error}');
      print('[UnifiedLoginScreen._handleLogin]   isLoading: ${authProvider.isLoading}');


      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        print('[UnifiedLoginScreen._handleLogin] User IS Authenticated. UserType: ${authProvider.userType}');
        final defaultRoute = RouteGuards.getDefaultRouteForUserType(
          authProvider.userType,
        );
        print('[UnifiedLoginScreen._handleLogin] Navigating to defaultRoute: $defaultRoute');
        Navigator.pushReplacementNamed(context, defaultRoute);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connexion réussie en tant que ${_getRoleDisplayName(authProvider.userType)}',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        print('[UnifiedLoginScreen._handleLogin] User IS NOT Authenticated. Error: ${authProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Email ou mot de passe incorrect.'),
            backgroundColor: AppColors.error, // Correction ici
          ),
        );
      }
    } catch (e) {
      print('[UnifiedLoginScreen._handleLogin] Caught exception during _handleLogin: ${e.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? "Erreur inattendue: ${e.toString()}"),
          backgroundColor: AppColors.error, // Correction ici
        ),
      );
    }
    print('-----------------------------------------------------');
  }

  String _getRoleDisplayName(UserType? userType) {
    switch (userType) {
      case UserType.admin:
        return 'Administrateur';
      case UserType.merchant:
        return 'Marchand';
      case UserType.user:
        return 'Utilisateur';
      default:
        return 'Utilisateur';
    }
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        // 🔴 Image de fond
        Positioned.fill(
          child: Image.asset(
            'assets/splash/32.png', // Vérifie le chemin
            fit: BoxFit.cover,
          ),
        ),

        // 🔵 Contenu principal
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.paddingL),
                children: [
                  const SizedBox(height: AppDimensions.paddingXL),
                  Column(
                    children: [
                      /**Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        //child: const Icon(
                          //Icons.my_location,
                          //color: AppColors.onPrimary,
                         // size: 40,
                        //),
                      ),**/
                      const SizedBox(height: 24),
                      Text(
                        'CONNEXION',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 28,
                          color: const Color.fromARGB(255, 35, 82, 37),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '',
                        style: AppTextStyles.body2.copyWith(
                          color: const Color.fromARGB(255, 11, 1, 1),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  // Champs Email
                  CustomTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'votre@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Veuillez entrer un email valide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Champs Mot de passe
                  CustomTextField(
                    controller: _passwordController,
                    labelText: 'Mot de passe',
                    hintText: '••••••••',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: const Color.fromARGB(255, 5, 3, 3),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Lien mot de passe oublié
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyles.body2.copyWith(
                          color: const Color.fromARGB(255, 35, 82, 37),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bouton Connexion
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomButton(
                        text: authProvider.isLoading ? 'Connexion...' : 'Se connecter',
                        onPressed: authProvider.isLoading ? null : _handleLogin,
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.paddingM),

                  // Lien inscription
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Pas encore de compte ? ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: Text(
                          'S\'inscrire',
                          style: AppTextStyles.body2.copyWith(
                            color: const Color.fromARGB(255, 35, 82, 37),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Lien marchand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Vous êtes un marchand ? ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.merchantRegister);
                        },
                        child: Text(
                          'Devenir partenaire',
                          style: AppTextStyles.body2.copyWith(
                            color: const Color.fromARGB(255, 35, 82, 37),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingXL),

                  // Footer
                  /**Text(
                    '© 2025 Geo Money&Charge - Tous droits réservés',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),**/
                  const SizedBox(height: AppDimensions.paddingM),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}