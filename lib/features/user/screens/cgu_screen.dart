import 'package:flutter/material.dart';
import 'package:locacharge/core/widgets/custom_app_bar.dart';

class CguScreen extends StatelessWidget {
  const CguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Conditions Générales d\'Utilisation',
        showLogo: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text("""
Conditions Générales d’Utilisation de l’Application GÉO
1. Objet
Les présentes Conditions Générales d’Utilisation (CGU) régissent l’accès et l’utilisation de l’application mobile GÉO (ci-après « l’Application »), éditée par [Nom de l’éditeur], par les utilisateurs en tant que Clients ou Marchands.
2. Définitions
- Application : GÉO, plateforme numérique de géolocalisation des points de vente, services financiers, et de recharge téléphonique en Afrique.
- Client : toute personne physique utilisant l’application pour localiser un service ou effectuer des opérations.
- Marchand : tout professionnel inscrit proposant des services ou produits référencés dans l’application.
- Compte : espace personnel sécurisé créé sur l’application.
3. Acceptation des CGU
L'utilisation de l’Application implique l’acceptation sans réserve des présentes CGU. Tout utilisateur s’engage à les lire et à les respecter.
4. Inscription et Compte
- L’inscription est gratuite.
- Le Client ou Marchand doit fournir des informations exactes et les tenir à jour.
- L’utilisateur s’engage à ne pas usurper l’identité d’un tiers.
- Le mot de passe et le code secret sont strictement personnels et confidentiels.
5. Services proposés
Pour les Clients :
- Géolocalisation des points de services à proximité.
- Consultation des stocks disponibles, crédits, retraits, SIM.
- Messagerie avec les marchands.
- Historique des opérations et portefeuille électronique (wallet).

Pour les Marchands :
- Référencement sur l’application.
- Gestion des stocks et des services disponibles.
- Réception de demandes clients.
- Visualisation des recherches proches et tableau de bord analytique.
6. Sécurité
Le code secret est confidentiel. L’équipe GÉO ne vous le demandera jamais. Toute opération frauduleuse ou tentative de piratage pourra entraîner la suppression du compte.
7. Engagements de l’utilisateur
- Ne pas utiliser l’Application à des fins illicites ou abusives.
- Respecter les règles d’éthique commerciale.
- Fournir des informations honnêtes sur les services et produits proposés.
8. Responsabilités
L’éditeur de l’Application ne saurait être tenu responsable d’un mauvais usage de la plateforme. Les marchands sont seuls responsables des services rendus et des transactions effectuées.
9. Données personnelles
Les données collectées sont traitées conformément aux lois en vigueur sur la protection des données personnelles. L’utilisateur peut accéder, modifier ou supprimer ses données via son compte ou en contactant l’équipe GÉO.
10. Résiliation
L’utilisateur peut supprimer son compte à tout moment. En cas de non-respect des CGU, GÉO se réserve le droit de suspendre ou résilier un compte sans préavis.
11. Modifications
Les CGU peuvent être mises à jour. Les utilisateurs seront notifiés en cas de modifications majeures.
12. Loi applicable
Les présentes CGU sont régies par le droit du pays d’exploitation (ex. Togo). Tout litige sera soumis à la juridiction compétente.
Acceptation finale
📌 En s’inscrivant sur GÉO, l’utilisateur accepte les présentes conditions générales d’utilisation.
        """),
      ),
    );
  }
}
