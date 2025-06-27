import 'package:flutter/material.dart';

/// Gestionnaire d'erreurs centralisé pour l'application
class ErrorHandler {
  static const String _defaultErrorMessage =
      'Une erreur inattendue s\'est produite';
  static const String _networkErrorMessage = 'Erreur de connexion réseau';
  static const String _authErrorMessage = 'Erreur d\'authentification';
  static const String _validationErrorMessage = 'Données invalides';

  /// Types d'erreurs supportés
  static const String networkError = 'network_error';
  static const String authError = 'auth_error';
  static const String validationError = 'validation_error';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';

  /// Gérer une erreur et retourner un message utilisateur
  static String handleError(dynamic error, {String? context}) {
    if (error is String) {
      return error;
    }

    if (error is Exception) {
      return _handleException(error, context);
    }

    return _defaultErrorMessage;
  }

  /// Gérer les exceptions spécifiques
  static String _handleException(Exception exception, String? context) {
    final errorMessage = exception.toString().toLowerCase();

    if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('timeout')) {
      return _networkErrorMessage;
    }

    if (errorMessage.contains('auth') ||
        errorMessage.contains('unauthorized') ||
        errorMessage.contains('forbidden')) {
      return _authErrorMessage;
    }

    if (errorMessage.contains('validation') ||
        errorMessage.contains('invalid')) {
      return _validationErrorMessage;
    }

    if (errorMessage.contains('server') ||
        errorMessage.contains('500') ||
        errorMessage.contains('502') ||
        errorMessage.contains('503')) {
      return 'Erreur du serveur. Veuillez réessayer plus tard.';
    }

    return _defaultErrorMessage;
  }

  /// Afficher un snackbar d'erreur
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Afficher une boîte de dialogue d'erreur
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            if (actionText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onAction?.call();
                },
                child: Text(actionText),
              ),
          ],
        );
      },
    );
  }

  /// Logger une erreur (pour debug/production)
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
  }) {
    // En production, on pourrait envoyer à un service comme Sentry
    debugPrint('Error in $context: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }
  }

  /// Vérifier si une erreur est récupérable
  static bool isRecoverable(dynamic error) {
    if (error is String) {
      return !error.toLowerCase().contains('fatal');
    }

    if (error is Exception) {
      final errorMessage = error.toString().toLowerCase();
      return !errorMessage.contains('fatal') &&
          !errorMessage.contains('critical');
    }

    return true;
  }
}
