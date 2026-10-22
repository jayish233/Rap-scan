import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// Files over 5 MB are rejected on the device (PRD §7.3).
const maxPhotoBytes = 5 * 1024 * 1024;

/// A picked label photo, held only in memory: photos are never persisted
/// (no photo archive in v1, PRD §13).
class PickedPhoto {
  const PickedPhoto({required this.bytes, required this.name});

  final Uint8List bytes;
  final String name;

  int get sizeBytes => bytes.length;
  bool get isTooLarge => sizeBytes > maxPhotoBytes;
}

enum PhotoSource { camera, gallery }

/// The user (or OS policy) has denied camera or photo-library access.
class PhotoAccessDenied implements Exception {
  const PhotoAccessDenied();
}

/// Platform photo access + upload preparation. Overridden in tests.
class PhotoService {
  const PhotoService();

  /// Longest edge after compression; plenty for label OCR.
  static const _maxEdge = 1600;
  static const _quality = 80;

  /// Null when the user cancels.
  Future<PickedPhoto?> pick(PhotoSource source) async {
    try {
      final file = await ImagePicker().pickImage(
        source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
        requestFullMetadata: false,
      );
      if (file == null) return null;
      return PickedPhoto(bytes: await file.readAsBytes(), name: file.name);
    } on PlatformException catch (e) {
      if (e.code.contains('access_denied')) throw const PhotoAccessDenied();
      rethrow;
    }
  }

  /// JPEG-compress so a typical label photo stays well under 5 MB, then
  /// encode as the `imageDataUrl` analyze-scan expects.
  Future<String> toUploadDataUrl(PickedPhoto photo) async {
    Uint8List bytes;
    try {
      bytes = await FlutterImageCompress.compressWithList(
        photo.bytes,
        minWidth: _maxEdge,
        minHeight: _maxEdge,
        quality: _quality,
        format: CompressFormat.jpeg,
      );
    } catch (_) {
      bytes = photo.bytes; // Unsupported format: send as-is (already ≤ 5 MB).
    }
    final mime = bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8 ? 'image/jpeg' : _sniffMime(bytes);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  static String _sniffMime(Uint8List b) {
    if (b.length > 4 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return 'image/png';
    if (b.length > 12 && String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') return 'image/webp';
    return 'image/jpeg';
  }
}

final photoServiceProvider = Provider<PhotoService>((ref) => const PhotoService());
