import 'package:cloud_firestore/cloud_firestore.dart';

enum InvoiceStatus { draft, sent, paid, cancelled }

class InvoiceItem {
  final String id;
  final String description;
  final double quantity;
  final double unitPrice;
  final double total;
  final String? category;

  InvoiceItem({
    required this.id,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
    this.category,
  });

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] ?? '',
      description: map['description'] ?? '',
      quantity: (map['quantity'] ?? 0).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      category: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'total': total,
      'category': category,
    };
  }
}

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String merchantId;
  final String? customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerEmail;
  final List<InvoiceItem> items;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double discount;
  final double total;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? paidAt;
  final String? notes;
  final String? paymentMethod;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.merchantId,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerEmail,
    required this.items,
    required this.subtotal,
    this.taxRate = 0.0,
    required this.taxAmount,
    this.discount = 0.0,
    required this.total,
    required this.status,
    required this.createdAt,
    this.dueDate,
    this.paidAt,
    this.notes,
    this.paymentMethod,
  });

  factory InvoiceModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    
    return InvoiceModel(
      id: doc.id,
      invoiceNumber: data['invoiceNumber'] ?? '',
      merchantId: data['merchantId'] ?? '',
      customerId: data['customerId'],
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'],
      customerEmail: data['customerEmail'],
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => InvoiceItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      taxRate: (data['taxRate'] ?? 0).toDouble(),
      taxAmount: (data['taxAmount'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      total: (data['total'] ?? 0).toDouble(),
      status: InvoiceStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => InvoiceStatus.draft,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      dueDate: data['dueDate'] != null ? (data['dueDate'] as Timestamp).toDate() : null,
      paidAt: data['paidAt'] != null ? (data['paidAt'] as Timestamp).toDate() : null,
      notes: data['notes'],
      paymentMethod: data['paymentMethod'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'invoiceNumber': invoiceNumber,
      'merchantId': merchantId,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discount': discount,
      'total': total,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'notes': notes,
      'paymentMethod': paymentMethod,
    };
  }

  String get statusDisplay {
    switch (status) {
      case InvoiceStatus.draft:
        return 'Brouillon';
      case InvoiceStatus.sent:
        return 'Envoyée';
      case InvoiceStatus.paid:
        return 'Payée';
      case InvoiceStatus.cancelled:
        return 'Annulée';
    }
  }

  bool get isPaid => status == InvoiceStatus.paid;
  bool get isOverdue => dueDate != null && DateTime.now().isAfter(dueDate!) && !isPaid;

  InvoiceModel copyWith({
    String? id,
    String? invoiceNumber,
    String? merchantId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    List<InvoiceItem>? items,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? discount,
    double? total,
    InvoiceStatus? status,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? paidAt,
    String? notes,
    String? paymentMethod,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      merchantId: merchantId ?? this.merchantId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      notes: notes ?? this.notes,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}