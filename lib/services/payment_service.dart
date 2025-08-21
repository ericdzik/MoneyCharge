import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PaymentService {
  final PaystackPlugin _paystackPlugin = PaystackPlugin();
  final String? publicKey;

  PaymentService({this.publicKey}) {
    _paystackPlugin.initialize(publicKey: publicKey!);
  }

  Future<void> chargeCardAndMakePayment(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    if (user == null) {
      // Handle user not logged in
      return;
    }

    Charge charge = Charge()
      ..amount = 5000 // amount in XOF
      ..reference = 'ref_${DateTime.now().millisecondsSinceEpoch}'
      ..email = user.email
      ..currency = 'XOF';

    try {
      CheckoutResponse response = await _paystackPlugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );

      if (response.status == true) {
        // Payment successful, update user to premium
        // This should be done on the server side via a webhook
        // or a cloud function for security reasons.
        // For now, we'll simulate it on the client.
        await authProvider.updateUserToPremium();
      } else {
        // Payment failed
      }
    } catch (e) {
      // Handle error
    }
  }
}
