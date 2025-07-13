import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';

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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash/25.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header avec bouton retour
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Mot de passe oublié',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Contenu principal
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  _isEmailSent ? Icons.email : Icons.lock_reset,
                                  color: AppColors.secondary,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                _isEmailSent
                                    ? 'Email envoyé !'
                                    : 'Mot de passe oublié ?',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 28,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isEmailSent
                                    ? 'Nous avons envoyé un lien de réinitialisation à votre adresse email.'
                                    : 'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
                                style: AppTextStyles.body2.copyWith(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),

                          if (!_isEmailSent) ...[
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
                            const SizedBox(height: 32),

                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return CustomButton(
                                  text: authProvider.isLoading
                                      ? 'Envoi...'
                                      : 'Envoyer le lien',
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleResetPassword,
                                );
                              },
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Vérifiez votre boîte email',
                                    style: AppTextStyles.h3.copyWith(
                                      color: Colors.green,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Si vous ne recevez pas l\'email dans les 5 minutes, vérifiez vos spams.',
                                    style: AppTextStyles.body2.copyWith(
                                      color: Colors.white70,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            CustomButton(
                              text: 'Renvoyer l\'email',
                              onPressed: _handleResendEmail,
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEmailSent = false;
                                });
                              },
                              child: const Text('Changer d\'email'),
                            ),
                          ],

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.1,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Retour à la ',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.paddingXS),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                                child: Flexible(
                                  child: Text(
                                    'connexion',
                                    style: AppTextStyles.body2.copyWith(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Logo en bas
                          Image.asset(
                            'assets/splash/24.png',
                            height: 200,
                            width: 200,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '© 2024 LocaCharge - Tous droits réservés',
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de réinitialisation envoyé avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Erreur lors de l\'envoi de l\'email.',
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

  Future<void> _handleResendEmail() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    try {
      await authProvider.resetPassword(_emailController.text);
      if (!mounted) return;

      if (authProvider.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email de réinitialisation renvoyé avec succès.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.error ?? 'Erreur lors du renvoi de l\'email.',
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
