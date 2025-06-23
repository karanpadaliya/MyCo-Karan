import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myco_karan/karan_file/custom_loader/custom_loader.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../themes_colors/colors.dart';

class EditorTheme {}

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

  final Map<int, Rect> _cropRects = {};
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
    if (size == null) return;
    setState(() {
      _cropRects[_currentIndex] = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: size.width * 0.8,
        height: size.height * 0.8,
      );
      _applyAspectRatio();
    });
  }

  void _resetCrop() {
    setState(() {
      _cropRects.remove(_currentIndex);
      _initializeCropRect();
    });
  }

  Future<Uint8List?> _getImagePreview(int index) async {
    return widget.assets[index].thumbnailDataWithSize(
      const ThumbnailSize(1080, 1080),
    );
  }

  void _updateCropRect(Rect newRect) {
    setState(() {
      _cropRects[_currentIndex] = newRect;
    });
  }

  Future<void> _processAndSaveChanges() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CustomLoader()),
    );

    final List<File> finalFiles = [];

    for (int i = 0; i < widget.assets.length; i++) {
      final originalFile = await widget.assets[i].file;
      if (originalFile == null) continue;

      if (_cropRects.containsKey(i)) {
        try {
          final cropRect = _cropRects[i]!;
          final cropShape = _cropShapes[i] ?? CropShape.rectangle;

          final bytes = await originalFile.readAsBytes();
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          final originalImage = frame.image;
          final imageSize = Size(
            originalImage.width.toDouble(),
            originalImage.height.toDouble(),
          );

          final previewSize = _imageDisplaySize!;
          final fittedSizes = applyBoxFit(
            BoxFit.contain,
            imageSize,
            previewSize,
          );
          final destinationRect = Alignment.center.inscribe(
            fittedSizes.destination,
            Rect.fromLTWH(0, 0, previewSize.width, previewSize.height),
          );
          final scale = destinationRect.width / imageSize.width;
          final offset = destinationRect.topLeft;

          final cropRectInImageCoords = Rect.fromLTWH(
            (cropRect.left - offset.dx) / scale,
            (cropRect.top - offset.dy) / scale,
            cropRect.width / scale,
            cropRect.height / scale,
          );

          final recorder = ui.PictureRecorder();
          final canvas = Canvas(recorder);
          final paint = Paint()..isAntiAlias = true;

          final outputRect = Rect.fromLTWH(
            0,
            0,
            cropRectInImageCoords.width,
            cropRectInImageCoords.height,
          );

          if (cropShape == CropShape.circle) {
            canvas.clipPath(Path()..addOval(outputRect));
          }

          canvas.drawImageRect(
            originalImage,
            cropRectInImageCoords,
            outputRect,
            paint,
          );

          final picture = recorder.endRecording();
          final croppedImage = await picture.toImage(
            outputRect.width.toInt(),
            outputRect.height.toInt(),
          );
          final byteData = await croppedImage.toByteData(
            format: ui.ImageByteFormat.png,
          );

          if (byteData == null) continue;

          final tempDir = Directory.systemTemp;
          final file = File(
            '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
          );
          await file.writeAsBytes(byteData.buffer.asUint8List());
          finalFiles.add(file);
        } catch (e) {
          debugPrint('Error cropping image at index $i: $e');
          finalFiles.add(originalFile);
        }
      } else {
        finalFiles.add(originalFile);
      }
    }

    if (mounted) {
      Navigator.pop(context);
      Navigator.pop(context, finalFiles);
    }
  }

  void _showConfirmDialog() {
    if (_cropRects.isEmpty) {
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

        if (!_cropRects.containsKey(_currentIndex)) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initializeCropRect(),
          );
        }
      });
    }
  }

  void _applyAspectRatio() {
    setState(() {
      _cropAspectRatios[_currentIndex] = _selectedAspectRatio;
      if (!_cropRects.containsKey(_currentIndex) || _imageDisplaySize == null) {
        return;
      }

      final ratio = _selectedAspectRatio.value;
      if (ratio == null) return;

      Rect currentRect = _cropRects[_currentIndex]!;
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

      _cropRects[_currentIndex] = Rect.fromCenter(
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
      IconButton(icon: const Icon(Icons.check), onPressed: _showConfirmDialog),
    ],
  );

  Widget _buildBody() => Column(
    children: [
      _buildMainImageViewer(),
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

              return RepaintBoundary(
                child: ResizableCropArea(
                  imageData: imageData,
                  initialRect: _cropRects[_currentIndex],
                  onRectChanged: _updateCropRect,
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
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
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
              Divider(height: 1, color: AppColors.white.withValues(alpha: 0.5)),
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
                                      : AppColors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ratio.label,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? AppColors.white
                                        : AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),

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
    highlightColor: AppColors.primary.withValues(alpha: 0.3),

    splashColor: AppColors.primary.withValues(alpha: 0.5),

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
      highlightColor: AppColors.primary.withValues(alpha: 0.3),

      splashColor: AppColors.primary.withValues(alpha: 0.5),

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
                      : AppColors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 4),
            Text(
              shape.toString().split('.').last.capitalize(),
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.3),
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
    color: AppColors.black.withValues(alpha: 0.5),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.assets.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final isSelected = index == _currentIndex;
        final isEdited = _cropRects.containsKey(index);
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
                    if (isEdited)
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

  @override
  State<ResizableCropArea> createState() => _ResizableCropAreaState();
}

class _ResizableCropAreaState extends State<ResizableCropArea> {
  Rect? _rect;
  _DragHandle _activeHandle = _DragHandle.none;

  static const double _handleTouchSize = 32.0;
  static const double _minCropSize = 50.0;

  @override
  void initState() {
    super.initState();
    _rect = widget.initialRect;
  }

  @override
  void didUpdateWidget(covariant ResizableCropArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRect != oldWidget.initialRect &&
        _activeHandle == _DragHandle.none) {
      setState(() {
        _rect = widget.initialRect;
      });
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

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == _DragHandle.none ||
        _rect == null ||
        widget.parentSize == null) {
      return;
    }

    Rect newRect = _rect!;
    final delta = details.delta;

    switch (_activeHandle) {
      case _DragHandle.center:
        newRect = newRect.translate(delta.dx, delta.dy);
        break;
      case _DragHandle.topLeft:
        newRect = Rect.fromPoints(newRect.bottomRight, newRect.topLeft + delta);
        break;
      case _DragHandle.topRight:
        newRect = Rect.fromPoints(newRect.bottomLeft, newRect.topRight + delta);
        break;
      case _DragHandle.bottomLeft:
        newRect = Rect.fromPoints(newRect.topRight, newRect.bottomLeft + delta);
        break;
      case _DragHandle.bottomRight:
        newRect = Rect.fromPoints(newRect.topLeft, newRect.bottomRight + delta);
        break;
      default:
        break;
    }

    newRect = Rect.fromPoints(newRect.topLeft, newRect.bottomRight);

    final ratio = widget.aspectRatio.value;
    if (ratio != null && _activeHandle != _DragHandle.center) {
      double newWidth = newRect.width;
      double newHeight = newWidth / ratio;
      switch (_activeHandle) {
        case _DragHandle.topLeft:
          newRect = Rect.fromLTWH(
            newRect.right - newWidth,
            newRect.bottom - newHeight,
            newWidth,
            newHeight,
          );
          break;
        case _DragHandle.bottomRight:
          newRect = Rect.fromLTWH(
            newRect.left,
            newRect.top,
            newWidth,
            newHeight,
          );
          break;
        case _DragHandle.topRight:
          newRect = Rect.fromLTWH(
            newRect.left,
            newRect.bottom - newHeight,
            newWidth,
            newHeight,
          );
          break;
        case _DragHandle.bottomLeft:
          newRect = Rect.fromLTWH(
            newRect.right - newWidth,
            newRect.top,
            newRect.width,
            newHeight,
          );
          break;
        default:
          break;
      }
    }

    double left = newRect.left.clamp(0.0, widget.parentSize!.width);
    double top = newRect.top.clamp(0.0, widget.parentSize!.height);
    double right = newRect.right.clamp(0.0, widget.parentSize!.width);
    double bottom = newRect.bottom.clamp(0.0, widget.parentSize!.height);

    if (right - left < _minCropSize) right = left + _minCropSize;
    if (bottom - top < _minCropSize) bottom = top + _minCropSize;

    final constrainedRect = Rect.fromLTRB(
      left.clamp(0.0, widget.parentSize!.width),
      top.clamp(0.0, widget.parentSize!.height),
      right.clamp(0.0, widget.parentSize!.width),
      bottom.clamp(0.0, widget.parentSize!.height),
    );

    setState(() {
      _rect = constrainedRect;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_rect != null) {
      widget.onRectChanged(_rect!);
    }
    setState(() {
      _activeHandle = _DragHandle.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_activeHandle == _DragHandle.none) {
      _rect = widget.initialRect;
    }

    if (widget.parentSize == null || _rect == null) {
      return Image.memory(widget.imageData, fit: BoxFit.contain);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.memory(widget.imageData, fit: BoxFit.contain),
        Positioned.fill(
          child: GestureDetector(
            onPanStart:
                (details) => setState(
                  () =>
                      _activeHandle = _getHandleForPosition(
                        details.localPosition,
                      ),
                ),
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
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

  final Paint _backgroundPaint =
      Paint()..color = Colors.black.withValues(alpha: 0.7);
  final Paint _borderPaint =
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
  final Paint _handlePaint = Paint()..color = AppColors.white;

  _CropRectPainter({required this.rect, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final clipPath = Path();
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
