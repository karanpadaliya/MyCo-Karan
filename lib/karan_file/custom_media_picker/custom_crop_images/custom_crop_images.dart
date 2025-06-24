import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../../themes_colors/colors.dart';
import '../../custom_loader/custom_loader.dart';

extension ColorExtension on Color {
  Color withValues({int? red, int? green, int? blue, double? alpha}) {
    return Color.fromARGB(
      (alpha == null ? this.alpha : (255 * alpha).round()).clamp(0, 255),
      red ?? this.red,
      green ?? this.green,
      blue ?? this.blue,
    );
  }
}

extension RectExtension on Rect {
  Rect normalize() {
    return Rect.fromLTRB(
      min(left, right),
      min(top, bottom),
      max(left, right),
      max(top, bottom),
    );
  }
}

enum CropShape { rectangle, circle }

class CropAspectRatio {
  final String label;
  final double? value;
  final IconData icon;

  const CropAspectRatio({required this.label, this.value, required this.icon});
}

class CustomCropImageScreen extends StatefulWidget {
  final List<AssetEntity> assets;

  const CustomCropImageScreen({super.key, required this.assets});

  @override
  State<CustomCropImageScreen> createState() => _CustomCropImageScreenState();
}

class _CustomCropImageScreenState extends State<CustomCropImageScreen> {
  final GlobalKey _imageContainerKey = GlobalKey();
  int _currentIndex = 0;

  final Map<int, Rect> _pendingCropRects = {};
  final Map<int, Rect> _croppedRects = {};
  final Map<int, CropShape> _cropShapes = {};
  final Map<int, CropAspectRatio> _cropAspectRatios = {};

  final List<CropAspectRatio> _aspectRatios = const [
    CropAspectRatio(label: 'Free', icon: Icons.crop_free, value: null),
    CropAspectRatio(label: '1:1', icon: Icons.crop_square, value: 1.0),
    CropAspectRatio(label: '4:3', icon: Icons.crop_landscape, value: 4.0 / 3.0),
    CropAspectRatio(label: '3:4', icon: Icons.crop_portrait, value: 3.0 / 4.0),
    CropAspectRatio(label: '16:9', icon: Icons.crop_16_9, value: 16.0 / 9.0),
    CropAspectRatio(label: '9:16', icon: Icons.crop_7_5, value: 9.0 / 16.0),
  ];

  late CropAspectRatio _selectedAspectRatio;
  CropShape _selectedShape = CropShape.rectangle;

