import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { sale, stockPurchase, refund, withdrawal }
enum TransactionStatus { pending, completed, failed, cancelled }
enum BalanceType { credit, debit }

class TransactionModel {
  final String id;
  final String merchantId;
  final String? userId;
  final String serviceName;
  final double amount;
  final double commission;
  final double netAmount;
  final TransactionType type;
  final TransactionStatus status;
  final BalanceType balanceType;
  final Timestamp timestamp;
  final String? details;
  final String? customerPhone;
  final String? operator;
  final String? reference;


  TransactionModel({
    required this.id,
    required this.merchantId,
    this.userId,
    required this.serviceName,
    required this.amount,
    required this.commission,
    required this.netAmount,
    required this.type,
    required this.status,
    required this.balanceType,
    required this.timestamp,
    this.details,
    this.customerPhone,
    this.operator,
    this.reference,
  });

  bool get isSuccessful => status == TransactionStatus.completed;

  factory TransactionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document de transaction vide pour l'ID: ${doc.id}");
    }

    return TransactionModel(
      id: doc.id,
      merchantId: data['merchantId'] as String? ?? '',
      userId: data['userId'] as String?,
      serviceName: data['serviceName'] as String? ?? 'Service inconnu',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      commission: (data['commission'] as num?)?.toDouble() ?? 0.0,
      netAmount: (data['netAmount'] as num?)?.toDouble() ?? 0.0,
      type: _parseTransactionType(data['type'] as String?),
      status: _parseTransactionStatus(data['status'] as String?),
      balanceType: _parseBalanceType(data['balanceType'] as String?),
      timestamp: data['timestamp'] as Timestamp? ?? Timestamp.now(),
      details: data['details'] as String?,
      customerPhone: data['customerPhone'] as String?,
      operator: data['operator'] as String?,
      reference: data['reference'] as String?,
    );
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'merchantId': merchantId,
      'userId': userId,
      'serviceName': serviceName,
      'amount': amount,
      'commission': commission,
      'netAmount': netAmount,
      'type': type.name,
      'status': status.name,
      'balanceType': balanceType.name,
      'timestamp': timestamp,
      'details': details,
      'customerPhone': customerPhone,
      'operator': operator,
      'reference': reference,
    };
  }

  static TransactionType _parseTransactionType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'sale':
        return TransactionType.sale;
      case 'stockpurchase':
      case 'stock_purchase':
        return TransactionType.stockPurchase;
      case 'refund':
        return TransactionType.refund;
      case 'withdrawal':
        return TransactionType.withdrawal;
      default:
        return TransactionType.sale;
    }
  }

  static BalanceType _parseBalanceType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'credit':
        return BalanceType.credit;
      case 'debit':
        return BalanceType.debit;
      default:
        return BalanceType.credit;
    }
  }

  static TransactionStatus _parseTransactionStatus(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  String get typeDisplay {
    switch (type) {
      case TransactionType.sale:
        return 'Vente';
      case TransactionType.stockPurchase:
        return 'Achat de Stock';
      case TransactionType.refund:
        return 'Remboursement';
      case TransactionType.withdrawal:
        return 'Retrait';
      default:
        return type.name;
    }
  }

   String get statusDisplay {
    switch (status) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.completed:
        return 'Terminée';
      case TransactionStatus.failed:
        return 'Échouée';
      case TransactionStatus.cancelled:
        return 'Annulée';
      default:
        return status.name;
    }
  }
}
