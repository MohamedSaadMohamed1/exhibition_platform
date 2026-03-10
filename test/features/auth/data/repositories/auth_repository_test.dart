import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import 'package:exhibition_platform/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:exhibition_platform/features/auth/domain/repositories/auth_repository.dart';
import 'package:exhibition_platform/core/exceptions/app_exceptions.dart';
import 'package:exhibition_platform/shared/models/user_model.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  late AuthRepository authRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseUser mockUser;
  late MockUserCredential mockUserCredential;

  setUpAll(() {
    setupTestMocks();
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockUser = MockFirebaseUser();
    mockUserCredential = MockUserCredential();

    authRepository = AuthRepositoryImpl(
      auth: mockFirebaseAuth,
      firestore: mockFirestore,
    );
  });

  group('AuthRepository', () {
    group('getCurrentUser', () {
      test('returns null when no user is logged in', () async {
        // Arrange
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) => expect(r, isNull),
        );
      });

      test('returns user model when user is logged in', () async {
        // Arrange
        const userId = 'test-user-id';
        const email = 'test@example.com';

        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(userId);
        when(() => mockUser.email).thenReturn(email);

        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(userId)).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn(userId);
        when(() => mockDocSnapshot.data()).thenReturn(generateTestUserData(
          id: userId,
          email: email,
        ));

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left'),
          (r) {
            expect(r, isNotNull);
            expect(r!.uid, equals(userId));
            expect(r.email, equals(email));
          },
        );
      });

      test('returns failure when Firestore throws exception', () async {
        // Arrange
        const userId = 'test-user-id';

        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(userId);

        final mockCollection = MockCollectionReference();
        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(userId)).thenThrow(
          FirebaseException(plugin: 'firestore', message: 'Test error'),
        );

        // Act
        final result = await authRepository.getCurrentUser();

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (l) => expect(l, isA<Failure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });
    });

    group('signInWithEmailAndPassword', () {
      test('returns user on successful sign in', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const userId = 'test-user-id';

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(userId);
        when(() => mockUser.email).thenReturn(email);

        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(userId)).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn(userId);
        when(() => mockDocSnapshot.data()).thenReturn(generateTestUserData(
          id: userId,
          email: email,
        ));

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left: ${l.message}'),
          (r) {
            expect(r.uid, equals(userId));
            expect(r.email, equals(email));
          },
        );

        verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).called(1);
      });

      test('returns failure on wrong password', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).thenThrow(
          firebase_auth.FirebaseAuthException.fromErrorCode('wrong-password'),
        );

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (l) => expect(l, isA<AuthFailure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });

      test('returns failure on user not found', () async {
        // Arrange
        const email = 'nonexistent@example.com';
        const password = 'password123';

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            )).thenThrow(
          firebase_auth.FirebaseAuthException.fromErrorCode('user-not-found'),
        );

        // Act
        final result = await authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (l) => expect(l, isA<AuthFailure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });
    });

    group('signUpWithEmailAndPassword', () {
      test('returns user on successful sign up', () async {
        // Arrange
        const email = 'newuser@example.com';
        const password = 'password123';
        const displayName = 'New User';
        const userId = 'new-user-id';

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            )).thenAnswer((_) async => mockUserCredential);

        when(() => mockUserCredential.user).thenReturn(mockUser);
        when(() => mockUser.uid).thenReturn(userId);
        when(() => mockUser.email).thenReturn(email);
        when(() => mockUser.updateDisplayName(displayName))
            .thenAnswer((_) async {});

        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(userId)).thenReturn(mockDocRef);
        when(() => mockDocRef.set(any())).thenAnswer((_) async {});
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn(userId);
        when(() => mockDocSnapshot.data()).thenReturn(generateTestUserData(
          id: userId,
          email: email,
          displayName: displayName,
        ));

        // Act
        final result = await authRepository.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, isA<Right>());
        result.fold(
          (l) => fail('Expected Right but got Left: ${l.message}'),
          (r) {
            expect(r.uid, equals(userId));
            expect(r.email, equals(email));
          },
        );
      });

      test('returns failure when email already in use', () async {
        // Arrange
        const email = 'existing@example.com';
        const password = 'password123';
        const displayName = 'User';

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: email,
              password: password,
            )).thenThrow(
          firebase_auth.FirebaseAuthException.fromErrorCode('email-already-in-use'),
        );

        // Act
        final result = await authRepository.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );

        // Assert
        expect(result, isA<Left>());
        result.fold(
          (l) => expect(l, isA<AuthFailure>()),
          (r) => fail('Expected Left but got Right'),
        );
      });
    });

    group('signOut', () {
      test('signs out successfully', () async {
        // Arrange
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

        // Act
        final result = await authRepository.signOut();

        // Assert
        expect(result, isA<Right>());
        verify(() => mockFirebaseAuth.signOut()).called(1);
      });

      test('returns failure when sign out fails', () async {
        // Arrange
        when(() => mockFirebaseAuth.signOut()).thenThrow(
          firebase_auth.FirebaseAuthException.fromErrorCode('unknown'),
        );

        // Act
        final result = await authRepository.signOut();

        // Assert
        expect(result, isA<Left>());
      });
    });

    group('authStateChanges', () {
      test('emits user when authenticated', () async {
        // Arrange
        const userId = 'test-user-id';

        when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(mockUser),
        );
        when(() => mockUser.uid).thenReturn(userId);

        final mockCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
        when(() => mockCollection.doc(userId)).thenReturn(mockDocRef);
        when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(() => mockDocSnapshot.exists).thenReturn(true);
        when(() => mockDocSnapshot.id).thenReturn(userId);
        when(() => mockDocSnapshot.data()).thenReturn(generateTestUserData(
          id: userId,
        ));

        // Act & Assert
        final stream = authRepository.authStateChanges();

        await expectLater(
          stream,
          emits(isA<UserModel>()),
        );
      });

      test('emits null when not authenticated', () async {
        // Arrange
        when(() => mockFirebaseAuth.authStateChanges()).thenAnswer(
          (_) => Stream.value(null),
        );

        // Act & Assert
        final stream = authRepository.authStateChanges();

        await expectLater(
          stream,
          emits(isNull),
        );
      });
    });

    group('resetPassword', () {
      test('sends password reset email successfully', () async {
        // Arrange
        const email = 'test@example.com';

        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenAnswer((_) async {});

        // Act
        final result = await authRepository.resetPassword(email);

        // Assert
        expect(result, isA<Right>());
        verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .called(1);
      });

      test('returns failure for invalid email', () async {
        // Arrange
        const email = 'invalid@example.com';

        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
            .thenThrow(
          firebase_auth.FirebaseAuthException.fromErrorCode('user-not-found'),
        );

        // Act
        final result = await authRepository.resetPassword(email);

        // Assert
        expect(result, isA<Left>());
      });
    });
  });
}

/// Extension to create FirebaseAuthException from error code
extension FirebaseAuthExceptionExtension on firebase_auth.FirebaseAuthException {
  static firebase_auth.FirebaseAuthException fromErrorCode(String code) {
    return firebase_auth.FirebaseAuthException(code: code, message: code);
  }
}
