import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/services/storage_service.dart';
import '../../domain/repositories/profile_repository.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final FirebaseFirestore _firestore;
  final StorageService _storageService;

  ProfileRepositoryImpl({
    required FirebaseFirestore firestore,
    required StorageService storageService,
  })  : _firestore = firestore,
        _storageService = storageService;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(FirestoreCollections.users);

  @override
  Future<Either<Failure, UserModel>> getProfile(String userId) async {
    try {
      final doc = await _usersCollection.doc(userId).get();

      if (!doc.exists) {
        return Left(NotFoundFailure('User profile not found'));
      }

      return Right(UserModel.fromFirestore(doc));
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? profileImage,
  }) async {
    try {
      final updates = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (email != null) updates['email'] = email;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _usersCollection.doc(userId).update(updates);

      // Fetch updated document
      final updatedDoc = await _usersCollection.doc(userId).get();
      return Right(UserModel.fromFirestore(updatedDoc));
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Upload image to Firebase Storage
      final downloadUrl = await _storageService.uploadProfileImage(
        userId,
        imageFile,
      );

      // Update user document with new image URL
      await _usersCollection.doc(userId).update({
        'profileImage': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return Right(downloadUrl);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfileImage(String userId) async {
    try {
      // Get current user to find existing image
      final doc = await _usersCollection.doc(userId).get();
      final data = doc.data();
      final currentImage = data?['profileImage'] as String?;

      // Delete from storage if exists
      if (currentImage != null && currentImage.isNotEmpty) {
        await _storageService.deleteFile(currentImage);
      }

      // Remove from user document
      await _usersCollection.doc(userId).update({
        'profileImage': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateFcmToken({
    required String userId,
    required String token,
  }) async {
    try {
      await _usersCollection.doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, void>> removeFcmToken(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'fcmToken': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Stream<UserModel?> watchProfile(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Failure _handleException(dynamic e) {
    if (e is FirebaseException) {
      return ServerFailure(e.message ?? 'Firebase error occurred');
    }
    if (e is UploadException) {
      return ServerFailure(e.message);
    }
    return ServerFailure('An unexpected error occurred');
  }
}
