import 'package:flutter/material.dart';
import 'package:locacharge/core/common.dart';
import 'package:locacharge/features/admin/widgets/merchant_table_widget.dart';
import 'package:locacharge/features/auth/models/merchant_auth_model.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:provider/provider.dart';

class PendingVerificationsScreen extends StatelessWidget {
  final List<MerchantAuthModel> pendingMerchants;

  const PendingVerificationsScreen({
    super.key,
    required this.pendingMerchants,
  });

  @override
  Widget build(BuildContext context) {
    // Les fonctions onVerify et onSuspend doivent être passées au MerchantTableWidget.
    // Comme cet écran est contextuel au dashboard, nous pouvons récupérer le provider
    // et créer des fonctions qui appellent les méthodes du provider.
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    void verifyMerchant(MerchantAuthModel merchant) async {
      final newStatus = !merchant.isVerified;
      final confirmed = await DialogHelper.showConfirmation(
        context,
        title: '${newStatus ? "Vérifier" : "Annuler la vérification de"} ce marchand ?',
        message: 'Voulez-vous vraiment changer le statut de ${merchant.businessName} ?',
        confirmText: newStatus ? 'Vérifier' : 'Confirmer',
      );
      
      if (confirmed == true) {
        await merchantProvider.updateMerchantVerification(merchant.id, newStatus);
      }
    }

    void suspendMerchant(MerchantAuthModel merchant) async {
      final newStatus = !merchant.isSuspended;
      final actionText = newStatus ? 'Suspendre' : 'Réactiver';
      final confirmed = await DialogHelper.showConfirmation(
        context,
        title: '$actionText le marchand ?',
        message: 'Voulez-vous vraiment ${actionText.toLowerCase()} ${merchant.businessName} ?',
        confirmText: actionText,
        isDangerous: newStatus,
      );
      
      if (confirmed == true) {
        await merchantProvider.updateMerchantSuspension(merchant.id, newStatus);
      }
    }

    void viewMerchantDetails(MerchantAuthModel merchant) {
       showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(merchant.businessName),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText('ID: ${merchant.id}'),
                SelectableText('Email: ${merchant.email}'),
                const Divider(height: 20, thickness: 1),
                const Text(
                  'Avis des clients:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200, // Hauteur fixe pour la liste d'avis
                  width: double.maxFinite, // Prendre toute la largeur
                  child: ReviewListWidget(merchantId: merchant.id),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Vérifications en attente',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<MerchantProvider>(
        builder: (context, provider, child) {
          // On filtre la liste des marchands du provider pour n'afficher que ceux qui sont en attente
          final pendingList = provider.adminMerchants.where((m) => !m.isVerified).toList();

          if (provider.isLoading) {
            return const LoadingIndicator();
          }

          if (pendingList.isEmpty) {
            return const Center(
              child: Text(
                'Aucun marchand en attente de vérification.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: MerchantTableWidget(
              merchants: pendingList,
              onVerify: verifyMerchant,
              onSuspend: suspendMerchant,
              onViewDetails: viewMerchantDetails,
            ),
          );
        },
      ),
    );
  }
}
