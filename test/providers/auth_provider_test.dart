import 'package:flutter_test/flutter_test.dart';
import 'package:locacharge/providers/auth_provider.dart';
import 'package:locacharge/services/auth_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fake_async/fake_async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'auth_provider_test.mocks.dart';

// Generate mocks for the dependencies
@GenerateMocks([
  AuthService,
  FirebaseFirestore,
  fb_auth.FirebaseAuth,
  fb_auth.User,
  fb_auth.UserCredential,
  DocumentSnapshot,
  CollectionReference,
  DocumentReference,
])
void main() {
  // Declare variables for the mocks and the provider under test
  late MockAuthService mockAuthService;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthProvider authProvider;

  // Mocks for deep Firestore/FirebaseAuth structures
  late MockCollectionReference<Map<String, dynamic>> mockUsersCollection;
  late MockDocumentReference<Map<String, dynamic>> mockUserDocument;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockUser mockUser;

  setUp(() {
    // Initialize the mocks
    mockAuthService = MockAuthService();
    mockFirestore = MockMockFirebaseFirestore();
    mockFirebaseAuth = MockMockFirebaseAuth();

    // Initialize the provider with the mocks
    authProvider = AuthProvider(
      authService: mockAuthService,
      firestore: mockFirestore,
      firebaseAuth: mockFirebaseAuth,
    );

    // Setup deep mocks for Firestore
    mockUsersCollection = MockCollectionReference<Map<String, dynamic>>();
    mockUserDocument = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockUsersCollection.doc(any)).thenReturn(mockUserDocument);
    when(mockUserDocument.get()).thenAnswer((_) async => mockDocumentSnapshot);

    // Setup deep mocks for FirebaseAuth
    mockUser = MockUser();
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn('test_uid');
  });

  group('AuthProvider Tests', () {
    test('Initial state is correct', () {
      expect(authProvider.isAuthenticated, isFalse);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.userType, UserType.unknown);
      expect(authProvider.error, isNull);
    });

    group('loginUnified', () {
      const testEmail = 'user@test.com';
      const testPassword = 'password';
      const testUid = 'test_uid';

      test('successful login sets user and clears error', () async {
        // Arrange
        // Mock the AuthService login response
        when(mockAuthService.loginUnified(testEmail, testPassword))
            .thenAnswer((_) async => testUid);

        // Mock the user document snapshot from Firestore
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({'role': 'user'});

        // Mock the auth state changes stream
        when(mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(mockUser));

        // Act
        await authProvider.loginUnified(testEmail, testPassword);

        // Assert
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.userType, UserType.user);
        expect(authProvider.error, isNull);
        expect(authProvider.isLoading, isFalse);

        // Verify that the correct methods were called
        verify(mockAuthService.loginUnified(testEmail, testPassword)).called(1);
        verify(mockUserDocument.get()).called(1);
      });

      test('login with non-existent profile sets error', () async {
        // Arrange
        when(mockAuthService.loginUnified(testEmail, testPassword))
            .thenAnswer((_) async => testUid);

        // Mock Firestore to return a non-existent document
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act
        await authProvider.loginUnified(testEmail, testPassword);

        // Assert
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.userType, UserType.unknown);
        expect(authProvider.error, isNotNull);
        expect(authProvider.error, "Profil utilisateur non trouvé dans Firestore.");
      });

      test('login with unknown role sets error', () async {
        // Arrange
        when(mockAuthService.loginUnified(testEmail, testPassword))
            .thenAnswer((_) async => testUid);

        // Mock Firestore to return a document with an unknown role
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({'role': 'guest'});

        // Act
        await authProvider.loginUnified(testEmail, testPassword);

        // Assert
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.userType, UserType.unknown);
        expect(authProvider.error, isNotNull);
        expect(authProvider.error, "Impossible de déterminer le rôle de l'utilisateur.");
      });

      test('login failure from AuthService sets error', () async {
        // Arrange
        final exception = Exception('Email ou mot de passe incorrect.');
        when(mockAuthService.loginUnified(testEmail, testPassword))
            .thenThrow(exception);

        // Act
        await authProvider.loginUnified(testEmail, testPassword);

        // Assert
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.userType, UserType.unknown);
        expect(authProvider.error, exception.toString());
      });
    });

    group('logout', () {
      test('logout clears user state', () async {
        // Arrange
        // First, simulate a login to set the state
        when(mockAuthService.loginUnified(any, any)).thenAnswer((_) async => 'test_uid');
        when(mockDocumentSnapshot.exists).thenReturn(true);
        when(mockDocumentSnapshot.data()).thenReturn({'role': 'user'});
        await authProvider.loginUnified('user@test.com', 'password');

        expect(authProvider.isAuthenticated, isTrue); // Pre-condition

        // Mock the logout call
        when(mockAuthService.logout()).thenAnswer((_) async {});

        // Act
        await authProvider.logout();

        // Assert
        // The authStateChanges listener will set the user to null and clear the state
        // We need to simulate the stream emitting a null user
        when(mockAuthService.authStateChanges).thenAnswer((_) => Stream.value(null));

        // Let the provider listen to the change
        authProvider.dispose(); // to cancel the old subscription
        authProvider = AuthProvider(
          authService: mockAuthService,
          firestore: mockFirestore,
          firebaseAuth: mockFirebaseAuth,
        );

        // Wait for the stream listener to process the null user
        await Future.delayed(Duration.zero);

        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.userType, UserType.unknown);
      });
    });
  });
}