  @override
  void initState() {
    super.initState();
    _selectedAspectRatio = _aspectRatios.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCropRect());
  }

  Size? get _imageDisplaySize {
    final RenderBox? renderBox =
        _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size;
  }

  void _initializeCropRect() {
    final size = _imageDisplaySize;
    if (size == null || size.isEmpty) {
      debugPrint(
        "Warning: _imageDisplaySize is null or empty, cannot initialize crop rect.",
      );
      return;
    }

    _cropShapes.putIfAbsent(_currentIndex, () => CropShape.rectangle);
    _cropAspectRatios.putIfAbsent(_currentIndex, () => _aspectRatios.first);

    setState(() {
      _pendingCropRects[_currentIndex] = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * 0.8,
        height: size.height * 0.8,
      );
      _selectedAspectRatio = _cropAspectRatios[_currentIndex]!;
      _selectedShape = _cropShapes[_currentIndex]!;
      _applyAspectRatio();
    });
  }

  void _resetCrop() {
    setState(() {
      _pendingCropRects.remove(_currentIndex);
      _croppedRects.remove(_currentIndex);
      _cropShapes.remove(_currentIndex);
      _cropAspectRatios.remove(_currentIndex);
      _selectedShape = CropShape.rectangle;
      _selectedAspectRatio = _aspectRatios.first;
      _initializeCropRect();
    });
  }

  Future<Uint8List?> _getImagePreview(int index) async {
    return widget.assets[index].thumbnailDataWithSize(
      const ThumbnailSize(1080, 1080),
    );
  }

  void _updatePendingCropRect(Rect newRect) {
    _pendingCropRects[_currentIndex] = newRect;
  }

  void _confirmCrop() {
    setState(() {
      if (_pendingCropRects.containsKey(_currentIndex)) {
        _croppedRects[_currentIndex] = _pendingCropRects[_currentIndex]!;
      }
      _cropShapes[_currentIndex] = _selectedShape;
      _cropAspectRatios[_currentIndex] = _selectedAspectRatio;
    });
  }

  Future<void> _processAndSaveChanges() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CustomLoader()),
    );

    final List<File> finalFiles = [];

    for (int i = 0; i < widget.assets.length; i++) {
      final originalAsset = widget.assets[i];
      File? originalFile = await originalAsset.file;
      if (originalFile == null) continue;

      Rect? cropRectFromUI = _croppedRects[i];
      final cropShape = _cropShapes[i] ?? CropShape.rectangle;

      if (cropRectFromUI == null) {
        finalFiles.add(originalFile);
        continue;
      }

      try {
        final bytes = await originalFile.readAsBytes();
        final codec = await ui.instantiateImageCodec(bytes);
        ui.Image originalImage = (await codec.getNextFrame()).image;

        Size originalImageNaturalSize = Size(
          originalImage.width.toDouble(),
          originalImage.height.toDouble(),
        );
        ui.Image imageToCropFrom = originalImage;

        Size imageToCropFromSize = Size(
          imageToCropFrom.width.toDouble(),
          imageToCropFrom.height.toDouble(),
        );

        Rect finalCropSourceRect;

        final displayAreaSize = _imageDisplaySize!;
        final fittedBoxResult = applyBoxFit(
          BoxFit.contain,
          originalImageNaturalSize,
          displayAreaSize,
        );
        final Rect displayedImageRectInUI = Alignment.center.inscribe(
          fittedBoxResult.destination,
          Rect.fromLTWH(0, 0, displayAreaSize.width, displayAreaSize.height),
        );

        double scaleX =
            imageToCropFromSize.width / displayedImageRectInUI.width;
        double scaleY =
            imageToCropFromSize.height / displayedImageRectInUI.height;

        final double translatedCropLeft =
            (cropRectFromUI.left - displayedImageRectInUI.left);
        final double translatedCropTop =
            (cropRectFromUI.top - displayedImageRectInUI.top);

        finalCropSourceRect = Rect.fromLTWH(
          translatedCropLeft * scaleX,
          translatedCropTop * scaleY,
          cropRectFromUI.width * scaleX,
          cropRectFromUI.height * scaleY,
        );

        finalCropSourceRect = finalCropSourceRect.intersect(
          Rect.fromLTWH(
            0,
            0,
            imageToCropFromSize.width,
            imageToCropFromSize.height,
          ),
        );

        final ui.PictureRecorder finalRecorder = ui.PictureRecorder();
        final Canvas finalCanvas = Canvas(finalRecorder);
        final Paint paint = Paint()..isAntiAlias = true;

        final outputRect = Rect.fromLTWH(
          0,
          0,
          finalCropSourceRect.width,
          finalCropSourceRect.height,
        );

        if (cropShape == CropShape.circle) {
          finalCanvas.clipPath(Path()..addOval(outputRect));
        }

        finalCanvas.drawImageRect(
          imageToCropFrom,
          finalCropSourceRect,
          outputRect,
          paint,
        );

        final ui.Picture finalPicture = finalRecorder.endRecording();
        final ui.Image croppedImage = await finalPicture.toImage(
          outputRect.width.toInt(),
          outputRect.height.toInt(),
        );
        final ByteData? byteData = await croppedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        imageToCropFrom.dispose();

        if (byteData == null) {
          finalFiles.add(originalFile);
          continue;
        }

        final tempDir = Directory.systemTemp;
        final file = File(
          '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await file.writeAsBytes(byteData.buffer.asUint8List());
        finalFiles.add(file);
      } catch (e) {
        debugPrint('Error processing image at index $i: $e');
        finalFiles.add(originalFile);
      }
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, finalFiles);
    }
  }

  void _showConfirmDialog() {
    final bool hasAnyCrop = _croppedRects.isNotEmpty;

    if (!hasAnyCrop) {
      _applyAndReturnOriginals();
      return;
    }

    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            'Apply Changes',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Text(
            'Do you want to save the changes made to these images?',
            style: TextStyle(color: AppColors.black),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.onCancleBtn),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                'Confirm',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _processAndSaveChanges();
      }
    });
  }

  void _applyAndReturnOriginals() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CustomLoader()),
    );
    final originalFiles = await Future.wait(widget.assets.map((e) => e.file));
    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, originalFiles.whereType<File>().toList());
    }
  }

  void _onThumbnailTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _selectedAspectRatio =
            _cropAspectRatios[_currentIndex] ?? _aspectRatios.first;
        _selectedShape = _cropShapes[_currentIndex] ?? CropShape.rectangle;

        if (!_pendingCropRects.containsKey(_currentIndex)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initializeCropRect(),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _applyAspectRatio(),
          );
        }
      });
    }
  }

  void _applyAspectRatio() {
    setState(() {
      _cropAspectRatios[_currentIndex] = _selectedAspectRatio;
      if (!_pendingCropRects.containsKey(_currentIndex) ||
          _imageDisplaySize == null ||
          _imageDisplaySize!.isEmpty) {
        return;
      }

      final ratio = _selectedAspectRatio.value;
      if (ratio == null) return;

      Rect currentRect = _pendingCropRects[_currentIndex]!;
      double newWidth = currentRect.width;
      double newHeight = newWidth / ratio;

      if (newHeight > _imageDisplaySize!.height) {
        newHeight = _imageDisplaySize!.height;
        newWidth = newHeight * ratio;
      }
      if (newWidth > _imageDisplaySize!.width) {
        newWidth = _imageDisplaySize!.width;
        newHeight = newWidth / ratio;
      }

      newWidth = max(ResizableCropArea._minCropSize, newWidth);
      newHeight = max(ResizableCropArea._minCropSize, newHeight);

      _pendingCropRects[_currentIndex] = Rect.fromCenter(
        center: currentRect.center,
        width: newWidth,
        height: newHeight,
      );
    });
  }

  void _onShapeChanged(CropShape shape) {
    setState(() {
      _selectedShape = shape;
      _cropShapes[_currentIndex] = shape;

      if (shape == CropShape.circle) {
        final oneToOneRatio = _aspectRatios.firstWhere(
          (ratio) => ratio.label == '1:1',
          orElse: () => _aspectRatios.first,
        );
        _selectedAspectRatio = oneToOneRatio;
        _applyAspectRatio();
      } else {
        _selectedAspectRatio =
            _cropAspectRatios[_currentIndex] ?? _aspectRatios.first;
        _applyAspectRatio();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.white,
    elevation: 0,
    title: const Text(
      'Edit & Crop',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
    actions: [
      IconButton(
        icon: const Icon(Icons.done_all),
        onPressed: _showConfirmDialog,
      ),
    ],
  );

  Widget _buildBody() => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      _buildMainImageViewer(),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: _confirmCrop,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(AppColors.primary),
            foregroundColor: WidgetStatePropertyAll(AppColors.white),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.crop, color: AppColors.white),
              SizedBox(width: 5),
              Text('Apply'),
            ],
          ),
        ),
      ),
      _buildEditingToolbar(),
      _buildThumbnailList(),
    ],
  );

  Widget _buildMainImageViewer() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          key: _imageContainerKey,
          alignment: Alignment.center,
          child: FutureBuilder<Uint8List?>(
            future: _getImagePreview(_currentIndex),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CustomLoader());
              }
              final imageData = snapshot.data!;

              if (_imageDisplaySize == null || _imageDisplaySize!.isEmpty) {
                return Image.memory(imageData, fit: BoxFit.contain);
              }

              return RepaintBoundary(
                child: ResizableCropArea(
                  imageData: imageData,
                  initialRect: _pendingCropRects[_currentIndex],
                  onRectChanged: _updatePendingCropRect,
                  aspectRatio: _selectedAspectRatio,
                  shape: _selectedShape,
                  parentSize: _imageDisplaySize,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditingToolbar() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
        child: Container(
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolbarButton(
                      icon: Icons.refresh,
                      label: "Reset",
                      onPressed: _resetCrop,
                    ),
                    _buildShapeButton(
                      icon: Icons.rectangle_outlined,
                      shape: CropShape.rectangle,
                    ),
                    _buildShapeButton(
                      icon: Icons.circle_outlined,
                      shape: CropShape.circle,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppColors.white.withOpacity(0.5)),
              if (_selectedShape == CropShape.rectangle)
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _aspectRatios.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final ratio = _aspectRatios[index];
                      final isSelected =
                          ratio.label == _selectedAspectRatio.label;
                      return GestureDetector(
                        onTap: () {
                          _selectedAspectRatio = ratio;
                          _applyAspectRatio();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                ratio.icon,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : AppColors.white.withOpacity(0.7),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                ratio.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      isSelected
                                          ? AppColors.white
                                          : AppColors.white.withOpacity(0.7),
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) => InkWell(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(8),
    highlightColor: AppColors.primary.withOpacity(0.3),
    splashColor: AppColors.primary.withOpacity(0.5),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.secondary, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
        ],
      ),
    ),
  );

  Widget _buildShapeButton({required IconData icon, required CropShape shape}) {
    final isSelected = _selectedShape == shape;
    return InkWell(
      onTap: () => _onShapeChanged(shape),
      borderRadius: BorderRadius.circular(8),
      highlightColor: AppColors.primary.withOpacity(0.3),
      splashColor: AppColors.primary.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color:
                  isSelected
                      ? AppColors.white
                      : AppColors.white.withOpacity(0.3),
            ),
            const SizedBox(height: 4),
            Text(
              shape.toString().split('.').last.capitalize(),
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? AppColors.white
                        : AppColors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnailList() => Container(
    height: 90,
    padding: const EdgeInsets.symmetric(vertical: 10),
    color: AppColors.black.withOpacity(0.5),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.assets.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final isSelected = index == _currentIndex;
        final isEdited = _croppedRects.containsKey(index);
        final hasChanges = isEdited;

        return GestureDetector(
          onTap: () => _onThumbnailTapped(index),
          child: AspectRatio(
            aspectRatio: 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  width: 2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FutureBuilder<Uint8List?>(
                      future: widget.assets[index].thumbnailDataWithSize(
                        const ThumbnailSize(200, 200),
                      ),
                      builder:
                          (context, snapshot) =>
                              snapshot.hasData
                                  ? Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(color: AppColors.secondary),
                    ),
                    if (hasChanges)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 12,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

extension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

enum _DragHandle { none, center, topLeft, topRight, bottomLeft, bottomRight }

class ResizableCropArea extends StatefulWidget {
  final Uint8List imageData;
  final Rect? initialRect;
  final ValueChanged<Rect> onRectChanged;
  final CropAspectRatio aspectRatio;
  final CropShape shape;
  final Size? parentSize;

  const ResizableCropArea({
    super.key,
    required this.imageData,
    this.initialRect,
    required this.onRectChanged,
    required this.aspectRatio,
    required this.shape,
    this.parentSize,
  });

  static const double _minCropSize = 50.0;

  @override
  State<ResizableCropArea> createState() => _ResizableCropAreaState();
}

class _ResizableCropAreaState extends State<ResizableCropArea> {
  Rect? _rect;
  _DragHandle _activeHandle = _DragHandle.none;

  Rect? _rectOnScaleStart;
  Offset? _focalPointOnScaleStart;

  static const double _handleTouchSize = 32.0;

  @override
  void initState() {
    super.initState();
    _rect = widget.initialRect;
  }

  @override
  void didUpdateWidget(covariant ResizableCropArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialRect != oldWidget.initialRect &&
        _activeHandle == _DragHandle.none &&
        _rectOnScaleStart == null) {
      _rect = widget.initialRect;
    }
  }

  _DragHandle _getHandleForPosition(Offset position) {
    if (_rect == null) return _DragHandle.none;

    final handleRects = {
      _DragHandle.topLeft: Rect.fromCenter(
        center: _rect!.topLeft,
        width: _handleTouchSize,
        height: _handleTouchSize,
      ),
      _DragHandle.topRight: Rect.fromCenter(
        center: _rect!.topRight,
        width: _handleTouchSize,
        height: _handleTouchSize,
      ),
      _DragHandle.bottomLeft: Rect.fromCenter(
        center: _rect!.bottomLeft,
        width: _handleTouchSize,
        height: _handleTouchSize,
      ),
      _DragHandle.bottomRight: Rect.fromCenter(
        center: _rect!.bottomRight,
        width: _handleTouchSize,
        height: _handleTouchSize,
      ),
    };

    for (final entry in handleRects.entries) {
      if (entry.value.contains(position)) return entry.key;
    }

    if (_rect!.contains(position)) return _DragHandle.center;
    return _DragHandle.none;
  }

  void _onScaleStart(ScaleStartDetails details) {
    _rectOnScaleStart = _rect;
    _focalPointOnScaleStart = details.focalPoint;

    if (details.pointerCount == 1) {
      _activeHandle = _getHandleForPosition(details.localFocalPoint);
    } else {
      _activeHandle = _DragHandle.none;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_rectOnScaleStart == null ||
        widget.parentSize == null ||
        widget.parentSize!.isEmpty) {
      debugPrint(
        "Warning: parentSize or initial rect not set or empty during scale update.",
      );
      return;
    }

    Rect newRect = _rectOnScaleStart!;

    Offset translationDelta = details.focalPoint - _focalPointOnScaleStart!;

    if (details.pointerCount == 1 && _activeHandle != _DragHandle.none) {
      if (_activeHandle == _DragHandle.center) {
        newRect = newRect.translate(translationDelta.dx, translationDelta.dy);
      } else {
        Offset newCorner;
        Offset oppositeCorner;

        switch (_activeHandle) {
          case _DragHandle.topLeft:
            newCorner = _rectOnScaleStart!.topLeft + translationDelta;
            oppositeCorner = _rectOnScaleStart!.bottomRight;
            break;
          case _DragHandle.topRight:
            newCorner = _rectOnScaleStart!.topRight + translationDelta;
            oppositeCorner = _rectOnScaleStart!.bottomLeft;
            break;
          case _DragHandle.bottomLeft:
            newCorner = _rectOnScaleStart!.bottomLeft + translationDelta;
            oppositeCorner = _rectOnScaleStart!.topRight;
            break;
          case _DragHandle.bottomRight:
            newCorner = _rectOnScaleStart!.bottomRight + translationDelta;
            oppositeCorner = _rectOnScaleStart!.topLeft;
            break;
          default:
            return;
        }

        newRect = Rect.fromPoints(newCorner, oppositeCorner).normalize();

        final ratio = widget.aspectRatio.value;
        if (ratio != null) {
          double currentWidth = newRect.width;
          double currentHeight = newRect.height;

          double targetWidth;
          double targetHeight;

          if (currentWidth / currentHeight > ratio) {
            targetWidth = currentHeight * ratio;
            targetHeight = currentHeight;
          } else {
            targetHeight = currentWidth / ratio;
            targetWidth = currentWidth;
          }

          targetWidth = max(ResizableCropArea._minCropSize, targetWidth);
          targetHeight = max(ResizableCropArea._minCropSize, targetHeight);

          if (_activeHandle == _DragHandle.topLeft) {
            newRect = Rect.fromLTWH(
              oppositeCorner.dx - targetWidth,
              oppositeCorner.dy - targetHeight,
              targetWidth,
              targetHeight,
            );
          } else if (_activeHandle == _DragHandle.topRight) {
            newRect = Rect.fromLTWH(
              oppositeCorner.dx,
              oppositeCorner.dy - targetHeight,
              targetWidth,
              targetHeight,
            );
          } else if (_activeHandle == _DragHandle.bottomLeft) {
            newRect = Rect.fromLTWH(
              oppositeCorner.dx - targetWidth,
              oppositeCorner.dy,
              targetWidth,
              targetHeight,
            );
          } else {
            newRect = Rect.fromLTWH(
              oppositeCorner.dx,
              oppositeCorner.dy,
              targetWidth,
              targetHeight,
            );
          }
        }
      }
    } else if (details.pointerCount > 1) {
      final Offset translation = translationDelta;

      double newWidth = _rectOnScaleStart!.width * details.scale;
      double newHeight = _rectOnScaleStart!.height * details.scale;

      if (widget.aspectRatio.value != null) {
        final ratio = widget.aspectRatio.value!;
        if (newWidth / newHeight > ratio) {
          newWidth = newHeight * ratio;
        } else {
          newHeight = newWidth / ratio;
        }
      }

      newWidth = newWidth.clamp(
        ResizableCropArea._minCropSize,
        widget.parentSize!.width,
      );
      newHeight = newHeight.clamp(
        ResizableCropArea._minCropSize,
        widget.parentSize!.height,
      );

      final newCenter = _rectOnScaleStart!.center + translation;

      newRect = Rect.fromCenter(
        center: newCenter,
        width: newWidth,
        height: newHeight,
      );
    } else {
      return;
    }

    double finalWidth = newRect.width.clamp(
      ResizableCropArea._minCropSize,
      widget.parentSize!.width,
    );
    double finalHeight = newRect.height.clamp(
      ResizableCropArea._minCropSize,
      widget.parentSize!.height,
    );

    double left = newRect.left.clamp(
      0.0,
      widget.parentSize!.width - finalWidth,
    );
    double top = newRect.top.clamp(
      0.0,
      widget.parentSize!.height - finalHeight,
    );

    newRect = Rect.fromLTWH(left, top, finalWidth, finalHeight);

    setState(() {
      _rect = newRect;
      widget.onRectChanged(_rect!);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _activeHandle = _DragHandle.none;
    _rectOnScaleStart = null;
    _focalPointOnScaleStart = null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.parentSize == null ||
        widget.parentSize!.isEmpty ||
        _rect == null) {
      return Image.memory(widget.imageData, fit: BoxFit.contain);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(widget.imageData, fit: BoxFit.contain),
        Positioned.fill(
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: CustomPaint(
              painter: _CropRectPainter(rect: _rect!, shape: widget.shape),
            ),
          ),
        ),
      ],
    );
  }
}

class _CropRectPainter extends CustomPainter {
  final Rect rect;
  final CropShape shape;
  static const double _handleSize = 8.0;

  final Paint _backgroundPaint = Paint()..color = Colors.black.withOpacity(0.7);
  final Paint _borderPaint =
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
  final Paint _handlePaint = Paint()..color = AppColors.white;

  _CropRectPainter({required this.rect, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final Path clipPath = Path();
    if (shape == CropShape.circle) {
      clipPath.addOval(rect);
    } else {
      clipPath.addRect(rect);
    }

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        clipPath,
      ),
      _backgroundPaint,
    );
    canvas.drawPath(clipPath, _borderPaint);

    if (shape == CropShape.rectangle) {
      canvas.drawCircle(rect.topLeft, _handleSize / 2, _handlePaint);
      canvas.drawCircle(rect.topRight, _handleSize / 2, _handlePaint);
      canvas.drawCircle(rect.bottomLeft, _handleSize / 2, _handlePaint);
      canvas.drawCircle(rect.bottomRight, _handleSize / 2, _handlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CropRectPainter oldDelegate) =>
      oldDelegate.rect != rect || oldDelegate.shape != shape;
}
