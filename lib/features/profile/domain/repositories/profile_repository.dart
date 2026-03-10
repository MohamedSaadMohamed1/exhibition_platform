import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/models/user_model.dart';

/// Profile repository interface
abstract class ProfileRepository {
  /// Get user profile by ID
  Future<Either<Failure, UserModel>> getProfile(String userId);

  /// Update profile information
  Future<Either<Failure, UserModel>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? profileImage,
  });

  /// Upload profile image and update user document
  Future<Either<Failure, String>> uploadProfileImage({
    required String userId,
    required File imageFile,
  });

  /// Delete profile image
  Future<Either<Failure, void>> deleteProfileImage(String userId);

  /// Update FCM token
  Future<Either<Failure, void>> updateFcmToken({
    required String userId,
    required String token,
  });

  /// Remove FCM token (on logout)
  Future<Either<Failure, void>> removeFcmToken(String userId);

  /// Stream user profile changes
  Stream<UserModel?> watchProfile(String userId);
}
