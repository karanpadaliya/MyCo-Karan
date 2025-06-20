import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../themes_colors/colors.dart';

class CustomCropImageScreen extends StatefulWidget {
  final List<AssetEntity> assets;

  const CustomCropImageScreen({super.key, required this.assets});

  @override
  State<CustomCropImageScreen> createState() => _CustomCropImageScreenState();
}

class _CustomCropImageScreenState extends State<CustomCropImageScreen> {
  final List<File?> _croppedFiles = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _croppedFiles.addAll(List.generate(widget.assets.length, (_) => null));
  }

  Future<File?> _getImageFile(int index) async {
    return _croppedFiles[index] ?? await widget.assets[index].file;
  }

  Future<void> _cropImage(int index) async {
    final asset = widget.assets[index];
    final file = await asset.file;
    if (file == null) return;

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
          // showCropGrid: false
          backgroundColor: Colors.grey,
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: false),
      ],
    );

    if (cropped != null && mounted) {
      setState(() {
        _croppedFiles[index] = File(cropped.path);
      });
    }
  }

  void _applyCrops() async {
    List<File> resultFiles = [];
    for (int i = 0; i < widget.assets.length; i++) {
      final file = _croppedFiles[i] ?? await widget.assets[i].file;
      if (file != null) resultFiles.add(file);
    }

    if (mounted) Navigator.pop(context, resultFiles);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Photos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        elevation: 1,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Large Preview Image
          Expanded(
            child: FutureBuilder<File?>(
              future: _getImageFile(_currentIndex),
              builder: (context, snapshot) {
                final file = snapshot.data;
                return file != null
                    ? Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        image: DecorationImage(
                          image: FileImage(file),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                    : const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          const SizedBox(height: 20),
          // Thumbnail Strip with Crop & Check Mark
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.assets.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return FutureBuilder<File?>(
                  future: _getImageFile(index),
                  builder: (context, snapshot) {
                    final file = snapshot.data;
                    final isSelected = index == _currentIndex;
                    final isCropped = _croppedFiles[index] != null;

                    return GestureDetector(
                      onTap: () => setState(() => _currentIndex = index),
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              image:
                                  file != null
                                      ? DecorationImage(
                                        image: FileImage(file),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                              color: AppColors.secondary,
                            ),
                            child:
                                file == null
                                    ? const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : null,
                          ),
                          // Crop Icon Button (Floating)
                          Positioned(
                            bottom: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => _cropImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.9),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.crop,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          // Tick if Cropped
                          if (isCropped)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      // Apply Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _applyCrops,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Apply',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
      ),
    );
  }
}
