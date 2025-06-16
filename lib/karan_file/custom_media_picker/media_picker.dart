import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../themes_colors/app_theme.dart';
import '../../themes_colors/colors.dart';
import '../app_permissions/app_permissions.dart';
import '../custom_loader/custom_loader.dart';
import '../custom_myco_button/custom_myco_button.dart';
import 'custome_shadow_container.dart';

Future<List<File>?> showMediaFilePicker({
  required BuildContext context,
  bool? isDialog,
  bool? selectDocument,
  bool isCameraShow = false,
  bool isGallaryShow = false,
  bool isDocumentShow = false,
}) async {
  bool _isLoading = false;

  return isDialog == true
      ? showDialog<List<File>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Stack(
          children: [
            AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: AppColors.white,
              content: _MediaFilePickerWidget(
                selectDocument: selectDocument,
                isCameraShow: isCameraShow,
                isGallaryShow: isGallaryShow,
                isDocumentShow: isDocumentShow,
                onLoading: (val) => setState(() => _isLoading = val),
              ),
            ),
            if (_isLoading) const Center(child: CustomLoader()),
          ],
        ),
      );
    },
  )
      : showDialog<List<File>>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: _MediaFilePickerWidget(
                    selectDocument: selectDocument,
                    isCameraShow: isCameraShow,
                    isGallaryShow: isGallaryShow,
                    isDocumentShow: isDocumentShow,
                    onLoading: (val) => setState(() => _isLoading = val),
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(child: CustomLoader()),
              ),
          ],
        ),
      );
    },
  );
}

class _MediaFilePickerWidget extends StatefulWidget {
  final bool? selectDocument;
  final bool isCameraShow;
  final bool isGallaryShow;
  final bool isDocumentShow;
  final void Function(bool)? onLoading;

  const _MediaFilePickerWidget({
    Key? key,
    this.selectDocument,
    this.isCameraShow = false,
    this.isGallaryShow = false,
    this.isDocumentShow = false,
    this.onLoading,
  }) : super(key: key);

  @override
  State<_MediaFilePickerWidget> createState() => _MediaFilePickerWidgetState();
}

class _MediaFilePickerWidgetState extends State<_MediaFilePickerWidget> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Select option",
            style: TextStyle(
              fontSize: AppTheme.lightTheme.textTheme.titleLarge!.fontSize,
              color: AppColors.borderColor,
            ),
          ),
          const Divider(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                if (widget.isCameraShow)
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.camera),
                    child: CustomShadowContainer(
                      image: Image.asset('assets/camera.png'),
                      title: 'Camera',
                    ),
                  ),
                if (widget.isCameraShow) const SizedBox(width: 20),
                if (widget.isGallaryShow)
                  GestureDetector(
                    onTap: () => _pickImage(ImageSource.gallery),
                    child: CustomShadowContainer(
                      image: Image.asset('assets/gallery-add.png'),
                      title: 'Gallery',
                    ),
                  ),
                if (widget.isGallaryShow) const SizedBox(width: 20),
                if (widget.isDocumentShow)
                  GestureDetector(
                    onTap: _pickDocument,
                    child: CustomShadowContainer(
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
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final hasPermission = await PermissionUtil.requestPermission(
        source == ImageSource.camera ? AppPermission.camera : AppPermission.storage,
      );

      if (!hasPermission) {
        PermissionUtil.showPermissionDeniedDialog(
          context,
          message: source == ImageSource.camera
              ? "Camera access is required to take pictures."
              : "Photos access is required to pick images from gallery.",
        );
        return;
      }

      widget.onLoading?.call(true);

      if (source == ImageSource.gallery) {
        final List<XFile>? pickedFiles = await _picker.pickMultiImage(
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          final List<File> validImages = pickedFiles
              .where((file) {
            final extension = path.extension(file.path).toLowerCase();
            return ['.png', '.jpg', '.jpeg', '.heic', '.heif'].contains(extension);
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
            if (mounted) Navigator.pop(context, [File(pickedFile.path)]);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Invalid file type. Use PNG, JPG, JPEG, HEIC or HEIF."),
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
      if (mounted) Navigator.pop(context);
    } finally {
      widget.onLoading?.call(false);
    }
  }

  Future<void> _pickDocument() async {
    try {
      final hasPermission = await PermissionUtil.requestPermission(AppPermission.manageExternalStorage);

      if (!hasPermission) {
        PermissionUtil.showPermissionDeniedDialog(
          context,
          message: "Storage access is required to select documents.",
        );
        return;
      }

      widget.onLoading?.call(true);

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
    } finally {
      widget.onLoading?.call(false);
    }
  }
}
