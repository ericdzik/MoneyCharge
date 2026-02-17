import 'package:flutter/foundation.dart';

/// Utilitaire de logging qui n'affiche les logs qu'en mode debug
class AppLogger {
  /// Log d'information (seulement en debug)
  static void info(String message) {
    if (kDebugMode) {
      debugPrint('ℹ️ $message');
    }
  }

  /// Log d'avertissement (seulement en debug)
  static void warning(String message) {
    if (kDebugMode) {
      debugPrint('⚠️ $message');
    }
  }

  /// Log d'erreur (seulement en debug)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('❌ $message');
      if (error != null) {
        debugPrint('Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
    }
  }

  /// Log de succès (seulement en debug)
  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ $message');
    }
  }

  /// Log de debug (seulement en debug)
  static void debug(String message) {
    if (kDebugMode) {
      debugPrint('🔍 $message');
    }
  }

  /// Log de sécurité (seulement en debug)
  static void security(String message) {
    if (kDebugMode) {
      debugPrint('🔐 $message');
    }
  }
}
