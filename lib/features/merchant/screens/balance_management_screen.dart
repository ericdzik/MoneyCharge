import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assurez-vous que cet import est présent pour Timestamp
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/auth_provider.dart';
import '../models/balance_model.dart';
import '../../../models/transaction_model.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      context.read<TransactionProvider>().fetchMerchantTransactions(authProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _reloadData() {
    final authProvider = context.read<AuthProvider>();
    context.read<TransactionProvider>().fetchMerchantTransactions(authProvider);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion du solde & Transactions'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTransactionDialog(authProvider),
            tooltip: 'Ajouter une transaction',
          ),
           IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reloadData,
            tooltip: 'Rafraîchir les données',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Toutes les Transactions'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (transactionProvider.balance != null)
            BalanceSummaryWidget(balance: transactionProvider.balance!),
          else
            const Padding(
              padding: EdgeInsets.all(AppDimensions.paddingM),
              child: Text("Solde non disponible.", style: AppTextStyles.body1),
            ),

          if (transactionProvider.isLoadingTransactions && transactionProvider.merchantTransactions.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (transactionProvider.transactionsError != null && transactionProvider.merchantTransactions.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: AppDimensions.paddingM),
                    Text(
                      'Erreur: ${transactionProvider.transactionsError}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body1.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: AppDimensions.paddingL),
                    CustomButton(text: 'Réessayer', onPressed: _reloadData),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTransactionsList(transactionProvider.merchantTransactions),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: AppColors.onSurface.withOpacity(0.5)),
              const SizedBox(height: AppDimensions.paddingM),
              Text(
                'Aucune transaction pour cette période.',
                style: AppTextStyles.body1.copyWith(color: AppColors.onSurface.withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: AppDimensions.paddingM),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionCardWidget(
          transaction: transaction,
          onTap: () => _showTransactionDetails(transaction),
        );
      },
    );
  }

  void _showAddTransactionDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
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
  final AuthProvider authProvider;
  const AddTransactionDialog({super.key, required this.authProvider});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _customerPhoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _commissionController = TextEditingController();
  final _serviceNameController = TextEditingController();
  final _detailsController = TextEditingController();
  final _referenceController = TextEditingController();

  TransactionType _selectedType = TransactionType.sale;
  BalanceType _selectedBalanceType = BalanceType.credit;
  String? _selectedOperator;

  final List<String> _operators = [
    'MTN', 'Orange', 'Moov', 'Moov Money', 'CIE', 'SODECI', 'Autre'
  ];

  @override
  void dispose() {
    _customerPhoneController.dispose();
    _amountController.dispose();
    _commissionController.dispose();
    _serviceNameController.dispose();
    _detailsController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  // Helper pour afficher le texte des TransactionType dans le Dropdown
  String _getTransactionTypeDisplayText(TransactionType type) {
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
              DropdownButtonFormField<TransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(labelText: 'Type de transaction', border: OutlineInputBorder()),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(_getTransactionTypeDisplayText(type)));
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              DropdownButtonFormField<BalanceType>(
                value: _selectedBalanceType,
                decoration: const InputDecoration(labelText: 'Impact sur le solde', border: OutlineInputBorder()),
                items: BalanceType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBalanceType = value!),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(labelText: 'Nom du Service/Produit', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _customerPhoneController,
                decoration: const InputDecoration(labelText: 'Téléphone client (si applicable)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant (FCFA)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.attach_money)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  if (double.tryParse(value) == null) return 'Montant invalide';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _commissionController,
                decoration: const InputDecoration(labelText: 'Commission (FCFA)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.percent)),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Saisir 0 si pas de commission';
                  if (double.tryParse(value) == null) return 'Commission invalide';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              DropdownButtonFormField<String>(
                value: _selectedOperator,
                decoration: const InputDecoration(labelText: 'Opérateur (si applicable)', border: OutlineInputBorder()),
                items: _operators.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                onChanged: (value) => setState(() => _selectedOperator = value),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _detailsController,
                decoration: const InputDecoration(labelText: 'Détails/Description (optionnel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Référence (optionnel)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.receipt)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        CustomButton(text: 'Ajouter', onPressed: _submitTransaction),
      ],
    );
  }

  void _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final transactionProvider = context.read<TransactionProvider>();
    final success = await transactionProvider.addTransaction(
      customerPhone: _customerPhoneController.text,
      type: _selectedType,
      balanceType: _selectedBalanceType,
      amount: double.parse(_amountController.text),
      commission: double.parse(_commissionController.text),
      serviceName: _serviceNameController.text,
      details: _detailsController.text.isNotEmpty ? _detailsController.text : null,
      operator: _selectedOperator,
      reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
      authProvider: widget.authProvider,
    );

    if (mounted) {
        if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction ajoutée avec succès'), backgroundColor: AppColors.success),
        );
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Erreur: ${transactionProvider.transactionsError ?? "Une erreur inconnue est survenue."}'),
            backgroundColor: Colors.red),
        );
        }
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
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID Transaction', transaction.id),
            _buildDetailRow('Type', transaction.typeDisplay),
            _buildDetailRow('Impact Solde', transaction.balanceType.name),
            if(transaction.customerPhone != null && transaction.customerPhone!.isNotEmpty)
              _buildDetailRow('Téléphone Client', transaction.customerPhone!),
            _buildDetailRow('Service', transaction.serviceName),
            _buildDetailRow('Montant', '${transaction.amount.toStringAsFixed(2)} FCFA'),
            _buildDetailRow('Commission', '${transaction.commission.toStringAsFixed(2)} FCFA'),
            _buildDetailRow('Montant Net', '${transaction.netAmount.toStringAsFixed(2)} FCFA'),
            if(transaction.operator != null && transaction.operator!.isNotEmpty)
              _buildDetailRow('Opérateur', transaction.operator!),
            if(transaction.details != null && transaction.details!.isNotEmpty)
              _buildDetailRow('Détails', transaction.details!),
            if (transaction.reference != null && transaction.reference!.isNotEmpty)
              _buildDetailRow('Référence', transaction.reference!),
            _buildDetailRow('Statut', transaction.statusDisplay),
            _buildDetailRow(
              'Date',
              '${transaction.timestamp.toDate().day.toString().padLeft(2, '0')}/${transaction.timestamp.toDate().month.toString().padLeft(2, '0')}/${transaction.timestamp.toDate().year} '
              'à ${transaction.timestamp.toDate().hour.toString().padLeft(2, '0')}:${transaction.timestamp.toDate().minute.toString().padLeft(2, '0')}',
            ),
          ],
        ),
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
