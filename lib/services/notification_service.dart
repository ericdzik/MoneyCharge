import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../core/constants/app_colors.dart';

/// Service de notifications pour l'application
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

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
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
    } catch (e) {
      print('Notification initialization error: $e');
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
      _handleNotificationPayload(payload);
    }
  }

  /// Gérer le payload de la notification
  static void _handleNotificationPayload(String payload) {
    // Implémenter la logique de navigation selon le type de notification
    print('Notification payload: $payload');
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
      await _notifications.show(id, title, body, details, payload: payload);
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

      await _notifications.zonedSchedule(
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
    await _notifications.cancel(id);
  }

  /// Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Obtenir les notifications en attente
  static Future<List<PendingNotificationRequest>>
  getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
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
