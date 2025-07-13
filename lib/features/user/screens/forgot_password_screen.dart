import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';

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
      appBar: CustomAppBar(
        title: 'Mot de passe oublié',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        showLogo: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              // Wrap main content in SingleChildScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment:
                    MainAxisAlignment.center, // Try to keep content centered
                children: [
                  // Adjust Spacers or use SizedBox for more predictable spacing if needed
                  // const Spacer(), // Spacer might behave differently in SingleChildScrollView if content is short
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ), // Example dynamic spacing
                  // Icône et titre
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
                        style: AppTextStyles.h1.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isEmailSent
                            ? 'Nous avons envoyé un lien de réinitialisation à votre adresse email.'
                            : 'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  if (!_isEmailSent) ...[
                    // Formulaire
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

                    // Bouton d'envoi
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
                    // Message de succès
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
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Boutons d'action
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

                  // const Spacer(), // Spacer might behave differently in SingleChildScrollView if content is short
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ), // Example dynamic spacing
                  // Lien de retour
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        // Make text flexible
                        child: Text(
                          'Retour à la ',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.end, // Align if it wraps
                        ),
                      ),
                      const SizedBox(
                        width: AppDimensions.paddingXS,
                      ), // Add minimal spacing
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        },
                        child: Flexible(
                          // Make tappable text flexible
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
      ),
    );
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError(); // Utiliser la méthode pour clearer l'erreur

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
    authProvider.clearError(); // Utiliser la méthode pour clearer l'erreur

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
