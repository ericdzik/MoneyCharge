import 'package:cloud_firestore/cloud_firestore.dart'; // Ajout de l'import

enum AdminRole { superAdmin, admin, moderator }

class AdminModel {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final List<String> permissions;

  AdminModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLoginAt,
    this.permissions = const [],
  });

  factory AdminModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    String? adminLevelString = data['adminLevel'] as String?;
    AdminRole determinedAdminRole = AdminRole.moderator; // Default
    if (adminLevelString != null) {
      determinedAdminRole = AdminRole.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == adminLevelString.toLowerCase(),
        orElse: () => AdminRole.moderator,
      );
    }

    return AdminModel(
      id: snapshot.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String? ?? '',
      role: determinedAdminRole,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      permissions: (data['permissions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString().split('.').last,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'permissions': permissions,
    };
  }

  AdminModel copyWith({
    String? id,
    String? email,
    String? name,
    AdminRole? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? permissions,
  }) {
    return AdminModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      permissions: permissions ?? this.permissions,
    );
  }

  String get roleText {
    switch (role) {
      case AdminRole.superAdmin:
        return 'Super Administrateur';
      case AdminRole.admin:
        return 'Administrateur';
      case AdminRole.moderator:
        return 'Modérateur';
    }
  }

  bool get canManageUsers =>
      role == AdminRole.superAdmin || role == AdminRole.admin;
  bool get canManageMerchants =>
      role == AdminRole.superAdmin || role == AdminRole.admin;
  bool get canViewAnalytics =>
      role == AdminRole.superAdmin || role == AdminRole.admin;
  bool get canModerateContent => true; // Tous les rôles peuvent modérer
}
