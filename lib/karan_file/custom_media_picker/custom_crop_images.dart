import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:photo_manager/photo_manager.dart';

class CustomCropImageScreen extends StatefulWidget {
  final List<AssetEntity> assets;

  const CustomCropImageScreen({
    super.key,
    required this.assets,
  });

  @override
  State<CustomCropImageScreen> createState() => _CustomCropImageScreenState();
}

class _CustomCropImageScreenState extends State<CustomCropImageScreen> {
  final List<File> _croppedFiles = [];
  int _currentIndex = 0;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _startCropping();
  }

  Future<void> _startCropping() async {
    if (_currentIndex >= widget.assets.length) {
      if (mounted) Navigator.pop(context, _croppedFiles);
      return;
    }

    setState(() => _isCropping = true);

    final asset = widget.assets[_currentIndex];
    final file = await asset.file;

    if (file == null) {
      _skipImage();
      return;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (!mounted) return;

    if (cropped != null) {
      _croppedFiles.add(File(cropped.path));
    }

    _currentIndex++;
    _startCropping();
  }

  void _skipImage() {
    _currentIndex++;
    _startCropping();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.assets.length;
    final current = _currentIndex + 1 > total ? total : _currentIndex + 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _isCropping
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Cropping image $current of $total...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        )
            : const SizedBox(),
      ),
    );
  }
}