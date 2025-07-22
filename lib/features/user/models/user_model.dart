import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoURL; // Ajout du champ photoURL
  final bool isSuspended;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoURL, // Ajout du champ photoURL
    this.isSuspended = false,
  });

  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return User(
      id: snapshot.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      photoURL: data['photoURL'], // Ajout du champ photoURL
      isSuspended: data['isSuspended'] ?? false,
    );
  }

  // Méthode pour créer une copie de l'utilisateur avec des champs mis à jour
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoURL,
    bool? isSuspended,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoURL: photoURL ?? this.photoURL,
      isSuspended: isSuspended ?? this.isSuspended,
    );
  }
}
