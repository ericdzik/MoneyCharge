import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/logging.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/features/auth/widgets/auth_background_widget.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Clés et contrôleurs
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  // État local
  bool _isEmailSent = false;

  // Constantes UI
  static const double _iconSize = 80.0;
  static const double _titleFontSize = 32.0;
  static const double _descriptionFontSize = 16.0;
  static const double _buttonWidth = 250.0;
  static const double _buttonHeight = 58.0;
  static const double _fieldBorderRadius = 30.0;

  @override
  void initState() {
    super.initState();
    appLogger.d('ForgotPasswordScreen: Initialisation');
    _configureStatusBar();
  }

  @override
  void dispose() {
    _emailController.dispose();
    appLogger.d('ForgotPasswordScreen: Dispose');
    super.dispose();
  }

  /// Configure la barre de statut transparente
  void _configureStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
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
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 24,
                right: 24,
                bottom: 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // En-tête avec icône et textes
                      _buildHeader(),

                      const SizedBox(height: 60),

                      // Formulaire ou confirmation
                      if (!_isEmailSent) ...[
                        _buildEmailField(),
                        const SizedBox(height: 40),
                        _buildSendButton(),
                        const SizedBox(height: 32),
                        _buildBackToLoginLink(),
                      ] else ...[
                        _buildSuccessButton(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construit l'en-tête avec icône, titre et description
  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          _isEmailSent ? Icons.email_rounded : Icons.lock_reset_rounded,
          size: _iconSize,
          color: AppColors.white,
        ),
        const SizedBox(height: 24),
        Text(
          _isEmailSent ? 'Email envoyé !' : 'Mot de passe oublié ?',
          style: AppTextStyles.h1.copyWith(
            fontSize: _titleFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _isEmailSent
              ? 'Nous avons envoyé un lien de réinitialisation à votre adresse email.'
              : 'Entrez votre adresse email pour recevoir un lien de réinitialisation.',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: _descriptionFontSize,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construit le champ email avec validation
  Widget _buildEmailField() {
    return _buildCustomTextField(
      controller: _emailController,
      label: 'Email',
      hint: 'votre@email.com',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
    );
  }

  /// Valide le format de l'email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  /// Construit le bouton d'envoi du lien
  Widget _buildSendButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Center(
          child: _AnimatedButton(
            onPressed: authProvider.isLoading ? null : _handleResetPassword,
            isLoading: authProvider.isLoading,
            text: 'Envoyer le lien',
            width: _buttonWidth,
            height: _buttonHeight,
          ),
        );
      },
    );
  }

  /// Construit le bouton de retour après succès
  Widget _buildSuccessButton() {
    return Center(
      child: _AnimatedButton(
        onPressed: _navigateToLogin,
        isLoading: false,
        text: 'Retour à la connexion',
        width: _buttonWidth,
        height: _buttonHeight,
      ),
    );
  }

  /// Construit le lien de retour à la connexion
  Widget _buildBackToLoginLink() {
    return Center(
      child: TextButton(
        onPressed: _navigateToLogin,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        child: Text(
          'Retour à la connexion',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// Gère la réinitialisation du mot de passe
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      appLogger.w('ForgotPasswordScreen: Validation échouée');
      return;
    }

    final email = _emailController.text.trim();
    appLogger.i('ForgotPasswordScreen: Envoi du lien de réinitialisation pour $email');

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.resetPassword(email);
      if (!mounted) return;

      setState(() {
        _isEmailSent = true;
      });

      appLogger.i('ForgotPasswordScreen: Email envoyé avec succès');
      SnackBarHelper.showSuccess(
        context,
        'Lien de réinitialisation envoyé',
      );
    } catch (e) {
      if (!mounted) return;

      appLogger.e('ForgotPasswordScreen: Erreur lors de l\'envoi', error: e);
      SnackBarHelper.showError(
        context,
        authProvider.error ?? 'Erreur lors de l\'envoi',
      );
    }
  }

  /// Navigue vers l'écran de connexion
  void _navigateToLogin() {
    appLogger.d('ForgotPasswordScreen: Navigation vers login');
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  /// Champ de texte personnalisé élégant avec effet glassmorphism
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),

        // Champ de texte avec gestion d'erreur externe
        FormField<String>(
          validator: (_) => validator?.call(controller.text),
          builder: (formFieldState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(_fieldBorderRadius),
                    border: Border.all(
                      color: formFieldState.hasError
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : AppColors.white.withValues(alpha: 0.25),
                      width: 1.5,
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
                    borderRadius: BorderRadius.circular(_fieldBorderRadius),
                    child: TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        hintText: hint,
                        hintStyle: AppTextStyles.body2.copyWith(
                          color: AppColors.white.withValues(alpha: 0.4),
                          fontSize: 16,
                        ),
                        prefixIcon: Icon(
                          icon,
                          color: AppColors.white.withValues(alpha: 0.7),
                          size: 22,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                      onChanged: (value) {
                        formFieldState.didChange(value);
                      },
                    ),
                  ),
                ),

                // Message d'erreur affiché en dehors
                if (formFieldState.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 8),
                    child: Text(
                      formFieldState.errorText!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Bouton animé avec effet de scale au tap
class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? text;
  final double? width;
  final double? height;

  const _AnimatedButton({
    required this.onPressed,
    required this.isLoading,
    this.text,
    this.width,
    this.height,
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
      duration: const Duration(milliseconds: 150),
      vsync: this,
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

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? 200,
          height: widget.height ?? 58,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  AppColors.white.withValues(alpha: 0.95),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.white.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    )
                  : Text(
                      widget.text ?? 'Valider',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
