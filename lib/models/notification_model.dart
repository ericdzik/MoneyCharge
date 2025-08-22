import 'dart:convert';

class NotificationModel {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      payload: json['payload'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  static String encode(List<NotificationModel> notifications) => json.encode(
        notifications
            .map<Map<String, dynamic>>((notification) => notification.toJson())
            .toList(),
      );

  static List<NotificationModel> decode(String notifications) =>
      (json.decode(notifications) as List<dynamic>)
          .map<NotificationModel>((item) => NotificationModel.fromJson(item))
          .toList();
}
