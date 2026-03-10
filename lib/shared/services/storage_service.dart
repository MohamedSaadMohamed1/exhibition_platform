import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/config/app_config.dart';
import '../../core/error/exceptions.dart';
import '../../core/utils/logger.dart';
import '../../data/datasources/remote/firebase_storage_datasource.dart';
import '../providers/firebase_providers.dart';

/// Image source type
enum ImageSourceType { camera, gallery }

/// Storage service for handling file uploads
class StorageService {
  final FirebaseStorageDataSource _storageDataSource;
  final ImagePicker _imagePicker;

  StorageService(this._storageDataSource, {ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  /// Pick image from camera or gallery
  Future<File?> pickImage({
    required ImageSourceType source,
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source == ImageSourceType.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: maxWidth?.toDouble() ?? AppConfig.maxImageWidth.toDouble(),
        maxHeight: maxHeight?.toDouble() ?? AppConfig.maxImageHeight.toDouble(),
        imageQuality: imageQuality ?? 85,
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);

      // Validate file size
      final fileSize = await file.length();
      if (fileSize > AppConfig.maxImageSizeInBytes) {
        throw UploadException.fileTooLarge();
      }

      return file;
    } catch (e) {
      if (e is UploadException) rethrow;
      AppLogger.error('Failed to pick image', error: e, tag: 'Storage');
      return null;
    }
  }

  /// Pick multiple images from gallery
  Future<List<File>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: maxWidth?.toDouble() ?? AppConfig.maxImageWidth.toDouble(),
        maxHeight: maxHeight?.toDouble() ?? AppConfig.maxImageHeight.toDouble(),
        imageQuality: imageQuality ?? 85,
        limit: limit,
      );

      final files = <File>[];
      for (final pickedFile in pickedFiles) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        if (fileSize <= AppConfig.maxImageSizeInBytes) {
          files.add(file);
        }
      }

      return files;
    } catch (e) {
      AppLogger.error('Failed to pick multiple images', error: e, tag: 'Storage');
      return [];
    }
  }

  /// Upload profile image
  Future<String> uploadProfileImage(String userId, File file) async {
    try {
      final storagePath = StoragePathBuilder.profileImage(userId);
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      AppLogger.info('Profile image uploaded for user: $userId', tag: 'Storage');
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload profile image', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload exhibition banner
  Future<String> uploadExhibitionBanner(String exhibitionId, File file) async {
    try {
      final storagePath = StoragePathBuilder.exhibitionBanner(exhibitionId);
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      AppLogger.info('Exhibition banner uploaded: $exhibitionId', tag: 'Storage');
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload exhibition banner', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload exhibition image
  Future<String> uploadExhibitionImage(
    String exhibitionId,
    File file, {
    String? fileName,
  }) async {
    try {
      final name = fileName ?? StoragePathBuilder.uniqueFileName('jpg');
      final storagePath = StoragePathBuilder.exhibitionImage(exhibitionId, name);
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload exhibition image', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload supplier logo
  Future<String> uploadSupplierLogo(String supplierId, File file) async {
    try {
      final storagePath = StoragePathBuilder.supplierLogo(supplierId);
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      AppLogger.info('Supplier logo uploaded: $supplierId', tag: 'Storage');
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload supplier logo', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload service image
  Future<String> uploadServiceImage(
    String serviceId,
    File file, {
    String? fileName,
  }) async {
    try {
      final name = fileName ?? StoragePathBuilder.uniqueFileName('jpg');
      final storagePath = StoragePathBuilder.serviceImage(serviceId, name);
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload service image', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload chat media (image)
  Future<String> uploadChatImage(
    String roomId,
    String messageId,
    File file,
  ) async {
    try {
      final storagePath = StoragePathBuilder.chatMedia(roomId, messageId, 'jpg');
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload chat image', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload chat media from bytes
  Future<String> uploadChatImageData(
    String roomId,
    String messageId,
    Uint8List data,
  ) async {
    try {
      final storagePath = StoragePathBuilder.chatMedia(roomId, messageId, 'jpg');
      final downloadUrl = await _storageDataSource.uploadData(
        storagePath: storagePath,
        data: data,
        contentType: 'image/jpeg',
      );
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload chat image data', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Upload resume/CV
  Future<String> uploadResume(String userId, File file) async {
    try {
      final fileName = file.path.split('/').last;
      final storagePath = StoragePathBuilder.resume(userId, fileName);
      final downloadUrl = await _storageDataSource.uploadFile(
        storagePath: storagePath,
        filePath: file.path,
      );
      AppLogger.info('Resume uploaded for user: $userId', tag: 'Storage');
      return downloadUrl;
    } catch (e) {
      AppLogger.error('Failed to upload resume', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile(String downloadUrl) async {
    try {
      // Extract storage path from download URL
      // This is a simplified version - actual implementation may need adjustment
      await _storageDataSource.deleteFile(downloadUrl);
      AppLogger.info('File deleted', tag: 'Storage');
    } catch (e) {
      AppLogger.error('Failed to delete file', error: e, tag: 'Storage');
      rethrow;
    }
  }

  /// Get download URL for a storage path
  Future<String> getDownloadUrl(String storagePath) async {
    return await _storageDataSource.getDownloadUrl(storagePath);
  }
}

/// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(firebaseStorageDataSourceProvider));
});
