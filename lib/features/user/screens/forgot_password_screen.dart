import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/constants/app_routes.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/core/widgets/custom_text_field.dart';
import 'package:locacharge/features/user/widgets/auth_shell.dart';
import 'package:locacharge/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEmailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: _isEmailSent ? 'Email envoyé !' : 'Mot de passe oublié ?',
      subtitle: _isEmailSent
          ? 'Nous avons envoyé un lien de réinitialisation à votre adresse email.'
          : 'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
      icon: _isEmailSent ? Icons.email_rounded : Icons.lock_reset_rounded,
      card: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_isEmailSent) ...[
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
              const SizedBox(height: 20),
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
                      onPressed: authProvider.isLoading
                          ? null
                          : _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: authProvider.isLoading
                          ? const LoadingIndicator.small(
                              color: AppColors.white,
                            )
                          : Text(
                              'Envoyer le lien',
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
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Vérifiez votre boîte email',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Si vous ne recevez pas l\'email dans les 5 minutes, vérifiez vos spams.',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.white.withOpacity(0.85),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
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
                  onPressed: _handleResendEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Renvoyer l\'email',
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isEmailSent = false;
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  side: const BorderSide(color: AppColors.white),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Changer d\'email',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottom: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.white.withOpacity(0.18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Retour à la ',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text(
                'connexion',
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

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    try {
      await authProvider.resetPassword(_emailController.text);
      if (!mounted) return;

      if (authProvider.error == null) {
        setState(() {
          _isEmailSent = true;
        });
        SnackBarHelper.showSuccess(
          context,
          'Email de réinitialisation envoyé avec succès.',
        );
      } else {
        SnackBarHelper.showError(
          context,
          authProvider.error ?? 'Erreur lors de l\'envoi de l\'email.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        authProvider.error ?? e.toString(),
      );
    }
  }

  Future<void> _handleResendEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    try {
      await authProvider.resetPassword(_emailController.text);
      if (!mounted) return;

      if (authProvider.error == null) {
        SnackBarHelper.showSuccess(
          context,
          'Email de réinitialisation renvoyé avec succès.',
        );
      } else {
        SnackBarHelper.showError(
          context,
          authProvider.error ?? 'Erreur lors du renvoi de l\'email.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        authProvider.error ?? e.toString(),
      );
    }
  }
}
