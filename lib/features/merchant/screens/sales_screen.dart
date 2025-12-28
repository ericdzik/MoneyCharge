import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/models/transaction_model.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/providers/transaction_provider.dart';
import 'package:locacharge/providers/invoice_provider.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedService;
  bool _isProcessing = false;
  
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Recharge de crédit',
      'icon': Icons.phone_android,
      'color': Colors.green,
      'commission': 0.02, // 2%
    },
    {
      'name': 'Transfert d\'argent',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue,
      'commission': 0.015, // 1.5%
    },
    {
      'name': 'Achat de carte SIM',
      'icon': Icons.sim_card,
      'color': Colors.orange,
      'commission': 0.05, // 5%
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadServices() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      
      if (authProvider.merchantProfile != null) {
        invoiceProvider.loadCustomServices(authProvider.merchantProfile!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Charger les services personnalisés
    _loadServices();
    
    final authProvider = Provider.of<AuthProvider>(context);
    final merchant = authProvider.merchantProfile;

    if (merchant == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Nouvelle Vente',
          showLogo: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('Profil marchand non disponible'),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Nouvelle Vente',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildServiceSelection(),
                const SizedBox(height: 24),
                _buildAmountInput(),
                const SizedBox(height: 24),
                _buildPhoneInput(),
                const SizedBox(height: 24),
                _buildNotesInput(),
                const SizedBox(height: 24),
                _buildTransactionSummary(),
                const SizedBox(height: 32),
                _buildProcessButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sélectionner le service',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          
          // Services prédéfinis
          Text(
            'Services standards',
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...(_services.map((service) => _buildServiceOption(service)).toList()),
          
          // Services personnalisés
          Consumer<InvoiceProvider>(
            builder: (context, invoiceProvider, child) {
              if (invoiceProvider.customServices.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Vos services personnalisés',
                      style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...invoiceProvider.customServices.map((service) => 
                      _buildCustomServiceOption(service)).toList(),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServiceOption(dynamic service) {
    final serviceName = service.name;
    final isSelected = _selectedService == serviceName;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedService = serviceName;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.miscellaneous_services,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      serviceName,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppColors.primary : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description.isNotEmpty ? service.description : 'Service personnalisé',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (service.defaultPrice > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Prix suggéré: ${service.defaultPrice.toStringAsFixed(0)} FCFA',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceOption(Map<String, dynamic> service) {
    final isSelected = _selectedService == service['name'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedService = service['name'];
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? service['color'].withOpacity(0.1) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? service['color'] : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: service['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  service['icon'],
                  color: service['color'],
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['name'],
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? service['color'] : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Commission: ${(service['commission'] * 100).toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: service['color'],
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Montant de la transaction',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: 'Entrez le montant',
              suffixText: 'FCFA',
              prefixIcon: const Icon(Icons.monetization_on),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Veuillez entrer un montant valide';
              }
              if (amount < 100) {
                return 'Le montant minimum est de 100 FCFA';
              }
              return null;
            },
            onChanged: (value) {
              setState(() {}); // Pour mettre à jour le résumé
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Numéro de téléphone du client',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Ex: 77 123 45 67',
              prefixIcon: const Icon(Icons.phone),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer le numéro du client';
              }
              if (value.length < 8) {
                return 'Numéro de téléphone invalide';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes (optionnel)',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ajouter des notes sur cette transaction...',
              prefixIcon: const Icon(Icons.note_add),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSummary() {
    if (_selectedService == null || _amountController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    final amount = double.tryParse(_amountController.text) ?? 0;
    final service = _services.firstWhere((s) => s['name'] == _selectedService);
    final commission = amount * service['commission'];
    final netAmount = amount - commission;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Résumé de la transaction',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.blue.shade800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Service', _selectedService!),
          _buildSummaryRow('Montant', '${amount.toStringAsFixed(0)} FCFA'),
          _buildSummaryRow('Commission (${(service['commission'] * 100).toStringAsFixed(1)}%)', 
                          '${commission.toStringAsFixed(0)} FCFA'),
          const Divider(),
          _buildSummaryRow('Montant net', '${netAmount.toStringAsFixed(0)} FCFA', 
                          isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.body2.copyWith(
              color: Colors.blue.shade800,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: Colors.blue.shade800,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessButton() {
    final canProcess = _selectedService != null && 
                     _amountController.text.isNotEmpty && 
                     _phoneController.text.isNotEmpty &&
                     !_isProcessing;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProcess ? _processTransaction : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Traitement en cours...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : const Text(
                'Effectuer la transaction',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _processTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      
      final amount = double.parse(_amountController.text);
      final service = _services.firstWhere((s) => s['name'] == _selectedService);
      final commission = amount * service['commission'];
      final netAmount = amount - commission;

      // Créer la transaction
      final success = await transactionProvider.addTransaction(
        customerPhone: _phoneController.text,
        type: TransactionType.sale,
        balanceType: BalanceType.credit,
        amount: amount,
        commission: commission,
        serviceName: _selectedService!,
        details: _notesController.text.isNotEmpty ? _notesController.text : null,
        authProvider: authProvider,
      );

      if (success && mounted) {
        // Afficher le succès
        SnackBarHelper.showSuccess(
          context,
          'Transaction effectuée avec succès !',
        );

        // Réinitialiser le formulaire
        _resetForm();

        // Optionnel: retourner au dashboard
        // Navigator.of(context).pop();
      } else if (mounted) {
        SnackBarHelper.showError(
          context,
          'Erreur lors de la transaction',
        );
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Erreur: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedService = null;
      _amountController.clear();
      _phoneController.clear();
      _notesController.clear();
    });
  }
}