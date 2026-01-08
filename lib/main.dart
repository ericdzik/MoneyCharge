import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/app.dart';
import 'package:locacharge/core/config/env_config.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/services/error_handler_service.dart';
import 'package:locacharge/firebase_options.dart';
import 'package:locacharge/providers/theme_provider.dart';
import 'package:locacharge/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==================== INITIALISATION GESTIONNAIRE D'ERREURS ====================
  // Initialiser le gestionnaire d'erreurs en premier pour capturer toutes les erreurs
  ErrorHandlerService.initialize();

  // ==================== INITIALISATION ENVIRONNEMENT ====================
  // Chargement sécurisé des variables d'environnement
  // IMPORTANT: Doit être fait AVANT toute utilisation de clés API
  await EnvConfig.initialize(fileName: '.env');

  // Affichage de la configuration en mode debug
  if (EnvConfig.isDebugMode) {
    EnvConfig.printConfiguration();
  }

  // ==================== INITIALISATION FIREBASE ====================
  // Firebase utilise maintenant les clés depuis EnvConfig
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ==================== INITIALISATION NOTIFICATIONS ====================
  await NotificationService.initialize();

  // Configuration de l'orientation de l'écran
  // Pour une application de type "mobile", on fixe l'orientation en portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configuration de la barre de statut et de la barre de navigation
  // Barre d'état verte pour correspondre à l'AppBar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.primary,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const LocaChargeApp(),
    ),
  );
}
