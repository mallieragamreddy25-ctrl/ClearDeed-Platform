import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fileServiceProvider = Provider<FileService>((ref) {
  return FileService();
});

/// File and Image handling service
class FileService {
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.instance;
  final ImageCropper _imageCropper = ImageCropper();

  /// Pick image from camera or gallery
  Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 95,
      );

      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Crop image with custom aspect ratio
  Future<File?> cropImage(
    File imageFile, {
    int aspectRatioX = 1,
    int aspectRatioY = 1,
    int maxWidth = 1080,
    int maxHeight = 1080,
  }) async {
    try {
      final croppedFile = await _imageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: const Color(0xFF1F2937),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockDimensionSwapEnabled: true,
            resetAspectRatioEnabled: true,
          ),
        ],
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      if (croppedFile == null) return null;
      return File(croppedFile.path);
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  /// Compress image for faster upload
  Future<File> compressImage(
    File imageFile, {
    int quality = 85,
    int maxWidth = 1080,
    int maxHeight = 1080,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);

      if (image == null) return imageFile;

      // Resize if too large
      if (image.width > maxWidth || image.height > maxHeight) {
        image = img.copyResize(
          image,
          width: maxWidth,
          height: maxHeight,
          interpolation: img.Interpolation.average,
        );
      }

      // Save compressed image
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedPath = path.join(tempDir.path, 'compressed_$timestamp.jpg');

      return File(compressedPath)
        ..writeAsBytesSync(img.encodeJpg(image, quality: quality));
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageFile;
    }
  }

  /// Compress multiple images
  Future<List<File>> compressImages(
    List<File> imageFiles, {
    int quality = 85,
    int maxWidth = 1080,
    int maxHeight = 1080,
  }) async {
    final compressed = <File>[];
    for (final file in imageFiles) {
      final compressedFile = await compressImage(
        file,
        quality: quality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );
      compressed.add(compressedFile);
    }
    return compressed;
  }

  /// Pick document file
  Future<File?> pickDocument({
    List<String> allowedExtensions = const ['pdf', 'doc', 'docx', 'jpg', 'png'],
  }) async {
    try {
      final result = await _filePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      if (file.bytes == null) return null;

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = path.join(tempDir.path, file.name);

      return File(filePath)..writeAsBytesSync(file.bytes!);
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }

  /// Get file size in human-readable format
  String getFileSizeString(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var index = 0;
    var size = bytes.toDouble();

    while (size >= 1024 && index < suffixes.length - 1) {
      size /= 1024;
      index++;
    }

    return '${size.toStringAsFixed(2)} ${suffixes[index]}';
  }

  /// Check file size
  bool isFileSizeValid(File file, int maxSizeInBytes) {
    return file.lengthSync() <= maxSizeInBytes;
  }

  /// Get file size
  int getFileSize(File file) => file.lengthSync();

  /// Delete file
  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting file: $e');
    }
  }

  /// Clear temporary files
  Future<void> clearTemporary() async {
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (e) {
      debugPrint('Error clearing temp: $e');
    }
  }
}
