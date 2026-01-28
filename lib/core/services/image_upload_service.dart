import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../exceptions/exceptions.dart';
import 'logger_service.dart';

/// Service for handling image upload functionality.
///
/// Provides methods for picking images from camera or gallery,
/// uploading to Supabase Storage, and deleting images.
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();

  factory ImageUploadService() => _instance;

  ImageUploadService._internal();

  /// Get Supabase client
  SupabaseClient get _supabase => SupabaseConfig.client;

  final ImagePicker _picker = ImagePicker();

  /// Storage bucket name for avatars
  static const String avatarBucket = StorageBuckets.avatars;

  /// Pick an image from the specified source.
  ///
  /// Returns [File] if image is picked, null if cancelled.
  /// Handles permissions and errors gracefully.
  Future<File?> pickImage(ImageSource source) async {
    try {
      AppLogger.info(
        'Picking image from ${source == ImageSource.camera ? 'camera' : 'gallery'}',
        tag: 'ImageUpload',
      );

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        AppLogger.info('Image picker cancelled', tag: 'ImageUpload');
        return null;
      }

      final file = File(pickedFile.path);
      final fileSize = await file.length();
      AppLogger.info(
        'Image picked: ${pickedFile.name}, size: ${fileSize / 1024} KB',
        tag: 'ImageUpload',
      );

      // Validate file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        throw ValidationException(
          'Image too large. Please select an image smaller than 5MB.',
          code: 'IMAGE_TOO_LARGE',
        );
      }

      return file;
    } on ValidationException {
      rethrow;
    } catch (e) {
      AppLogger.error(
        'Failed to pick image',
        error: e,
        tag: 'ImageUpload',
      );
      throw DatabaseException(
        'Failed to pick image. Please try again.',
        code: 'PICK_IMAGE_FAILED',
        originalError: e,
      );
    }
  }

  /// Upload an image to Supabase Storage.
  ///
  /// [image] - The image file to upload
  /// [userId] - The user ID (used for filename generation)
  ///
  /// Returns the public URL of the uploaded image.
  /// Throws [DatabaseException] on failure.
  Future<String> uploadToSupabase(File image, String userId) async {
    try {
      AppLogger.info('Uploading image for user: $userId', tag: 'ImageUpload');

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = '${userId}_$timestamp.jpg';

      // Upload to Supabase Storage
      final path = await _supabase.storage.from(avatarBucket).upload(
            filename,
            image,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      AppLogger.info('Image uploaded: $path', tag: 'ImageUpload');

      // Get public URL
      final publicUrl = _supabase.storage.from(avatarBucket).getPublicUrl(filename);

      AppLogger.info('Public URL generated: $publicUrl', tag: 'ImageUpload');

      return publicUrl;
    } on StorageException catch (e) {
      AppLogger.error(
        'Storage error during upload',
        error: e,
        tag: 'ImageUpload',
      );
      throw DatabaseException(
        'Failed to upload image: ${e.message}',
        code: 'UPLOAD_FAILED',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error(
        'Unexpected error during upload',
        error: e,
        tag: 'ImageUpload',
      );
      throw DatabaseException(
        'Failed to upload image. Please try again.',
        code: 'UPLOAD_FAILED',
        originalError: e,
      );
    }
  }

  /// Delete an image from Supabase Storage.
  ///
  /// [imageUrl] - The public URL of the image to delete
  ///
  /// Extracts the filename from the URL and deletes the file.
  /// Handles errors gracefully without throwing.
  Future<void> deleteFromSupabase(String imageUrl) async {
    try {
      AppLogger.info('Deleting image: $imageUrl', tag: 'ImageUpload');

      // Extract filename from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find the filename after the bucket name in the path
      final bucketIndex = pathSegments.indexOf(avatarBucket);
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        AppLogger.warning(
          'Could not extract filename from URL: $imageUrl',
          tag: 'ImageUpload',
        );
        return;
      }

      final filename = pathSegments[bucketIndex + 1];

      // Delete from Supabase Storage
      await _supabase.storage.from(avatarBucket).remove([filename]);

      AppLogger.info('Image deleted: $filename', tag: 'ImageUpload');
    } on StorageException catch (e) {
      // Log but don't throw - deletion failures shouldn't block the user
      AppLogger.warning(
        'Storage error during deletion: ${e.message}',
        tag: 'ImageUpload',
      );
    } catch (e) {
      // Log but don't throw - deletion failures shouldn't block the user
      AppLogger.warning(
        'Failed to delete image',
        tag: 'ImageUpload',
      );
    }
  }

  /// Upload avatar and update user profile.
  ///
  /// Convenience method that picks, uploads, and updates the profile.
  /// Returns the public URL of the uploaded image.
  Future<String> uploadAvatar({
    required ImageSource source,
    required String userId,
  }) async {
    final image = await pickImage(source);
    if (image == null) {
      throw ValidationException('No image selected', code: 'NO_IMAGE');
    }

    return await uploadToSupabase(image, userId);
  }
}
