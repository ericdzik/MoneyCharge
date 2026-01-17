import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Filtre qui désactive les logs en release pour éviter tout bruit en production.
class _ReleaseAwareFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return !kReleaseMode; // Logs actifs seulement en debug/profile
  }
}

/// Logger applicatif partagé, à utiliser partout dans l’app.
/// Utilise PrettyPrinter minimal pour des messages lisibles et concis.
final Logger appLogger = Logger(
  filter: _ReleaseAwareFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);
