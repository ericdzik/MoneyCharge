import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/payment_service.dart';
import '../../../providers/auth_provider.dart';

class PremiumSubscriptionScreen extends StatelessWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentService = PaymentService(
        publicKey: 'pk_test_YOUR_PUBLIC_KEY',
        secretKey: 'sk_test_YOUR_SECRET_KEY');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Abonnement Premium'),
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
