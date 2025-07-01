import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../features/merchant/models/balance_model.dart';
// import '../services/api_service.dart'; // No longer using ApiService here
import './auth_provider.dart'; // Import AuthProvider

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Add Firestore instance
  // final ApiService _apiService = ApiService(); // Remove ApiService instance

  BalanceModel? _balance;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false; // Combined loading state for simplicity for now
  String? _error;

  // Getters
  BalanceModel? get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistiques (remain unchanged, operate on local _transactions)
  double get totalRevenue => _transactions
      .where((t) => t.isSuccessful && t.balanceType == BalanceType.credit)
      .fold(0.0, (sum, t) => sum + t.netAmount);

  double get totalExpenses => _transactions
      .where((t) => t.isSuccessful && t.balanceType == BalanceType.debit)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalProfit => totalRevenue - totalExpenses;

  List<TransactionModel> getTransactionsForPeriod(DateTime start, DateTime end) {
    return _transactions
        .where((t) => t.createdAt.isAfter(start) && t.createdAt.isBefore(end))
        .toList();
  }

  double getRevenueForPeriod(DateTime start, DateTime end) {
    return getTransactionsForPeriod(start, end)
        .where((t) => t.isSuccessful && t.balanceType == BalanceType.credit)
        .fold(0.0, (sum, t) => sum + t.netAmount);
  }

  double getExpensesForPeriod(DateTime start, DateTime end) {
    return getTransactionsForPeriod(start, end)
        .where((t) => t.isSuccessful && t.balanceType == BalanceType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double getProfitForPeriod(DateTime start, DateTime end) {
    return getRevenueForPeriod(start, end) - getExpensesForPeriod(start, end);
  }

  List<TransactionModel> get todayTransactions {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getTransactionsForPeriod(startOfDay, endOfDay);
  }

  double get todayRevenue => getRevenueForPeriod(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  double get todayExpenses => getExpensesForPeriod(
    DateTime.now().subtract(const Duration(days: 1)),
    DateTime.now(),
  );

  double get todayProfit => todayRevenue - todayExpenses;

  List<TransactionModel> get weekTransactions {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return getTransactionsForPeriod(startOfWeek, endOfWeek);
  }

  double get weekRevenue => getRevenueForPeriod(
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now(),
  );

  double get weekExpenses => getExpensesForPeriod(
    DateTime.now().subtract(const Duration(days: 7)),
    DateTime.now(),
  );

  double get weekProfit => weekRevenue - weekExpenses;

  List<TransactionModel> get monthTransactions {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    return getTransactionsForPeriod(startOfMonth, endOfMonth);
  }

  double get monthRevenue => getRevenueForPeriod(
    DateTime.now().subtract(const Duration(days: 30)),
    DateTime.now(),
  );

  double get monthExpenses => getExpensesForPeriod(
    DateTime.now().subtract(const Duration(days: 30)),
    DateTime.now(),
  );

  double get monthProfit => monthRevenue - monthExpenses;

  Future<void> fetchTransactionsAndBalance(AuthProvider authProvider) async {
    if (authProvider.userType != UserType.merchant || authProvider.merchantProfile == null) {
      _error = "Utilisateur non marchand ou profil marchand non chargé.";
      _isLoading = false;
      notifyListeners();
      return;
    }
    final String? merchantId = authProvider.merchantProfile!.id;
    if (merchantId == null || merchantId.isEmpty) {
      _error = "ID du marchand non disponible.";
      _isLoading = false;
      notifyListeners();
      return;
    }

    _setLoading(true);
    _error = null;
    try {
      // Fetch Transactions from Firestore
      final transactionsSnapshot = await _firestore
          .collection('transactions')
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('createdAt', descending: true)
          .get();

      _transactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data() as Map<String, dynamic>..['id'] = doc.id))
          .toList();

      // Fetch Balance from Merchant's profile in 'users' collection
      final merchantDocSnapshot = await _firestore.collection('users').doc(merchantId).get();
      if (merchantDocSnapshot.exists) {
        final merchantData = merchantDocSnapshot.data() as Map<String, dynamic>;
        // Assuming balance fields are directly on the merchant document
        // and BalanceModel.fromJson can handle this structure (e.g. using merchantId as 'id' for BalanceModel)
         _balance = BalanceModel.fromJson(merchantData..['id'] = merchantDocSnapshot.id);
      } else {
        // If merchant profile doesn't exist, or balance info isn't there
        _balance = null;
        print("Profil marchand non trouvé pour récupérer le solde, ou solde non inclus.");
        // Optionally set an error or use a default balance
      }

    } catch (e) {
      print("Error in fetchTransactionsAndBalance: $e");
      _error = "Erreur lors de la récupération des données: ${e.toString()}";
      _transactions = [];
      _balance = null;
    } finally {
      _setLoading(false);
    }
  }

  // _fetchBalanceData method is now integrated into fetchTransactionsAndBalance
  // Future<void> _fetchBalanceData(String merchantId) async { ... }


  Future<bool> addTransaction({
    required String customerPhone,
    required TransactionType type,
    required BalanceType balanceType,
    required double amount,
    required double commission,
    required String description,
    String? operator,
    String? reference,
    required AuthProvider authProvider,
  }) async {
    _setLoading(true);
    _error = null; // Clear previous errors

    String? currentMerchantId;
    if (authProvider.userType == UserType.merchant && authProvider.merchantProfile != null) {
      currentMerchantId = authProvider.merchantProfile!.id;
    }

    if (currentMerchantId == null || currentMerchantId.isEmpty) {
       _error = "Impossible d'ajouter la transaction: ID du marchand non disponible.";
      _setLoading(false);
      return false;
    }

    // Prepare data for API
    // Assuming netAmount is calculated server-side or needs to be calculated before sending
    // For now, let's calculate it client-side as before, but API might override or expect specific fields.
    double netAmountValue = (balanceType == BalanceType.credit)
        ? amount - commission
        : amount + commission; // This logic might need adjustment based on API spec

    final Map<String, dynamic> transactionData = {
      'merchantId': currentMerchantId,
      'customerPhone': customerPhone,
      'type': type.toString().split('.').last, // Send enum value as string
      'balanceType': balanceType.toString().split('.').last, // Send enum value as string
      'amount': amount,
      'commission': commission,
      'netAmount': netAmountValue, // Or let server calculate
      'description': description,
      if (operator != null) 'operator': operator,
      if (reference != null) 'reference': reference,
      // 'isSuccessful' will be set to true upon successful write to Firestore for now.
      // 'createdAt' will be set using FieldValue.serverTimestamp().
    };

    try {
      // Add transaction to Firestore
      // We use toFirestoreMap() from TransactionModel which should prepare data correctly
      final newTransactionRef = await _firestore.collection('transactions').add(
        TransactionModel( // Create a temporary model to get the map, then add server timestamp
          id: '', // Firestore will generate ID
          merchantId: currentMerchantId,
          customerPhone: customerPhone,
          type: type,
          balanceType: balanceType,
          amount: amount,
          commission: commission,
          netAmount: netAmountValue,
          description: description,
          operator: operator,
          reference: reference,
          isSuccessful: true, // Assume success for now, can be updated by backend if needed
          createdAt: DateTime.now(), // Placeholder, will be replaced by server timestamp
        ).toFirestoreMap()
          ..['createdAt'] = FieldValue.serverTimestamp(), // Add server timestamp
      );

      // Create a TransactionModel instance from the data we have + new ID and fetched timestamp (or estimate)
      // For immediate UI update, we can construct it. A more robust way is to re-fetch or get from server.
      final newTransactionForUI = TransactionModel(
        id: newTransactionRef.id, // Use the ID from Firestore
        merchantId: currentMerchantId,
        customerPhone: customerPhone,
        type: type,
        balanceType: balanceType,
        amount: amount,
        commission: commission,
        netAmount: netAmountValue,
        description: description,
        operator: operator,
        reference: reference,
        isSuccessful: true, // Assuming direct write success
        createdAt: DateTime.now(), // Approximate with current time for UI, actual is server time
      );

      _transactions.insert(0, newTransactionForUI);

      // --- Balance Update Logic (Client-Side with Firestore write) ---
      // This is where a Cloud Function is highly recommended for atomicity and reliability.
      // For now, performing a client-side read-modify-write on the merchant's balance.
      final merchantDocRef = _firestore.collection('users').doc(currentMerchantId);
      await _firestore.runTransaction((firestoreTransaction) async {
        final merchantSnapshot = await firestoreTransaction.get(merchantDocRef);
        if (!merchantSnapshot.exists) {
          throw Exception("Document marchand non trouvé pour la mise à jour du solde!");
        }

        double currentBalance = (merchantSnapshot.data()?['currentBalance'] as num?)?.toDouble() ?? 0.0;
        double currentTotalCredits = (merchantSnapshot.data()?['totalCredits'] as num?)?.toDouble() ?? 0.0;
        double currentTotalDebits = (merchantSnapshot.data()?['totalDebits'] as num?)?.toDouble() ?? 0.0;

        if (newTransactionForUI.balanceType == BalanceType.credit) {
          currentBalance += newTransactionForUI.netAmount;
          currentTotalCredits += newTransactionForUI.netAmount;
        } else { // Debit
          currentBalance -= newTransactionForUI.amount; // Assuming amount is positive for debit
          currentTotalDebits += newTransactionForUI.amount;
        }

        firestoreTransaction.update(merchantDocRef, {
          'currentBalance': currentBalance,
          'totalCredits': currentTotalCredits,
          'totalDebits': currentTotalDebits,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Update local balance model for immediate UI reflection
        _balance = BalanceModel(
          id: currentMerchantId!, // Use null assertion operator
          merchantId: currentMerchantId!, // Use null assertion operator
          currentBalance: currentBalance,
          totalCredits: currentTotalCredits,
          totalDebits: currentTotalDebits,
          lastUpdated: DateTime.now(), // Approximate for UI
        );
      });
      // --- End of Balance Update Logic ---

      _setLoading(false);
      notifyListeners();
      return true;

    } catch (e) {
      print("Error in addTransaction: $e");
      _error = "Erreur lors de l'ajout de la transaction: ${e.toString()}";
      _setLoading(false);
      return false;
    }
  }

  void _updateBalanceLocally(TransactionModel transaction) {
    if (_balance == null) {
      print("Warning: Updating balance locally, but initial balance was null. Initializing to zero for merchant ${transaction.merchantId}.");
      _balance = BalanceModel(
        id: 'balance_local_${transaction.merchantId}',
        merchantId: transaction.merchantId,
        currentBalance: 0.0,
        totalCredits: 0.0,
        totalDebits: 0.0,
        lastUpdated: DateTime.now(),
      );
    }

    double newCurrentBalance = _balance!.currentBalance;
    double newTotalCredits = _balance!.totalCredits;
    double newTotalDebits = _balance!.totalDebits;

    if (transaction.isSuccessful) { // Only update balance for successful transactions
      if (transaction.balanceType == BalanceType.credit) {
        newCurrentBalance += transaction.netAmount;
        newTotalCredits += transaction.netAmount;
      } else {
        newCurrentBalance -= transaction.amount;
        newTotalDebits += transaction.amount;
      }
    }

    _balance = _balance!.copyWith(
      currentBalance: newCurrentBalance,
      totalCredits: newTotalCredits,
      totalDebits: newTotalDebits,
      lastUpdated: DateTime.now(), // Should ideally be server timestamp if balance is server-authoritative
    );
  }

  // _updateBalanceLocally is no longer needed as its logic is integrated into addTransaction
  // void _updateBalanceLocally(TransactionModel transaction) { ... }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
