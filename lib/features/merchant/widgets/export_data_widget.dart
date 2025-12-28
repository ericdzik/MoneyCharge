import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/transaction_model.dart';

class ExportDataWidget extends StatelessWidget {
  final List<TransactionModel> transactions;
  final double totalRevenue;
  final int totalTransactions;

  const ExportDataWidget({
    super.key,
    required this.transactions,
    required this.totalRevenue,
    required this.totalTransactions,
  });

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(
                Icons.file_download,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Export des données',
                style: AppTextStyles.h3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildExportButton(
                  context,
                  title: 'Rapport PDF',
                  subtitle: 'Résumé complet',
                  icon: Icons.picture_as_pdf,
                  color: Colors.red,
                  onTap: () => _exportToPDF(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildExportButton(
                  context,
                  title: 'Données CSV',
                  subtitle: 'Transactions détaillées',
                  icon: Icons.table_chart,
                  color: Colors.green,
                  onTap: () => _exportToCSV(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              title,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.caption.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF(BuildContext context) {
    // TODO: Implémenter l'export PDF avec le package pdf
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export PDF en cours de développement...'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportToCSV(BuildContext context) {
    // TODO: Implémenter l'export CSV
    final csvData = _generateCSVData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Données CSV générées (${transactions.length} transactions)'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Partager',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Utiliser share_plus pour partager le fichier CSV
          },
        ),
      ),
    );
  }

  String _generateCSVData() {
    final buffer = StringBuffer();
    
    // En-têtes
    buffer.writeln('Date,Type,Service,Montant,Commission,Net,Statut,Client');
    
    // Données
    for (final transaction in transactions) {
      final date = DateFormat('dd/MM/yyyy HH:mm').format(transaction.timestamp.toDate());
      final type = transaction.typeDisplay;
      final service = transaction.serviceName ?? 'N/A';
      final amount = transaction.amount.toStringAsFixed(2);
      final commission = transaction.commission.toStringAsFixed(2);
      final net = transaction.netAmount.toStringAsFixed(2);
      final status = transaction.statusDisplay;
      final client = transaction.userId?.substring(0, 8) ?? 'N/A';
      
      buffer.writeln('$date,$type,$service,$amount,$commission,$net,$status,$client');
    }
    
    return buffer.toString();
  }
}