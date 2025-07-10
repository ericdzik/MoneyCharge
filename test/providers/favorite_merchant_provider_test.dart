import 'package:flutter_test/flutter_test.dart';
import 'package:locacharge/providers/favorite_merchant_provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Générer le mock pour SharedPreferences
@GenerateMocks([SharedPreferences])
import 'favorite_merchant_provider_test.mocks.dart'; // Sera généré par build_runner

void main() {
  late FavoriteMerchantProvider favoriteMerchantProvider;
  late MockSharedPreferences mockSharedPreferences;

  // Clé utilisée dans le provider
  const String favoritesKey = 'favorite_merchant_ids';

  setUp(() {
    // Crée une nouvelle instance de mock avant chaque test
    mockSharedPreferences = MockSharedPreferences();
    // Configure SharedPreferences pour retourner notre mock pour toutes les instances
    SharedPreferences.setMockInitialValues({}); // Efface les valeurs précédentes pour l'instance statique
                                             // Ceci est important pour les tests avec SharedPreferences.getInstance()

    // Crée une instance du provider à tester
    // Nous devons trouver un moyen d'injecter le mockSharedPreferences ou de mocker SharedPreferences.getInstance()
    // Pour l'instant, on va compter sur setMockInitialValues et le fait que le provider utilise getInstance()
  });

  // Groupe de tests pour l'initialisation et le chargement des favoris
  group('Initialization and Loading Favorites', () {
    test('Initial state is correct (empty list, not loading)', () async {
      // Simule aucune donnée dans SharedPreferences au démarrage
      when(mockSharedPreferences.getStringList(favoritesKey)).thenReturn(null);

      // Pour que le constructeur du provider utilise notre mock,
      // nous devons nous assurer que SharedPreferences.getInstance() le retourne.
      // SharedPreferences.setMockInitialValues configure l'instance partagée.
      // Le constructeur de FavoriteMerchantProvider appelle loadFavorites, qui appelle getInstance().

      // On configure ce que getInstance().getStringList() doit retourner
      // Ceci est un peu délicat car getInstance est statique et le constructeur est appelé avant qu'on puisse le mocker directement.
      // L'approche avec setMockInitialValues est la plus simple pour les tests unitaires de SharedPreferences.
      // Pour que le provider utilise le mockSharedPreferences directement, il faudrait une injection de dépendance.

      // Alternative: Utiliser SharedPreferences.setMockInitialValues pour simuler le contenu.
      SharedPreferences.setMockInitialValues({favoritesKey: <String>[]});
      favoriteMerchantProvider = FavoriteMerchantProvider(); // Le constructeur appelle loadFavorites()

      // Attendre que loadFavorites (appelé dans le constructeur) soit terminé
      await Future.delayed(Duration.zero); // Permet aux microtasks de s'exécuter

      expect(favoriteMerchantProvider.favoriteMerchantIds, isEmpty);
      expect(favoriteMerchantProvider.isLoading, isFalse);
    });

    test('loadFavorites loads list from SharedPreferences', () async {
      final mockList = ['id1', 'id2'];
      SharedPreferences.setMockInitialValues({favoritesKey: mockList});

      favoriteMerchantProvider = FavoriteMerchantProvider(); // Le constructeur appelle loadFavorites()

      // Attendre la fin de loadFavorites()
      await Future.delayed(Duration.zero);

      expect(favoriteMerchantProvider.favoriteMerchantIds, mockList);
      expect(favoriteMerchantProvider.isLoading, isFalse);
    });

     test('loadFavorites handles empty list from SharedPreferences (null)', () async {
      SharedPreferences.setMockInitialValues({favoritesKey: null}); // Simule une clé non existante

      favoriteMerchantProvider = FavoriteMerchantProvider();
      await Future.delayed(Duration.zero);

      expect(favoriteMerchantProvider.favoriteMerchantIds, isEmpty);
      expect(favoriteMerchantProvider.isLoading, isFalse);
    });
  });

  // Groupe de tests pour l'ajout de favoris
  group('Adding Favorites', () {
    setUp(() async {
      // Assurer un état propre pour chaque test de ce groupe
      SharedPreferences.setMockInitialValues({favoritesKey: <String>[]});
      favoriteMerchantProvider = FavoriteMerchantProvider();
      await Future.delayed(Duration.zero); // Laisser loadFavorites du constructeur se terminer
    });

    test('addFavorite adds id and saves to SharedPreferences', () async {
      const merchantId = 'merchant1';

      // Mocker l'appel à setStringList qui sera fait par _saveFavorites
      // Comme on utilise setMockInitialValues, on ne peut pas directement vérifier l'appel à l'instance mockSharedPreferences
      // mais on peut vérifier le résultat après l'opération.
      // Pour vérifier les appels, il faudrait injecter le mock.

      await favoriteMerchantProvider.addFavorite(merchantId);

      expect(favoriteMerchantProvider.favoriteMerchantIds, contains(merchantId));
      expect(favoriteMerchantProvider.isFavorite(merchantId), isTrue);

      // Vérifier la persistance (en rechargeant ou en accédant à SharedPreferences via une nouvelle instance si possible)
      // Pour ce test, on se fie au fait que le provider met à jour sa liste interne.
      // Un test plus approfondi vérifierait que SharedPreferences.getInstance().getStringList() retourne la nouvelle liste.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(favoritesKey), contains(merchantId));
    });

    test('addFavorite does not add duplicate id', () async {
      const merchantId = 'merchant1';
      await favoriteMerchantProvider.addFavorite(merchantId); // Ajout initial
      await favoriteMerchantProvider.addFavorite(merchantId); // Tentative d'ajout du même ID

      expect(favoriteMerchantProvider.favoriteMerchantIds, [merchantId]); // Doit contenir l'ID une seule fois

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(favoritesKey), [merchantId]);
    });
  });

  // Groupe de tests pour la suppression de favoris
  group('Removing Favorites', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({favoritesKey: ['id1', 'id2']});
      favoriteMerchantProvider = FavoriteMerchantProvider();
      await Future.delayed(Duration.zero);
    });

    test('removeFavorite removes id and saves to SharedPreferences', () async {
      const merchantIdToRemove = 'id1';
      await favoriteMerchantProvider.removeFavorite(merchantIdToRemove);

      expect(favoriteMerchantProvider.favoriteMerchantIds, isNot(contains(merchantIdToRemove)));
      expect(favoriteMerchantProvider.favoriteMerchantIds, ['id2']);
      expect(favoriteMerchantProvider.isFavorite(merchantIdToRemove), isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(favoritesKey), ['id2']);
    });

    test('removeFavorite does nothing if id does not exist', () async {
      const nonExistentId = 'id3';
      await favoriteMerchantProvider.removeFavorite(nonExistentId);

      expect(favoriteMerchantProvider.favoriteMerchantIds, ['id1', 'id2']); // La liste ne doit pas changer

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList(favoritesKey), ['id1', 'id2']);
    });
  });

  // Groupe de tests pour isFavorite
  group('isFavorite', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({favoritesKey: ['id1', 'id2']});
      favoriteMerchantProvider = FavoriteMerchantProvider();
      await Future.delayed(Duration.zero);
    });

    test('isFavorite returns true for an existing favorite', () {
      expect(favoriteMerchantProvider.isFavorite('id1'), isTrue);
    });

    test('isFavorite returns false for a non-existing favorite', () {
      expect(favoriteMerchantProvider.isFavorite('id3'), isFalse);
    });
  });
}
