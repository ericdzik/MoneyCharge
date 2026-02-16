import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/utils/route_guards.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/features/auth/widgets/auth_background_widget.dart';
import 'package:locacharge/core/logging.dart';
import 'package:logger/logger.dart';

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
  void initState() {
    super.initState();
    // Configuration de la barre de statut transparente avec icônes blancs
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

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

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    appLogger.i('[Login] Attempt for $email');

    try {
      appLogger.d('[Login] Calling authProvider.loginUnified');
      await authProvider.loginUnified(email, password);
      appLogger.d(
        '[Login] loginUnified completed. isAuthenticated=${authProvider.isAuthenticated} userType=${authProvider.userType} error=${authProvider.error}',
      );

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        appLogger.i('[Login] Success. UserType=${authProvider.userType}');
        final defaultRoute = RouteGuards.getDefaultRouteForUserType(
          authProvider.userType,
        );
        appLogger.d('[Login] Navigating to $defaultRoute');
        Navigator.pushReplacementNamed(context, defaultRoute);

        SnackBarHelper.showSuccess(
          context,
          'Connexion réussie en tant que ${_getRoleDisplayName(authProvider.userType)}',
        );
      } else {
        appLogger.w('[Login] Failed. error=${authProvider.error}');
        SnackBarHelper.showError(
          context,
          authProvider.error ?? 'Email ou mot de passe incorrect.',
        );
      }
    } catch (e, s) {
      appLogger.log(
        Level.error,
        '[Login] Exception during _handleLogin',
        error: e,
        stackTrace: s,
      );
      if (!mounted) return;
      SnackBarHelper.showError(
        context,
        authProvider.error ?? 'Erreur inattendue: ${e.toString()}',
      );
    }
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: AuthBackgroundWidget(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              context.isExtraSmall ? 16 : AppDimensions.paddingL,
              MediaQuery.of(context).padding.top +
                  (context.isSmall ? 16 : AppDimensions.paddingXL),
              context.isExtraSmall ? 16 : AppDimensions.paddingL,
              AppDimensions.paddingXL,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Logo icône élégant
                  Container(
                    width: ResponsiveHelper.getResponsiveValue(
                      context,
                      extraSmall: 70,
                      medium: 90,
                    ),
                    height: ResponsiveHelper.getResponsiveValue(
                      context,
                      extraSmall: 70,
                      medium: 90,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(
                          context,
                          baseRadius: 28,
                        ),
                      ),
                      border: Border.all(
                        color: AppColors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: ResponsiveHelper.getIconSize(context, baseSize: 48),
                      color: AppColors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Titre élégant
                  Text(
                    'Bienvenue',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        baseSize: 36,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Connectez-vous à votre compte',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.white.withValues(alpha: 0.85),
                      fontSize: ResponsiveHelper.getFontSize(
                        context,
                        baseSize: 16,
                      ),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 56),

                  // Champ Email personnalisé
                  _buildCustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'votre@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez saisir votre email';
                      }
                      if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(value.trim())) {
                        return 'Email invalide';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Champ Mot de passe personnalisé
                  _buildCustomTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: !_obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.white.withValues(alpha: 0.7),
                        size: 22,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir votre mot de passe';
                      }
                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au minimum 6 caractères';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Lien mot de passe oublié élégant
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        'Mot de passe oublié ?',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.white.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            baseSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Boutons Se connecter et S'inscrire côte à côte
                  Row(
                    children: [
                      // Bouton Se connecter
                      Expanded(
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return _AnimatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleLogin,
                              isLoading: authProvider.isLoading,
                              text: 'Se connecter',
                              width: null,
                              height: ResponsiveHelper.getButtonHeight(context),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Bouton S'inscrire
                      Expanded(
                        child: _AnimatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.register);
                          },
                          isLoading: false,
                          text: 'S\'inscrire',
                          width: null,
                          height: ResponsiveHelper.getButtonHeight(context),
                          backgroundColor: AppColors.yellow,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Lien compte marchand
                  _buildMerchantLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Champ de texte personnalisé élégant avec effet glassmorphism et focus
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
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
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 15),
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
                _FocusableTextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  hint: hint,
                  icon: icon,
                  suffixIcon: suffixIcon,
                  hasError: formFieldState.hasError,
                  onChanged: (value) {
                    formFieldState.didChange(value);
                  },
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

  /// Lien compte marchand
  Widget _buildMerchantLink() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            'Vous êtes un marchand ?',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 15),
            ),
          ),
          const SizedBox(height: 16),

          _AnimatedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.merchantRegister);
            },
            isLoading: false,
            text: 'Créer un compte marchand',
            width: double.infinity,
            height: ResponsiveHelper.getResponsiveValue(
              context,
              extraSmall: 44,
              medium: 50,
            ),
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 15),
            backgroundColor: AppColors.orange,
          ),
        ],
      ),
    );
  }
}

/// TextField avec effet de focus sur la bordure
class _FocusableTextField extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String hint;
  final IconData icon;
  final Widget? suffixIcon;
  final bool hasError;
  final Function(String) onChanged;

  const _FocusableTextField({
    required this.controller,
    required this.keyboardType,
    required this.obscureText,
    required this.hint,
    required this.icon,
    required this.suffixIcon,
    required this.hasError,
    required this.onChanged,
  });

  @override
  State<_FocusableTextField> createState() => _FocusableTextFieldState();
}

class _FocusableTextFieldState extends State<_FocusableTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: widget.hasError
              ? AppColors.error.withValues(alpha: 0.8)
              : _isFocused
              ? AppColors.yellow.withValues(alpha: 0.8)
              : AppColors.white.withValues(alpha: 0.25),
          width: _isFocused ? 2.0 : 1.5,
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
        borderRadius: BorderRadius.circular(30),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          style: AppTextStyles.body1.copyWith(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: AppColors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.transparent,
            hintText: widget.hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.white.withValues(alpha: 0.4),
              fontSize: 15,
            ),
            prefixIcon: Icon(
              widget.icon,
              color: _isFocused
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.7),
              size: 22,
            ),
            suffixIcon: widget.suffixIcon,
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
          onChanged: widget.onChanged,
        ),
      ),
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
  final double? fontSize;
  final Color? backgroundColor;

  const _AnimatedButton({
    required this.onPressed,
    required this.isLoading,
    this.text,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor,
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
                  widget.backgroundColor ?? AppColors.white,
                  (widget.backgroundColor ?? AppColors.white).withValues(
                    alpha: 0.95,
                  ),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? AppColors.white).withValues(
                    alpha: 0.3,
                  ),
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
                      widget.text ?? 'Se connecter',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.fontSize ?? 17,
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
