import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:photo_manager/photo_manager.dart';
import '../../themes_colors/app_theme.dart';
import '../../themes_colors/colors.dart';
import '../app_permissions/app_permissions.dart';
import '../custom_loader/custom_loader.dart';
import '../custom_myco_button/custom_myco_button.dart';
import 'custome_shadow_container.dart';
import 'gallery_picker_screen.dart';

Future<List<File>?> showMediaFilePicker({
  required BuildContext context,
  bool? isDialog,
  bool isCameraShow = false,
  bool isGallaryShow = false,
  bool isDocumentShow = false,
  int maxCount = 5,
}) async {
  bool _isLoading = false;

  return isDialog == true
      ? showDialog<List<File>>(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder:
                (context, setState) => Stack(
                  children: [
                    AlertDialog(
                      contentPadding: const EdgeInsets.all(0),
                      backgroundColor: AppColors.white,
                      content: _MediaFilePickerWidget(
                        isCameraShow: isCameraShow,
                        isGallaryShow: isGallaryShow,
                        isDocumentShow: isDocumentShow,
                        onLoading: (val) => setState(() => _isLoading = val),
                        maxCount: maxCount,
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
        barrierDismissible: false,
        builder: (context) {
          return _AnimatedBottomSheet(
            isCameraShow: isCameraShow,
            isGallaryShow: isGallaryShow,
            isDocumentShow: isDocumentShow,
            maxCount: maxCount,
          );
        },
      );
}

class _AnimatedBottomSheet extends StatefulWidget {
  final bool isCameraShow;
  final bool isGallaryShow;
  final bool isDocumentShow;
  final int maxCount;

  const _AnimatedBottomSheet({
    Key? key,
    required this.isCameraShow,
    required this.isGallaryShow,
    required this.isDocumentShow,
    required this.maxCount,
  }) : super(key: key);

  @override
  State<_AnimatedBottomSheet> createState() => _AnimatedBottomSheetState();
}

class _AnimatedBottomSheetState extends State<_AnimatedBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 400),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: _MediaFilePickerWidget(
                  isCameraShow: widget.isCameraShow,
                  isGallaryShow: widget.isGallaryShow,
                  isDocumentShow: widget.isDocumentShow,
                  onLoading: _setLoading,
                  maxCount: widget.maxCount,
                ),
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
    );
  }
}

class _MediaFilePickerWidget extends StatefulWidget {
  final bool isCameraShow;
  final bool isGallaryShow;
  final bool isDocumentShow;
  final int maxCount;
  final void Function(bool)? onLoading;

  const _MediaFilePickerWidget({
    Key? key,
    this.isCameraShow = false,
    this.isGallaryShow = false,
    this.isDocumentShow = false,
    this.onLoading,
    this.maxCount = 5,
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
              onTap: () => Navigator.pop(context),
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
      final hasPermission = await PermissionUtil.checkPermissionByPickerType(
        source == ImageSource.camera ? 'camera' : 'gallery',
        context,
      );

      if (!hasPermission) return;

      widget.onLoading?.call(true);

      if (source == ImageSource.gallery) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => GalleryPickerScreen(
                  maxSelection: widget.maxCount,
                  onSelectionDone: (List<AssetEntity> assets) async {
                    List<File> files = [];

                    for (final asset in assets) {
                      final file = await asset.file;
                      if (file != null) files.add(file);
                    }

                    if (files.isNotEmpty && mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context, files);
                    } else if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
          ),
        );
      } else {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (pickedFile != null && mounted) {
          final file = File(pickedFile.path);
          Navigator.pop(context, [file]);
        } else {
          if (mounted) Navigator.pop(context);
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
      final hasPermission = await PermissionUtil.checkPermissionByPickerType(
        'document',
        context,
      );

      if (!hasPermission) return;

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
