import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum BalanceType { credit, debit }

enum TransactionType {
  rechargeCredit, // Recharge de crédit téléphonique
  dataPackage, // Forfait data
  simCard, // Vente de carte SIM
  moneyTransfer, // Transfert d'argent
  billPayment, // Paiement de factures
  other, // Autres services
}

extension BalanceTypeExtension on BalanceType {
  String get balanceTypeText {
    switch (this) {
      case BalanceType.credit:
        return 'Crédit';
      case BalanceType.debit:
        return 'Débit';
    }
  }
}

extension TransactionTypeExtension on TransactionType {
  String get typeText {
    switch (this) {
      case TransactionType.rechargeCredit:
        return 'Recharge crédit';
      case TransactionType.dataPackage:
        return 'Forfait data';
      case TransactionType.simCard:
        return 'Carte SIM';
      case TransactionType.moneyTransfer:
        return 'Transfert d\'argent';
      case TransactionType.billPayment:
        return 'Paiement facture';
      case TransactionType.other:
        return 'Autre service';
    }
  }
}

class BalanceModel {
  final String id;
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
      id: json['id'] ?? '',
      merchantId: json['merchantId'] ?? '',
      currentBalance: (json['currentBalance'] ?? 0.0).toDouble(),
      totalCredits: (json['totalCredits'] ?? 0.0).toDouble(),
      totalDebits: (json['totalDebits'] ?? 0.0).toDouble(),
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantId': merchantId,
      'currentBalance': currentBalance,
      'totalCredits': totalCredits,
      'totalDebits': totalDebits,
      'lastUpdated': lastUpdated.toIso8601String(),
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

class TransactionModel {
  final String id;
  final String merchantId;
  final String customerPhone;
  final TransactionType type;
  final BalanceType balanceType;
  final double amount;
  final double commission;
  final double netAmount;
  final String description;
  final String? operator; // MTN, Orange, Moov, etc.
  final String? reference;
  final bool isSuccessful;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.merchantId,
    required this.customerPhone,
    required this.type,
    required this.balanceType,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.description,
    this.operator,
    this.reference,
    required this.isSuccessful,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      merchantId: json['merchantId'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
        orElse: () => TransactionType.other,
      ),
      balanceType: BalanceType.values.firstWhere(
        (e) => e.toString() == 'BalanceType.${json['balanceType']}',
        orElse: () => BalanceType.debit,
      ),
      amount: (json['amount'] ?? 0.0).toDouble(),
      commission: (json['commission'] ?? 0.0).toDouble(),
      netAmount: (json['netAmount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      operator: json['operator'],
      reference: json['reference'],
      isSuccessful: json['isSuccessful'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantId': merchantId,
      'customerPhone': customerPhone,
      'type': type.toString().split('.').last,
      'balanceType': balanceType.toString().split('.').last,
      'amount': amount,
      'commission': commission,
      'netAmount': netAmount,
      'description': description,
      'operator': operator,
      'reference': reference,
      'isSuccessful': isSuccessful,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get operatorText {
    return operator ?? 'N/A';
  }

  Color get statusColor {
    return isSuccessful ? AppColors.success : AppColors.outOfStock;
  }

  String get statusText {
    return isSuccessful ? 'Réussi' : 'Échec';
  }
}
