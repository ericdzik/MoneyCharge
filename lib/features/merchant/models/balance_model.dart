import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure this is the first or among the top imports
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum BalanceType { credit, debit }

enum TransactionType {
  rechargeCredit,
  dataPackage,
  simCard,
  moneyTransfer,
  billPayment,
  other,
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
    dynamic lastUpdatedData = json['lastUpdated'];
    DateTime parsedLastUpdated;
    if (lastUpdatedData is Timestamp) {
      parsedLastUpdated = lastUpdatedData.toDate();
    } else if (lastUpdatedData is String) {
      parsedLastUpdated = DateTime.tryParse(lastUpdatedData) ?? DateTime.now();
    } else {
      parsedLastUpdated = DateTime.now();
    }

    return BalanceModel(
      id: json['id'] ?? json['uid'] ?? '',
      merchantId: json['merchantId'] ?? json['uid'] ?? '',
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0.0,
      totalCredits: (json['totalCredits'] as num?)?.toDouble() ?? 0.0,
      totalDebits: (json['totalDebits'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: parsedLastUpdated,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
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
  final String? operator;
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
    dynamic createdAtData = json['createdAt'];
    DateTime parsedCreatedAt;
    if (createdAtData is Timestamp) {
      parsedCreatedAt = createdAtData.toDate();
    } else if (createdAtData is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtData) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return TransactionModel(
      id: json['id'] ?? '',
      merchantId: json['merchantId'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      type: TransactionType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (json['type'] as String?)?.toLowerCase(),
        orElse: () => TransactionType.other,
      ),
      balanceType: BalanceType.values.firstWhere(
        (e) => e.toString().split('.').last.toLowerCase() == (json['balanceType'] as String?)?.toLowerCase(),
        orElse: () => BalanceType.debit,
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['netAmount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      operator: json['operator'] as String?,
      reference: json['reference'] as String?,
      isSuccessful: json['isSuccessful'] as bool? ?? false,
      createdAt: parsedCreatedAt,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
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
      'createdAt': Timestamp.fromDate(createdAt), // Store as Firestore Timestamp
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
