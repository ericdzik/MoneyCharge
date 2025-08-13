import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_text_styles.dart';

class PremiumServicesScreen extends StatelessWidget {
  const PremiumServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services Premium'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildServiceCard(
            context: context,
            icon: Icons.campaign,
            title: 'Gérer mes publicités',
            subtitle: 'Créez et suivez la performance de vos annonces.',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.merchantManageAds);
            },
          ),
          // D'autres services premium pourront être ajoutés ici
        ],
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(icon, size: 40, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.h3),
        subtitle: Text(subtitle, style: AppTextStyles.body2),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
