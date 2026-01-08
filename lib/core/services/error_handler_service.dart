import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service pour gérer les erreurs de l'application
class ErrorHandlerService {
  static final ErrorHandlerService _instance = ErrorHandlerService._internal();
  factory ErrorHandlerService() => _instance;
  ErrorHandlerService._internal();

  /// Initialise le gestionnaire d'erreurs global
  static void initialize() {
    // Capturer les erreurs Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleFlutterError(details);
    };

    // Capturer les erreurs de la plateforme
    PlatformDispatcher.instance.onError = (error, stack) {
      _handlePlatformError(error, stack);
      return true;
    };
  }

  static void _handleFlutterError(FlutterErrorDetails details) {
    // Log l'erreur
    if (kDebugMode) {
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
    }

    // Filtrer les erreurs de rendu OpenGL courantes
    final errorString = details.exception.toString().toLowerCase();
    if (_isRenderError(errorString)) {
      if (kDebugMode) {
        print('Render error detected and handled: ${details.exception}');
      }
      return;
    }

    // Pour les autres erreurs, utiliser le gestionnaire par défaut
    FlutterError.presentError(details);
  }

  static void _handlePlatformError(Object error, StackTrace stack) {
    if (kDebugMode) {
      print('Platform Error: $error');
      print('Stack trace: $stack');
    }

    // Filtrer les erreurs de rendu OpenGL courantes
    final errorString = error.toString().toLowerCase();
    if (_isRenderError(errorString)) {
      if (kDebugMode) {
        print('Platform render error detected and handled: $error');
      }
      return;
    }
  }

  static bool _isRenderError(String errorString) {
    final renderErrorPatterns = [
      'surface had destroyed before draw',
      'updateacquirefence',
      'did not find frame',
      'queuebuffer time out',
      'renderthread',
      'openglrenderer',
    ];

    return renderErrorPatterns.any((pattern) => errorString.contains(pattern));
  }

  /// Log une erreur personnalisée
  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('Custom Error: $message');
      if (error != null) print('Error object: $error');
      if (stackTrace != null) print('Stack trace: $stackTrace');
    }
  }

  /// Log un avertissement
  static void logWarning(String message) {
    if (kDebugMode) {
      print('Warning: $message');
    }
  }

  /// Log une information
  static void logInfo(String message) {
    if (kDebugMode) {
      print('Info: $message');
    }
  }
}