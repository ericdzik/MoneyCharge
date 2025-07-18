import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final bool isSuspended;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.isSuspended = false,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      isSuspended: data['isSuspended'] ?? false,
    );
  }
}
