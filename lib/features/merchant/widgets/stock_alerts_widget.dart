import 'package:flutter/material.dart';
import 'package:locacharge/core/constants/app_text_styles.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';

class StockAlertsWidget extends StatelessWidget {
  final MerchantAuthModel merchant;
  final VoidCallback? onManageStock;

  const StockAlertsWidget({
    super.key,
    required this.merchant,
    this.onManageStock,
  });

  @override
  Widget build(BuildContext context) {
    final lowStockServices = _getLowStockServices();
    
    if (lowStockServices.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Alertes Stock',
                style: AppTextStyles.h3.copyWith(
                  color: Colors.orange.shade800,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (onManageStock != null)
                TextButton(
                  onPressed: onManageStock,
                  child: Text(
                    'Gérer',
                    style: TextStyle(color: Colors.orange.shade700),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...lowStockServices.map((service) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.orange.shade600,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$service - Stock indisponible',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<String> _getLowStockServices() {
    if (merchant.serviceStockStatus == null) return [];
    
    return merchant.serviceStockStatus!.entries
        .where((entry) => entry.value.toLowerCase() == 'indisponible')
        .map((entry) => entry.key)
        .toList();
  }
}