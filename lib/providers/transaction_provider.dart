import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:locacharge/features/merchant/models/balance_model.dart';
import 'package:locacharge/models/transaction_model.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BalanceModel? _balance;
  List<TransactionModel> _merchantTransactions = [];
  List<TransactionModel> _userTransactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionsError;

  // Getters
  BalanceModel? get balance => _balance;
  List<TransactionModel> get merchantTransactions => _merchantTransactions;
  List<TransactionModel> get transactions => _userTransactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get transactionsError => _transactionsError;

  double get totalRevenue => _merchantTransactions
      .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.sale)
      .fold(0.0, (sum, t) => sum + t.netAmount);

  double get totalExpenses => _merchantTransactions
      .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.stockPurchase)
      .fold(0.0, (sum, t) => sum + t.amount);

  int get totalSalesTransactionsCount => _merchantTransactions
      .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.sale)
      .length;

  double get previousRevenue {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return _merchantTransactions
        .where((t) => 
            t.status == TransactionStatus.completed && 
            t.type == TransactionType.sale &&
            t.timestamp.toDate().isBefore(yesterday))
        .fold(0.0, (sum, t) => sum + t.netAmount);
  }

  int get previousTransactionsCount {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return _merchantTransactions
        .where((t) => 
            t.status == TransactionStatus.completed && 
            t.type == TransactionType.sale &&
            t.timestamp.toDate().isBefore(yesterday))
        .length;
  }

  List<double> get last7DaysRevenue {
    final now = DateTime.now();
    final revenues = <double>[];
    
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayRevenue = _merchantTransactions
          .where((t) => 
              t.status == TransactionStatus.completed && 
              t.type == TransactionType.sale &&
              t.timestamp.toDate().isAfter(dayStart) &&
              t.timestamp.toDate().isBefore(dayEnd))
          .fold(0.0, (sum, t) => sum + t.netAmount);
      
      revenues.add(dayRevenue);
    }
    
    return revenues;
  }

  List<String> get last7DaysLabels {
    final now = DateTime.now();
    final labels = <String>[];
    
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      labels.add('${day.day}/${day.month}');
    }
    
    return labels;
  }

  List<TransactionModel> get recentTransactions {
    return _merchantTransactions.take(5).toList();
  }

  Future<void> fetchMerchantTransactions(AuthProvider authProvider) async {
    if (authProvider.userType != UserType.merchant || authProvider.merchantProfile == null) {
      _transactionsError = "Utilisateur non marchand ou profil marchand non chargé.";
      _isLoadingTransactions = false;
      notifyListeners();
      return;
    }
    final String merchantId = authProvider.merchantProfile!.id;
    if (merchantId.isEmpty) {
      _transactionsError = "ID du marchand non disponible.";
      _isLoadingTransactions = false;
      notifyListeners();
      return;
    }

    // Éviter les appels multiples si déjà en cours de chargement
    if (_isLoadingTransactions) return;

    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    try {
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('timestamp', descending: true)
          .get();

      _merchantTransactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _transactionsError = null;
    } catch (e) {
      print("Error in fetchMerchantTransactions: $e");
      _transactionsError = "Erreur lors de la récupération des transactions: ${e.toString()}";
      _merchantTransactions = [];
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction({
    required String customerPhone,
    required TransactionType type,
    required BalanceType balanceType,
    required double amount,
    required double commission,
    required String serviceName,
    String? details,
    String? operator,
    String? reference,
    required AuthProvider authProvider,
  }) async {
    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    String? currentMerchantId = authProvider.merchantProfile?.id;
    String? currentUserId = authProvider.userId;

    if (currentMerchantId == null || currentMerchantId.isEmpty) {
       _transactionsError = "Impossible d'ajouter la transaction: ID du marchand non disponible.";
      _isLoadingTransactions = false;
      notifyListeners();
      return false;
    }

    double netAmountValue = (balanceType == BalanceType.credit)
        ? amount - commission
        : amount;

    try {
      final newTransaction = TransactionModel(
        id: '',
        merchantId: currentMerchantId,
        userId: currentUserId,
        serviceName: serviceName,
        amount: amount,
        commission: commission,
        netAmount: netAmountValue,
        type: type,
        status: TransactionStatus.completed,
        balanceType: balanceType,
        timestamp: Timestamp.now(),
        details: details,
        customerPhone: customerPhone,
        operator: operator,
        reference: reference,
      );

      final DocumentReference newTransactionRef = await _firestore.collection('transactions').add(
        newTransaction.toFirestoreMap()
          ..['timestamp'] = FieldValue.serverTimestamp(),
      );

      final newDocSnapshot = await newTransactionRef.get();
      _merchantTransactions.insert(0, TransactionModel.fromFirestore(newDocSnapshot as DocumentSnapshot<Map<String, dynamic>>));

      _isLoadingTransactions = false;
      notifyListeners();
      return true;

    } catch (e) {
      print("Error in addTransaction: $e");
      _transactionsError = "Erreur lors de l'ajout de la transaction: ${e.toString()}";
      _isLoadingTransactions = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTransactions(String userId) async {
    // Éviter les appels multiples si déjà en cours de chargement
    if (_isLoadingTransactions) return;

    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    try {
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      _userTransactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _transactionsError = null;
    } catch (e) {
      print("Error in fetchTransactions: $e");
      _transactionsError = "Erreur lors de la récupération des transactions: ${e.toString()}";
      _userTransactions = [];
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

}
