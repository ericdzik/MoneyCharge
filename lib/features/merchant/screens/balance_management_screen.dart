import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/auth_provider.dart'; // Import AuthProvider
import '../models/balance_model.dart';
import '../widgets/transaction_card_widget.dart';
import '../widgets/balance_summary_widget.dart';

class BalanceManagementScreen extends StatefulWidget {
  const BalanceManagementScreen({super.key});

  @override
  State<BalanceManagementScreen> createState() =>
      _BalanceManagementScreenState();
}

class _BalanceManagementScreenState extends State<BalanceManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // String _selectedPeriod = 'today'; // This variable was not used

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch AuthProvider instance first
      final authProvider = context.read<AuthProvider>();
      // Then call fetchTransactionsAndBalance
      context.read<TransactionProvider>().fetchTransactionsAndBalance(authProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadData() {
    final authProvider = context.read<AuthProvider>();
    context.read<TransactionProvider>().fetchTransactionsAndBalance(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Obtain AuthProvider here to pass to AddTransactionDialog
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion du solde'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(authProvider), // Pass authProvider
            tooltip: 'Ajouter une transaction',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Aujourd\'hui'),
            Tab(text: 'Cette semaine'),
            Tab(text: 'Ce mois'),
          ],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.outOfStock,
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Erreur: ${provider.error}',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.outOfStock,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  CustomButton(
                    text: 'Réessayer',
                    onPressed: _reloadData, // Use the new reload method
                  ),
                ],
              ),
            );
          }

          // Envelopper la Column principale dans un SingleChildScrollView
          return SingleChildScrollView(
            child: Column(
              children: [
                // Résumé du solde
                BalanceSummaryWidget(balance: provider.balance),

                // Statistiques par période
                Container(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  margin: const EdgeInsets.all(AppDimensions.paddingL),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistiques',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingM),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Revenus',
                              _getRevenueForCurrentTab(provider),
                              Icons.trending_up,
                              AppColors.success,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: _buildStatCard(
                              'Dépenses',
                              _getExpensesForCurrentTab(provider),
                              Icons.trending_down,
                              AppColors.outOfStock,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.paddingM),
                          Expanded(
                            child: _buildStatCard(
                              'Bénéfice',
                              _getProfitForCurrentTab(provider),
                              Icons.account_balance_wallet,
                              _getProfitForCurrentTab(provider) >= 0
                                  ? AppColors.primary
                                  : AppColors.outOfStock,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Liste des transactions
                SizedBox( // Envelopper TabBarView dans un SizedBox avec une hauteur fixe pour test
                  height: 400.0, // Hauteur de test, à ajuster ou rendre dynamique
                  child: TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildTransactionsList(provider.todayTransactions),
                      _buildTransactionsList(provider.weekTransactions),
                      _buildTransactionsList(provider.monthTransactions),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    double value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.paddingS),
          Text(
            '${value.toStringAsFixed(0)} FCFA',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long,
              size: 64,
              color: AppColors.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.paddingM),
            Text(
              'Aucune transaction pour cette période.',
              style: AppTextStyles.body1.copyWith(
                color: AppColors.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      // Retirer shrinkWrap et NeverScrollableScrollPhysics pour permettre le défilement
      // à l'intérieur du SizedBox parent du TabBarView.
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionCardWidget(
          transaction: transactions[index],
          onTap: () => _showTransactionDetails(transactions[index]),
        );
      },
    );
  }

  double _getRevenueForCurrentTab(TransactionProvider provider) {
    switch (_tabController.index) {
      case 0:
        return provider.todayRevenue;
      case 1:
        return provider.weekRevenue;
      case 2:
        return provider.monthRevenue;
      default:
        return 0.0;
    }
  }

  double _getExpensesForCurrentTab(TransactionProvider provider) {
    switch (_tabController.index) {
      case 0:
        return provider.todayExpenses;
      case 1:
        return provider.weekExpenses;
      case 2:
        return provider.monthExpenses;
      default:
        return 0.0;
    }
  }

  double _getProfitForCurrentTab(TransactionProvider provider) {
    switch (_tabController.index) {
      case 0:
        return provider.todayProfit;
      case 1:
        return provider.weekProfit;
      case 2:
        return provider.monthProfit;
      default:
        return 0.0;
    }
  }

  void _showAddTransactionDialog(AuthProvider authProvider) { // Accept AuthProvider
    showDialog(
      context: context,
      // Pass authProvider to AddTransactionDialog
      builder: (context) => AddTransactionDialog(authProvider: authProvider),
    );
  }

  void _showTransactionDetails(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailsDialog(transaction: transaction),
    );
  }
}

class AddTransactionDialog extends StatefulWidget {
  final AuthProvider authProvider; // Add AuthProvider field

  // Modify constructor to accept AuthProvider
  const AddTransactionDialog({super.key, required this.authProvider});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _commissionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  TransactionType _selectedType = TransactionType.rechargeCredit;
  BalanceType _selectedBalanceType = BalanceType.credit;
  String? _selectedOperator;

  final List<String> _operators = [
    'MTN',
    'Orange',
    'Moov',
    'Moov Money',
    'CIE',
    'SODECI',
  ];

  @override
  void dispose() {
    _customerPhoneController.dispose();
    _amountController.dispose();
    _commissionController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvelle transaction'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type de transaction
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de transaction',
                  border: OutlineInputBorder(),
                ),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.typeText),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Type de solde
              DropdownButtonFormField<BalanceType>(
                value: _selectedBalanceType,
                decoration: const InputDecoration(
                  labelText: 'Type de solde',
                  border: OutlineInputBorder(),
                ),
                items: BalanceType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.balanceTypeText),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBalanceType = value!;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Téléphone client
              TextFormField(
                controller: _customerPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone client',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le téléphone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Montant
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (FCFA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir le montant';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Commission
              TextFormField(
                controller: _commissionController,
                decoration: const InputDecoration(
                  labelText: 'Commission (FCFA)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir la commission';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Commission invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Opérateur
              DropdownButtonFormField<String>(
                value: _selectedOperator,
                decoration: const InputDecoration(
                  labelText: 'Opérateur',
                  border: OutlineInputBorder(),
                ),
                items: _operators.map((operator) {
                  return DropdownMenuItem(
                    value: operator,
                    child: Text(operator),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedOperator = value;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez saisir une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),

              // Référence
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  labelText: 'Référence (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        CustomButton(text: 'Ajouter', onPressed: _submitTransaction),
      ],
    );
  }

  void _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    // TransactionProvider is read here, but AuthProvider is accessed via widget.authProvider
    final transactionProvider = context.read<TransactionProvider>();
    final success = await transactionProvider.addTransaction(
      customerPhone: _customerPhoneController.text,
      type: _selectedType,
      balanceType: _selectedBalanceType,
      amount: double.parse(_amountController.text),
      commission: double.parse(_commissionController.text),
      description: _descriptionController.text,
      operator: _selectedOperator,
      reference: _referenceController.text.isNotEmpty
          ? _referenceController.text
          : null,
      authProvider: widget.authProvider, // Use the passed AuthProvider
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction ajoutée avec succès'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // Use transactionProvider.error to show the error from the provider
          content: Text('Erreur: ${transactionProvider.error ?? "Une erreur inconnue est survenue."}'),
          backgroundColor: AppColors.outOfStock,
        ),
      );
    }
  }
}

class TransactionDetailsDialog extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailsDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Détails de la transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Type', transaction.type.typeText),
          _buildDetailRow('Solde', transaction.balanceType.balanceTypeText),
          _buildDetailRow('Téléphone', transaction.customerPhone),
          _buildDetailRow('Montant', '${transaction.amount} FCFA'),
          _buildDetailRow('Commission', '${transaction.commission} FCFA'),
          _buildDetailRow('Montant net', '${transaction.netAmount} FCFA'),
          _buildDetailRow('Opérateur', transaction.operatorText),
          _buildDetailRow('Description', transaction.description),
          if (transaction.reference != null)
            _buildDetailRow('Référence', transaction.reference!),
          _buildDetailRow('Statut', transaction.statusText),
          _buildDetailRow(
            'Date',
            '${transaction.createdAt.day}/${transaction.createdAt.month}/${transaction.createdAt.year} à ${transaction.createdAt.hour}:${transaction.createdAt.minute.toString().padLeft(2, '0')}',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.body1)),
        ],
      ),
    );
  }
}
