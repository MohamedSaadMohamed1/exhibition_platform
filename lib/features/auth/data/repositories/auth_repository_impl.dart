import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/enums.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementation of AuthRepository using Firebase
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Stores the web ConfirmationResult for OTP verification on web platform
  ConfirmationResult? _webConfirmationResult;

  AuthRepositoryImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<Either<Failure, String>> sendOtp({
    required String phoneNumber,
    required String countryCode,
  }) async {
    try {
      final fullPhone = '$countryCode$phoneNumber';
      AppLogger.info('🔥 sendOtp starting: $fullPhone', tag: 'AuthRepo');

      // Web uses signInWithPhoneNumber (reCAPTCHA-based)
      if (kIsWeb) {
        final confirmationResult = await _auth.signInWithPhoneNumber(fullPhone);
        _webConfirmationResult = confirmationResult;
        AppLogger.info('🔥 Web: codeSent, verificationId=${confirmationResult.verificationId}', tag: 'AuthRepo');
        return Right(confirmationResult.verificationId);
      }

      // Mobile uses verifyPhoneNumber
      final completer = Completer<Either<Failure, String>>();

      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: AppConstants.otpTimeout,
        verificationCompleted: (PhoneAuthCredential credential) async {
          AppLogger.info('🔥 verificationCompleted (auto-verification)', tag: 'AuthRepo');
        },
        verificationFailed: (FirebaseAuthException e) {
          AppLogger.error('🔥 verificationFailed: code=${e.code}, message=${e.message}', tag: 'AuthRepo');
          if (e.code == 'invalid-phone-number') {
            completer.complete(Left(AuthFailure.invalidPhoneNumber()));
          } else if (e.code == 'too-many-requests') {
            completer.complete(Left(AuthFailure.tooManyRequests()));
          } else {
            completer.complete(Left(AuthFailure.unknown(e.message)));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          AppLogger.info('🔥 codeSent callback: verificationId=$verificationId', tag: 'AuthRepo');
          completer.complete(Right(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.info('🔥 codeAutoRetrievalTimeout: $verificationId', tag: 'AuthRepo');
        },
      );

      AppLogger.info('🔥 Waiting for completer...', tag: 'AuthRepo');
      return await completer.future;
    } catch (e) {
      AppLogger.error('🔥 sendOtp exception: $e', tag: 'AuthRepo');
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      final UserCredential userCredential;

      if (kIsWeb && _webConfirmationResult != null) {
        // Web: confirm OTP via ConfirmationResult
        userCredential = await _webConfirmationResult!.confirm(otp);
        _webConfirmationResult = null;
      } else {
        // Mobile: use PhoneAuthCredential
        final credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: otp,
        );
        userCredential = await _auth.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user == null) {
        return Left(AuthFailure.unknown('User not found after sign in'));
      }

      // Check if user document exists by Firebase Auth UID
      final userDoc = await _usersCollection.doc(user.uid).get(
        const GetOptions(source: Source.server),
      );

      if (userDoc.exists) {
        // Existing user - return user data
        return Right(UserModel.fromFirestore(userDoc));
      }

      // Check if admin pre-created an account with this phone number
      final phoneQuery = await _usersCollection
          .where('phone', isEqualTo: user.phoneNumber ?? '')
          .limit(1)
          .get();

      if (phoneQuery.docs.isNotEmpty) {
        // Admin pre-created account found - migrate it to use the real Firebase Auth UID
        final preCreatedDoc = phoneQuery.docs.first;
        final oldTempUid = preCreatedDoc.id;
        final preCreatedData = Map<String, dynamic>.from(preCreatedDoc.data());

        AppLogger.info(
          '🔄 Migrating pre-created account from tempUid=$oldTempUid to authUid=${user.uid}',
          tag: 'AuthRepo',
        );

        final batch = _firestore.batch();

        // Create new document with the real Firebase Auth UID
        preCreatedData['updatedAt'] = FieldValue.serverTimestamp();
        batch.set(_usersCollection.doc(user.uid), preCreatedData);

        // Delete the old document with the temporary UUID
        batch.delete(_usersCollection.doc(oldTempUid));

        // Update any supplier documents that reference the old temporary UID
        final supplierQuery = await _firestore
            .collection(FirestoreCollections.suppliers)
            .where('ownerId', isEqualTo: oldTempUid)
            .get();

        for (final supplierDoc in supplierQuery.docs) {
          batch.update(supplierDoc.reference, {'ownerId': user.uid});
        }

        await batch.commit();

        // Return the migrated user with the real UID
        final migratedUser = UserModel.fromJson({
          'id': user.uid,
          ...preCreatedData,
        });
        return Right(migratedUser);
      } else {
        // New self-registered user - create as visitor
        final newUser = UserModel(
          id: user.uid,
          name: '',
          phone: user.phoneNumber ?? '',
          role: UserRole.visitor, // Self-registered users are visitors (matches Firestore rule)
          createdBy: 'self',
          createdAt: DateTime.now(),
        );

        await _usersCollection.doc(user.uid).set(newUser.toFirestore());

        return Right(newUser);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return Left(AuthFailure.invalidOtp());
      } else if (e.code == 'session-expired') {
        return Left(AuthFailure.otpExpired());
      }
      return Left(AuthFailure.unknown(e.message));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return const Right(null);
      }

      final userDoc = await _usersCollection.doc(user.uid).get(
        const GetOptions(source: Source.server),
      );

      if (!userDoc.exists) {
        return const Right(null);
      }

      return Right(UserModel.fromFirestore(userDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserById(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get(
        const GetOptions(source: Source.serverAndCache),
      );

      if (!userDoc.exists) {
        return Left(FirestoreFailure.notFound('User'));
      }

      return Right(UserModel.fromFirestore(userDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> createUserDocument({
    required String uid,
    required String phone,
    String? name,
  }) async {
    try {
      final newUser = UserModel(
        id: uid,
        name: name ?? '',
        phone: phone,
        role: UserRole.visitor,
        createdBy: 'self',
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(uid).set(newUser.toFirestore());

      return Right(newUser);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserProfile({
    required String userId,
    String? name,
    String? profileImage,
    String? email,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (profileImage != null) updates['profileImage'] = profileImage;
      if (email != null) updates['email'] = email;

      await _usersCollection.doc(userId).update(updates);

      final updatedDoc = await _usersCollection.doc(userId).get();
      return Right(UserModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(e.toFailure());
    }
  }

  @override
  Stream<UserModel?> authStateChanges() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);

      // Watch Firestore document so UI updates when profile changes (e.g. profile image)
      return _usersCollection.doc(user.uid).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      });
    });
  }

  @override
  Future<Either<Failure, bool>> checkPhoneExists(String phoneNumber) async {
    try {
      final query = await _usersCollection
          .where('phone', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      return Right(query.docs.isNotEmpty);
    } catch (e) {
      return Left(e.toFailure());
    }
  }
}
