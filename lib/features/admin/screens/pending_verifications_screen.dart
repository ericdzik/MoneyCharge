import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';
import 'package:locacharge/features/admin/widgets/merchant_table_widget.dart';
import 'package:locacharge/features/merchant/models/merchant_auth_model.dart';
import 'package:locacharge/features/user/widgets/review_list_widget.dart';
import 'package:locacharge/providers/merchant_provider.dart';
import 'package:provider/provider.dart';

class PendingVerificationsScreen extends StatelessWidget {
  final List<MerchantAuthModel> pendingMerchants;

  const PendingVerificationsScreen({
    Key? key,
    required this.pendingMerchants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Les fonctions onVerify et onSuspend doivent être passées au MerchantTableWidget.
    // Comme cet écran est contextuel au dashboard, nous pouvons récupérer le provider
    // et créer des fonctions qui appellent les méthodes du provider.
    final merchantProvider = Provider.of<MerchantProvider>(context, listen: false);

    void verifyMerchant(MerchantAuthModel merchant) {
      final newStatus = !merchant.isVerified;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${newStatus ? "Vérifier" : "Annuler la vérification de"} ce marchand ?'),
          content: Text('Voulez-vous vraiment changer le statut de ${merchant.businessName} ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await merchantProvider.updateMerchantVerification(merchant.id, newStatus);
                // On pourrait vouloir rafraîchir l'état ici, mais le provider notifie déjà
                // et le dashboard précédent se mettra à jour. Pour cet écran, on pourrait
                // vouloir retirer l'élément de la liste. Pour l'instant, on laisse comme ça.
              },
              child: Text(newStatus ? 'Vérifier' : 'Confirmer'),
            ),
          ],
        ),
      );
    }

    void suspendMerchant(MerchantAuthModel merchant) {
      final newStatus = !(merchant.isSuspended ?? false);
      final actionText = newStatus ? 'Suspendre' : 'Réactiver';
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('$actionText le marchand ?'),
          content: Text('Voulez-vous vraiment ${actionText.toLowerCase()} ${merchant.businessName} ?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await merchantProvider.updateMerchantSuspension(merchant.id, newStatus);
              },
              style: ElevatedButton.styleFrom(backgroundColor: newStatus ? Colors.red : Colors.green),
              child: Text(actionText),
            ),
          ],
        ),
      );
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<MerchantProvider>(
        builder: (context, provider, child) {
          // On filtre la liste des marchands du provider pour n'afficher que ceux qui sont en attente
          final pendingList = provider.adminMerchants.where((m) => !m.isVerified).toList();

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
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
