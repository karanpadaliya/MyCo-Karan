import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;


Future<List<File>> validateAndHandleImages({
  required BuildContext context,
  required List<File> files,
}) async {
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.heic', '.heif'];
  const maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
  List<File> validFiles = [];

  for (var file in files) {
    final ext = path.extension(file.path).toLowerCase();
    final size = await file.length();

    if (allowedExtensions.contains(ext) && size <= maxFileSizeInBytes) {
      validFiles.add(file);
    }
  }

  final skipped = files.length - validFiles.length;
  if (skipped > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$skipped unsupported image(s) were skipped.')),
    );
  }

  return validFiles;
}

/// Result of validating files: valid files and invalid files with reasons
class ImageFileValidatorResult {
  final List<File> validFiles;
  final List<Map<String, dynamic>> invalidFiles;

  ImageFileValidatorResult({
    required this.validFiles,
    required this.invalidFiles,
  });
}

/// Validator for image files: checks size and format
class ImageFileValidator {
  static const List<String> _supportedExtensions = [
    '.png',
    '.jpg',
    '.jpeg',
    '.heic',
    '.heif',
  ];

  static const int _maxFileSizeBytes = 5 * 1024 * 1024;

  /// Validate list of files and classify them as valid or invalid
  static Future<ImageFileValidatorResult> validateFiles(
    List<File> files,
  ) async {
    List<File> validFiles = [];
    List<Map<String, dynamic>> invalidFiles = [];

    for (final file in files) {
      final fileSize = await file.length();
      final ext = path.extension(file.path).toLowerCase();

      if (!_supportedExtensions.contains(ext)) {
        invalidFiles.add({'file': file, 'reason': 'format'});
      } else if (fileSize > _maxFileSizeBytes) {
        invalidFiles.add({'file': file, 'reason': 'size'});
      } else {
        validFiles.add(file);
      }
    }

    return ImageFileValidatorResult(
      validFiles: validFiles,
      invalidFiles: invalidFiles,
    );
  }

  /// Check if file format is supported
  static bool isSupportedFormat(String filePath) {
    final ext = path.extension(filePath).toLowerCase();
    return _supportedExtensions.contains(ext);
  }

  /// Check if file size is valid
  static bool isValidSize(int fileSize) {
    return fileSize <= _maxFileSizeBytes;
  }

  /// Show bottom sheet with preview of invalid files
  static void showInvalidFilesBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> invalidFiles,
  ) {
    if (invalidFiles.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'File(s) Restriction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Some files were discarded because they are either unsupported format (e.g., WebP) or larger than 5MB.\n\nSupported formats: PNG, JPG, JPEG, HEIC.\nMax size: 5MB.',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        invalidFiles.map((item) {
                          final File file = item['file'];
                          final String reason = item['reason'];
                          final String ext =
                              path.extension(file.path).toLowerCase();
                          final String fileName = path.basename(file.path);
                          final String reasonText =
                              reason == 'format'
                                  ? 'Unsupported ($ext)'
                                  : 'Too large (>5MB)';

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.broken_image,
                                          size: 40,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reasonText,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                fileName,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
