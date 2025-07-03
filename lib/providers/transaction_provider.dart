import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/merchant/models/balance_model.dart'; // Conservé si BalanceModel est utilisé ailleurs ou sera réintégré
import '../models/transaction_model.dart'; // Import de notre nouveau TransactionModel
import './auth_provider.dart';

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BalanceModel? _balance; // Conservé pour l'instant, mais sa mise à jour est hors du scope de ce refactor immédiat
  List<TransactionModel> _merchantTransactions = [];
  bool _isLoadingTransactions = false;
  String? _transactionsError;

  // Getters
  BalanceModel? get balance => _balance; // Conservé
  List<TransactionModel> get merchantTransactions => _merchantTransactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String? get transactionsError => _transactionsError;

  // Getters de statistiques pour le Dashboard Marchand

  // Revenu total (basé sur les ventes complétées)
  double get totalRevenue => _merchantTransactions
      .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.sale)
      .fold(0.0, (sum, t) => sum + t.netAmount);

  // Dépenses totales (par exemple, achat de stock complété)
  // Note: ce calcul est une simplification. Une vraie gestion des dépenses pourrait être plus complexe.
  double get totalExpenses => _merchantTransactions
      .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.stockPurchase)
      .fold(0.0, (sum, t) => sum + t.amount); // 'amount' représente le coût total de l'achat de stock

  // Nombre total de transactions de vente complétées
  int get totalSalesTransactionsCount => _merchantTransactions
      .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.sale)
      .length;

  // Transactions récentes pour le dashboard (ex: les 5 dernières)
  List<TransactionModel> get recentTransactions {
    // La requête Firestore dans fetchMerchantTransactions trie déjà par timestamp descendant.
    return _merchantTransactions.take(5).toList();
  }

  /* --- Getters de période commentés pour l'instant ---
     Ils nécessiteraient d'adapter la comparaison de date avec t.timestamp.toDate()
     et potentiellement d'ajuster la logique de TransactionType/BalanceType si besoin.

  List<TransactionModel> getTransactionsForPeriod(DateTime start, DateTime end) {
    return _merchantTransactions
        .where((t) => t.timestamp.toDate().isAfter(start) && t.timestamp.toDate().isBefore(end))
        .toList();
  }

  double getRevenueForPeriod(DateTime start, DateTime end) {
    return getTransactionsForPeriod(start, end)
        .where((t) => t.status == TransactionStatus.completed && t.type == TransactionType.sale)
        .fold(0.0, (sum, t) => sum + t.netAmount);
  }

  // ... (autres getters de période : today, week, month) ...
  */

  Future<void> fetchMerchantTransactions(AuthProvider authProvider) async {
    if (authProvider.userType != UserType.merchant || authProvider.merchantProfile == null) {
      _transactionsError = "Utilisateur non marchand ou profil marchand non chargé.";
      _isLoadingTransactions = false;
      notifyListeners();
      return;
    }
    final String? merchantId = authProvider.merchantProfile!.id;
    if (merchantId == null || merchantId.isEmpty) {
      _transactionsError = "ID du marchand non disponible.";
      _isLoadingTransactions = false;
      notifyListeners();
      return;
    }

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

      // La récupération du _balance est retirée d'ici.
      // Si le solde est nécessaire, il devrait être récupéré via AuthProvider (si inclus dans MerchantAuthModel)
      // ou par une méthode dédiée si c'est une source de données séparée.

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
    required String serviceName, // Champ principal pour le nom du service
    String? details,       // Pour une description plus longue ou des notes
    String? operator,
    String? reference,
    required AuthProvider authProvider,
  }) async {
    _isLoadingTransactions = true;
    _transactionsError = null;
    notifyListeners();

    String? currentMerchantId = authProvider.merchantProfile?.id;
    // Pourrait aussi prendre un userId si la transaction est initiée par un utilisateur spécifique lié au marchand
    // String? initiatorUserId = authProvider.userId;

    if (currentMerchantId == null || currentMerchantId.isEmpty) {
       _transactionsError = "Impossible d'ajouter la transaction: ID du marchand non disponible.";
      _isLoadingTransactions = false;
      notifyListeners();
      return false;
    }

    double netAmountValue = (balanceType == BalanceType.credit)
        ? amount - commission // Pour une vente, le netAmount est ce que le marchand gagne
        : amount; // Pour un débit (ex: achat de stock), amount est le coût total

    try {
      final newTransaction = TransactionModel(
        id: '', // Firestore générera l'ID
        merchantId: currentMerchantId,
        userId: null, // À définir si applicable (par exemple, ID de l'employé qui fait la transaction)
        serviceName: serviceName,
        amount: amount,
        commission: commission,
        netAmount: netAmountValue,
        type: type,
        // Par défaut à 'completed' si l'écriture est directe.
        // Si un processus de validation/paiement externe est nécessaire, ce serait 'pending'.
        status: TransactionStatus.completed,
        balanceType: balanceType,
        timestamp: Timestamp.now(), // Sera écrasé par serverTimestamp lors de l'écriture
        details: details,
        customerPhone: customerPhone,
        operator: operator,
        reference: reference,
      );

      final DocumentReference newTransactionRef = await _firestore.collection('transactions').add(
        newTransaction.toFirestoreMap()
          ..['timestamp'] = FieldValue.serverTimestamp(), // Assurer le timestamp serveur
      );

      // Mettre à jour la liste locale pour une réactivité immédiate de l'UI
      // On récupère le document fraîchement créé pour avoir le timestamp serveur et l'ID
      final newDocSnapshot = await newTransactionRef.get();
      _merchantTransactions.insert(0, TransactionModel.fromFirestore(newDocSnapshot as DocumentSnapshot<Map<String, dynamic>>));

      // La mise à jour du solde du marchand doit impérativement être gérée côté serveur
      // (ex: Cloud Functions) pour garantir l'atomicité et la sécurité.
      // Le client ne doit pas mettre à jour le solde directement.
      // Après cette transaction, le profil du marchand (et donc son solde)
      // sera rafraîchi lors du prochain appel à AuthProvider._fetchUserProfile.

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

  void _setLoading(bool loading) {
    _isLoadingTransactions = loading;
    notifyListeners();
  }
}
