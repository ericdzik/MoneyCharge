import 'package:flutter/material.dart';
import 'package:loca_charge/features/user/widgets/balance_card.dart';
import 'package:loca_charge/features/user/widgets/transaction_history.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portefeuille'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BalanceCard(balance: 1234.56),
            SizedBox(height: 24),
            Text(
              'Historique des transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: TransactionHistory(),
            ),
          ],
        ),
      ),
    );
  }
}
