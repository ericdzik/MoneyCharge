import 'package:flutter/material.dart';

/// Types de SnackBar disponibles
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

/// Helper professionnel pour afficher des SnackBars uniformes
/// 
/// Centralise l'affichage des messages utilisateur avec un design cohérent
/// et élimine la duplication de code (50+ occurrences dans le projet).
/// 
/// Usage:
/// ```dart
/// SnackBarHelper.showSuccess(context, 'Opération réussie');
/// SnackBarHelper.showError(context, 'Une erreur est survenue');
/// SnackBarHelper.showWarning(context, 'Attention !');
/// SnackBarHelper.showInfo(context, 'Information importante');
/// ```
class SnackBarHelper {
  // Durées par défaut
  static const Duration _defaultDuration = Duration(seconds: 3);
  static const Duration _shortDuration = Duration(seconds: 2);
  static const Duration _longDuration = Duration(seconds: 5);

  /// Affiche un SnackBar de succès (vert)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool floating = true,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      action: action,
      floating: floating,
    );
  }

  /// Affiche un SnackBar d'erreur (rouge)
  static void showError(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool floating = true,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration ?? _longDuration, // Erreurs visibles plus longtemps
      action: action,
      floating: floating,
    );
  }

  /// Affiche un SnackBar d'avertissement (orange)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool floating = true,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      action: action,
      floating: floating,
    );
  }

  /// Affiche un SnackBar d'information (bleu)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    SnackBarAction? action,
    bool floating = true,
  }) {
    _show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration ?? _shortDuration,
      action: action,
      floating: floating,
    );
  }

  /// Affiche un SnackBar personnalisé
  static void showCustom(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    Color textColor = Colors.white,
    IconData? icon,
    Duration? duration,
    SnackBarAction? action,
    bool floating = true,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration ?? _defaultDuration,
        behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
        action: action,
        shape: floating
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            : null,
        margin: floating ? const EdgeInsets.all(16) : null,
      ),
    );
  }

  /// Affiche un SnackBar avec action de retry
  static void showErrorWithRetry(
    BuildContext context,
    String message,
    VoidCallback onRetry, {
    String retryLabel = 'Réessayer',
  }) {
    showError(
      context,
      message,
      action: SnackBarAction(
        label: retryLabel,
        textColor: Colors.white,
        onPressed: onRetry,
      ),
    );
  }

  /// Affiche un SnackBar avec action de undo
  static void showWithUndo(
    BuildContext context,
    String message,
    VoidCallback onUndo, {
    String undoLabel = 'Annuler',
    SnackBarType type = SnackBarType.info,
  }) {
    _show(
      context,
      message: message,
      type: type,
      action: SnackBarAction(
        label: undoLabel,
        textColor: Colors.white,
        onPressed: onUndo,
      ),
    );
  }

  /// Affiche un SnackBar de chargement (avec CircularProgressIndicator)
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showLoading(
    BuildContext context,
    String message, {
    bool dismissible = false,
  }) {
    if (!context.mounted) {
      // Return a dummy controller if context is not mounted
      return ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('')),
      );
    }

    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(days: 365), // Très longue durée
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey[800],
        dismissDirection: dismissible ? DismissDirection.down : DismissDirection.none,
      ),
    );
  }

  /// Cache le SnackBar actuellement affiché
  static void hide(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Cache tous les SnackBars
  static void clearAll(BuildContext context) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // ==================== MÉTHODES PRIVÉES ====================

  /// Méthode interne pour afficher un SnackBar
  static void _show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    Duration? duration,
    SnackBarAction? action,
    bool floating = true,
  }) {
    if (!context.mounted) return;

    final config = _getConfigForType(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.color,
        duration: duration ?? _defaultDuration,
        behavior: floating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
        action: action ?? _getDefaultAction(type),
        shape: floating
            ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
            : null,
        margin: floating ? const EdgeInsets.all(16) : null,
      ),
    );
  }

  /// Obtient la configuration (couleur, icône) pour un type de SnackBar
  static _SnackBarConfig _getConfigForType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          color: const Color(0xFF4CAF50), // Green
          icon: Icons.check_circle,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          color: const Color(0xFFF44336), // Red
          icon: Icons.error,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          color: const Color(0xFFFF9800), // Orange
          icon: Icons.warning,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          color: const Color(0xFF2196F3), // Blue
          icon: Icons.info,
        );
    }
  }

  /// Obtient l'action par défaut pour un type de SnackBar
  static SnackBarAction? _getDefaultAction(SnackBarType type) {
    // Ajouter une action "OK" uniquement pour les erreurs
    if (type == SnackBarType.error) {
      return SnackBarAction(
        label: 'OK',
        textColor: Colors.white,
        onPressed: () {},
      );
    }
    return null;
  }
}

/// Configuration interne pour un SnackBar
class _SnackBarConfig {
  final Color color;
  final IconData icon;

  _SnackBarConfig({
    required this.color,
    required this.icon,
  });
}
