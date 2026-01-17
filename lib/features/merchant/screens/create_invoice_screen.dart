import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/merchant/models/invoice_model.dart';
import 'package:locacharge/features/auth/providers/auth_provider.dart';
import 'package:locacharge/providers/invoice_provider.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final InvoiceModel? invoice; // Pour édition

  const CreateInvoiceScreen({super.key, this.invoice});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerEmailController = TextEditingController();
  final _notesController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  List<InvoiceItem> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    if (widget.invoice != null) {
      _loadInvoiceData();
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      
      if (authProvider.merchantProfile != null) {
        invoiceProvider.loadCustomServices(authProvider.merchantProfile!.id);
      }
    });
  }

  void _loadInvoiceData() {
    final invoice = widget.invoice!;
    _customerNameController.text = invoice.customerName;
    _customerPhoneController.text = invoice.customerPhone ?? '';
    _customerEmailController.text = invoice.customerEmail ?? '';
    _notesController.text = invoice.notes ?? '';
    _discountController.text = invoice.discount.toString();
    _items = List.from(invoice.items);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _customerEmailController.dispose();
    _notesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.invoice == null ? 'Nouvelle Facture' : 'Modifier Facture',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveInvoice,
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCustomerInfo(),
                      const SizedBox(height: 24),
                      _buildItemsSection(),
                      const SizedBox(height: 24),
                      _buildTotalsSection(),
                      const SizedBox(height: 24),
                      _buildNotesSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerInfo() {
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
            'Informations client',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du client *',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom du client est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerPhoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _customerEmailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Articles/Services',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _showAddItemDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Ajouter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun article ajouté',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Appuyez sur "Ajouter" pour commencer',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildItemCard(item, index);
            }),
        ],
      ),
    );
  }

  Widget _buildItemCard(InvoiceItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity.toStringAsFixed(0)} × ${item.unitPrice.toStringAsFixed(0)} FCFA',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.total.toStringAsFixed(0)} FCFA',
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _editItem(index),
                icon: const Icon(Icons.edit, size: 16),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    final subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
    final discount = double.tryParse(_discountController.text) ?? 0.0;
    final total = subtotal - discount;

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
            'Totaux',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildTotalRow('Sous-total', '${subtotal.toStringAsFixed(0)} FCFA'),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remise',
                style: AppTextStyles.body2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _discountController,
                decoration: const InputDecoration(
                  suffixText: 'FCFA',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => setState(() {}),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildTotalRow('Total', '${total.toStringAsFixed(0)} FCFA', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTextStyles.body1.copyWith(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.body1.copyWith(
                fontWeight: FontWeight.bold,
                color: isTotal ? AppColors.primary : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
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
            'Notes',
            style: AppTextStyles.h3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Notes additionnelles...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previewInvoice,
                    child: const Text('Aperçu'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAndSend,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Sauvegarder & Envoyer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onItemAdded: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        item: _items[index],
        onItemAdded: (item) {
          setState(() {
            _items[index] = item;
          });
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _previewInvoice() {
    // TODO: Implémenter l'aperçu de la facture
    SnackBarHelper.showInfo(context, 'Aperçu en cours de développement');
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      if (_items.isEmpty) {
        SnackBarHelper.showError(context, 'Ajoutez au moins un article');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final invoiceProvider = Provider.of<InvoiceProvider>(context, listen: false);
      
      final merchantId = authProvider.merchantProfile!.id;
      final subtotal = _items.fold(0.0, (sum, item) => sum + item.total);
      final discount = double.tryParse(_discountController.text) ?? 0.0;
      final total = subtotal - discount;

      final invoice = InvoiceModel(
        id: widget.invoice?.id ?? '',
        invoiceNumber: widget.invoice?.invoiceNumber ?? 
                      invoiceProvider.generateInvoiceNumber(merchantId),
        merchantId: merchantId,
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text.isNotEmpty 
                      ? _customerPhoneController.text : null,
        customerEmail: _customerEmailController.text.isNotEmpty 
                      ? _customerEmailController.text : null,
        items: _items,
        subtotal: subtotal,
        taxAmount: 0.0,
        discount: discount,
        total: total,
        status: InvoiceStatus.draft,
        createdAt: widget.invoice?.createdAt ?? DateTime.now(),
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      String? result;
      if (widget.invoice == null) {
        result = await invoiceProvider.createInvoice(invoice);
      } else {
        final success = await invoiceProvider.updateInvoice(invoice);
        result = success ? invoice.id : null;
      }

      if (result != null && mounted) {
        SnackBarHelper.showSuccess(
          context,
          widget.invoice == null ? 'Facture créée avec succès' : 'Facture mise à jour',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.showError(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveAndSend() async {
    await _saveInvoice();
    // TODO: Implémenter l'envoi de la facture
  }
}

class _AddItemDialog extends StatefulWidget {
  final InvoiceItem? item;
  final Function(InvoiceItem) onItemAdded;

  const _AddItemDialog({
    this.item,
    required this.onItemAdded,
  });

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController();
  
  String? _selectedService;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _descriptionController.text = widget.item!.description;
      _quantityController.text = widget.item!.quantity.toString();
      _priceController.text = widget.item!.unitPrice.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'Ajouter un article' : 'Modifier l\'article'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<InvoiceProvider>(
                builder: (context, invoiceProvider, child) {
                  final allServices = [
                    ...invoiceProvider.predefinedServices,
                    ...invoiceProvider.customServices.map((service) => {
                      'name': service.name,
                      'category': service.category,
                      'defaultPrice': service.defaultPrice,
                    }),
                  ];

                  return DropdownButtonFormField<String>(
                    value: _selectedService,
                    decoration: const InputDecoration(
                      labelText: 'Service (optionnel)',
                      isDense: true,
                    ),
                    isExpanded: true,
                    items: allServices.map((service) {
                      return DropdownMenuItem<String>(
                        value: service['name'],
                        child: Text(
                          service['name'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedService = value;
                        if (value != null) {
                          final service = allServices.firstWhere((s) => s['name'] == value);
                          _descriptionController.text = service['name'];
                          if (service['defaultPrice'] > 0) {
                            _priceController.text = service['defaultPrice'].toString();
                          }
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Description requise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Qté *',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        final qty = double.tryParse(value);
                        if (qty == null || qty <= 0) {
                          return 'Invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Prix *',
                        suffixText: 'FCFA',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requis';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price < 0) {
                          return 'Invalide';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
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
          onPressed: _addItem,
          child: Text(widget.item == null ? 'Ajouter' : 'Modifier'),
        ),
      ],
    );
  }

  void _addItem() {
    if (!_formKey.currentState!.validate()) return;

    final quantity = double.parse(_quantityController.text);
    final unitPrice = double.parse(_priceController.text);
    final total = quantity * unitPrice;

    final item = InvoiceItem(
      id: widget.item?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      description: _descriptionController.text,
      quantity: quantity,
      unitPrice: unitPrice,
      total: total,
      category: _selectedService,
    );

    widget.onItemAdded(item);
    Navigator.of(context).pop();
  }
}