import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/providers/providers.dart';
import '../../../../shared/services/storage_service.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';

/// Profile Repository Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    firestore: ref.watch(firestoreProvider),
    storageService: ref.watch(storageServiceProvider),
  );
});

/// Profile state class
class ProfileState {
  final UserModel? user;
  final bool isLoading;
  final bool isUploading;
  final String? errorMessage;
  final String? successMessage;
  final double uploadProgress;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.isUploading = false,
    this.errorMessage,
    this.successMessage,
    this.uploadProgress = 0,
  });

  ProfileState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isUploading,
    String? errorMessage,
    String? successMessage,
    double? uploadProgress,
  }) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

/// Profile Notifier
class ProfileNotifier extends Notifier<ProfileState> {
  late ProfileRepository _profileRepository;

  @override
  ProfileState build() {
    _profileRepository = ref.watch(profileRepositoryProvider);

    // Initialize with current user
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    return ProfileState(user: currentUser);
  }

  /// Load profile
  Future<void> loadProfile(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _profileRepository.getProfile(userId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
        );
      },
    );
  }

  /// Update profile
  Future<bool> updateProfile({
    required String userId,
    String? name,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _profileRepository.updateProfile(
      userId: userId,
      name: name,
      email: email,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          successMessage: 'Profile updated successfully',
        );
        return true;
      },
    );
  }

  /// Upload profile image
  Future<bool> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    state = state.copyWith(
      isUploading: true,
      uploadProgress: 0,
      errorMessage: null,
    );

    final result = await _profileRepository.uploadProfileImage(
      userId: userId,
      imageFile: imageFile,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (imageUrl) {
        // Update local state with new image
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 1.0,
          user: state.user?.copyWith(profileImage: imageUrl),
          successMessage: 'Profile image updated',
        );
        return true;
      },
    );
  }

  /// Upload profile image from bytes (web)
  Future<bool> uploadProfileImageBytes({
    required String userId,
    required Uint8List bytes,
  }) async {
    state = state.copyWith(isUploading: true, uploadProgress: 0, errorMessage: null);

    final result = await _profileRepository.uploadProfileImageBytes(
      userId: userId,
      bytes: bytes,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isUploading: false, errorMessage: failure.message);
        return false;
      },
      (imageUrl) {
        state = state.copyWith(
          isUploading: false,
          uploadProgress: 1.0,
          user: state.user?.copyWith(profileImage: imageUrl),
          successMessage: 'Profile image updated',
        );
        return true;
      },
    );
  }

  /// Delete profile image
  Future<bool> deleteProfileImage(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _profileRepository.deleteProfileImage(userId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          user: state.user?.copyWith(profileImage: null),
          successMessage: 'Profile image removed',
        );
        return true;
      },
    );
  }

  /// Update FCM token
  Future<void> updateFcmToken({
    required String userId,
    required String token,
  }) async {
    await _profileRepository.updateFcmToken(
      userId: userId,
      token: token,
    );
  }

  /// Remove FCM token (called on logout)
  Future<void> removeFcmToken(String userId) async {
    await _profileRepository.removeFcmToken(userId);
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear success message
  void clearSuccess() {
    state = state.copyWith(successMessage: null);
  }
}

/// Profile Notifier Provider
final profileNotifierProvider = NotifierProvider<ProfileNotifier, ProfileState>(() {
  return ProfileNotifier();
});

/// Watch profile stream
final profileStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  return ref.watch(profileRepositoryProvider).watchProfile(userId);
});
