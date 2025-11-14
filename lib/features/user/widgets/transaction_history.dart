import 'package:flutter/material.dart';

class TransactionHistory extends StatelessWidget {
  const TransactionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      {
        'title': 'Recharge',
        'amount': 50.0,
        'date': '12/11/2025',
        'isCredit': true,
      },
      {
        'title': 'Course avec John',
        'amount': -15.5,
        'date': '11/11/2025',
        'isCredit': false,
      },
      {
        'title': 'Course avec Sarah',
        'amount': -22.0,
        'date': '10/11/2025',
        'isCredit': false,
      },
      {
        'title': 'Recharge',
        'amount': 100.0,
        'date': '09/11/2025',
        'isCredit': true,
      },
    ];

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isCredit = transaction['isCredit'] as bool;
        final amount = transaction['amount'] as double;
        final title = transaction['title'] as String;
        final date = transaction['date'] as String;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            leading: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
            ),
            title: Text(title),
            subtitle: Text(date),
            trailing: Text(
              '${amount.toStringAsFixed(2)} €',
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
