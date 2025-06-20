import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:myco_karan/karan_file/custom_loader/custom_loader.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:math' as math;
import '../../themes_colors/colors.dart';

class EditorTheme {
  static const Color background = Color(0xFF121822);
  static const Color surface = Color(0xFF1A2433);
  static const Color onSurface = Color(0xFFEAEBEE);
}

enum CropShape { rectangle, circle }

class CropAspectRatio {
  final String label;
  final double? value;

  const CropAspectRatio({required this.label, this.value});
}

class CustomCropImageScreen extends StatefulWidget {
  final List<AssetEntity> assets;

  const CustomCropImageScreen({super.key, required this.assets});

  @override
  State<CustomCropImageScreen> createState() => _CustomCropImageScreenState();
}

class _CustomCropImageScreenState extends State<CustomCropImageScreen> {
  final List<File?> _croppedFiles = [];
  int _currentIndex = 0;
  Rect? _cropRect;

  final GlobalKey _imageContainerKey = GlobalKey();

  // State for new crop options
  CropShape _selectedShape = CropShape.rectangle;
  late CropAspectRatio _selectedAspectRatio;

  // Performance: Make aspect ratios a constant list
  final List<CropAspectRatio> _aspectRatios = const [
    CropAspectRatio(label: 'Free', value: null),
    CropAspectRatio(label: '1:1', value: 1.0),
    CropAspectRatio(label: '4:3', value: 4.0 / 3.0),
    CropAspectRatio(label: '3:2', value: 3.0 / 2.0),
    CropAspectRatio(label: '16:9', value: 16.0 / 9.0),
    CropAspectRatio(label: '9:16', value: 9.0 / 16.0),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCropRect();
    _selectedAspectRatio = _aspectRatios.first;
    _croppedFiles.addAll(List.generate(widget.assets.length, (_) => null));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCropRect());
  }

  // Performance: Getter for image display size, cached if possible
  Size? get _imageDisplaySize {
    // Only look up if null, otherwise use cached value (if stateful widget's renderbox doesn't change)
    final RenderBox? renderBox =
    _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size;
  }

  void _initializeCropRect() {
    final size = _imageDisplaySize;
    if (size == null) return;
    setState(() {
      // Ensure the initial crop rect is within bounds and has a minimum size
      double initialWidth = size.width * 0.7;
      double initialHeight = size.height * 0.7;

      if (initialWidth < 50) initialWidth = 50; // Minimum size
      if (initialHeight < 50) initialHeight = 50; // Minimum size

      _cropRect = Rect.fromCenter(
        center: size.center(Offset.zero),
        width: initialWidth,
        height: initialHeight,
      );
      _applyAspectRatio(_selectedAspectRatio);
    });
  }

  void _resetCrop() {
    setState(() {
      _croppedFiles[_currentIndex] != null;
      _initializeCropRect();
    });
  }

  Future<File?> _getImageFile(int index) async {
    if (_croppedFiles.length > index && _croppedFiles[index] != null) {
      return _croppedFiles[index];
    }
    return await widget.assets[index].file;
  }

  void _updateCropRect(Rect newRect) {
    setState(() {
      _cropRect = newRect;
    });
  }

  Future<void> _cropManually() async {
    if (_cropRect == null ||
        _imageDisplaySize == null ||
        _imageDisplaySize!.isEmpty) return;
    final originalFile = await widget.assets[_currentIndex].file;
    if (originalFile == null) return;

    if (!mounted) return; // Check mounted before showing dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CustomLoader()),
    );

    try {
      final bytes = await originalFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      final imageFileRect = Rect.fromLTWH(
        0,
        0,
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      );

      final fittedSizes = applyBoxFit(
        BoxFit.contain,
        imageFileRect.size,
        _imageDisplaySize!,
      );
      final destinationRect = Alignment.center.inscribe(
        fittedSizes.destination,
        Rect.fromLTWH(
          0,
          0,
          _imageDisplaySize!.width,
          _imageDisplaySize!.height,
        ),
      );

      final scale = destinationRect.width / imageFileRect.width;
      final offset = destinationRect.topLeft;

      final cropRectInImageCoords = Rect.fromLTWH(
        (_cropRect!.left - offset.dx) / scale,
        (_cropRect!.top - offset.dy) / scale,
        _cropRect!.width / scale,
        _cropRect!.height / scale,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final paint = Paint();

      final outputRect = Rect.fromLTWH(
        0,
        0,
        cropRectInImageCoords.width,
        cropRectInImageCoords.height,
      );

      if (_selectedShape == CropShape.circle) {
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
        format:
        ui.ImageByteFormat.png, // Performance: PNG is lossless but larger; consider JPEG for smaller files.
      );
      if (byteData == null) throw Exception("Failed to encode cropped image.");
      final pngBytes = byteData.buffer.asUint8List();

      final tempDir = Directory.systemTemp;
      final file = File(
        '${tempDir.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      setState(() {
        _croppedFiles[_currentIndex] = file;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error cropping image: $e')));
      }
    } finally {
      if (mounted) Navigator.pop(context);
    }
  }

  // Original method to apply crops and return files
  void _applyAndReturn() {
    // Performance: Future.wait is good for concurrent operations.
    Future.wait(
      _croppedFiles.asMap().entries.map((entry) async {
        int idx = entry.key;
        File? file = entry.value;
        return file ?? await widget.assets[idx].file;
      }),
    ).then((resultFiles) {
      final validFiles = resultFiles.whereType<File>().toList();
      if (mounted) Navigator.pop(context, validFiles);
    });
  }

  // New method to show the confirmation dialog
  void _showConfirmDialog() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: EditorTheme.surface,
          title: const Text(
            'Confirm Crop & Save?',
            style: TextStyle(color: EditorTheme.onSurface),
          ),
          content: const Text(
            'Are you sure you want to apply these changes and save the cropped images?',
            style: TextStyle(color: EditorTheme.onSurface),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Dismiss dialog, do not proceed
              },
              child: const Text('Cancel', style: TextStyle(color: AppColors.primary)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Dismiss dialog, proceed
              },
              child: const Text('Confirm', style: TextStyle(color: AppColors.secondPrimary)),
            ),
          ],
        );
      },
    ).then((confirmed) {
      if (confirmed == true) {
        _applyAndReturn(); // Only proceed if confirmed
      }
    });
  }


  void _onThumbnailTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
        _cropRect = null; // Clear cropRect to re-initialize for new image
      });
      // Performance: PostFrameCallback is the correct way to ensure layout before calculating rect.
      WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initializeCropRect(),
      );
    }
  }

  void _applyAspectRatio(CropAspectRatio aspectRatio) {
    setState(() {
      _selectedAspectRatio = aspectRatio;
      if (_cropRect == null || _imageDisplaySize == null) return;

      final ratio = aspectRatio.value;
      if (ratio == null) return; // Freeform, no change needed

      Rect currentRect = _cropRect!;
      double newWidth = currentRect.width;
      double newHeight = newWidth / ratio;

      // Adjust to fit within image display size
      if (newHeight > _imageDisplaySize!.height) {
        newHeight = _imageDisplaySize!.height;
        newWidth = newHeight * ratio;
      }
      if (newWidth > _imageDisplaySize!.width) {
        newWidth = _imageDisplaySize!.width;
        newHeight = newWidth / ratio;
      }

      _cropRect = Rect.fromCenter(
        center: currentRect.center,
        width: newWidth,
        height: newHeight,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditorTheme.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: EditorTheme.surface,
    elevation: 0,
    iconTheme: const IconThemeData(color: EditorTheme.onSurface),
    title: const Text(
      'Edit & Crop',
      style: TextStyle(
        color: EditorTheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: true,
    actions: [
      // Changed onPressed to call _showConfirmDialog
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
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<File?>(
          future: _getImageFile(_currentIndex),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CustomLoader());
            }
            final file = snapshot.data!;

            return Container(
              key: _imageContainerKey,
              alignment: Alignment.center,
              child: ResizableCropArea(
                imageFile: file,
                initialRect: _cropRect,
                onRectChanged: _updateCropRect,
                aspectRatio: _selectedAspectRatio,
                shape: _selectedShape,
                parentSize: _imageDisplaySize,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEditingToolbar() {
    return Container(
      color: EditorTheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildToolbarButton(
                icon: Icons.crop,
                label: "Crop",
                onPressed: _cropManually,
              ),
              _buildToolbarButton(
                icon: Icons.refresh,
                label: "Reset",
                onPressed: _resetCrop,
              ),
              // Performance: Use const for widget creation where possible
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
          const Divider(
            height: 1,
            color: EditorTheme.background,
          ), // Performance: const
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _aspectRatios.length,
              itemBuilder: (context, index) {
                final ratio = _aspectRatios[index];
                final isSelected = ratio.label == _selectedAspectRatio.label;
                return GestureDetector(
                  onTap: () => _applyAspectRatio(ratio),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // Performance: const
                    alignment: Alignment.center,
                    child: Text(
                      ratio.label,
                      style: TextStyle(
                        color:
                        isSelected
                            ? AppColors.secondPrimary
                            : EditorTheme.onSurface,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) => TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: EditorTheme.onSurface, size: 20),
    // Performance: Color and size are fixed, could be const if not dynamic
    label: Text(
      label,
      style: TextStyle(color: EditorTheme.onSurface),
    ), // Performance: const
  );

  Widget _buildShapeButton({required IconData icon, required CropShape shape}) {
    final isSelected = _selectedShape == shape;
    return IconButton(
      onPressed: () => setState(() => _selectedShape = shape),
      icon: Icon(
        icon,
        color: isSelected ? AppColors.secondPrimary : EditorTheme.onSurface,
      ),
    );
  }

  Widget _buildThumbnailList() => Container(
    height: 90,
    padding: const EdgeInsets.symmetric(vertical: 10), // Performance: const
    color: EditorTheme.surface.withOpacity(0.5),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // Performance: const
      itemCount: widget.assets.length,
      separatorBuilder: (_, __) => const SizedBox(width: 12),
      // Performance: const
      itemBuilder: (context, index) {
        final isSelected = index == _currentIndex;
        final isCropped = _croppedFiles[index] != null;
        return GestureDetector(
          onTap: () => _onThumbnailTapped(index),
          child: AspectRatio(
            aspectRatio: 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              // Performance: const
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Performance: const
                border: Border.all(
                  color:
                  isSelected ? AppColors.secondPrimary : Colors.transparent,
                  width: 3,
                ),
                boxShadow:
                isSelected
                    ? [
                  BoxShadow(
                    color: AppColors.secondPrimary.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                // Performance: const
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    FutureBuilder<Uint8List?>(
                      // Performance: PhotoManager thumbnail generation is efficient.
                      future: widget.assets[index].thumbnailDataWithSize(
                        const ThumbnailSize(200, 200), // Performance: const
                      ),
                      builder:
                          (context, snapshot) =>
                      snapshot.hasData
                          ? Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      )
                          : Container(color: EditorTheme.surface),
                    ),
                    if (isCropped)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(
                            2,
                          ), // Performance: const
                          decoration: const BoxDecoration(
                            color: AppColors.secondPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: EditorTheme.background,
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

  Widget _buildBottomBar() =>
      const SizedBox.shrink(); // Moved controls to toolbar
}

// --- WIDGET FOR RESIZABLE CROP AREA ---

enum _DragHandle { none, center, topLeft, topRight, bottomLeft, bottomRight }

class ResizableCropArea extends StatefulWidget {
  final File imageFile;
  final Rect? initialRect;
  final ValueChanged<Rect> onRectChanged;
  final CropAspectRatio aspectRatio;
  final CropShape shape;
  final Size? parentSize; // Add parentSize for constraining

  const ResizableCropArea({
    super.key,
    required this.imageFile,
    this.initialRect,
    required this.onRectChanged,
    required this.aspectRatio,
    required this.shape,
    this.parentSize, // Make sure to pass this from parent
  });

  @override
  State<ResizableCropArea> createState() => _ResizableCropAreaState();
}

class _ResizableCropAreaState extends State<ResizableCropArea> {
  Rect? _rect;
  _DragHandle _activeHandle = _DragHandle.none;

  // Performance: Make constants final static
  static const double _handleSize = 24.0; // Increased handle touch area
  static const double _minCropSize = 50.0; // Minimum size for crop rect

  @override
  void initState() {
    super.initState();
    _rect = widget.initialRect;
  }

  @override
  void didUpdateWidget(covariant ResizableCropArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Performance: Only update _rect from initialRect if no active drag AND initialRect has actually changed.
    // This prevents unnecessary _rect updates during a drag if the parent rebuilds for another reason.
    if (widget.initialRect != oldWidget.initialRect &&
        _activeHandle == _DragHandle.none) {
      _rect = widget.initialRect;
    }
    // Performance: If aspect ratio or shape changes during a drag, ensure a valid rect.
    // This is handled by _applyAspectRatio in the parent, which will then trigger _updateCropRect.
  }

  // Helper to get the correct handle for a given position
  _DragHandle _getHandleForPosition(Offset position) {
    if (_rect == null) return _DragHandle.none;

    // Check corner handles first (larger touch area)
    // Performance: These Rects are created on every tap/panStart, consider caching if many handles.
    // For 4 handles, it's negligible.
    final handleRects = {
      _DragHandle.topLeft: Rect.fromLTWH(
        _rect!.topLeft.dx - _handleSize / 2,
        _rect!.topLeft.dy - _handleSize / 2,
        _handleSize,
        _handleSize,
      ),
      _DragHandle.topRight: Rect.fromLTWH(
        _rect!.topRight.dx - _handleSize / 2,
        _rect!.topRight.dy - _handleSize / 2,
        _handleSize,
        _handleSize,
      ),
      _DragHandle.bottomLeft: Rect.fromLTWH(
        _rect!.bottomLeft.dx - _handleSize / 2,
        _rect!.bottomLeft.dy - _handleSize / 2,
        _handleSize,
        _handleSize,
      ),
      _DragHandle.bottomRight: Rect.fromLTWH(
        _rect!.bottomRight.dx - _handleSize / 2,
        _rect!.bottomRight.dy - _handleSize / 2,
        _handleSize,
        _handleSize,
      ),
    };

    for (final entry in handleRects.entries) {
      if (entry.value.contains(position)) return entry.key;
    }

    // Check if dragging the center of the rectangle
    if (_rect!.contains(position)) return _DragHandle.center;
    return _DragHandle.none;
  }

  // This method is critical for performance during drag.
  // It should update _rect directly and then call onRectChanged.
  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeHandle == _DragHandle.none ||
        _rect == null ||
        widget.parentSize == null) return;

    final double ratio = widget.aspectRatio.value ?? 0.0; // 0.0 for freeform
    Rect newRect = _rect!; // Start with current rect

    switch (_activeHandle) {
      case _DragHandle.center:
        newRect = newRect.translate(details.delta.dx, details.delta.dy);
        break;
      case _DragHandle.topLeft:
        newRect = Rect.fromLTRB(
          newRect.left + details.delta.dx,
          newRect.top + details.delta.dy,
          newRect.right,
          newRect.bottom,
        );
        break;
      case _DragHandle.topRight:
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top + details.delta.dy,
          newRect.right + details.delta.dx,
          newRect.bottom,
        );
        break;
      case _DragHandle.bottomLeft:
        newRect = Rect.fromLTRB(
          newRect.left + details.delta.dx,
          newRect.top,
          newRect.right,
          newRect.bottom + details.delta.dy,
        );
        break;
      case _DragHandle.bottomRight:
        newRect = Rect.fromLTRB(
          newRect.left,
          newRect.top,
          newRect.right + details.delta.dx,
          newRect.bottom + details.delta.dy,
        );
        break;
      case _DragHandle.none:
        break;
    }

    // Apply aspect ratio for resizing handles
    // Performance: Only apply aspect ratio if it's a resizing handle and ratio is fixed.
    if (ratio != 0.0 && _activeHandle != _DragHandle.center) {
      double calculatedWidth = newRect.width;
      double calculatedHeight = newRect.height;

      // Adjust based on aspect ratio
      switch (_activeHandle) {
        case _DragHandle.topLeft:
        case _DragHandle.bottomRight:
        // For diagonal handles, adjust both width/height based on the larger change.
          if (calculatedWidth.abs() / ratio > calculatedHeight.abs()) {
            calculatedHeight = calculatedWidth / ratio;
          } else {
            calculatedWidth = calculatedHeight * ratio;
          }
          break;
        case _DragHandle.topRight:
        case _DragHandle.bottomLeft:
        // Similar for other diagonal handles, ensure consistent aspect ratio.
          if (calculatedWidth.abs() / ratio > calculatedHeight.abs()) {
            calculatedHeight = calculatedWidth / ratio;
          } else {
            calculatedWidth = calculatedHeight * ratio;
          }
          break;
        default:
          break;
      }

      // Reconstruct newRect based on calculated dimensions and original corner
      switch (_activeHandle) {
        case _DragHandle.topLeft:
          newRect = Rect.fromLTWH(
            newRect.right - calculatedWidth,
            newRect.bottom - calculatedHeight,
            calculatedWidth,
            calculatedHeight,
          );
          break;
        case _DragHandle.topRight:
          newRect = Rect.fromLTWH(
            newRect.left,
            newRect.bottom - calculatedHeight,
            calculatedWidth,
            calculatedHeight,
          );
          break;
        case _DragHandle.bottomLeft:
          newRect = Rect.fromLTWH(
            newRect.right - calculatedWidth,
            newRect.top,
            calculatedWidth,
            calculatedHeight,
          );
          break;
        case _DragHandle.bottomRight:
          newRect = Rect.fromLTWH(
            newRect.left,
            newRect.top,
            calculatedWidth,
            calculatedHeight,
          );
          break;
        default:
          break;
      }
    }

    // Constrain to parent bounds *after* aspect ratio but *before* min size,
    // as min size might push it out of bounds if not careful.
    double left = math.max(0, newRect.left);
    double top = math.max(0, newRect.top);
    double right = math.min(widget.parentSize!.width, newRect.right);
    double bottom = math.min(widget.parentSize!.height, newRect.bottom);

    // Reconstruct newRect from constrained coordinates
    newRect = Rect.fromLTRB(left, top, right, bottom);

    // Ensure minimum size after constraining to parent bounds
    // This order is important: constrain first, then apply min size, then re-constrain if min size push it out.
    // A simpler way: if the current width/height is less than min, try to expand, but also clamp.
    if (newRect.width < _minCropSize) {
      newRect = Rect.fromLTWH(
        newRect.left,
        newRect.top,
        math.max(_minCropSize, newRect.width), // Ensure at least min size
        newRect.height,
      );
      // Re-clamp right if min size pushed it out
      if (newRect.right > widget.parentSize!.width) {
        newRect = Rect.fromLTRB(
          widget.parentSize!.width - newRect.width,
          newRect.top,
          widget.parentSize!.width,
          newRect.bottom,
        );
      }
    }
    if (newRect.height < _minCropSize) {
      newRect = Rect.fromLTWH(
        newRect.left,
        newRect.top,
        newRect.width,
        math.max(_minCropSize, newRect.height), // Ensure at least min size
      );
      // Re-clamp bottom if min size pushed it out
      if (newRect.bottom > widget.parentSize!.height) {
        newRect = Rect.fromLTRB(
          newRect.left,
          widget.parentSize!.height - newRect.height,
          newRect.right,
          widget.parentSize!.height,
        );
      }
    }

    // Ensure width and height are positive (can become negative if dragged past each other)
    // This typically happens if the user drags a handle across the opposite side.
    // Ensure rect is valid before updating state.
    if (newRect.width < 0 || newRect.height < 0) {
      return; // Or handle more gracefully, e.g., snap back to previous valid state
    }

    if (_rect != newRect) {
      setState(() {
        _rect = newRect;
      });
      widget.onRectChanged(newRect);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.parentSize == null || _rect == null) {
      // This can happen on initial build before _imageContainerKey has rendered
      // or if parentSize is not provided.
      return Image.file(widget.imageFile, fit: BoxFit.contain);
    }

    // Performance: Use a RepaintBoundary if image is complex or frequently changing
    // (though Image.file is often efficient).
    return Stack(
      fit: StackFit.expand,
      children: [
        // Display the image
        Image.file(widget.imageFile, fit: BoxFit.contain),

        // GestureDetector for crop area manipulation
        Positioned.fill(
          child: GestureDetector(
            onPanStart: (details) {
              setState(() {
                _activeHandle = _getHandleForPosition(details.localPosition);
              });
            },
            onPanUpdate: _onPanUpdate,
            onPanEnd: (_) {
              setState(() {
                _activeHandle = _DragHandle.none;
              });
            },
            // Performance: Pass the rect and shape to the painter directly
            child: CustomPaint(
              painter: _CropRectPainter(rect: _rect!, shape: widget.shape),
              child:
              Container(), // A dummy child to ensure CustomPaint takes up space
            ),
          ),
        ),
      ],
    );
  }
}

/// A custom painter to draw the crop overlay.
class _CropRectPainter extends CustomPainter {
  final Rect rect;
  final CropShape shape;
  static const double _handleSize = 8.0; // Smaller visual handles

  // Performance: Define paints once to avoid re-creation in every paint call
  // Use final for these as they are not expected to change after initialization.
  final Paint _backgroundPaint = Paint()..color = Colors.black.withOpacity(0.7);
  final Paint _borderPaint =
  Paint()
    ..color = AppColors.white.withOpacity(0.9)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
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

    if (shape == CropShape.circle) {
      canvas.drawOval(rect, _borderPaint);
    } else {
      canvas.drawRect(rect, _borderPaint);
    }

    // Draw handles only for rectangle shape
    if (shape == CropShape.rectangle) {
      canvas.drawCircle(rect.topLeft, _handleSize / 2, _handlePaint);
      canvas.drawCircle(rect.topRight, _handleSize / 2, _handlePaint);
      canvas.drawCircle(rect.bottomLeft, _handleSize / 2, _handlePaint);
      canvas.drawCircle(rect.bottomRight, _handleSize / 2, _handlePaint);
    }
  }

  // Performance: Crucial for custom painters. Only repaint if rect or shape changes.
  @override
  bool shouldRepaint(covariant _CropRectPainter oldDelegate) =>
      oldDelegate.rect != rect || oldDelegate.shape != shape;
}