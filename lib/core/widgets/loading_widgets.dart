import 'package:flutter/material.dart';

/// Widget de chargement uniforme pour toute l'application
/// 
/// Remplace les 26 occurrences de `Center(child: CircularProgressIndicator())`
/// par un widget centralisé avec options de personnalisation.
/// 
/// Usage:
/// ```dart
/// LoadingIndicator()
/// LoadingIndicator.small()
/// LoadingIndicator.large(message: 'Chargement...')
/// ```
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;
  final double strokeWidth;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size,
    this.color,
    this.strokeWidth = 4.0,
  });

  /// Petit indicateur de chargement (20x20)
  const LoadingIndicator.small({
    super.key,
    this.message,
    this.color,
  })  : size = 20,
        strokeWidth = 2.0;

  /// Indicateur de chargement moyen (40x40) - Par défaut
  const LoadingIndicator.medium({
    super.key,
    this.message,
    this.color,
  })  : size = 40,
        strokeWidth = 4.0;

  /// Grand indicateur de chargement (60x60)
  const LoadingIndicator.large({
    super.key,
    this.message,
    this.color,
  })  : size = 60,
        strokeWidth = 5.0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size ?? 40,
            height: size ?? 40,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget d'affichage d'erreur uniforme pour toute l'application
/// 
/// Remplace les affichages d'erreur inconsistants avec un widget
/// centralisé offrant retry, refresh, et navigation.
/// 
/// Usage:
/// ```dart
/// ErrorDisplay(message: 'Une erreur est survenue')
/// ErrorDisplay.withRetry(
///   message: 'Échec du chargement',
///   onRetry: () => loadData(),
/// )
/// ```
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;
  final String? retryButtonText;
  final VoidCallback? onGoBack;
  final String? subtitle;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.retryButtonText,
    this.onGoBack,
    this.subtitle,
  });

  /// Affichage d'erreur avec bouton de réessai
  const ErrorDisplay.withRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.subtitle,
  })  : icon = Icons.refresh,
        retryButtonText = 'Réessayer',
        onGoBack = null;

  /// Affichage d'erreur réseau
  const ErrorDisplay.network({
    super.key,
    this.onRetry,
  })  : message = 'Problème de connexion internet',
        subtitle = 'Vérifiez votre connexion et réessayez',
        icon = Icons.wifi_off,
        retryButtonText = 'Réessayer',
        onGoBack = null;

  /// Affichage pour contenu vide (pas une erreur)
  const ErrorDisplay.empty({
    super.key,
    this.message = 'Aucun élément à afficher',
    this.subtitle,
    this.onRetry,
  })  : icon = Icons.inbox_outlined,
        retryButtonText = null,
        onGoBack = null;

  /// Affichage pour permission refusée
  const ErrorDisplay.permissionDenied({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
  })  : icon = Icons.block,
        retryButtonText = 'Ouvrir Paramètres',
        onGoBack = null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'erreur
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),

            // Message principal
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            // Sous-titre optionnel
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Boutons d'action
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bouton Retour
                if (onGoBack != null) ...[
                  OutlinedButton.icon(
                    onPressed: onGoBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Retour'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // Bouton Réessayer
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(
                      retryButtonText == 'Ouvrir Paramètres'
                          ? Icons.settings
                          : Icons.refresh,
                    ),
                    label: Text(retryButtonText ?? 'Réessayer'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget d'état vide personnalisable
/// 
/// Pour afficher un message quand une liste ou un contenu est vide
class EmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyState({
    super.key,
    required this.message,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
            if (onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionText ?? 'Ajouter'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget overlay de chargement plein écran
/// 
/// Affiche un loader qui bloque toute l'interface
/// Usage avec showDialog ou comme overlay
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final Color backgroundColor;
  final bool dismissible;

  const LoadingOverlay({
    super.key,
    this.message,
    this.backgroundColor = Colors.black54,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Container(
        color: backgroundColor,
        child: LoadingIndicator.large(
          message: message,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Affiche un overlay de chargement plein écran
  /// Retourne une fonction pour le fermer
  static VoidCallback show(
    BuildContext context, {
    String? message,
    bool dismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      barrierColor: Colors.black54,
      builder: (context) => LoadingOverlay(
        message: message,
        dismissible: dismissible,
      ),
    );

    return () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    };
  }
}
