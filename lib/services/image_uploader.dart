// lib/services/image_uploader.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploader {
  final _picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  Future<File?> pickImage({required bool fromCamera}) async {
    final pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<String?> uploadImage({
    required File file,
    required String userId,
    required String folder, // 'profile' or 'document'
  }) async {
    try {
      final fileExt = path.extension(file.path);
      final fileName = '$userId/$folder-${DateTime.now().millisecondsSinceEpoch}$fileExt';

      final bucketName = folder == 'profile'
          ? 'tour-guide-photos'
          : 'tour_guide_assets';

      final storageRef = _supabase.storage.from(bucketName);
      await storageRef.upload(fileName, file);
      final publicUrl = storageRef.getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Upload error: $e');
      return null;
    }
  }
}
