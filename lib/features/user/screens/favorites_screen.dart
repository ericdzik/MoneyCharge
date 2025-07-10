import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/merchant_card.dart';
import '../../../providers/favorite_merchant_provider.dart';
import '../../../providers/merchant_provider.dart';
import '../models/merchant_model.dart';
import '../../../core/constants/app_routes.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // L'AppBar est gérée par HomeScreen, donc pas besoin ici
      // si cet écran est toujours affiché dans le corps de HomeScreen.
      // Si c'était un écran poussé par Navigator, il aurait sa propre AppBar.
      body: Consumer<FavoriteMerchantProvider>(
        builder: (context, favoriteProvider, child) {
          if (favoriteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (favoriteProvider.favoriteMerchantIds.isEmpty) {
            return Center(
              child: Text(
                'Vous n\'avez pas encore de favoris.',
                style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            );
          }

          // Obtenir les détails des commerçants à partir des IDs favoris
          // Nous avons besoin d'accéder à la liste complète des commerçants
          // du MerchantProvider pour filtrer ceux qui sont favoris.
          return Consumer<MerchantProvider>(
            builder: (context, merchantProvider, child) {
              if (merchantProvider.isLoading && merchantProvider.merchants.isEmpty) {
                // Peut arriver si les marchands ne sont pas encore chargés
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (merchantProvider.error != null) {
                return Center(child: Text("Erreur: ${merchantProvider.error}", style: AppTextStyles.body1.copyWith(color: AppColors.error)));
              }

              final favoriteMerchants = merchantProvider.merchants
                  .where((merchant) => favoriteProvider.isFavorite(merchant.id))
                  .toList();

              if (favoriteMerchants.isEmpty && favoriteProvider.favoriteMerchantIds.isNotEmpty) {
                // Cela peut arriver si les IDs favoris existent mais que les marchands
                // correspondants ne sont pas dans la liste actuelle (par ex. filtrés ou supprimés)
                // Ou si les marchands ne sont tout simplement pas encore chargés.
                // Pour l'instant, on montre un message simple.
                // Une meilleure gestion pourrait impliquer de tenter de charger spécifiquement ces marchands.
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Certains favoris ne peuvent être affichés.',
                        style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                       Text(
                        'Assurez-vous que les commerçants sont disponibles et que votre liste est à jour.',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              if (favoriteMerchants.isEmpty) {
                 return Center(
                    child: Text(
                      'Vous n\'avez pas encore de favoris.',
                      style: AppTextStyles.body1.copyWith(color: AppTextColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  );
              }

              return ListView.builder(
                itemCount: favoriteMerchants.length,
                itemBuilder: (context, index) {
                  final merchant = favoriteMerchants[index];
                  return MerchantCard(
                    merchant: merchant,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.merchantDetail,
                        arguments: {'merchant': merchant},
                      );
                    },
                    // onDirectionsPressed: () { ... } // Peut être ajouté si nécessaire
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
