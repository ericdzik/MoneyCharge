import 'package:flutter/material.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/services/payment_service.dart';

class PremiumSubscriptionScreen extends StatelessWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Utilisation sécurisée des clés depuis EnvConfig
    final paymentService = PaymentService(
      publicKey: EnvConfig.paystackPublicKey,
      secretKey: EnvConfig.paystackSecretKey,
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Abonnement Premium',
        showLogo: false,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 100, color: Colors.amber),
              const SizedBox(height: 20),
              const Text(
                'Passez à Premium!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text(
                'Débloquez des fonctionnalités exclusives pour booster votre visibilité et vos ventes.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  await paymentService.chargeCardAndMakePayment(context);
                },
                child: const Text('S\'abonner pour 5000 FCFA / mois'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
