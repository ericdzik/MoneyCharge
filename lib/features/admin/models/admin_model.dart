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

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      role: AdminRole.values.firstWhere(
        (e) => e.toString() == 'AdminRole.${json['role']}',
        orElse: () => AdminRole.moderator,
      ),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'])
          : null,
      permissions: List<String>.from(json['permissions'] ?? []),
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
