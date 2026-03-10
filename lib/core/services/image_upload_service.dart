import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

/// Image upload result
class ImageUploadResult {
  final String url;
  final String path;
  final String? thumbnailUrl;
  final String? thumbnailPath;

  const ImageUploadResult({
    required this.url,
    required this.path,
    this.thumbnailUrl,
    this.thumbnailPath,
  });
}

/// Image upload progress callback
typedef UploadProgressCallback = void Function(double progress);

/// Image upload service
class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  /// Pick image from gallery
  Future<XFile?> pickImageFromGallery({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality ?? 80,
    );
  }

  /// Pick image from camera
  Future<XFile?> pickImageFromCamera({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
  }) async {
    return _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality ?? 80,
    );
  }

  /// Pick multiple images
  Future<List<XFile>> pickMultipleImages({
    int? maxWidth,
    int? maxHeight,
    int? imageQuality,
    int? limit,
  }) async {
    final images = await _picker.pickMultiImage(
      maxWidth: maxWidth?.toDouble(),
      maxHeight: maxHeight?.toDouble(),
      imageQuality: imageQuality ?? 80,
      limit: limit,
    );
    return images;
  }

  /// Upload image to Firebase Storage
  Future<ImageUploadResult> uploadImage({
    required File file,
    required String storagePath,
    bool generateThumbnail = true,
    UploadProgressCallback? onProgress,
  }) async {
    final fileName = '${_uuid.v4()}${path.extension(file.path)}';
    final fullPath = '$storagePath/$fileName';
    final ref = _storage.ref(fullPath);

    // Compress image if needed
    final compressedFile = await _compressImage(file);

    // Upload task
    final uploadTask = ref.putFile(
      compressedFile,
      SettableMetadata(
        contentType: 'image/${path.extension(file.path).replaceFirst('.', '')}',
      ),
    );

    // Listen to progress
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress);
      });
    }

    // Wait for upload
    await uploadTask;

    // Get download URL
    final url = await ref.getDownloadURL();

    // Generate thumbnail if requested
    String? thumbnailUrl;
    String? thumbnailPath;

    if (generateThumbnail) {
      final thumbnailResult = await _uploadThumbnail(
        file: compressedFile,
        storagePath: storagePath,
        fileName: 'thumb_$fileName',
      );
      thumbnailUrl = thumbnailResult.url;
      thumbnailPath = thumbnailResult.path;
    }

    return ImageUploadResult(
      url: url,
      path: fullPath,
      thumbnailUrl: thumbnailUrl,
      thumbnailPath: thumbnailPath,
    );
  }

  /// Upload image from bytes (for web)
  Future<ImageUploadResult> uploadImageFromBytes({
    required Uint8List bytes,
    required String storagePath,
    required String fileName,
    bool generateThumbnail = true,
    UploadProgressCallback? onProgress,
  }) async {
    final uniqueFileName = '${_uuid.v4()}_$fileName';
    final fullPath = '$storagePath/$uniqueFileName';
    final ref = _storage.ref(fullPath);

    // Upload task
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/${path.extension(fileName).replaceFirst('.', '')}',
      ),
    );

    // Listen to progress
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress);
      });
    }

    // Wait for upload
    await uploadTask;

    // Get download URL
    final url = await ref.getDownloadURL();

    return ImageUploadResult(
      url: url,
      path: fullPath,
    );
  }

  /// Upload profile image
  Future<ImageUploadResult> uploadProfileImage({
    required File file,
    required String userId,
    UploadProgressCallback? onProgress,
  }) async {
    return uploadImage(
      file: file,
      storagePath: '${StoragePaths.profileImages}/$userId',
      generateThumbnail: true,
      onProgress: onProgress,
    );
  }

  /// Upload event image
  Future<ImageUploadResult> uploadEventImage({
    required File file,
    required String eventId,
    UploadProgressCallback? onProgress,
  }) async {
    return uploadImage(
      file: file,
      storagePath: '${StoragePaths.eventImages}/$eventId',
      generateThumbnail: true,
      onProgress: onProgress,
    );
  }

  /// Upload supplier image
  Future<ImageUploadResult> uploadSupplierImage({
    required File file,
    required String supplierId,
    UploadProgressCallback? onProgress,
  }) async {
    return uploadImage(
      file: file,
      storagePath: '${StoragePaths.supplierImages}/$supplierId',
      generateThumbnail: true,
      onProgress: onProgress,
    );
  }

  /// Upload chat media
  Future<ImageUploadResult> uploadChatMedia({
    required File file,
    required String chatId,
    UploadProgressCallback? onProgress,
  }) async {
    return uploadImage(
      file: file,
      storagePath: '${StoragePaths.chatMedia}/$chatId',
      generateThumbnail: false,
      onProgress: onProgress,
    );
  }

  /// Upload resume/document
  Future<String> uploadDocument({
    required File file,
    required String userId,
    UploadProgressCallback? onProgress,
  }) async {
    final fileName = '${_uuid.v4()}${path.extension(file.path)}';
    final fullPath = '${StoragePaths.resumes}/$userId/$fileName';
    final ref = _storage.ref(fullPath);

    final uploadTask = ref.putFile(file);

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((event) {
        final progress = event.bytesTransferred / event.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  /// Delete image
  Future<void> deleteImage(String storagePath) async {
    try {
      await _storage.ref(storagePath).delete();
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  /// Delete multiple images
  Future<void> deleteImages(List<String> storagePaths) async {
    await Future.wait(storagePaths.map((p) => deleteImage(p)));
  }

  /// Compress image
  Future<File> _compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return file;

    // Check if compression is needed
    final sizeKB = bytes.length / 1024;
    if (sizeKB <= AppConstants.maxImageSizeKB) {
      return file;
    }

    // Resize if too large
    img.Image resized = image;
    if (image.width > 1920 || image.height > 1920) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? 1920 : null,
        height: image.height >= image.width ? 1920 : null,
      );
    }

    // Compress
    final compressed = img.encodeJpg(
      resized,
      quality: (AppConstants.imageQuality * 100).toInt(),
    );

    // Save to temp file
    final tempPath = '${file.parent.path}/compressed_${path.basename(file.path)}';
    final compressedFile = File(tempPath);
    await compressedFile.writeAsBytes(compressed);

    return compressedFile;
  }

  /// Upload thumbnail
  Future<ImageUploadResult> _uploadThumbnail({
    required File file,
    required String storagePath,
    required String fileName,
  }) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Create thumbnail
    final thumbnail = img.copyResize(
      image,
      width: AppConstants.thumbnailSize,
      height: AppConstants.thumbnailSize,
      maintainAspect: true,
    );

    final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);

    // Upload
    final fullPath = '$storagePath/$fileName';
    final ref = _storage.ref(fullPath);
    await ref.putData(
      Uint8List.fromList(thumbnailBytes),
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();

    return ImageUploadResult(
      url: url,
      path: fullPath,
    );
  }
}

