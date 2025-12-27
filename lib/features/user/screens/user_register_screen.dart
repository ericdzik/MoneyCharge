import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/features/user/widgets/auth_shell.dart';
import 'package:locacharge/providers/auth_provider.dart';

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
    return AuthShell(
      title: 'Créer un compte',
      subtitle: 'Rejoignez GEO et accédez à tous nos services',
      icon: Icons.person_add_rounded,
      card: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Nom complet',
              hintText: 'Votre nom complet',
              validator: (value) {
                final requiredError = FormValidators.required(
                  'Veuillez entrer votre nom',
                )(value);
                if (requiredError != null) return requiredError;
                return FormValidators.minLength(
                  2,
                  'Le nom doit contenir au moins 2 caractères',
                )(value);
              },
            ),
            const SizedBox(height: 16),
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
              controller: _phoneController,
              labelText: 'Téléphone',
              hintText: '+225 0123456789',
              keyboardType: TextInputType.phone,
              validator: FormValidators.required(
                'Veuillez entrer votre numéro de téléphone',
              ),
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
                  'Veuillez entrer un mot de passe',
                )(value);
                if (requiredError != null) return requiredError;
                return FormValidators.minLength(
                  6,
                  'Le mot de passe doit contenir au moins 6 caractères',
                )(value);
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
            const SizedBox(height: 14),
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
                  child: Text(
                    'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                    onPressed:
                        (!_acceptTerms || authProvider.isLoading)
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    await authProvider.registerUser(
                                      _nameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                    );
                                    if (mounted &&
                                        authProvider.isAuthenticated) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.home,
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Inscription réussie !'),
                                          backgroundColor: AppColors.success,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            authProvider.error ??
                                                'Erreur lors de l\'inscription',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
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
                            'Créer mon compte',
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Déjà un compte ? ',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text(
                'Se connecter',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.yellow,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      secondary: null,
    );
  }
}
