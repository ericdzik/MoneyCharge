import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../providers/transaction_provider.dart';
import '../../../providers/auth_provider.dart';
import '../models/balance_model.dart'; // Contient BalanceModel
import '../../../models/transaction_model.dart'; // Notre TransactionModel centralisé
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
    _tabController = TabController(length: 1, vsync: this); // Réduit à 1 onglet "Toutes" pour l'instant
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      // Utiliser le nouveau nom de méthode
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
    // Utiliser le nouveau nom de méthode
    context.read<TransactionProvider>().fetchMerchantTransactions(authProvider);
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => _showAddTransactionDialog(authProvider),
            tooltip: 'Ajouter une transaction',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.onPrimary,
          labelColor: AppColors.onPrimary,
          unselectedLabelColor: AppColors.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Toutes les Transactions'), // Un seul onglet pour l'instant
            // Tab(text: 'Cette semaine'), // Commenté
            // Tab(text: 'Ce mois'), // Commenté
          ],
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          // Utiliser les nouveaux noms de getters pour l'état de chargement et d'erreur
          if (provider.isLoadingTransactions && provider.merchantTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.transactionsError != null && provider.merchantTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.outOfStock, // Peut-être une couleur d'erreur plus générique
                  ),
                  const SizedBox(height: AppDimensions.paddingM),
                  Text(
                    'Erreur: ${provider.transactionsError}', // Utiliser transactionsError
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.outOfStock, // Peut-être une couleur d'erreur plus générique
                    ),
                  ),
                  const SizedBox(height: AppDimensions.paddingL),
                  CustomButton(
                    text: 'Réessayer',
                    onPressed: _reloadData,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              BalanceSummaryWidget(balance: provider.balance), // Affichage du solde (si disponible)

              // Les statistiques par période sont commentées car les getters correspondants
              // dans TransactionProvider sont commentés.
              /*
              Container(
                // ... (ancien code pour les statistiques par période) ...
              ),
              */

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Afficher toutes les transactions du marchand
                    _buildTransactionsList(provider.merchantTransactions),
                    // _buildTransactionsList(provider.weekTransactions), // Commenté
                    // _buildTransactionsList(provider.monthTransactions), // Commenté
                  ],
                ),
              ),
            ],
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
    // ... (contenu de _buildStatCard inchangé, mais il n'est plus appelé pour l'instant) ...
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
        // ... (contenu inchangé) ...
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
      // ... (contenu inchangé) ...
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingL,
        vertical: AppDimensions.paddingM,
      ),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return TransactionCardWidget( // S'assurer que TransactionCardWidget est compatible avec le nouveau TransactionModel
          transaction: transactions[index],
          onTap: () => _showTransactionDetails(transactions[index]),
        );
      },
    );
  }

  // Les méthodes _getRevenueForCurrentTab, _getExpensesForCurrentTab, _getProfitForCurrentTab
  // sont commentées car les getters de période dans TransactionProvider sont commentés.
  /*
  double _getRevenueForCurrentTab(TransactionProvider provider) { ... }
  double _getExpensesForCurrentTab(TransactionProvider provider) { ... }
  double _getProfitForCurrentTab(TransactionProvider provider) { ... }
  */

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
  // Remplacer _descriptionController par _serviceNameController et _detailsController
  final _serviceNameController = TextEditingController();
  final _detailsController = TextEditingController(); // Pour les détails/description optionnels
  final _referenceController = TextEditingController();

  TransactionType _selectedType = TransactionType.sale; // Type par défaut
  BalanceType _selectedBalanceType = BalanceType.credit; // Type de solde par défaut
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
                decoration: const InputDecoration(labelText: 'Type de transaction'),
                items: TransactionType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name)); // Utiliser .name pour l'affichage de l'enum
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              DropdownButtonFormField<BalanceType>(
                value: _selectedBalanceType,
                decoration: const InputDecoration(labelText: 'Impact sur le solde'),
                items: BalanceType.values.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type.name)); // Utiliser .name
                }).toList(),
                onChanged: (value) => setState(() => _selectedBalanceType = value!),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _serviceNameController,
                decoration: const InputDecoration(labelText: 'Nom du Service/Produit'),
                validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _customerPhoneController,
                decoration: const InputDecoration(labelText: 'Téléphone client (si applicable)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Montant (FCFA)'),
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
                decoration: const InputDecoration(labelText: 'Commission (FCFA)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis (0 si pas de commission)';
                  if (double.tryParse(value) == null) return 'Commission invalide';
                  return null;
                },
              ),
              const SizedBox(height: AppDimensions.paddingM),
              DropdownButtonFormField<String>(
                value: _selectedOperator,
                decoration: const InputDecoration(labelText: 'Opérateur (si applicable)'),
                items: _operators.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
                onChanged: (value) => setState(() => _selectedOperator = value),
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _detailsController, // Nouveau contrôleur pour les détails
                decoration: const InputDecoration(labelText: 'Détails/Description (optionnel)'),
                maxLines: 2,
              ),
              const SizedBox(height: AppDimensions.paddingM),
              TextFormField(
                controller: _referenceController,
                decoration: const InputDecoration(labelText: 'Référence (optionnel)'),
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
      serviceName: _serviceNameController.text, // Utiliser serviceName
      details: _detailsController.text.isNotEmpty ? _detailsController.text : null, // Utiliser details
      operator: _selectedOperator,
      reference: _referenceController.text.isNotEmpty ? _referenceController.text : null,
      authProvider: widget.authProvider,
    );

    if (mounted) { // Vérifier avant d'utiliser context
        if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction ajoutée avec succès'), backgroundColor: AppColors.success),
        );
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
            content: Text('Erreur: ${transactionProvider.transactionsError ?? "Une erreur inconnue est survenue."}'),
            backgroundColor: Colors.red), // Utiliser transactionsError
        );
        }
    }
  }
}

class TransactionDetailsDialog extends StatelessWidget {
  final TransactionModel transaction; // Doit être notre TransactionModel centralisé

  const TransactionDetailsDialog({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Détails de la transaction'),
      content: SingleChildScrollView( // Ajout pour éviter overflow si trop de détails
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID Transaction', transaction.id),
            _buildDetailRow('Type', transaction.typeDisplay), // Utiliser le getter
            _buildDetailRow('Impact Solde', transaction.balanceType.name), // Utiliser .name ou un getter display
            if(transaction.customerPhone != null && transaction.customerPhone!.isNotEmpty)
              _buildDetailRow('Téléphone Client', transaction.customerPhone!),
            _buildDetailRow('Montant', '${transaction.amount.toStringAsFixed(2)} FCFA'),
            _buildDetailRow('Commission', '${transaction.commission.toStringAsFixed(2)} FCFA'),
            _buildDetailRow('Montant Net', '${transaction.netAmount.toStringAsFixed(2)} FCFA'),
            if(transaction.operator != null && transaction.operator!.isNotEmpty)
              _buildDetailRow('Opérateur', transaction.operator!),
            if(transaction.details != null && transaction.details!.isNotEmpty)
              _buildDetailRow('Détails', transaction.details!),
            if (transaction.reference != null && transaction.reference!.isNotEmpty)
              _buildDetailRow('Référence', transaction.reference!),
            _buildDetailRow('Statut', transaction.statusDisplay), // Utiliser le getter
            _buildDetailRow(
              'Date',
              // Formatter la date pour meilleure lisibilité
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
    // ... (contenu inchangé) ...
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
