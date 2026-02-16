import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Widget d'exemple démontrant l'utilisation du système de responsivité
///
/// Ce widget peut être utilisé comme référence pour créer des composants responsifs
class ResponsiveExampleWidget extends StatelessWidget {
  const ResponsiveExampleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemple Responsive'),
        toolbarHeight: ResponsiveHelper.getAppBarHeight(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(
          ResponsiveHelper.getPadding(
            context,
            extraSmall: 12.0,
            medium: 16.0,
            tablet: 24.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage du type d'écran
            _ScreenTypeIndicator(),

            SizedBox(
              height: ResponsiveHelper.getPadding(
                context,
                extraSmall: 16.0,
                medium: 24.0,
              ),
            ),

            // Exemple de texte responsive
            _ResponsiveTextExample(),

            SizedBox(
              height: ResponsiveHelper.getPadding(
                context,
                extraSmall: 16.0,
                medium: 24.0,
              ),
            ),

            // Exemple d'image responsive
            _ResponsiveImageExample(),

            SizedBox(
              height: ResponsiveHelper.getPadding(
                context,
                extraSmall: 16.0,
                medium: 24.0,
              ),
            ),

            // Exemple de grille responsive
            _ResponsiveGridExample(),

            SizedBox(
              height: ResponsiveHelper.getPadding(
                context,
                extraSmall: 16.0,
                medium: 24.0,
              ),
            ),

            // Exemple de bouton responsive
            _ResponsiveButtonExample(),

            SizedBox(
              height: ResponsiveHelper.getPadding(
                context,
                extraSmall: 16.0,
                medium: 24.0,
              ),
            ),

            // Exemple de carte responsive
            _ResponsiveCardExample(),
          ],
        ),
      ),
    );
  }
}

/// Indicateur du type d'écran actuel
class _ScreenTypeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        ResponsiveHelper.getPadding(context, extraSmall: 12.0, medium: 16.0),
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
        ),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations d\'écran',
            style: AppTextStyles.h3.copyWith(
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          _InfoRow(label: 'Type', value: context.screenType),
          _InfoRow(
            label: 'Largeur',
            value: '${context.screenWidth.toStringAsFixed(0)}px',
          ),
          _InfoRow(
            label: 'Hauteur',
            value: '${context.screenHeight.toStringAsFixed(0)}px',
          ),
          _InfoRow(
            label: 'Orientation',
            value: context.isPortrait ? 'Portrait' : 'Paysage',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: AppTextStyles.body2.copyWith(
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              fontSize: ResponsiveHelper.getFontSize(context, baseSize: 14),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Exemple de texte avec différentes tailles
class _ResponsiveTextExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Textes Responsifs',
          style: AppTextStyles.h2.copyWith(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Titre principal (H1)',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 28),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Sous-titre (H2)',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 22),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Corps de texte normal avec une taille adaptative selon l\'écran',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 16),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Petit texte ou caption',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 12),
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Exemple d'image avec hauteur responsive
class _ResponsiveImageExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Image Responsive',
          style: AppTextStyles.h2.copyWith(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          height: ResponsiveHelper.getImageHeight(
            context,
            extraSmall: 150.0,
            small: 170.0,
            medium: 200.0,
            large: 220.0,
            tablet: 250.0,
          ),
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, baseRadius: 16),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              size: ResponsiveHelper.getIconSize(context, baseSize: 64),
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Exemple de grille responsive
class _ResponsiveGridExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Grille Responsive',
          style: AppTextStyles.h2.copyWith(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: ResponsiveHelper.getGridColumns(
            context,
            extraSmall: 2,
            medium: 3,
            tablet: 4,
          ),
          crossAxisSpacing: ResponsiveHelper.getGridSpacing(context),
          mainAxisSpacing: ResponsiveHelper.getGridSpacing(context),
          children: List.generate(
            6,
            (index) => Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context, baseRadius: 8),
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(
                      context,
                      baseSize: 24,
                    ),
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Exemple de bouton responsive
class _ResponsiveButtonExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bouton Responsive',
          style: AppTextStyles.h2.copyWith(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.getButtonHeight(context),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
                ),
              ),
            ),
            child: Text(
              'Bouton d\'action',
              style: TextStyle(
                fontSize: ResponsiveHelper.getFontSize(context, baseSize: 16),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Exemple de carte responsive
class _ResponsiveCardExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Carte Responsive',
          style: AppTextStyles.h2.copyWith(
            fontSize: ResponsiveHelper.getFontSize(context, baseSize: 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(
            ResponsiveHelper.getPadding(
              context,
              extraSmall: 12.0,
              medium: 16.0,
              tablet: 20.0,
            ),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, baseRadius: 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: ResponsiveHelper.getResponsiveValue(
                  context,
                  extraSmall: 60.0,
                  medium: 70.0,
                  tablet: 80.0,
                ),
                height: ResponsiveHelper.getResponsiveValue(
                  context,
                  extraSmall: 60.0,
                  medium: 70.0,
                  tablet: 80.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
                  ),
                ),
                child: Icon(
                  Icons.star,
                  size: ResponsiveHelper.getIconSize(context, baseSize: 32),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(
                width: ResponsiveHelper.getPadding(
                  context,
                  extraSmall: 12.0,
                  medium: 16.0,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titre de la carte',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          baseSize: 16,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Description avec texte adaptatif',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getFontSize(
                          context,
                          baseSize: 14,
                        ),
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
