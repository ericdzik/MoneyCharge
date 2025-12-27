import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/utils/route_guards.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/features/user/widgets/auth_shell.dart';
import 'package:locacharge/providers/auth_provider.dart';

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

        SnackBarHelper.showSuccess(
          context,
          'Connexion réussie en tant que ${_getRoleDisplayName(authProvider.userType)}',
        );
      } else {
        print(
          '[UnifiedLoginScreen._handleLogin] User IS NOT Authenticated. Error: ${authProvider.error}',
        );
        SnackBarHelper.showError(
          context,
          authProvider.error ?? 'Email ou mot de passe incorrect.',
        );
      }
    } catch (e) {
      print(
        '[UnifiedLoginScreen._handleLogin] Caught exception during _handleLogin: ${e.toString()}',
      );
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        authProvider.error ?? "Erreur inattendue: ${e.toString()}",
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
    return AuthShell(
      title: 'Bienvenue',
      subtitle: 'Connectez-vous à votre compte',
      icon: Icons.login_rounded,
      card: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'votre@email.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final requiredError = FormValidators.required(
                  'Veuillez entrer votre email',
                )(value);
                if (requiredError != null) return requiredError;
                return FormValidators.email(value);
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
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              validator: (value) {
                final requiredError = FormValidators.required(
                  'Veuillez entrer votre mot de passe',
                )(value);
                if (requiredError != null) return requiredError;
                return FormValidators.minLength(
                  6,
                  'Le mot de passe doit contenir au moins 6 caractères',
                )(value);
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.forgotPassword);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: Text(
                  'Mot de passe oublié ?',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.yellow, AppColors.orange],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.orange.withOpacity(0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const LoadingIndicator.small(color: AppColors.white)
                        : Text(
                            'Se connecter',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
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
      bottom: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.white.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  'Pas encore de compte ?',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.register);
                  },
                  child: Text(
                    'S\'inscrire',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Text(
                  'Vous êtes un marchand ?',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.merchantRegister);
                  },
                  child: Text(
                    'Créer un compte marchand',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.yellow,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      secondary: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          'En continuant, vous acceptez nos Conditions Générales et notre Politique de Confidentialité.',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.white.withOpacity(0.82),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

