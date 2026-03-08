import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:restaurant_td/constant/constant.dart';
import 'package:restaurant_td/constant/show_toast_dialog.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:restaurant_td/main.dart';

class SupabaseStorageService {
  // ─── Story Image Upload ──────────────────────────────────────

  /// Upload story thumbnail image
  static Future<String> uploadStoryThumbnail(
      File image, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading thumbnail...");

      final String fileName =
          'story_thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String bucketName = 'story_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, image.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading thumbnail: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Story Video Upload ──────────────────────────────────────

  /// Upload story video
  static Future<String> uploadStoryVideo(
      File video, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");

      final String fileName =
          'story_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String bucketName = 'story_videos';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, video.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'video/mp4',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading video: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Chat Image Upload ───────────────────────────────────────

  /// Upload chat image
  static Future<String> uploadChatImage(
      File image, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading image...");

      final String fileName =
          'chat_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String bucketName = 'chat_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, image.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading image: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Chat Video Upload ───────────────────────────────────────

  /// Upload chat video
  static Future<String> uploadChatVideo(
      File video, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");

      final String fileName =
          'chat_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final String bucketName = 'chat_videos';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, video.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'video/mp4',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading video: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Product Image Upload ────────────────────────────────────

  /// Upload product image
  static Future<String> uploadProductImage(
      File image, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading product image...");

      final String fileName =
          'product_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String bucketName = 'product_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, image.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Error uploading product image: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Advertisement Image Upload ──────────────────────────────

  /// Upload advertisement image
  static Future<String> uploadAdvertisementImage(
      File image, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading advertisement image...");

      final String fileName =
          'advertisement_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String bucketName = 'advertisement_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, image.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Error uploading advertisement image: ${e.toString()}");
      rethrow;
    }
  }

  // ─── User Profile Image Upload ───────────────────────────────

  /// Upload user profile image
  static Future<String> uploadUserProfileImage(
      File image, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading profile image...");

      final String fileName =
          'profile_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String bucketName = 'profile_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, image.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Error uploading profile image: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Vendor Profile Image Upload ─────────────────────────────

  /// Upload vendor profile image
  static Future<String> uploadVendorProfileImage(
      File image, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading vendor image...");

      final String fileName =
          'vendor_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String bucketName = 'vendor_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, image.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Error uploading vendor image: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Document Upload ─────────────────────────────────────────

  /// Upload document
  static Future<String> uploadDocument(
      File document, String fileName, BuildContext context) async {
    try {
      ShowToastDialog.showLoader("Uploading document...");

      final String bucketName = 'documents';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response = await supabase.storage
          .from(bucketName)
          .upload(fileName, document.readAsBytesSync(),
              fileOptions: FileOptions(
                contentType: _getContentType(fileName),
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error uploading document: ${e.toString()}");
      rethrow;
    }
  }

  // ─── Utility Methods ─────────────────────────────────────────

  /// Ensure bucket exists
  static Future<void> _ensureBucketExists(String bucketName) async {
    try {
      // Try to get bucket info to check if it exists
      await supabase.storage.getBucket(bucketName);
    } catch (e) {
      // Bucket doesn't exist, create it
      try {
        await supabase.storage.createBucket(
            bucketName,
            BucketOptions(
              public: true,
              fileSizeLimit: 50 * 1024 * 1024, // 50MB limit
              allowedMimeTypes: [
                'image/jpeg',
                'image/png',
                'image/gif',
                'video/mp4',
                'video/mov',
                'application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              ],
            ));
      } catch (createError) {
        // Bucket might already exist or creation failed
        // Continue with upload anyway
      }
    }
  }

  /// Get content type based on file extension
  static String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }

  // ─── File Management ─────────────────────────────────────────

  /// Delete file from storage
  static Future<void> deleteFile(String bucketName, String fileName) async {
    try {
      await supabase.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      ShowToastDialog.showToast("Error deleting file: ${e.toString()}");
      rethrow;
    }
  }

  /// List files in bucket
  static Future<List<FileObject>> listFiles(String bucketName,
      {String? path}) async {
    try {
      final response = await supabase.storage.from(bucketName).list(path ?? '');
      return response;
    } catch (e) {
      ShowToastDialog.showToast("Error listing files: ${e.toString()}");
      rethrow;
    }
  }

  /// Get file public URL
  static String getPublicUrl(String bucketName, String fileName) {
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  /// Upload restaurant image
  static Future<String> uploadRestaurantImage(
      File image, String path, String fileName) async {
    try {
      ShowToastDialog.showLoader("Uploading restaurant image...");

      final String bucketName = 'restaurant_images';

      // Ensure bucket exists and is configured for public access
      await _ensureBucketExists(bucketName);

      final response =
          await supabase.storage.from(bucketName).uploadBinary(fileName, await image.readAsBytes(),
              fileOptions: FileOptions(
                contentType: 'image/jpeg',
                upsert: true,
              ));

      // Get public URL
      final publicUrl =
          supabase.storage.from(bucketName).getPublicUrl(fileName);

      ShowToastDialog.closeLoader();
      return publicUrl;
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(
          "Error uploading restaurant image: ${e.toString()}");
      rethrow;
    }
  }
}
