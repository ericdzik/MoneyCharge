import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/core/logging.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/features/auth/widgets/auth_background_widget.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  // Clés et contrôleurs
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // État local
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // Système d'étapes
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Constantes UI
  static const double _iconSize = 80.0;
  static const double _titleFontSize = 32.0;
  static const double _descriptionFontSize = 16.0;
  // _buttonHeight remplacé par ResponsiveHelper.getButtonHeight(context)

  @override
  void initState() {
    super.initState();
    appLogger.d('UserRegisterScreen: Initialisation');
    _configureStatusBar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    appLogger.d('UserRegisterScreen: Dispose');
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

  /// Passe à l'étape suivante
  void _nextStep() {
    if (_currentStep < 2) {
      // Validation de l'étape actuelle
      if (_currentStep == 0) {
        // Valider nom et email
        final nameError = _validateName(_nameController.text);
        final emailError = _validateEmail(_emailController.text);
        if (nameError != null || emailError != null) {
          setState(() {}); // Force la mise à jour pour afficher les erreurs
          return;
        }
      } else if (_currentStep == 1) {
        // Valider téléphone
        final phoneError = _validatePhone(_phoneController.text);
        if (phoneError != null) {
          setState(() {});
          return;
        }
      }

      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  /// Revient à l'étape précédente
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
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
            child: Column(
              children: [
                // En-tête avec indicateur d'étapes
                Padding(
                  padding: EdgeInsets.only(
                    top:
                        MediaQuery.of(context).padding.top +
                        ResponsiveHelper.getPadding(
                          context,
                          extraSmall: 10,
                          medium: 20,
                        ),
                    left: ResponsiveHelper.getPadding(
                      context,
                      extraSmall: 16,
                      medium: 24,
                    ),
                    right: ResponsiveHelper.getPadding(
                      context,
                      extraSmall: 16,
                      medium: 24,
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: ResponsiveHelper.getPadding(
                          context,
                          extraSmall: 10,
                          medium: 20,
                        ),
                      ),
                      _buildHeader(),
                      SizedBox(
                        height: ResponsiveHelper.getPadding(
                          context,
                          extraSmall: 20,
                          medium: 32,
                        ),
                      ),
                      _buildStepIndicator(),
                    ],
                  ),
                ),

                // Contenu des étapes
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [_buildStep1(), _buildStep2(), _buildStep3()],
                    ),
                  ),
                ),

                // Boutons de navigation
                Padding(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getPadding(
                      context,
                      extraSmall: 16,
                      medium: 24,
                    ),
                  ),
                  child: _buildNavigationButtons(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construit l'en-tête avec icône et textes
  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.person_add_rounded,
          size: ResponsiveHelper.getResponsiveValue(
            context,
            extraSmall: 60,
            medium: _iconSize,
          ),
          color: AppColors.white,
        ),
        const SizedBox(height: 24),
        Text(
          'Créer un compte',
          style: AppTextStyles.h1.copyWith(
            fontSize: ResponsiveHelper.getFontSize(
              context,
              baseSize: _titleFontSize,
            ),
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Rejoignez GEO et accédez à tous nos services',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.white.withValues(alpha: 0.9),
            fontSize: ResponsiveHelper.getFontSize(
              context,
              baseSize: _descriptionFontSize,
            ),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Construit l'indicateur d'étapes
  Widget _buildStepIndicator() {
    final steps = ['Infos', 'Contact', 'Sécurité'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getPadding(
          context,
          extraSmall: 16,
          medium: 24,
        ),
        vertical: 20,
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: ResponsiveHelper.getResponsiveValue(
                          context,
                          extraSmall: 32,
                          medium: 40,
                        ),
                        height: ResponsiveHelper.getResponsiveValue(
                          context,
                          extraSmall: 32,
                          medium: 40,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.yellow
                              : isCompleted
                              ? AppColors.success
                              : Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: ResponsiveHelper.getIconSize(
                                    context,
                                    baseSize: 20,
                                  ),
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? AppColors.primary
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveHelper.getFontSize(
                                      context,
                                      baseSize: 16,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[index],
                        style: TextStyle(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.6),
                          fontSize: ResponsiveHelper.getFontSize(
                            context,
                            baseSize: 11,
                          ),
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.only(bottom: 30),
                      color: isCompleted
                          ? AppColors.success
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// Étape 1 : Informations personnelles
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalMargin(context),
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 1/3 : Informations personnelles',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          _buildNameField(),
          const SizedBox(height: 20),

          _buildEmailField(),
        ],
      ),
    );
  }

  /// Étape 2 : Contact
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalMargin(context),
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 2/3 : Contact',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          _buildPhoneField(),
        ],
      ),
    );
  }

  /// Étape 3 : Sécurité
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getHorizontalMargin(context),
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Étape 3/3 : Sécurité',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 16),
            ),
          ),
          const SizedBox(height: 24),

          _buildPasswordField(),
          const SizedBox(height: 20),

          _buildConfirmPasswordField(),
          const SizedBox(height: 24),

          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  /// Construit les boutons de navigation
  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Bouton Précédent
        if (_currentStep > 0)
          Expanded(
            child: _AnimatedButton(
              onPressed: _previousStep,
              isLoading: false,
              text: 'Précédent',
              width: null,
              height: ResponsiveHelper.getButtonHeight(context),
              backgroundColor: AppColors.white.withValues(alpha: 0.2),
            ),
          ),

        if (_currentStep > 0) const SizedBox(width: 12),

        // Bouton Suivant / S'inscrire
        Expanded(
          flex: _currentStep == 0 ? 1 : 1,
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return _AnimatedButton(
                onPressed: _currentStep < 2
                    ? _nextStep
                    : (!_acceptTerms || authProvider.isLoading)
                    ? null
                    : _handleRegister,
                isLoading: _currentStep == 2 && authProvider.isLoading,
                text: _currentStep < 2 ? 'Suivant' : 'Créer mon compte',
                width: null,
                height: ResponsiveHelper.getButtonHeight(context),
                backgroundColor: AppColors.yellow,
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construit le champ nom
  Widget _buildNameField() {
    return _buildCustomTextField(
      controller: _nameController,
      label: 'Nom complet',
      hint: 'Votre nom complet',
      icon: Icons.person_outline_rounded,
      validator: _validateName,
    );
  }

  /// Construit le champ email
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

  /// Construit le champ téléphone
  Widget _buildPhoneField() {
    return _buildCustomTextField(
      controller: _phoneController,
      label: 'Téléphone',
      hint: '+228 90123456',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: _validatePhone,
    );
  }

  /// Construit le champ mot de passe
  Widget _buildPasswordField() {
    return _buildCustomTextField(
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
      validator: _validatePassword,
    );
  }

  /// Construit le champ confirmation mot de passe
  Widget _buildConfirmPasswordField() {
    return _buildCustomTextField(
      controller: _confirmPasswordController,
      label: 'Confirmer le mot de passe',
      hint: '••••••••',
      icon: Icons.lock_outline_rounded,
      obscureText: !_obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: AppColors.white.withValues(alpha: 0.7),
          size: 22,
        ),
        onPressed: () {
          setState(() {
            _obscureConfirmPassword = !_obscureConfirmPassword;
          });
        },
      ),
      validator: _validateConfirmPassword,
    );
  }

  /// Construit la checkbox des conditions d'utilisation
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppColors.yellow,
          checkColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.white.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        Expanded(
          child: Text(
            'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  /// Valide le nom
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre nom';
    }
    if (value.trim().length < 2) {
      return 'Le nom doit contenir au minimum 2 caractères';
    }
    return null;
  }

  /// Valide l'email
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre email';
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value.trim())) {
      return 'Email invalide';
    }
    return null;
  }

  /// Valide le téléphone
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Veuillez saisir votre numéro de téléphone';
    }
    return null;
  }

  /// Valide le mot de passe
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au minimum 6 caractères';
    }
    return null;
  }

  /// Valide la confirmation du mot de passe
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _passwordController.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  /// Gère l'inscription
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      appLogger.w('UserRegisterScreen: Validation échouée');
      return;
    }

    appLogger.i(
      'UserRegisterScreen: Inscription pour ${_emailController.text.trim()}',
    );

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        appLogger.i('UserRegisterScreen: Inscription réussie');
        SnackBarHelper.showSuccess(context, 'Inscription réussie !');
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;

      appLogger.e(
        'UserRegisterScreen: Erreur lors de l\'inscription',
        error: e,
      );
      SnackBarHelper.showError(
        context,
        authProvider.error ?? 'Erreur lors de l\'inscription',
      );
    }
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
          validator: validator != null
              ? (_) => validator(controller.text)
              : null,
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
        color: AppColors.white.withValues(alpha: 0.08),
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
            filled: false,
            hintText: widget.hint,
            hintStyle: AppTextStyles.body2.copyWith(
              color: AppColors.white.withValues(alpha: 0.4),
              fontSize: 16,
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
  final Color? backgroundColor;

  const _AnimatedButton({
    required this.onPressed,
    required this.isLoading,
    this.text,
    this.width,
    this.height,
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
