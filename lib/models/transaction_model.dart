import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { sale, stockPurchase, refund, withdrawal }
enum TransactionStatus { pending, completed, failed, cancelled }
enum BalanceType { credit, debit } // Nouvel enum

class TransactionModel {
  final String id;
  final String merchantId;
  final String? userId;
  final String serviceName;
  final double amount; // Montant brut de la transaction
  final double commission; // Commission prise sur la transaction
  final double netAmount; // Montant net après commission (pour les crédits) ou montant total (pour les débits)
  final TransactionType type;
  final TransactionStatus status;
  final BalanceType balanceType; // Indique si la transaction crédite ou débite le solde du marchand
  final Timestamp timestamp;
  final String? details;
  final String? customerPhone; // Ajouté car utilisé dans TransactionProvider
  final String? operator; // Ajouté car utilisé dans TransactionProvider
  final String? reference; // Ajouté car utilisé dans TransactionProvider


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

  // Getter pour la compatibilité avec la logique existante dans TransactionProvider
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

  Map<String, dynamic> toFirestoreMap() { // Renommé pour clarté, utilisé par TransactionProvider
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
      'timestamp': timestamp, // Sera remplacé par FieldValue.serverTimestamp() lors de l'écriture si nouvelle transaction
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
        return TransactionType.sale; // Valeur par défaut
    }
  }

  static BalanceType _parseBalanceType(String? typeStr) {
    switch (typeStr?.toLowerCase()) {
      case 'credit':
        return BalanceType.credit;
      case 'debit':
        return BalanceType.debit;
      default:
        return BalanceType.credit; // Valeur par défaut
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
        return TransactionStatus.pending; // Valeur par défaut
    }
  }

  // Helper pour l'affichage
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
        return 'Inconnu';
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
        return 'Inconnu';
    }
  }
}
