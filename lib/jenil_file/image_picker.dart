import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../themes_colors/app_theme.dart';
import '../themes_colors/colors.dart';
import 'design_container.dart';
import '../karan_file/new_myco_button.dart';

Future<File?> showImageFilePicker({
  required BuildContext context,
  bool? isDialog,
  bool? selectDocument,
}) async {
  return isDialog == true
      ? showDialog<File>(
        context: context,
        builder:
            (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: AppColors.white,
              content: _ImageFilePickerWidget(selectDocument: selectDocument),
            ),
      )
      : showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder:
            (context) => _ImageFilePickerWidget(selectDocument: selectDocument),
      );
}

class _ImageFilePickerWidget extends StatefulWidget {
  final bool? selectDocument;
  const _ImageFilePickerWidget({this.selectDocument});

  @override
  State<_ImageFilePickerWidget> createState() => _ImageFilePickerWidgetState();
}

class _ImageFilePickerWidgetState extends State<_ImageFilePickerWidget> {
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
          Divider(height: 2),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: const CustomTaskWidget(
                    imagePath: 'assets/camera.png',
                    title: 'Camera',
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: const CustomTaskWidget(
                    imagePath: 'assets/gallery-add.png',
                    title: 'Gallery',
                  ),
                ),
                const SizedBox(width: 10),

                if (widget.selectDocument == true)
                  GestureDetector(
                    onTap: _pickDocument,
                    child: CustomTaskWidget(
                      // height: 70,
                      // width: 70,
                      image: Image.asset(
                        'assets/document.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                      // imagePath: 'assets/document.png',
                      title: 'Documents',
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: MyCoButton(
              onTap: () {
                Navigator.pop(context);
              },
              boarderRadius: 50,
              title: 'Cancel',
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Picks an image and returns it to the parent using Navigator.pop
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,

      );

      if (pickedFile != null) {
        final String extension = path.extension(pickedFile.path).toLowerCase();

        if (extension == '.png' ||
            extension == '.jpg' ||
            extension == '.jpeg') {
          final File imageFile = File(pickedFile.path);
          if (mounted) Navigator.pop(context, imageFile); // Return the image
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Invalid file type. Use PNG, JPG, or JPEG."),
              ),
            );
          }
        }
      } else {
        Navigator.pop(context); // Close if user cancels
      }
    } catch (e) {
      print("Error picking image: $e");
      if (mounted) {
        Navigator.pop(context); // Close in case of error
      }
    }
  }

  //   import 'dart:io';
  // import 'package:file_picker/file_picker.dart';
  // import 'package:flutter/material.dart';
  // import 'package:image_picker/image_picker.dart'; // still needed for camera
  // import 'package:path/path.dart' as path;

  // Future<void> _pickImage(
  //   ImageSource source, {
  //   bool multiSelect = false,
  // }) async {
  //   try {
  //     if (source == ImageSource.camera || !multiSelect) {
  //       // Use image_picker for single image or camera
  //       final XFile? pickedFile = await ImagePicker().pickImage(
  //         source: source,
  //         maxWidth: 800,
  //         maxHeight: 800,
  //         imageQuality: 80,
  //       );
  //
  //       if (pickedFile != null) {
  //         final String extension =
  //             path.extension(pickedFile.path).toLowerCase();
  //         if (['.png', '.jpg', '.jpeg'].contains(extension)) {
  //           final File imageFile = File(pickedFile.path);
  //           if (context.mounted)
  //             Navigator.pop(context, [imageFile]); // return as list
  //         } else {
  //           if (context.mounted) {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                 content: Text("Invalid file type. Use PNG, JPG, or JPEG."),
  //               ),
  //             );
  //           }
  //         }
  //       } else {
  //         Navigator.pop(context); // User cancelled
  //       }
  //     } else {
  //       // Use file_picker for multi-image selection from gallery
  //       final result = await FilePicker.platform.pickFiles(
  //         type: FileType.custom,
  //         allowedExtensions: ['png', 'jpg', 'jpeg'],
  //         allowMultiple: true,
  //       );
  //
  //       if (result != null && result.files.isNotEmpty) {
  //         final List<File> images =
  //             result.paths
  //                 .where((path) => path != null)
  //                 .map((path) => File(path!))
  //                 .toList();
  //         log(".............................................$images");
  //         // if (context.mounted) Navigator.pop(context, images);
  //       } else {
  //         Navigator.pop(context); // User cancelled
  //       }
  //     }
  //   } catch (e) {
  //     print("Error picking image(s): $e");
  //     if (context.mounted) {
  //       Navigator.pop(context); // Close in case of error
  //     }
  //   }
  // }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final File file = File(result.files.single.path!);
        if (mounted) Navigator.pop(context, file); // Return the document
      } else {
        Navigator.pop(context); // User canceled
      }
    } catch (e) {
      print("Error picking document: $e");
      if (mounted) Navigator.pop(context); // On error
    }
  }
}
