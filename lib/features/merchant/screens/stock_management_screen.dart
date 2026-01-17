import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';
import 'package:locacharge/features/merchant/models/custom_service_model.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/providers/invoice_provider.dart';

class StockManagementScreen extends StatefulWidget {
  const StockManagementScreen({super.key});

  @override
  State<StockManagementScreen> createState() => _StockManagementScreenState();
}

class _StockManagementScreenState extends State<StockManagementScreen> {
  bool _isLoading = false;
  Map<String, String> _stockStatus = {};
  int _selectedTabIndex = 0; // 0: Services prédéfinis, 1: Services personnalisés

  @override
  void initState() {
    super.initState();
    _loadCurrentStock();
    _loadCustomServices();
  }

  void _loadCurrentStock() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchant = authProvider.merchantProfile;
    
    if (merchant?.serviceStockStatus != null) {
      setState(() {
        _stockStatus = Map<String, String>.from(merchant!.serviceStockStatus!);
      });
    }
  }

  void _loadCustomServices() {
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
    final authProvider = Provider.of<AuthProvider>(context);
    final merchant = authProvider.merchantProfile;

    if (merchant == null) {
      return Scaffold(
        appBar: CustomAppBar(
          title: 'Gestion de Stock',
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
        title: 'Gestion de Stock',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_hasChanges())
            TextButton(
              onPressed: _isLoading ? null : _saveChanges,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Sauvegarder',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Onglets
            Container(
              margin: const EdgeInsets.all(16),
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
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0 ? AppColors.primary : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Services Standards',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body1.copyWith(
                            color: _selectedTabIndex == 0 ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1 ? AppColors.primary : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Services Personnalisés',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body1.copyWith(
                            color: _selectedTabIndex == 1 ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedTabIndex == 0) ...[
                      _buildStockOverview(merchant),
                      const SizedBox(height: 24),
                      _buildServicesStock(merchant),
                      const SizedBox(height: 24),
                      _buildStockTips(),
                    ] else ...[
                      _buildCustomServicesSection(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockOverview(MerchantAuthModel merchant) {
    final totalServices = merchant.services?.length ?? 0;
    final availableServices = _stockStatus.values
        .where((status) => status.toLowerCase() == 'disponible')
        .length;
    final unavailableServices = totalServices - availableServices;

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
            'Aperçu du stock',
            style: AppTextStyles.h2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStockCard(
                  title: 'Total Services',
                  value: '$totalServices',
                  color: AppColors.primary,
                  icon: Icons.inventory,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockCard(
                  title: 'Disponibles',
                  value: '$availableServices',
                  color: Colors.green,
                  icon: Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockCard(
                  title: 'Indisponibles',
                  value: '$unavailableServices',
                  color: Colors.red,
                  icon: Icons.cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicesStock(MerchantAuthModel merchant) {
    final services = merchant.services ?? [];
    
    if (services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('Aucun service configuré'),
        ),
      );
    }

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
            'Gestion par service',
            style: AppTextStyles.h2.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 16),
          ...services.map((service) => _buildServiceItem(service)),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String service) {
    final currentStatus = _stockStatus[service] ?? 'disponible';
    final isAvailable = currentStatus.toLowerCase() == 'disponible';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getServiceColor(service).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getServiceIcon(service),
              color: _getServiceColor(service),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAvailable ? 'Service disponible' : 'Service indisponible',
                  style: AppTextStyles.caption.copyWith(
                    color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isAvailable,
            onChanged: (value) {
              setState(() {
                _stockStatus[service] = value ? 'disponible' : 'indisponible';
              });
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServicesSection() {
    return Consumer<InvoiceProvider>(
      builder: (context, invoiceProvider, child) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Services personnalisés',
                    style: AppTextStyles.h2.copyWith(fontSize: 18),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddServiceDialog,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Ajouter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (invoiceProvider.customServices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_business,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun service personnalisé',
                        style: AppTextStyles.body1.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Créez vos propres services pour vos besoins spécifiques',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...invoiceProvider.customServices.map((service) => 
                  _buildCustomServiceItem(service)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomServiceItem(CustomServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: service.isActive ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor(service.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(service.category),
                  color: _getCategoryColor(service.category),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prix par défaut: ${service.defaultPrice.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditServiceDialog(service);
                      break;
                    case 'delete':
                      _deleteService(service);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Supprimer'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockTips() {
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
                Icons.lightbulb_outline,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Conseils de gestion',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.blue.shade800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTip('Mettez à jour régulièrement le statut de vos services'),
          _buildTip('Les clients ne verront que les services disponibles'),
          _buildTip('Activez les notifications pour être alerté des demandes'),
          _buildTip('Un service indisponible peut affecter votre classement'),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body2.copyWith(
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getServiceColor(String service) {
    switch (service.toLowerCase()) {
      case 'recharge de crédit':
        return Colors.green;
      case 'transfert d\'argent':
        return Colors.blue;
      case 'achat de carte sim':
        return Colors.orange;
      default:
        return AppColors.primary;
    }
  }

  IconData _getServiceIcon(String service) {
    switch (service.toLowerCase()) {
      case 'recharge de crédit':
        return Icons.phone_android;
      case 'transfert d\'argent':
        return Icons.account_balance_wallet;
      case 'achat de carte sim':
        return Icons.sim_card;
      default:
        return Icons.miscellaneous_services;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'télécommunication':
        return Colors.blue;
      case 'finance':
        return Colors.green;
      case 'bureau':
        return Colors.orange;
      case 'commerce':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'télécommunication':
        return Icons.phone;
      case 'finance':
        return Icons.account_balance_wallet;
      case 'bureau':
        return Icons.business;
      case 'commerce':
        return Icons.store;
      default:
        return Icons.miscellaneous_services;
    }
  }

  void _showAddServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        onServiceSaved: (service) {
          final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
          invoiceProvider.addCustomService(service);
        },
      ),
    );
  }

  void _showEditServiceDialog(CustomServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => _ServiceDialog(
        service: service,
        onServiceSaved: (updatedService) {
          // TODO: Implémenter la mise à jour du service
        },
      ),
    );
  }

  void _deleteService(CustomServiceModel service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le service'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${service.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
              invoiceProvider.deleteCustomService(service.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool _hasChanges() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchant = authProvider.merchantProfile;
    
    if (merchant?.serviceStockStatus == null) {
      return _stockStatus.isNotEmpty;
    }
    
    return !_mapsEqual(_stockStatus, merchant!.serviceStockStatus!);
  }

  bool _mapsEqual(Map<String, String> map1, Map<String, String> map2) {
    if (map1.length != map2.length) return false;
    
    for (final key in map1.keys) {
      if (map1[key] != map2[key]) return false;
    }
    
    return true;
  }

  Future<void> _saveChanges() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchant = authProvider.merchantProfile;
    
    if (merchant == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(merchant.id)
          .update({
        'serviceStockStatus': _stockStatus,
      });

      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          'Stock mis à jour avec succès',
        );
        
        // Recharger le profil marchand
        await authProvider.refreshMerchantProfile();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(
          context,
          'Erreur lors de la mise à jour: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _ServiceDialog extends StatefulWidget {
  final CustomServiceModel? service;
  final Function(CustomServiceModel) onServiceSaved;

  const _ServiceDialog({
    this.service,
    required this.onServiceSaved,
  });

  @override
  State<_ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<_ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  
  String _selectedCategory = 'Autre';
  
  final List<String> _categories = [
    'Télécommunication',
    'Finance',
    'Bureau',
    'Commerce',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _priceController.text = widget.service!.defaultPrice.toString();
      _selectedCategory = widget.service!.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.service == null ? 'Nouveau service' : 'Modifier le service'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du service *',
                  hintText: 'Ex: Réparation téléphone',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description du service...',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix par défaut',
                  suffixText: 'FCFA',
                  hintText: '0',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Prix invalide';
                    }
                  }
                  return null;
                },
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
        ElevatedButton(
          onPressed: _saveService,
          child: Text(widget.service == null ? 'Créer' : 'Modifier'),
        ),
      ],
    );
  }

  void _saveService() {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final merchantId = authProvider.merchantProfile!.id;

    final service = CustomServiceModel(
      id: widget.service?.id ?? '',
      merchantId: merchantId,
      name: _nameController.text,
      description: _descriptionController.text,
      defaultPrice: double.tryParse(_priceController.text) ?? 0.0,
      category: _selectedCategory,
      isActive: true,
      createdAt: widget.service?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onServiceSaved(service);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}