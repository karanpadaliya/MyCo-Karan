import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../themes_colors/app_theme.dart';
import '../../themes_colors/colors.dart';
import '../new_myco_button.dart';
import 'custom_media_widget.dart';

Future<List<File>?> showImageFilePicker({
  required BuildContext context,
  bool? isDialog,
  bool? selectDocument,
}) async {
  return isDialog == true
      ? showDialog<List<File>>(
        context: context,
        builder:
            (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: AppColors.white,
              content: _MediaFilePickerWidget(selectDocument: selectDocument),
            ),
      )
      : showModalBottomSheet<List<File>>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder:
            (context) => _MediaFilePickerWidget(selectDocument: selectDocument),
      );
}

class _MediaFilePickerWidget extends StatefulWidget {
  final bool? selectDocument;

  const _MediaFilePickerWidget({this.selectDocument});

  @override
  State<_MediaFilePickerWidget> createState() => _MediaFilePickerWidgetState();
}

class _MediaFilePickerWidgetState extends State<_MediaFilePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select option",
              style: TextStyle(
                fontSize: AppTheme.lightTheme.textTheme.titleLarge!.fontSize,
                color: AppColors.borderColor,
              ),
            ),
          ),
          const Divider(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: const CustomMediaWidget(
                    imagePath: 'assets/camera.png',
                    title: 'Camera',
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: const CustomMediaWidget(
                    imagePath: 'assets/gallery-add.png',
                    title: 'Gallery',
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickDocument,
                  child: CustomMediaWidget(
                    image: Image.asset(
                      'assets/document.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.contain,
                    ),
                    title: 'Documents',
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: MyCoButton(
              isShadowBottomLeft: true,
              onTap: () {
                Navigator.pop(context);
              },
              boarderRadius: 50,
              title: 'Cancel',
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        final List<XFile>? pickedFiles = await _picker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          final List<File> validImages =
              pickedFiles
                  .where((file) {
                    final extension = path.extension(file.path).toLowerCase();
                    return [
                      '.png',
                      '.jpg',
                      '.jpeg',
                      '.heic',
                      '.heif',
                    ].contains(extension);
                  })
                  .map((file) => File(file.path))
                  .toList();

          if (validImages.isNotEmpty && mounted) {
            Navigator.pop(context, validImages);
          } else if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No valid images selected.")),
            );
          }
        } else {
          Navigator.pop(context);
        }
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          final extension = path.extension(pickedFile.path).toLowerCase();
          if (['.png', '.jpg', '.jpeg', '.heic', '.heif'].contains(extension)) {
            final File imageFile = File(pickedFile.path);
            if (mounted) Navigator.pop(context, [imageFile]);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Invalid file type. Use PNG, JPG, JPEG HEIC or HEIF.",
                    style: TextStyle(
                      backgroundColor: AppColors.white,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              );
            }
          }
        } else {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'heic', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        if (mounted) Navigator.pop(context, [file]);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error picking document: $e");
      if (mounted) Navigator.pop(context);
    }
  }
}
