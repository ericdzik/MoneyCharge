# 🐛 Correctif : Liste des Marchands Invisible

## Problème Identifié
La liste des marchands ne s'affichait pas au démarrage de l'application ("Home Feed Empty").

### Analyse (Race Condition)
1. `FeedManager` s'initialise et demande les marchands via `MerchantProvider`.
2. À cet instant, `MerchantProvider` n'a pas encore reçu les données de Firestore (écouteur asynchrone).
3. `FeedManager` construit son fil d'actualité avec 0 marchands.
4. `MerchantProvider` reçoit les données plus tard, mais `FeedManager` ne les écoutait pas et ne se mettait pas à jour.

## Solution Apportée
- **Ajout d'un écouteur** : `FeedManager` écoute désormais les changements de `MerchantProvider`.
- **Rechargement Intelligent** : Si `FeedManager` détecte que les marchands sont arrivés (alors qu'il n'en affichait aucun), il recharge automatiquement le fil d'actualité.

## Résultat
La liste des marchands apparaitra automatiquement dès que les données seront disponibles, sans action de l'utilisateur.
