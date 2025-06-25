import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';
import '../../jenil_file/app_theme.dart';
import '../../themes_colors/colors.dart';
import 'design_border_container.dart';
import 'gallery_picker_screen.dart';
import 'media_picker.dart';

class CustomMediaPickerContainer extends StatefulWidget {
  final double? imageMargin;
  final double? containerHeight;
  final String title;
  final String imageTitle;
  final int multipleImage;
  final String imagePath;
  final Color backgroundColor;
  final bool isCameraShow;
  final bool isGallaryShow;
  final bool isDocumentShow;
  final bool isCropImage;

  const CustomMediaPickerContainer({
    super.key,
    this.imageMargin,
    this.containerHeight,
    required this.title,
    required this.imageTitle,
    required this.multipleImage,
    required this.imagePath,
    this.backgroundColor = AppColors.imagePickerBg,
    this.isCameraShow = false,
    this.isGallaryShow = false,
    this.isDocumentShow = false,
    this.isCropImage = false,
  });

  @override
  State<CustomMediaPickerContainer> createState() =>
      _CustomMediaPickerContainerState();
}

class _CustomMediaPickerContainerState
    extends State<CustomMediaPickerContainer> {
  List<File> _pickedImages = [];
  File? pickedFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: "Gilroy-Bold",
            fontWeight: FontWeight.w400,
            color: AppColors.titleColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildPickerContent(),
      ],
    );
  }

  Widget _buildPickerContent() {
    if (_pickedImages.isNotEmpty) {
      return DesignBorderContainer(
        borderRadius: 8,
        borderColor: AppColors.primary,
        backgroundColor: AppColors.white,
        padding: const EdgeInsets.all(0),
        child: Padding(
          padding: EdgeInsets.all(widget.imageMargin ?? 10),
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.75,
            children: List.generate(
              _pickedImages.length < widget.multipleImage
                  ? _pickedImages.length + 1
                  : _pickedImages.length,
              (index) {
                if (_pickedImages.length < widget.multipleImage &&
                    index == _pickedImages.length) {
                  return GestureDetector(
                    onTap: () => openMediaPicker(context),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.imagePickerBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primary, width: 1),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _pickedImages[index],
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _pickedImages.removeAt(index);
                          });
                        },
                        child: Image.asset('assets/trash.png', height: 20),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else if (pickedFile != null) {
      return DesignBorderContainer(
        borderRadius: 12,
        borderColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(
                Icons.insert_drive_file,
                color: AppColors.primary,
                size: 40,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  path.basename(pickedFile!.path),
                  style: TextStyle(
                    fontSize:
                        AppTheme.lightTheme.textTheme.bodyLarge?.fontSize ?? 16,
                    fontFamily: "Gilroy-Medium",
                    color: AppColors.titleColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => pickedFile = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.removeBackground,
                    border: Border.all(color: AppColors.remove),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Remove",
                    style: TextStyle(
                      fontSize:
                          AppTheme.lightTheme.textTheme.bodyLarge?.fontSize ??
                          14,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => openMediaPicker(context),
        child: DesignBorderContainer(
          borderRadius: 12,
          borderColor: AppColors.primary,
          backgroundColor: widget.backgroundColor,
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: double.infinity,
            height: widget.containerHeight ?? 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.imagePath.isNotEmpty
                      ? widget.imagePath
                      : 'assets/gallery-export.png',
                  width: 30,
                  height: 30,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.imageTitle,
                  style: TextStyle(
                    fontSize:
                        AppTheme.lightTheme.textTheme.bodyLarge?.fontSize ?? 16,
                    fontFamily: "Gilroy-SemiBold",
                    fontWeight: FontWeight.w400,
                    color: AppColors.titleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  void openMediaPicker(BuildContext context) async {
    List<File>? selectedFiles = [];

    final remainingCount = widget.multipleImage - _pickedImages.length;
    print('remainingCount:-----------------------------$remainingCount');
    if (remainingCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You have already selected the maximum number of images.',
          ),
        ),
      );
      return;
    }

    if (widget.isGallaryShow &&
        !widget.isCameraShow &&
        !widget.isDocumentShow) {
      selectedFiles = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GalleryPickerScreen(
                maxSelection: remainingCount,
                // isCropImage: false,
                onSelectionDone: (List<dynamic> assets) async {
                  List<File> files = [];
                  for (final asset in assets) {
                    final file = await asset.file;
                    if (file != null) {
                      files.add(file);
                    }
                  }
                  Navigator.pop(context, files);
                },
              ),
        ),
      );
    } else {
      selectedFiles = await showMediaFilePicker(
        context: context,
        maxCount: remainingCount,
        isCameraShow: widget.isCameraShow,
        isGallaryShow: widget.isGallaryShow,
        isDocumentShow: widget.isDocumentShow,
        isCropImage: widget.isCropImage,
      );
    }

    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      final List<File> imageFiles = [];
      File? documentFile;

      for (final file in selectedFiles) {
        final String extension = path.extension(file.path).toLowerCase();

        if (['.png', '.jpg', '.jpeg', '.heic', '.heif'].contains(extension)) {
          imageFiles.add(file);
        } else if (['.pdf', '.doc', '.docx'].contains(extension)) {
          documentFile = file;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported file type')),
          );
          return;
        }
      }

      if (imageFiles.isNotEmpty) {
        if (_pickedImages.length + imageFiles.length <= widget.multipleImage) {
          setState(() {
            _pickedImages.addAll(imageFiles);
            pickedFile = null;
          });
        } else {
          final remaining = widget.multipleImage - _pickedImages.length;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'You can only select $remaining more image${remaining > 1 ? "s" : ""}.',
              ),
            ),
          );
        }
      }

      if (documentFile != null) {
        setState(() {
          pickedFile = documentFile;
          _pickedImages.clear();
        });
      }
    } else {
      log('User cancelled or error occurred.');
    }
  }
}
