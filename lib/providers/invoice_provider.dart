import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../features/merchant/models/invoice_model.dart';
import '../features/merchant/models/custom_service_model.dart';

class InvoiceProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<InvoiceModel> _invoices = [];
  List<CustomServiceModel> _customServices = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<InvoiceModel> get invoices => _invoices;
  List<CustomServiceModel> get customServices => _customServices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Services prédéfinis
  final List<Map<String, dynamic>> predefinedServices = [
    {
      'name': 'Recharge de crédit',
      'category': 'Télécommunication',
      'icon': 'phone_android',
      'defaultPrice': 0.0,
    },
    {
      'name': 'Transfert d\'argent',
      'category': 'Finance',
      'icon': 'account_balance_wallet',
      'defaultPrice': 0.0,
    },
    {
      'name': 'Achat de carte SIM',
      'category': 'Télécommunication',
      'icon': 'sim_card',
      'defaultPrice': 2000.0,
    },
    {
      'name': 'Photocopie',
      'category': 'Bureau',
      'icon': 'content_copy',
      'defaultPrice': 25.0,
    },
    {
      'name': 'Impression',
      'category': 'Bureau',
      'icon': 'print',
      'defaultPrice': 50.0,
    },
    {
      'name': 'Scan document',
      'category': 'Bureau',
      'icon': 'scanner',
      'defaultPrice': 100.0,
    },
  ];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Génération du numéro de facture
  String generateInvoiceNumber(String merchantId) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final timeStr = DateFormat('HHmmss').format(now);
    final merchantPrefix = merchantId.substring(0, 3).toUpperCase();
    return 'INV-$merchantPrefix-$dateStr-$timeStr';
  }

  // Charger les factures du marchand
  Future<void> loadInvoices(String merchantId) async {
    _setLoading(true);
    _setError(null);

    try {
      final querySnapshot = await _firestore
          .collection('invoices')
          .where('merchantId', isEqualTo: merchantId)
          .orderBy('createdAt', descending: true)
          .get();

      _invoices = querySnapshot.docs
          .map((doc) => InvoiceModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _setError('Erreur lors du chargement des factures: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Charger les services personnalisés
  Future<void> loadCustomServices(String merchantId) async {
    try {
      final querySnapshot = await _firestore
          .collection('customServices')
          .where('merchantId', isEqualTo: merchantId)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      _customServices = querySnapshot.docs
          .map((doc) => CustomServiceModel.fromFirestore(doc))
          .toList();
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors du chargement des services: $e');
    }
  }

  // Créer une nouvelle facture
  Future<String?> createInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    _setError(null);

    try {
      final docRef = await _firestore
          .collection('invoices')
          .add(invoice.toFirestore());

      // Ajouter à la liste locale
      final newInvoice = invoice.copyWith(id: docRef.id);
      _invoices.insert(0, newInvoice);
      
      notifyListeners();
      return docRef.id;
    } catch (e) {
      _setError('Erreur lors de la création de la facture: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Mettre à jour une facture
  Future<bool> updateInvoice(InvoiceModel invoice) async {
    _setLoading(true);
    _setError(null);

    try {
      await _firestore
          .collection('invoices')
          .doc(invoice.id)
          .update(invoice.toFirestore());

      // Mettre à jour la liste locale
      final index = _invoices.indexWhere((inv) => inv.id == invoice.id);
      if (index != -1) {
        _invoices[index] = invoice;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('Erreur lors de la mise à jour: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Marquer une facture comme payée
  Future<bool> markAsPaid(String invoiceId, String paymentMethod) async {
    try {
      final invoice = _invoices.firstWhere((inv) => inv.id == invoiceId);
      final updatedInvoice = invoice.copyWith(
        status: InvoiceStatus.paid,
        paidAt: DateTime.now(),
        paymentMethod: paymentMethod,
      );

      return await updateInvoice(updatedInvoice);
    } catch (e) {
      _setError('Erreur lors du marquage comme payée: $e');
      return false;
    }
  }

  // Ajouter un service personnalisé
  Future<bool> addCustomService(CustomServiceModel service) async {
    try {
      final docRef = await _firestore
          .collection('customServices')
          .add(service.toFirestore());

      final newService = service.copyWith(id: docRef.id);
      _customServices.add(newService);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erreur lors de l\'ajout du service: $e');
      return false;
    }
  }

  // Supprimer un service personnalisé
  Future<bool> deleteCustomService(String serviceId) async {
    try {
      await _firestore
          .collection('customServices')
          .doc(serviceId)
          .update({'isActive': false});

      _customServices.removeWhere((service) => service.id == serviceId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
      return false;
    }
  }

  // Statistiques des factures
  double get totalRevenue => _invoices
      .where((inv) => inv.isPaid)
      .fold(0.0, (sum, inv) => sum + inv.total);

  double get pendingAmount => _invoices
      .where((inv) => inv.status == InvoiceStatus.sent)
      .fold(0.0, (sum, inv) => sum + inv.total);

  int get overdueCount => _invoices
      .where((inv) => inv.isOverdue)
      .length;
}