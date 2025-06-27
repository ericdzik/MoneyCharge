import 'package:flutter/foundation.dart';
import '../features/merchant/models/balance_model.dart';

class TransactionProvider with ChangeNotifier {
  BalanceModel? _balance;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  BalanceModel? get balance => _balance;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Statistiques
  double get totalRevenue => _transactions
      .where((t) => t.isSuccessful && t.balanceType == BalanceType.credit)
      .fold(0.0, (sum, t) => sum + t.netAmount);

  double get totalExpenses => _transactions
      .where((t) => t.isSuccessful && t.balanceType == BalanceType.debit)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalProfit => totalRevenue - totalExpenses;

  // Statistiques par période
  List<TransactionModel> getTransactionsForPeriod(
    DateTime start,
    DateTime end,
  ) {
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

  // Statistiques du jour
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

  // Statistiques de la semaine
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

  // Statistiques du mois
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

  // Charger les données
  Future<void> loadData() async {
    _setLoading(true);
    try {
      await Future.delayed(const Duration(seconds: 1)); // Simulation API
      _loadDemoData();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Ajouter une transaction
  Future<bool> addTransaction({
    required String customerPhone,
    required TransactionType type,
    required BalanceType balanceType,
    required double amount,
    required double commission,
    required String description,
    String? operator,
    String? reference,
  }) async {
    _setLoading(true);
    try {
      final transaction = TransactionModel(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        merchantId:
            'merchant_1', // En production, récupérer depuis AuthProvider
        customerPhone: customerPhone,
        type: type,
        balanceType: balanceType,
        amount: amount,
        commission: commission,
        netAmount: balanceType == BalanceType.credit
            ? amount - commission
            : amount + commission,
        description: description,
        operator: operator,
        reference: reference,
        isSuccessful: true, // En production, vérifier avec l'API
        createdAt: DateTime.now(),
      );

      _transactions.insert(0, transaction);
      _updateBalance(transaction);

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour le solde
  void _updateBalance(TransactionModel transaction) {
    if (_balance == null) {
      _balance = BalanceModel(
        id: 'balance_1',
        merchantId: 'merchant_1',
        currentBalance: 0.0,
        totalCredits: 0.0,
        totalDebits: 0.0,
        lastUpdated: DateTime.now(),
      );
    }

    if (transaction.balanceType == BalanceType.credit) {
      _balance = _balance!.copyWith(
        currentBalance: _balance!.currentBalance + transaction.netAmount,
        totalCredits: _balance!.totalCredits + transaction.netAmount,
        lastUpdated: DateTime.now(),
      );
    } else {
      _balance = _balance!.copyWith(
        currentBalance: _balance!.currentBalance - transaction.amount,
        totalDebits: _balance!.totalDebits + transaction.amount,
        lastUpdated: DateTime.now(),
      );
    }
  }

  // Charger des données de démonstration
  void _loadDemoData() {
    // Solde initial
    _balance = BalanceModel(
      id: 'balance_1',
      merchantId: 'merchant_1',
      currentBalance: 125000.0,
      totalCredits: 250000.0,
      totalDebits: 125000.0,
      lastUpdated: DateTime.now(),
    );

    // Transactions de démonstration
    _transactions = [
      // Transactions d'aujourd'hui
      TransactionModel(
        id: 'txn_1',
        merchantId: 'merchant_1',
        customerPhone: '+225 0123456789',
        type: TransactionType.rechargeCredit,
        balanceType: BalanceType.credit,
        amount: 1000.0,
        commission: 50.0,
        netAmount: 950.0,
        description: 'Recharge crédit MTN',
        operator: 'MTN',
        reference: 'REF001',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      TransactionModel(
        id: 'txn_2',
        merchantId: 'merchant_1',
        customerPhone: '+225 0123456790',
        type: TransactionType.dataPackage,
        balanceType: BalanceType.credit,
        amount: 2000.0,
        commission: 100.0,
        netAmount: 1900.0,
        description: 'Forfait data Orange 1GB',
        operator: 'Orange',
        reference: 'REF002',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      TransactionModel(
        id: 'txn_3',
        merchantId: 'merchant_1',
        customerPhone: '+225 0123456791',
        type: TransactionType.moneyTransfer,
        balanceType: BalanceType.credit,
        amount: 5000.0,
        commission: 250.0,
        netAmount: 4750.0,
        description: 'Transfert d\'argent',
        operator: 'Moov Money',
        reference: 'REF003',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      // Transactions de la semaine
      TransactionModel(
        id: 'txn_4',
        merchantId: 'merchant_1',
        customerPhone: '+225 0123456792',
        type: TransactionType.simCard,
        balanceType: BalanceType.credit,
        amount: 1500.0,
        commission: 75.0,
        netAmount: 1425.0,
        description: 'Vente carte SIM MTN',
        operator: 'MTN',
        reference: 'REF004',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: 'txn_5',
        merchantId: 'merchant_1',
        customerPhone: '+225 0123456793',
        type: TransactionType.billPayment,
        balanceType: BalanceType.credit,
        amount: 3000.0,
        commission: 150.0,
        netAmount: 2850.0,
        description: 'Paiement facture électricité',
        operator: 'CIE',
        reference: 'REF005',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      // Dépenses
      TransactionModel(
        id: 'txn_6',
        merchantId: 'merchant_1',
        customerPhone: 'N/A',
        type: TransactionType.other,
        balanceType: BalanceType.debit,
        amount: 50000.0,
        commission: 0.0,
        netAmount: 50000.0,
        description: 'Achat de crédit MTN',
        operator: 'MTN',
        reference: 'REF006',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: 'txn_7',
        merchantId: 'merchant_1',
        customerPhone: 'N/A',
        type: TransactionType.other,
        balanceType: BalanceType.debit,
        amount: 30000.0,
        commission: 0.0,
        netAmount: 30000.0,
        description: 'Achat de crédit Orange',
        operator: 'Orange',
        reference: 'REF007',
        isSuccessful: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
