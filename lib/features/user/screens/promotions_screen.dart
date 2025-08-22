import 'package:flutter/material.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PromotionsScreen extends StatelessWidget {
  const PromotionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Promotions',
        showLogo: false,
      ),
      body: const Center(
        child: Text('Écran des promotions (à implémenter)'),
      ),
    );
  }
}
