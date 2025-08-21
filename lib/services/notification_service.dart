import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/app_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'dart:convert';
import 'navigation_service.dart';
import '../core/constants/app_routes.dart';

/// Service de notifications pour l'application
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final AuthService _authService = AuthService();

  static bool _isInitialized = false;

  /// Initialiser le service de notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser timezone
      tz.initializeTimeZones();

      // Demander les permissions
      await _requestPermissions();

      // Configuration Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuration iOS
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Configuration générale
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialiser le plugin
      await _localNotifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Initialiser FCM
      await initFCM();

      _isInitialized = true;
    } catch (e) {
      print('Notification initialization error: $e');
    }
  }

  /// Initialiser Firebase Cloud Messaging
  static Future<void> initFCM() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await _fcm.getToken();
      if (token != null) {
        await _authService.saveFCMToken(token);
        _fcm.onTokenRefresh.listen((newToken) async {
          await _authService.saveFCMToken(newToken);
        });
      }

      // Gérer les notifications lorsque l'application est au premier plan
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Message also contained a notification: ${message.notification}');
          showNotification(
            id: message.hashCode,
            title: message.notification!.title ?? 'Notification',
            body: message.notification!.body ?? '',
            payload: json.encode(message.data), // Encode the whole data map
          );
        }
      });

      // Gérer le clic sur la notification lorsque l'application est ouverte depuis l'arrière-plan
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('A new onMessageOpenedApp event was published!');
        _handleNotificationPayload(message.data);
      });
    } else {
      print('User declined or has not accepted permission for FCM');
    }
  }

  /// Demander les permissions de notification
  static Future<void> _requestPermissions() async {
    try {
      final status = await Permission.notification.request();
      if (status.isDenied) {
        print('Notification permission denied');
      }
    } catch (e) {
      print('Permission request error: $e');
    }
  }

  /// Gérer le tap sur une notification
  static void _onNotificationTapped(NotificationResponse response) {
    // Navigation basée sur le payload de la notification
    final payload = response.payload;
    if (payload != null) {
      try {
        final decodedPayload = json.decode(payload) as Map<String, dynamic>;
        _handleNotificationPayload(decodedPayload);
      } catch (e) {
        print('Error decoding notification payload: $e');
      }
    }
  }

  /// Gérer le payload de la notification
  static void _handleNotificationPayload(Map<String, dynamic> data) {
    final screen = data['screen'] as String?;

    switch (screen) {
      case 'reviews':
        final merchantId = data['merchantId'] as String?;
        if (merchantId != null) {
          NavigationService.navigatorKey.currentState?.pushNamed(
            AppRoutes.merchantReviews,
            arguments: {'merchantId': merchantId},
          );
        }
        break;
      case 'balance_management':
        NavigationService.navigatorKey.currentState?.pushNamed(
          AppRoutes.balanceManagement,
        );
        break;
      case 'pending_verifications':
        NavigationService.navigatorKey.currentState?.pushNamed(
          AppRoutes.adminPendingVerifications,
        );
        break;
      default:
        // Optional: navigate to a default screen if payload is unknown
        print('Unknown notification screen: $screen');
        break;
    }
  }

  /// Afficher une notification locale
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationType type = NotificationType.info,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Configuration Android
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'locacharge_channel',
            'LocaCharge Notifications',
            channelDescription: 'Notifications de l\'application LocaCharge',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      // Configuration iOS
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Configuration générale
      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Afficher la notification
      await _localNotifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      print('Show notification error: $e');
    }
  }

  /// Afficher une notification de transaction réussie
  static Future<void> showTransactionSuccess({
    required String merchantName,
    required double amount,
    required String transactionType,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Transaction réussie',
      body: '$transactionType de $amount FCFA chez $merchantName',
      type: NotificationType.success,
      payload: 'transaction_success',
    );
  }

  /// Afficher une notification de nouveau marchand
  static Future<void> showNewMerchant({
    required String merchantName,
    required String address,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Nouveau point de service',
      body: '$merchantName est maintenant disponible à $address',
      type: NotificationType.info,
      payload: 'new_merchant',
    );
  }

  /// Afficher une notification de promotion
  static Future<void> showPromotion({
    required String title,
    required String description,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: description,
      type: NotificationType.promotion,
      payload: 'promotion',
    );
  }

  /// Afficher une notification d'erreur
  static Future<void> showError({
    required String title,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: message,
      type: NotificationType.error,
      payload: 'error',
    );
  }

  /// Afficher une notification de rappel
  static Future<void> showReminder({
    required String title,
    required String message,
  }) async {
    await showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: message,
      type: NotificationType.reminder,
      payload: 'reminder',
    );
  }

  /// Programmer une notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationType type = NotificationType.info,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'locacharge_scheduled',
            'LocaCharge Scheduled',
            channelDescription: 'Notifications programmées',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convertir DateTime en TZDateTime
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        details,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      print('Schedule notification error: $e');
    }
  }

  /// Annuler une notification
  static Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Obtenir les notifications en attente
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Vérifier si les notifications sont activées
  static Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      return false;
    }
  }
}

/// Types de notifications
enum NotificationType { info, success, error, warning, promotion, reminder }

/// Extension pour obtenir l'icône selon le type
extension NotificationTypeExtension on NotificationType {
  String get icon {
    switch (this) {
      case NotificationType.info:
        return 'info';
      case NotificationType.success:
        return 'check_circle';
      case NotificationType.error:
        return 'error';
      case NotificationType.warning:
        return 'warning';
      case NotificationType.promotion:
        return 'local_offer';
      case NotificationType.reminder:
        return 'schedule';
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.success:
        return AppColors.primary;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.promotion:
        return Colors.purple;
      case NotificationType.reminder:
        return Colors.teal;
    }
  }
}