/// Image upload service provider
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  return ImageUploadService();
});

/// Image picker state
class ImagePickerState {
  final List<XFile> selectedImages;
  final bool isLoading;
  final double uploadProgress;
  final String? error;

  const ImagePickerState({
    this.selectedImages = const [],
    this.isLoading = false,
    this.uploadProgress = 0,
    this.error,
  });

  ImagePickerState copyWith({
    List<XFile>? selectedImages,
    bool? isLoading,
    double? uploadProgress,
    String? error,
  }) {
    return ImagePickerState(
      selectedImages: selectedImages ?? this.selectedImages,
      isLoading: isLoading ?? this.isLoading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      error: error,
    );
  }
}

/// Image picker notifier
class ImagePickerNotifier extends Notifier<ImagePickerState> {
  late final ImageUploadService _uploadService;

  @override
  ImagePickerState build() {
    _uploadService = ref.watch(imageUploadServiceProvider);
    return const ImagePickerState();
  }

  Future<void> pickFromGallery({bool multiple = false}) async {
    try {
      if (multiple) {
        final images = await _uploadService.pickMultipleImages();
        state = state.copyWith(
          selectedImages: [...state.selectedImages, ...images],
        );
      } else {
        final image = await _uploadService.pickImageFromGallery();
        if (image != null) {
          state = state.copyWith(
            selectedImages: [...state.selectedImages, image],
          );
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final image = await _uploadService.pickImageFromCamera();
      if (image != null) {
        state = state.copyWith(
          selectedImages: [...state.selectedImages, image],
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to take photo: $e');
    }
  }

  void removeImage(int index) {
    final images = [...state.selectedImages];
    images.removeAt(index);
    state = state.copyWith(selectedImages: images);
  }

  void clearImages() {
    state = state.copyWith(selectedImages: []);
  }

  Future<List<ImageUploadResult>> uploadAll({
    required String storagePath,
    bool generateThumbnails = true,
  }) async {
    if (state.selectedImages.isEmpty) return [];

    state = state.copyWith(isLoading: true, uploadProgress: 0);

    final results = <ImageUploadResult>[];
    final total = state.selectedImages.length;

    for (var i = 0; i < total; i++) {
      final image = state.selectedImages[i];
      final result = await _uploadService.uploadImage(
        file: File(image.path),
        storagePath: storagePath,
        generateThumbnail: generateThumbnails,
        onProgress: (progress) {
          final overallProgress = (i + progress) / total;
          state = state.copyWith(uploadProgress: overallProgress);
        },
      );
      results.add(result);
    }

    state = state.copyWith(
      isLoading: false,
      uploadProgress: 1,
      selectedImages: [],
    );

    return results;
  }
}

/// Image picker notifier provider
final imagePickerNotifierProvider =
    NotifierProvider<ImagePickerNotifier, ImagePickerState>(() {
  return ImagePickerNotifier();
});
