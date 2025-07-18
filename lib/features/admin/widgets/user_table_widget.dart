import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_colors.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package.locacharge/providers/auth_provider.dart' as auth; // Using alias to avoid conflict with User model

class UserTableWidget extends StatelessWidget {
  final List<auth.User> users;
  final Function(auth.User) onSuspend;
  final Function(auth.User) onViewDetails;

  const UserTableWidget({
    Key? key,
    required this.users,
    required this.onSuspend,
    required this.onViewDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: AppColors.onPrimary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Utilisateurs (${users.length})',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.onPrimary,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingTextStyle: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              dataTextStyle: AppTextStyles.body2,
              columns: const [
                DataColumn(label: Text('Nom')),
                DataColumn(label: Text('Email')),
                DataColumn(label: Text('Statut')),
                DataColumn(label: Text('Date d\'inscription')),
                DataColumn(label: Text('Actions')),
              ],
              rows: users.map((user) {
                // We need to know if the user is suspended. This info should be on the User model.
                // Assuming `isSuspended` will be added to the `auth.User` model.
                // For now, we'll assume it's not suspended.
                final isSuspended = false; // Placeholder

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(
                          user.name,
                          style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(SizedBox(width: 180, child: Text(user.email, overflow: TextOverflow.ellipsis))),
                    DataCell(_buildStatusChip(isSuspended)),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(
                          _formatDate(user.createdAt),
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 18, color: AppColors.primary),
                            tooltip: 'Voir détails',
                            onPressed: () => onViewDetails(user),
                          ),
                          IconButton(
                            icon: Icon(
                              isSuspended ? Icons.play_circle_outline : Icons.block,
                              size: 18,
                              color: isSuspended ? AppColors.success : Colors.red,
                            ),
                            tooltip: isSuspended ? 'Réactiver' : 'Suspendre',
                            onPressed: () => onSuspend(user),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(bool isSuspended) {
    String text;
    Color color;
    Color backgroundColor;

    if (isSuspended) {
      text = 'Suspendu';
      color = Colors.white;
      backgroundColor = Colors.red;
    } else {
      text = 'Actif';
      color = Colors.green;
      backgroundColor = Colors.green.withOpacity(0.1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().substring(2)}';
  }
}
