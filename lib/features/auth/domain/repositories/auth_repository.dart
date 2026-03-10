import 'package:dartz/dartz.dart';
import '../../../../core/exceptions/app_exceptions.dart';
import '../../../../shared/models/user_model.dart';

/// Auth repository interface
abstract class AuthRepository {
  /// Send OTP to phone number
  Future<Either<Failure, String>> sendOtp({
    required String phoneNumber,
    required String countryCode,
  });

  /// Verify OTP and sign in
  Future<Either<Failure, UserModel>> verifyOtp({
    required String verificationId,
    required String otp,
  });

  /// Get current user
  Future<Either<Failure, UserModel?>> getCurrentUser();

  /// Get user by ID
  Future<Either<Failure, UserModel>> getUserById(String userId);

  /// Create or update user document
  Future<Either<Failure, UserModel>> createUserDocument({
    required String uid,
    required String phone,
    String? name,
  });

  /// Update user profile
  Future<Either<Failure, UserModel>> updateUserProfile({
    required String userId,
    String? name,
    String? profileImage,
    String? email,
  });

  /// Update FCM token
  Future<Either<Failure, void>> updateFcmToken({
    required String userId,
    required String token,
  });

  /// Sign out
  Future<Either<Failure, void>> signOut();

  /// Stream of auth state changes
  Stream<UserModel?> authStateChanges();

  /// Check if phone number exists
  Future<Either<Failure, bool>> checkPhoneExists(String phoneNumber);
}
