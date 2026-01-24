import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/core/security/permission_provider.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';

/// Widget de debug pour afficher les permissions actuelles de l'utilisateur
/// Utile pour diagnostiquer les problèmes de RBAC
class PermissionDebugWidget extends StatelessWidget {
  const PermissionDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PermissionProvider>(
      builder: (context, authProvider, permissionProvider, _) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.yellow, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.bug_report, color: Colors.yellow, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'DEBUG: Permissions',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildInfoRow('User Type', authProvider.userType.toString()),
              _buildInfoRow(
                'Authenticated',
                authProvider.isAuthenticated.toString(),
              ),
              _buildInfoRow('User ID', authProvider.userId ?? 'null'),
              const Divider(color: Colors.yellow),
              const Text(
                'Permissions:',
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...permissionProvider.currentPermissions.map((permission) {
                final permName = permission.toString().split('.').last;
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          permName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              if (permissionProvider.currentPermissions.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(
                    'No permissions',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating Action Button pour afficher le debug des permissions
class PermissionDebugFAB extends StatefulWidget {
  const PermissionDebugFAB({Key? key}) : super(key: key);

  @override
  State<PermissionDebugFAB> createState() => _PermissionDebugFABState();
}

class _PermissionDebugFABState extends State<PermissionDebugFAB> {
  bool _showDebug = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_showDebug)
          Positioned(
            bottom: 80,
            right: 16,
            left: 16,
            child: const PermissionDebugWidget(),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.yellow,
            onPressed: () {
              setState(() {
                _showDebug = !_showDebug;
              });
            },
            child: const Icon(Icons.bug_report, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
