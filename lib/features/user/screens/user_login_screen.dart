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
    print(
      '[UnifiedLoginScreen._handleLogin] Attempting login for ${_emailController.text}',
    );

    try {
      print(
        '[UnifiedLoginScreen._handleLogin] Calling await authProvider.loginUnified...',
      );
      await authProvider.loginUnified(
        _emailController.text,
        _passwordController.text,
      );
      print(
        '[UnifiedLoginScreen._handleLogin] After await authProvider.loginUnified completed.',
      );
      print('[UnifiedLoginScreen._handleLogin] Current authProvider state:');
      print(
        '[UnifiedLoginScreen._handleLogin]   isAuthenticated: ${authProvider.isAuthenticated}',
      );
      print(
        '[UnifiedLoginScreen._handleLogin]   userType: ${authProvider.userType}',
      );
      print('[UnifiedLoginScreen._handleLogin]   error: ${authProvider.error}');
      print(
        '[UnifiedLoginScreen._handleLogin]   isLoading: ${authProvider.isLoading}',
      );

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        print(
          '[UnifiedLoginScreen._handleLogin] User IS Authenticated. UserType: ${authProvider.userType}',
        );
        final defaultRoute = RouteGuards.getDefaultRouteForUserType(
          authProvider.userType,
        );
        print(
          '[UnifiedLoginScreen._handleLogin] Navigating to defaultRoute: $defaultRoute',
        );
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
        print(
          '[UnifiedLoginScreen._handleLogin] User IS NOT Authenticated. Error: ${authProvider.error}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Email ou mot de passe incorrect.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      print(
        '[UnifiedLoginScreen._handleLogin] Caught exception during _handleLogin: ${e.toString()}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.error ?? "Erreur inattendue: ${e.toString()}",
          ),
          backgroundColor: AppColors.error,
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
                    Color.fromRGBO(
                      30,
                      58,
                      138,
                      0.7,
                    ), // #1E3A8A avec opacité 0.7
                    Color.fromRGBO(
                      29,
                      78,
                      216,
                      0.7,
                    ), // #1D4ED8 avec opacité 0.7
                  ],
                ),
              ),
            ),
          ),
          // Contenu du formulaire
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingL,
                vertical: AppDimensions.paddingXL,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Header avec logo et titre
                    const SizedBox(height: 40),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
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
                        Icons.login_rounded,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Bienvenue',
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connectez-vous à votre compte',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Carte de connexion
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Veuillez entrer un email valide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Champs Mot de passe
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

                          // Lien mot de passe oublié
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.forgotPassword,
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                              ),
                              child: Text(
                                'Mot de passe oublié ?',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton Connexion
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.yellow,
                                      AppColors.orange,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.orange.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          'Se connecter',
                                          style: AppTextStyles.button.copyWith(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Liens d'inscription
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Lien inscription utilisateur
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Pas encore de compte ? ',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.register,
                                  );
                                },
                                child: Text(
                                  'S\'inscrire',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Lien inscription marchand
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Vous êtes un marchand ? ',
                                style: AppTextStyles.body2.copyWith(
                                  color: AppColors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.merchantRegister,
                                  );
                                },
                                child: Text(
                                  'Devenir partenaire',
                                  style: AppTextStyles.body2.copyWith(
                                    color: AppColors.yellow,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Logo en bas
                    Center(
                      child: Image.asset(
                        'assets/splash/24.png',
                        height: 120,
                        width: 120,
                      ),
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
}
