import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for picking and processing images with compression and cropping
class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery
  static Future<File?> pickFromGallery({
    bool compress = true,
    bool crop = false,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (xFile == null) return null;

      File file = File(xFile.path);

      // Crop if requested
      if (crop) {
        final croppedFile = await _cropImage(file);
        if (croppedFile == null) return null;
        file = croppedFile;
      }

      // Compress if requested
      if (compress) {
        final compressedFile = await _compressImage(file, quality: quality);
        if (compressedFile == null) return file;
        file = compressedFile;
      }

      return file;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick an image from camera
  static Future<File?> pickFromCamera({
    bool compress = true,
    bool crop = false,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );

      if (xFile == null) return null;

      File file = File(xFile.path);

      // Crop if requested
      if (crop) {
        final croppedFile = await _cropImage(file);
        if (croppedFile == null) return null;
        file = croppedFile;
      }

      // Compress if requested
      if (compress) {
        final compressedFile = await _compressImage(file, quality: quality);
        if (compressedFile == null) return file;
        file = compressedFile;
      }

      return file;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick avatar image with square crop
  static Future<File?> pickAvatar({
    bool fromCamera = false,
    int quality = 90,
  }) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: quality,
      );

      if (xFile == null) return null;

      File file = File(xFile.path);

      // Always crop avatar to square
      final croppedFile = await _cropImage(
        file,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      if (croppedFile == null) return null;

      // Compress to 512x512
      final compressedFile = await _compressImage(
        croppedFile,
        quality: quality,
        maxWidth: 512,
        maxHeight: 512,
      );

      return compressedFile ?? croppedFile;
    } catch (e) {
      print('Error picking avatar: $e');
      return null;
    }
  }

  /// Pick post image with optional crop
  static Future<File?> pickPostImage({
    bool fromCamera = false,
    int quality = 85,
  }) async {
    try {
      final XFile? xFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: quality,
      );

      if (xFile == null) return null;

      File file = File(xFile.path);

      // Optional crop for posts
      final croppedFile = await _cropImage(file);
      if (croppedFile != null) {
        file = croppedFile;
      }

      // Compress
      final compressedFile = await _compressImage(
        file,
        quality: quality,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      return compressedFile ?? file;
    } catch (e) {
      print('Error picking post image: $e');
      return null;
    }
  }

  /// Compress image to reduce file size
  static Future<File?> _compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: CompressFormat.jpeg,
      );

      if (result == null) return null;

      return File(result.path);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  /// Crop image with customizable aspect ratio
  static Future<File?> _cropImage(
    File file, {
    CropAspectRatio? aspectRatio,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: file.path,
        aspectRatio: aspectRatio,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Kırp',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: aspectRatio != null,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Kırp',
            doneButtonTitle: 'Tamam',
            cancelButtonTitle: 'İptal',
            aspectRatioLockEnabled: aspectRatio != null,
          ),
        ],
      );

      if (croppedFile == null) return null;

      return File(croppedFile.path);
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  /// Show image source bottom sheet
  static Future<File?> showImageSourcePicker({
    required BuildContext context,
    bool enableCrop = false,
    int quality = 85,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galeriden Seç'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('İptal'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return await pickFromCamera(
        compress: true,
        crop: enableCrop,
        quality: quality,
      );
    } else {
      return await pickFromGallery(
        compress: true,
        crop: enableCrop,
        quality: quality,
      );
    }
  }

  /// Get file size in KB
  static Future<double> getFileSizeInKB(File file) async {
    final bytes = await file.length();
    return bytes / 1024;
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final kb = await getFileSizeInKB(file);
    return kb / 1024;
  }
}
