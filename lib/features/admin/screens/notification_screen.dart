import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../services/notification_service.dart';
import '../../../models/notification_model.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = NotificationService.getStoredNotifications();
    });
  }

  void _clearNotifications() async {
    await NotificationService.clearStoredNotifications();
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        backgroundColor: AppColors.primary,
        showLogo: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Effacer tout',
            onPressed: _clearNotifications,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement des notifications: ${snapshot.error}',
                style: AppTextStyles.body1.copyWith(color: Colors.red),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: AppTextStyles.h3.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les nouvelles notifications apparaîtront ici.',
                    style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timeAgo =
                  DateTime.now().difference(notification.timestamp);
              String timeDisplay;
              if (timeAgo.inMinutes < 1) {
                timeDisplay = 'À l\'instant';
              } else if (timeAgo.inMinutes < 60) {
                timeDisplay = 'Il y a ${timeAgo.inMinutes} min';
              } else if (timeAgo.inHours < 24) {
                timeDisplay = 'Il y a ${timeAgo.inHours} h';
              } else {
                timeDisplay = DateFormat('dd/MM/yyyy').format(notification.timestamp);
              }

              return ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppColors.primary),
                title: Text(notification.title, style: AppTextStyles.body1),
                subtitle: Text(notification.body, style: AppTextStyles.body2),
                trailing: Text(timeDisplay, style: AppTextStyles.caption),
                onTap: () {
                  // Handle notification tap if needed
                },
              );
            },
          );
        },
      ),
    );
  }
}
