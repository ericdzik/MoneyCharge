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
  final _emailController = TextEditingController(text: 'user@example.com');
  final _passwordController = TextEditingController(text: 'password123');
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
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('[UnifiedLoginScreen._handleLogin] Caught exception during _handleLogin: ${e.toString()}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? "Erreur inattendue: ${e.toString()}"),
          backgroundColor: Colors.red,
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
      body: SafeArea(
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
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.phone_android,
                        color: AppColors.onPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Geo Money&Charge',
                      style: AppTextStyles.h1.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '----------------------------------------------',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 48),

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
                      return 'Veuillez entrer votre mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.forgotPassword);
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTextStyles.body2.copyWith(
                        color: const Color.fromARGB(255, 46, 125, 50),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: authProvider.isLoading
                          ? 'Connexion...'
                          : 'Se connecter',
                      onPressed: authProvider.isLoading ? null : _handleLogin,
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.paddingM),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible( // Make text flexible
                      child: Text(
                        'Pas encore de compte ? ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.end, // Align if it wraps to keep it neat
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: Flexible( // Make tappable text flexible
                        child: Text(
                          'S\'inscrire',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible( // Make text flexible
                      child: Text(
                        'Vous êtes un marchand ? ',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.end, // Align if it wraps
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.merchantRegister,
                        );
                      },
                      child: Flexible( // Make tappable text flexible
                        child: Text(
                          'Devenir partenaire',
                          style: AppTextStyles.body2.copyWith(
                            color: const Color.fromARGB(255, 46, 125, 50),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                        ),
                      ),
                    ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.paddingXL),

                Text(
                  '© 2025 Geo Money&Charge - Tous droits réservés',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.paddingM),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleInfo(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '- $description',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailExample(String email, String role) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            email,
            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '- $role',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
