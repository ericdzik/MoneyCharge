import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';
import 'package:locacharge/features/auth/services/account_deletion_service.dart';

void main() {
  group('AccountDeletionService', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseStorage mockStorage;
    late AccountDeletionService service;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockStorage = MockFirebaseStorage();
      service = AccountDeletionService(
        firestore: fakeFirestore,
        firebaseAuth: mockAuth,
        storage: mockStorage,
      );
    });

    test('canDeleteAccount retourne true pour un utilisateur sans transactions', () async {
      // Arrange
      const userId = 'test-user-id';
      const userRole = 'user';

      // Act
      final result = await service.canDeleteAccount(userId, userRole);

      // Assert
      expect(result, true);
    });

    test('canDeleteAccount lance une exception pour un marchand avec transactions en attente', () async {
      // Arrange
      const merchantId = 'test-merchant-id';
      const userRole = 'merchant';

      // Créer une transaction en attente
      await fakeFirestore.collection('transactions').add({
        'merchantId': merchantId,
        'status': 'pending',
      });

      // Act & Assert
      expect(
        () => service.canDeleteAccount(merchantId, userRole),
        throwsException,
      );
    });

    test('deleteAccount supprime les données utilisateur', () async {
      // Arrange
      const userId = 'test-user-id';
      const userRole = 'user';

      // Créer un utilisateur
      await fakeFirestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': 'test@example.com',
        'name': 'Test User',
        'role': userRole,
      });

      // Créer des favoris
      await fakeFirestore.collection('favorites').add({
        'userId': userId,
        'merchantId': 'merchant-1',
      });

      // Créer un utilisateur mock dans Firebase Auth
      final mockUser = MockUser(
        uid: userId,
        email: 'test@example.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      service = AccountDeletionService(
        firestore: fakeFirestore,
        firebaseAuth: mockAuth,
        storage: mockStorage,
      );

      // Act
      final result = await service.deleteAccount(userId, userRole);

      // Assert
      expect(result, true);

      // Vérifier que l'utilisateur a été supprimé
      final userDoc = await fakeFirestore.collection('users').doc(userId).get();
      expect(userDoc.exists, false);

      // Vérifier que les favoris ont été supprimés
      final favorites = await fakeFirestore
          .collection('favorites')
          .where('userId', isEqualTo: userId)
          .get();
      expect(favorites.docs.isEmpty, true);
    });

    test('deleteAccount supprime les données marchand', () async {
      // Arrange
      const merchantId = 'test-merchant-id';
      const userRole = 'merchant';

      // Créer un marchand
      await fakeFirestore.collection('users').doc(merchantId).set({
        'uid': merchantId,
        'email': 'merchant@example.com',
        'name': 'Test Merchant',
        'role': userRole,
      });

      // Créer des factures
      await fakeFirestore.collection('invoices').add({
        'merchantId': merchantId,
        'amount': 100,
      });

      // Créer des transactions
      await fakeFirestore.collection('transactions').add({
        'merchantId': merchantId,
        'status': 'completed',
      });

      // Créer un utilisateur mock dans Firebase Auth
      final mockUser = MockUser(
        uid: merchantId,
        email: 'merchant@example.com',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      service = AccountDeletionService(
        firestore: fakeFirestore,
        firebaseAuth: mockAuth,
        storage: mockStorage,
      );

      // Act
      final result = await service.deleteAccount(merchantId, userRole);

      // Assert
      expect(result, true);

      // Vérifier que le marchand a été supprimé
      final merchantDoc = await fakeFirestore.collection('users').doc(merchantId).get();
      expect(merchantDoc.exists, false);

      // Vérifier que les factures ont été supprimées
      final invoices = await fakeFirestore
          .collection('invoices')
          .where('merchantId', isEqualTo: merchantId)
          .get();
      expect(invoices.docs.isEmpty, true);

      // Vérifier que les transactions ont été supprimées
      final transactions = await fakeFirestore
          .collection('transactions')
          .where('merchantId', isEqualTo: merchantId)
          .get();
      expect(transactions.docs.isEmpty, true);
    });
  });
}
