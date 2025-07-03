import 'package:cloud_firestore/cloud_firestore.dart';

// Note: TransactionModel, TransactionType, BalanceType, TransactionStatus ne sont plus définis ici.
// Si BalanceModel a besoin de ces types (par exemple pour une liste de transactions récentes),
// il devra importer `package:locacharge/models/transaction_model.dart`.
// Pour l'instant, nous avons commenté `recentTransactions` pour éviter ce besoin.

class BalanceModel {
  final String id; // Peut être l'ID du marchand
  final String merchantId;
  final double currentBalance;
  final double totalCredits;
  final double totalDebits;
  final DateTime lastUpdated;

  BalanceModel({
    required this.id,
    required this.merchantId,
    required this.currentBalance,
    required this.totalCredits,
    required this.totalDebits,
    required this.lastUpdated,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      id: json['id'] as String? ?? '',
      merchantId: json['merchantId'] as String? ?? json['uid'] as String? ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0.0,
      totalDebits: (json['totalDebits'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: (json['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() { // Renommé depuis toFirestoreMap pour convention si c'est un modèle de données simple
    return {
      'merchantId': merchantId,
      'currentBalance': currentBalance,
      'totalCredits': totalCredits,
      'totalDebits': totalDebits,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

   BalanceModel copyWith({
    String? id,
    String? merchantId,
    double? currentBalance,
    double? totalCredits,
    double? totalDebits,
    DateTime? lastUpdated,
  }) {
    return BalanceModel(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      currentBalance: currentBalance ?? this.currentBalance,
      totalCredits: totalCredits ?? this.totalCredits,
      totalDebits: totalDebits ?? this.totalDebits,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
