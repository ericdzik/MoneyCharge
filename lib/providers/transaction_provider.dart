import 'package:flutter/foundation.dart';
import '../features/merchant/models/balance_model.dart';
import '../services/api_service.dart'; // Import ApiService
import './auth_provider.dart'; // Import AuthProvider

class TransactionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(); // Instantiate ApiService

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

  Future<void> _fetchBalanceData(String merchantId) async {
    try {
      final statsData = await _apiService.getStats(merchantId: merchantId);
      if (statsData.containsKey('currentBalance')) {
         _balance = BalanceModel.fromJson(statsData);
      } else if (statsData.containsKey('balance') && statsData['balance'] is Map) {
         _balance = BalanceModel.fromJson(statsData['balance'] as Map<String, dynamic>);
      } else {
        print("Balance data not found in stats or in expected format.");
      }
    } catch (e) {
      print("Error fetching balance: $e");
      _balance = null;
      rethrow;
    }
  }

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
      final List<Map<String, dynamic>> transactionData =
          await _apiService.getTransactions(merchantId: merchantId);
      _transactions = transactionData
          .map((data) => TransactionModel.fromJson(data))
          .toList();

      await _fetchBalanceData(merchantId);

    } catch (e) {
      _error = e.toString();
      _transactions = [];
      _balance = null;
    } finally {
      _setLoading(false);
    }
  }

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
      // 'isSuccessful' and 'createdAt' are typically set by the server upon creation
    };

    try {
      final Map<String, dynamic> createdTransactionData =
          await _apiService.createTransaction(transactionData);

      // Assuming the API returns the full created transaction object including its new ID and timestamps
      final newTransaction = TransactionModel.fromJson(createdTransactionData);

      _transactions.insert(0, newTransaction);
      // After successful transaction creation, it's best to re-fetch balance
      // or update it based on reliable data from API if possible.
      // For now, we'll call _updateBalanceLocally, then trigger a full refresh.
      _updateBalanceLocally(newTransaction);

      // Optionally, trigger a full refresh of transactions and balance to ensure consistency
      // This could be a separate call or a flag to the UI to refresh.
      // For now, just local update and notify. A full refresh might be better.
      // Consider calling: await fetchTransactionsAndBalance(authProvider);
      // For simplicity in this step, we'll rely on local update and subsequent manual refresh by user if needed.

      _setLoading(false);
      notifyListeners(); // Notify after all local state updates
      return true;
    } catch (e) {
      _error = e.toString();
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
