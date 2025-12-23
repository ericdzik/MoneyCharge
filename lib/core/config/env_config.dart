import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

/// Service centralisé pour gérer toutes les variables d'environnement
/// Configuration professionnelle avec validation et logging
/// 
/// Usage:
/// ```dart
/// await EnvConfig.initialize();
/// final apiKey = EnvConfig.googleMapsApiKey;
/// ```
class EnvConfig {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  // État d'initialisation
  static bool _isInitialized = false;

  /// Initialise le service de configuration
  /// À appeler dans main() avant runApp()
  static Future<void> initialize({String fileName = '.env'}) async {
    if (_isInitialized) {
      _logger.w('EnvConfig déjà initialisé');
      return;
    }

    try {
      await dotenv.load(fileName: fileName);
      _isInitialized = true;
      _logger.i('✅ Variables d\'environnement chargées avec succès');
      _validateConfiguration();
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Erreur lors du chargement du fichier $fileName',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception(
        'Impossible de charger $fileName. '
        'Assurez-vous que le fichier existe et est configuré correctement.',
      );
    }
  }

  /// Récupère une variable d'environnement avec validation
  static String _getEnv(
    String key, {
    String? defaultValue,
    bool required = false,
  }) {
    if (!_isInitialized) {
      throw StateError(
        'EnvConfig non initialisé. Appelez EnvConfig.initialize() d\'abord.',
      );
    }

    final value = dotenv.env[key] ?? defaultValue;

    if (required && (value == null || value.isEmpty)) {
      _logger.e('❌ Variable d\'environnement requise manquante: $key');
      throw Exception('Variable d\'environnement requise: $key');
    }

    if (value == null || value.isEmpty) {
      _logger.w('⚠️ Variable d\'environnement non définie: $key');
    }

    return value ?? '';
  }

  // ==================== CONFIGURATION API ====================

  /// URL de base de l'API backend
  static String get apiBaseUrl => _getEnv(
        'API_BASE_URL',
        defaultValue: 'https://api.locacharge.com/v1',
      );

  /// Timeout des requêtes API (en secondes)
  static int get apiTimeout => int.tryParse(
        _getEnv('API_TIMEOUT', defaultValue: '30'),
      ) ??
      30;

  // ==================== GOOGLE MAPS ====================

  /// Clé API Google Maps pour Android
  static String get googleMapsApiKeyAndroid => _getEnv(
        'GOOGLE_MAPS_API_KEY_ANDROID',
        required: true,
      );

  /// Clé API Google Maps pour iOS
  static String get googleMapsApiKeyIos => _getEnv(
        'GOOGLE_MAPS_API_KEY_IOS',
        required: true,
      );

  /// Clé API Google Maps pour Web
  static String get googleMapsApiKeyWeb => _getEnv(
        'GOOGLE_MAPS_API_KEY_WEB',
        required: true,
      );

  /// Clé API Google Directions (backend)
  static String get googleDirectionsApiKey => _getEnv(
        'GOOGLE_DIRECTIONS_API_KEY',
        required: true,
      );

  // ==================== FIREBASE ====================

  /// Firebase API Key pour Web
  static String get firebaseApiKeyWeb => _getEnv(
        'FIREBASE_API_KEY_WEB',
        required: true,
      );

  /// Firebase API Key pour Android
  static String get firebaseApiKeyAndroid => _getEnv(
        'FIREBASE_API_KEY_ANDROID',
        required: true,
      );

  /// Firebase API Key pour iOS
  static String get firebaseApiKeyIos => _getEnv(
        'FIREBASE_API_KEY_IOS',
        required: true,
      );

  /// Firebase App ID Web
  static String get firebaseAppIdWeb => _getEnv(
        'FIREBASE_APP_ID_WEB',
        required: true,
      );

  /// Firebase App ID Android
  static String get firebaseAppIdAndroid => _getEnv(
        'FIREBASE_APP_ID_ANDROID',
        required: true,
      );

  /// Firebase App ID iOS
  static String get firebaseAppIdIos => _getEnv(
        'FIREBASE_APP_ID_IOS',
        required: true,
      );

  /// Firebase Messaging Sender ID
  static String get firebaseMessagingSenderId => _getEnv(
        'FIREBASE_MESSAGING_SENDER_ID',
        required: true,
      );

  /// Firebase Project ID
  static String get firebaseProjectId => _getEnv(
        'FIREBASE_PROJECT_ID',
        required: true,
      );

  /// Firebase Auth Domain
  static String get firebaseAuthDomain => _getEnv(
        'FIREBASE_AUTH_DOMAIN',
        required: true,
      );

  /// Firebase Storage Bucket
  static String get firebaseStorageBucket => _getEnv(
        'FIREBASE_STORAGE_BUCKET',
        required: true,
      );

  /// Firebase iOS Bundle ID
  static String get firebaseIosBundleId => _getEnv(
        'FIREBASE_IOS_BUNDLE_ID',
        required: true,
      );

  // ==================== PAYSTACK ====================

  /// Clé publique Paystack
  static String get paystackPublicKey => _getEnv(
        'PAYSTACK_PUBLIC_KEY',
        required: true,
      );

  /// Clé secrète Paystack (à utiliser uniquement côté serveur)
  static String get paystackSecretKey => _getEnv(
        'PAYSTACK_SECRET_KEY',
        required: false, // Ne pas utiliser côté client
      );

  /// Mode Paystack (test/live)
  static bool get paystackTestMode =>
      _getEnv('PAYSTACK_MODE', defaultValue: 'test').toLowerCase() == 'test';

  // ==================== CONFIGURATION APP ====================

  /// Mode debug
  static bool get isDebugMode =>
      _getEnv('DEBUG_MODE', defaultValue: 'false').toLowerCase() == 'true';

  /// Version de l'environnement (dev, staging, production)
  static String get environment => _getEnv(
        'ENVIRONMENT',
        defaultValue: 'development',
      );

  /// Activer les logs
  static bool get enableLogging =>
      _getEnv('ENABLE_LOGGING', defaultValue: 'true').toLowerCase() == 'true';

  // ==================== VALIDATION ====================

  /// Valide que toutes les configurations requises sont présentes
  static void _validateConfiguration() {
    final errors = <String>[];

    // Validation Google Maps
    if (googleDirectionsApiKey.isEmpty) {
      errors.add('GOOGLE_DIRECTIONS_API_KEY manquant');
    }
    if (googleMapsApiKeyAndroid.isEmpty) {
      errors.add('GOOGLE_MAPS_API_KEY_ANDROID manquant');
    }

    // Validation Firebase
    if (firebaseProjectId.isEmpty) {
      errors.add('FIREBASE_PROJECT_ID manquant');
    }

    // Validation Paystack
    if (paystackPublicKey.isEmpty) {
      errors.add('PAYSTACK_PUBLIC_KEY manquant');
    }

    if (errors.isNotEmpty) {
      _logger.e('❌ Erreurs de configuration:\n${errors.join('\n')}');
      throw Exception(
        'Configuration incomplète. Vérifiez votre fichier .env',
      );
    }

    _logger.i('✅ Configuration validée avec succès');
    _logger.d('Environnement: $environment');
    _logger.d('Mode debug: $isDebugMode');
    _logger.d('Logging activé: $enableLogging');
  }

  /// Affiche toutes les variables de configuration (sans les valeurs sensibles)
  static void printConfiguration() {
    if (!_isInitialized) return;

    _logger.i('''
╔══════════════════════════════════════════════╗
║       CONFIGURATION ENVIRONNEMENT            ║
╚══════════════════════════════════════════════╝

🌍 Environnement: $environment
🐛 Mode debug: $isDebugMode
📝 Logging: $enableLogging

🔗 API Base URL: $apiBaseUrl
⏱️  API Timeout: ${apiTimeout}s

🗺️  Google Maps Android: ${_maskKey(googleMapsApiKeyAndroid)}
🗺️  Google Maps iOS: ${_maskKey(googleMapsApiKeyIos)}
🗺️  Google Maps Web: ${_maskKey(googleMapsApiKeyWeb)}
🧭 Google Directions: ${_maskKey(googleDirectionsApiKey)}

🔥 Firebase Project: $firebaseProjectId
🔥 Firebase Auth Domain: $firebaseAuthDomain
🔥 Firebase Storage: $firebaseStorageBucket

💳 Paystack Mode: ${paystackTestMode ? 'TEST' : 'LIVE'}
💳 Paystack Public Key: ${_maskKey(paystackPublicKey)}
''');
  }

  /// Masque une clé API pour l'affichage sécurisé
  static String _maskKey(String key) {
    if (key.isEmpty) return '[NON DÉFINI]';
    if (key.length <= 8) return '***';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }

  /// Réinitialise le service (pour les tests)
  static void reset() {
    _isInitialized = false;
    _logger.d('EnvConfig réinitialisé');
  }
}
