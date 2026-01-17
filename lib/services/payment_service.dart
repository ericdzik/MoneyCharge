import 'package:flutter/material.dart';
import 'package:flutter_paystack_plus/flutter_paystack_plus.dart';
import 'package:provider/provider.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'notification_service.dart';

class PaymentService {
  final String? publicKey;
  final String? secretKey;

  PaymentService({this.publicKey, this.secretKey});

  Future<void> chargeCardAndMakePayment(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUserProfile;

    if (user == null) {
      // Handle user not logged in
      return;
    }

    await FlutterPaystackPlus.openPaystackPopup(
      publicKey: publicKey!,
      secretKey: secretKey!,
      customerEmail: user.email,
      context: context,
      amount: (5000 * 100).toString(),
      reference: DateTime.now().millisecondsSinceEpoch.toString(),
      callBackUrl: "https://locacharge.app/payment-callback",
      onClosed: () {
        debugPrint('Could\'nt finish payment');
        return null;
      },
      onSuccess: () async {
        debugPrint('successful payment');
        await authProvider.updateUserToPremium();
        await NotificationService.showTransactionSuccess(
          merchantName: 'LocaCharge Premium',
          amount: 5000,
          transactionType: 'Abonnement Premium',
        );
        return null;
      },
    );
  }
}
