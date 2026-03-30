import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/error/exceptions.dart';

/// Firebase Storage Data Source Interface
abstract class FirebaseStorageDataSource {
  /// Upload file and return download URL
  Future<String> uploadFile({
    required String storagePath,
    required String filePath,
    Map<String, String>? metadata,
  });

  /// Upload data bytes and return download URL
  Future<String> uploadData({
    required String storagePath,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
  });

  /// Delete file from storage
  Future<void> deleteFile(String storagePath);

  /// Get download URL for a storage path
  Future<String> getDownloadUrl(String storagePath);

  /// Upload file with progress stream
  UploadTask uploadFileWithProgress({
    required String storagePath,
    required String filePath,
    Map<String, String>? metadata,
  });

  /// Upload data with progress stream
  UploadTask uploadDataWithProgress({
    required String storagePath,
    required Uint8List data,
    String? contentType,
  });

  /// Check if file exists
  Future<bool> fileExists(String storagePath);

  /// Get file metadata
  Future<FullMetadata> getMetadata(String storagePath);

  /// List files in a directory
  Future<ListResult> listFiles(String storagePath, {int? maxResults});
}

/// Firebase Storage Data Source Implementation
class FirebaseStorageDataSourceImpl implements FirebaseStorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSourceImpl(this._storage);

  @override
  Future<String> uploadFile({
    required String storagePath,
    required String filePath,
    Map<String, String>? metadata,
  }) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw const UploadException(message: 'File does not exist');
      }

      final ref = _storage.ref().child(storagePath);
      final settableMetadata = SettableMetadata(
        contentType: _getContentType(filePath),
        customMetadata: metadata,
      );

      await ref.putFile(file, settableMetadata);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw UploadException(
        message: e.message ?? 'Failed to upload file',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException(
        message: 'Failed to upload file: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<String> uploadData({
    required String storagePath,
    required Uint8List data,
    String? contentType,
    Map<String, String>? metadata,
  }) async {
    try {
      final ref = _storage.ref().child(storagePath);

      final settableMetadata = SettableMetadata(
        contentType: contentType,
        customMetadata: metadata,
      );

      await ref.putData(data, settableMetadata);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw UploadException(
        message: e.message ?? 'Failed to upload data',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw UploadException(
        message: 'Failed to upload data: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<void> deleteFile(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        // File doesn't exist, consider it deleted
        return;
      }
      throw ServerException(
        message: e.message ?? 'Failed to delete file',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete file: $e',
        originalException: e,
      );
    }
  }

  @override
  Future<String> getDownloadUrl(String storagePath) async {
    try {
      return await _storage.ref().child(storagePath).getDownloadURL();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get download URL',
        code: e.code,
        originalException: e,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get download URL: $e',
        originalException: e,
      );
    }
  }

  @override
  UploadTask uploadFileWithProgress({
    required String storagePath,
    required String filePath,
    Map<String, String>? metadata,
  }) {
    final file = File(filePath);
    final ref = _storage.ref().child(storagePath);

    SettableMetadata? settableMetadata;
    if (metadata != null) {
      settableMetadata = SettableMetadata(
        customMetadata: metadata,
        contentType: _getContentType(filePath),
      );
    }

    return ref.putFile(file, settableMetadata);
  }

  @override
  UploadTask uploadDataWithProgress({
    required String storagePath,
    required Uint8List data,
    String? contentType,
  }) {
    final ref = _storage.ref().child(storagePath);
    final metadata = contentType != null
        ? SettableMetadata(contentType: contentType)
        : null;
    return ref.putData(data, metadata);
  }

  @override
  Future<bool> fileExists(String storagePath) async {
    try {
      await _storage.ref().child(storagePath).getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<FullMetadata> getMetadata(String storagePath) async {
    try {
      return await _storage.ref().child(storagePath).getMetadata();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to get metadata',
        code: e.code,
        originalException: e,
      );
    }
  }

  @override
  Future<ListResult> listFiles(String storagePath, {int? maxResults}) async {
    try {
      final ref = _storage.ref().child(storagePath);
      if (maxResults != null) {
        return await ref.list(ListOptions(maxResults: maxResults));
      }
      return await ref.listAll();
    } on FirebaseException catch (e) {
      throw ServerException(
        message: e.message ?? 'Failed to list files',
        code: e.code,
        originalException: e,
      );
    }
  }

  /// Get content type based on file extension
  String? _getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return null;
    }
  }
}

/// Storage path builder helper
class StoragePathBuilder {
  StoragePathBuilder._();

  /// Profile image path
  static String profileImage(String userId) {
    return 'users/$userId/profile.jpg';
  }

  /// Exhibition banner path
  static String exhibitionBanner(String exhibitionId) {
    return 'exhibitions/$exhibitionId/banner.jpg';
  }

  /// Exhibition image path
  static String exhibitionImage(String exhibitionId, String fileName) {
    return 'exhibitions/$exhibitionId/images/$fileName';
  }

  /// Supplier logo path
  static String supplierLogo(String supplierId) {
    return 'suppliers/$supplierId/logo.jpg';
  }

  /// Service image path
  static String serviceImage(String serviceId, String fileName) {
    return 'services/$serviceId/$fileName';
  }

  /// Chat media path
  static String chatMedia(String roomId, String messageId, String extension) {
    return 'chat/$roomId/$messageId.$extension';
  }

  /// Resume/CV path
  static String resume(String userId, String fileName) {
    return 'resumes/$userId/$fileName';
  }

  /// Review image path
  static String reviewImage(String reviewId, String fileName) {
    return 'reviews/$reviewId/$fileName';
  }

  /// Job image path
  static String jobImage(String jobId) {
    return 'jobs/$jobId/image.jpg';
  }

  /// Generate unique filename with timestamp
  static String uniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp.$extension';
  }
}
