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

  // Stores the crop rectangle for each image.
  final Map<int, Rect> _pendingCropRects = {};

  // Stores the confirmed (applied) crop rectangle for each image.
  final Map<int, Rect> _croppedRects = {};

  // Stores the selected crop shape (rectangle/circle) for each image.
  final Map<int, CropShape> _cropShapes = {};

  // Stores the selected aspect ratio for each image.
  final Map<int, CropAspectRatio> _cropAspectRatios = {};

  // List of available crop aspect ratios.
  final List<CropAspectRatio> _aspectRatios = const [
    CropAspectRatio(label: 'Free', icon: Icons.crop_free, value: null),
    CropAspectRatio(label: '1:1', icon: Icons.crop_square, value: 1.0),
    CropAspectRatio(label: '4:3', icon: Icons.crop_landscape, value: 4.0 / 3.0),
    CropAspectRatio(label: '3:4', icon: Icons.crop_portrait, value: 3.0 / 4.0),
    CropAspectRatio(label: '16:9', icon: Icons.crop_16_9, value: 16.0 / 9.0),
    CropAspectRatio(label: '9:16', icon: Icons.crop_7_5, value: 9.0 / 16.0),
  ];

  // The currently selected aspect ratio shown in the UI.
  late CropAspectRatio _selectedAspectRatio;

  // The currently selected crop shape shown in the UI.
  CropShape _selectedShape = CropShape.rectangle;

  // Flag to indicate if a global aspect ratio is active.
  bool _isGlobalAspectRatioActive = false;

  // Stores the fixed aspect ratio when _isGlobalAspectRatioActive is true.
  CropAspectRatio? _globalFixedAspectRatio;

  // Defines the scaling factor for fixed aspect ratio frames relative to the display area.
  static const double _fixedAspectRatioScaleFactor = 0.8;

  @override
  void initState() {
    super.initState();
    // Initialize with the 'Free' aspect ratio.
    _selectedAspectRatio = _aspectRatios.first;
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeCropRect());
  }

  // Returns the size of the image display area.
  Size? get _imageDisplaySize {
    final RenderBox? renderBox =
        _imageContainerKey.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size;
  }

  // Initializes the crop rectangle and settings for the current image.
  void _initializeCropRect() {
    final size = _imageDisplaySize;
    if (size == null || size.isEmpty) {
      debugPrint(
        "Warning: _imageDisplaySize is null or empty, cannot initialize crop rect.",
      );
      return;
    }

    // Ensure crop shape is initialized for the current image.
    _cropShapes.putIfAbsent(_currentIndex, () => CropShape.rectangle);
    _selectedShape = _cropShapes[_currentIndex]!;

    setState(() {
      // Determine the correct aspect ratio to use for initialization.
      if (_isGlobalAspectRatioActive && _globalFixedAspectRatio != null) {
        _cropAspectRatios.putIfAbsent(
          _currentIndex,
          () => _globalFixedAspectRatio!,
        );
        _selectedAspectRatio = _globalFixedAspectRatio!;
      } else {
        // If not global, use the stored one for this image, or default to 'Free'.
        _cropAspectRatios.putIfAbsent(
          _currentIndex,
          () => _aspectRatios.first,
        ); // Default to 'Free'
        _selectedAspectRatio = _cropAspectRatios[_currentIndex]!;
      }

      // Initialize a default pending crop rect if it doesn't exist for this image.
      if (!_pendingCropRects.containsKey(_currentIndex)) {
        _pendingCropRects[_currentIndex] = Rect.fromCenter(
          center: size.center(Offset.zero),
          width: size.width * 0.8,
          height: size.height * 0.8,
        );
      }
      // Apply the selected aspect ratio to the newly initialized or existing crop rect.
      _applyAspectRatio();
    });
  }

  // Resets the crop settings for the current image.
  void _resetCrop() {
    setState(() {
      // Remove individual crop details.
      _pendingCropRects.remove(_currentIndex);
      _croppedRects.remove(_currentIndex);
      _cropShapes.remove(_currentIndex);
      _cropAspectRatios.remove(_currentIndex);

      // Reset shape to rectangle.
      _selectedShape = CropShape.rectangle;

      // Handle aspect ratio reset based on global mode.
      if (_isGlobalAspectRatioActive && _globalFixedAspectRatio != null) {
        // If global mode is active, the reset should still use the global fixed ratio.
        _selectedAspectRatio = _globalFixedAspectRatio!;
        _cropAspectRatios[_currentIndex] =
            _globalFixedAspectRatio!; // Ensure current image uses it.
      } else {
        // Otherwise, reset to 'Free' and ensure not in global mode.
        _selectedAspectRatio = _aspectRatios.first; // 'Free'
        _cropAspectRatios[_currentIndex] =
            _aspectRatios.first; // Set 'Free' for current image.
        _isGlobalAspectRatioActive = false;
        _globalFixedAspectRatio = null;
      }

      // Re-initialize the crop rect for the current image.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _initializeCropRect(),
      );
    });
  }

  // Fetches the thumbnail data for a given asset.
  Future<Uint8List?> _getImagePreview(int index) async {
    return widget.assets[index].thumbnailDataWithSize(
      const ThumbnailSize(1080, 1080),
    );
  }

  // Updates the pending crop rectangle for the current image.
  void _updatePendingCropRect(Rect newRect) {
    _pendingCropRects[_currentIndex] = newRect;
  }

  // Confirms the pending crop and stores it in _croppedRects.
  void _confirmCrop() {
    setState(() {
      if (_pendingCropRects.containsKey(_currentIndex)) {
        _croppedRects[_currentIndex] = _pendingCropRects[_currentIndex]!;
      }
      _cropShapes[_currentIndex] = _selectedShape;
      _cropAspectRatios[_currentIndex] = _selectedAspectRatio;
    });
  }

  // Processes all images, applying crops, and returns the final files.
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
      // Use the stored crop shape for this image, or default to rectangle.
      final cropShape = _cropShapes[i] ?? CropShape.rectangle;

      if (cropRectFromUI == null) {
        // If no crop was applied, add the original file.
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

        // Calculate the actual display size of the image within its container.
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

        // Calculate scaling factors to map UI coordinates to original image pixels.
        double scaleX =
            imageToCropFromSize.width / displayedImageRectInUI.width;
        double scaleY =
            imageToCropFromSize.height / displayedImageRectInUI.height;

        // Translate and scale the UI crop rectangle to the original image's coordinate system.
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

        // Ensure the crop rect does not exceed original image bounds.
        finalCropSourceRect = finalCropSourceRect.intersect(
          Rect.fromLTWH(
            0,
            0,
            imageToCropFromSize.width,
            imageToCropFromSize.height,
          ),
        );

        // Perform the actual cropping using a PictureRecorder and Canvas.
        final ui.PictureRecorder finalRecorder = ui.PictureRecorder();
        final Canvas finalCanvas = Canvas(finalRecorder);
        final Paint paint = Paint()..isAntiAlias = true;

        final outputRect = Rect.fromLTWH(
          0,
          0,
          finalCropSourceRect.width,
          finalCropSourceRect.height,
        );

        // Apply circular clip if crop shape is circle.
        if (cropShape == CropShape.circle) {
          finalCanvas.clipPath(Path()..addOval(outputRect));
        }

        // Draw the cropped portion of the image.
        finalCanvas.drawImageRect(
          imageToCropFrom,
          finalCropSourceRect,
          outputRect,
          paint,
        );

        // Convert the canvas content to an Image and then to ByteData.
        final ui.Picture finalPicture = finalRecorder.endRecording();
        final ui.Image croppedImage = await finalPicture.toImage(
          outputRect.width.toInt(),
          outputRect.height.toInt(),
        );
        final ByteData? byteData = await croppedImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        imageToCropFrom
            .dispose(); // Dispose of the original image to free memory.

        if (byteData == null) {
          finalFiles.add(originalFile);
          continue;
        }

        // Save the cropped image to a temporary file.
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
      Navigator.pop(context); // Dismiss loader
      Navigator.pop(context, finalFiles); // Return processed files
    }
  }

  // Shows a confirmation dialog before saving changes.
  void _showConfirmDialog() {
    final bool hasAnyCrop = _croppedRects.isNotEmpty;

    if (!hasAnyCrop) {
      // If no crops applied, just return original files.
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

  // Returns original files without applying any crops.
  void _applyAndReturnOriginals() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CustomLoader()),
    );
    final originalFiles = await Future.wait(widget.assets.map((e) => e.file));
    if (mounted) {
      Navigator.pop(context); // Dismiss loader
      Navigator.pop(
        context,
        originalFiles.whereType<File>().toList(),
      ); // Return original files
    }
  }

  // Handles thumbnail tap events to switch current image.
  void _onThumbnailTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;

        // Determine selected aspect ratio based on global mode or individual setting.
        if (_isGlobalAspectRatioActive && _globalFixedAspectRatio != null) {
          _selectedAspectRatio = _globalFixedAspectRatio!;
          // Ensure this image also has the global fixed ratio stored for it.
          _cropAspectRatios[_currentIndex] = _globalFixedAspectRatio!;
        } else {
          _selectedAspectRatio =
              _cropAspectRatios[_currentIndex] ?? _aspectRatios.first;
        }

        _selectedShape = _cropShapes[_currentIndex] ?? CropShape.rectangle;

        // Initialize crop rect for the new image if it hasn't been touched yet.
        // Otherwise, just apply the aspect ratio to the existing rect.
        // Post frame callback ensures _imageDisplaySize is available.
        WidgetsBinding.instance.addPostFrameCallback(
          (_) =>
              _initializeCropRect(), // Re-initialize to ensure proper rect setup.
        );
      });
    }
  }

  // Applies the current _selectedAspectRatio to the _pendingCropRect for the _currentIndex.
  void _applyAspectRatio() {
    setState(() {
      // Determine the effective aspect ratio to apply
      CropAspectRatio effectiveAspectRatio;
      if (_isGlobalAspectRatioActive && _globalFixedAspectRatio != null) {
        effectiveAspectRatio = _globalFixedAspectRatio!;
      } else {
        effectiveAspectRatio =
            _cropAspectRatios[_currentIndex] ?? _aspectRatios.first;
      }

      // Update the currently selected aspect ratio in the UI.
      // This is crucial for the visual highlighting in the toolbar.
      _selectedAspectRatio = effectiveAspectRatio;

      if (_imageDisplaySize == null || _imageDisplaySize!.isEmpty) {
        debugPrint(
          "Warning: _imageDisplaySize is null or empty, cannot apply aspect ratio.",
        );
        return;
      }

      final ratio = effectiveAspectRatio.value;
      if (ratio == null) {
        // If 'Free' is selected, no fixed aspect ratio constraint.
        // We just ensure the current rect is within bounds, if it exists.
        Rect? currentRect = _pendingCropRects[_currentIndex];
        if (currentRect != null) {
          double clampedLeft = currentRect.left.clamp(
            0.0,
            _imageDisplaySize!.width - currentRect.width,
          );
          double clampedTop = currentRect.top.clamp(
            0.0,
            _imageDisplaySize!.height - currentRect.height,
          );
          _pendingCropRects[_currentIndex] = Rect.fromLTWH(
            clampedLeft,
            clampedTop,
            currentRect.width,
            currentRect.height,
          );
        } else {
          // If no current rect, initialize a default free rect.
          _pendingCropRects[_currentIndex] = Rect.fromCenter(
            center: _imageDisplaySize!.center(Offset.zero),
            width: _imageDisplaySize!.width * 0.8,
            height: _imageDisplaySize!.height * 0.8,
          );
        }
        return;
      }

      // --- Logic for Fixed Aspect Ratios ---
      // Calculate the maximum possible dimensions for the given ratio within the display area.
      double maxWidthBasedOnRatio = _imageDisplaySize!.height * ratio;
      double maxHeightBasedOnRatio = _imageDisplaySize!.width / ratio;

      double calculatedWidth = _imageDisplaySize!.width;
      double calculatedHeight = calculatedWidth / ratio;

      if (calculatedHeight > _imageDisplaySize!.height) {
        calculatedHeight = _imageDisplaySize!.height;
        calculatedWidth = calculatedHeight * ratio;
      }

      // Apply the scale factor to get the desired fixed visual size.
      double finalWidth = calculatedWidth * _fixedAspectRatioScaleFactor;
      double finalHeight = calculatedHeight * _fixedAspectRatioScaleFactor;

      // Ensure minimum size for the frame.
      finalWidth = max(ResizableCropArea._minCropSize, finalWidth);
      finalHeight = max(ResizableCropArea._minCropSize, finalHeight);

      // Create a new rect, centered in the display area.
      _pendingCropRects[_currentIndex] = Rect.fromCenter(
        center: _imageDisplaySize!.center(Offset.zero),
        width: finalWidth,
        height: finalHeight,
      );
    });
  }

  // Handles changes in crop shape (rectangle/circle).
  void _onShapeChanged(CropShape shape) {
    setState(() {
      _selectedShape = shape;
      _cropShapes[_currentIndex] = shape;

      if (shape == CropShape.circle) {
        final oneToOneRatio = _aspectRatios.firstWhere(
          (ratio) => ratio.label == '1:1',
          orElse: () => _aspectRatios.first,
        );
        // When circle is selected, it forces 1:1, so we also make this global.
        _isGlobalAspectRatioActive = true;
        _globalFixedAspectRatio = oneToOneRatio;
        // Apply this 1:1 ratio to all images.
        for (int i = 0; i < widget.assets.length; i++) {
          _cropAspectRatios[i] = oneToOneRatio;
        }
      } else {
        // shape == CropShape.rectangle
        // If we were globally fixed to an aspect ratio (e.g., from previously selecting circle),
        // maintain that global setting to the last active fixed ratio if applicable,
        // otherwise revert to individual 'Free' mode.
        if (_globalFixedAspectRatio != null) {
          // If there was a fixed ratio set
          _isGlobalAspectRatioActive =
              true; // Stay in global mode with that ratio
        } else {
          _isGlobalAspectRatioActive = false; // Go back to individual/free mode
          _globalFixedAspectRatio = null; // Clear global fixed ratio
          _cropAspectRatios.putIfAbsent(
            _currentIndex,
            () => _aspectRatios.first,
          ); // Ensure 'Free' or stored for current image.
        }
      }
      // Re-apply the aspect ratio based on the updated state.
      _applyAspectRatio();
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
                // Use ValueKey to force state reset when image index changes
                key: ValueKey(_currentIndex),
                child: ResizableCropArea(
                  imageData: imageData,
                  // Use the pending crop rect for the current index, or a default one.
                  initialRect:
                      _pendingCropRects[_currentIndex] ??
                      Rect.fromCenter(
                        center: _imageDisplaySize!.center(Offset.zero),
                        width: _imageDisplaySize!.width * 0.8,
                        height: _imageDisplaySize!.height * 0.8,
                      ),
                  onRectChanged: _updatePendingCropRect,
                  aspectRatio: _selectedAspectRatio,
                  // Pass the effective selected aspect ratio.
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
              if (_selectedShape ==
                  CropShape
                      .rectangle) // Aspect ratios only for rectangle shape.
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _aspectRatios.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final ratio = _aspectRatios[index];
                      // Determine if this ratio button is selected.
                      // If global fixed ratio is active, it's selected if it matches the global one.
                      // Otherwise, it's selected if it matches the individual one for the current image.
                      final isSelected =
                          (_isGlobalAspectRatioActive &&
                              _globalFixedAspectRatio == ratio) ||
                          (!_isGlobalAspectRatioActive &&
                              _selectedAspectRatio == ratio);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (ratio.value == null) {
                              // 'Free' is selected
                              _isGlobalAspectRatioActive = false;
                              _globalFixedAspectRatio = null;
                              _cropAspectRatios[_currentIndex] =
                                  ratio; // Store 'Free' for current image
                            } else {
                              // Fixed aspect ratio selected
                              _isGlobalAspectRatioActive = true;
                              _globalFixedAspectRatio = ratio;
                              // Apply this fixed ratio to all images
                              for (int i = 0; i < widget.assets.length; i++) {
                                _cropAspectRatios[i] = ratio;
                              }
                            }
                            _selectedAspectRatio = ratio; // Update UI selection
                            _applyAspectRatio(); // Apply to current image, considering global/individual state
                          });
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
                                        : AppColors.white.withValues(
                                          alpha: 0.7,
                                        ),
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
        // An image is considered "edited" if it has a confirmed crop rectangle.
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

  static const double _minCropSize = 50.0; // Minimum size for the crop area.

  @override
  State<ResizableCropArea> createState() => _ResizableCropAreaState();
}

class _ResizableCropAreaState extends State<ResizableCropArea> {
  Rect? _rect; // The current crop rectangle.
  _DragHandle _activeHandle =
      _DragHandle.none; // The currently active drag handle.

  Rect?
  _rectOnScaleStart; // Stores the rect state at the start of a scale gesture.
  Offset?
  _focalPointOnScaleStart; // Stores the focal point at the start of a scale gesture.

  static const double _handleTouchSize =
      32.0; // Size of the touchable area for handles.

  @override
  void initState() {
    super.initState();
    // Initialize _rect from the widget's initialRect.
    _rect = widget.initialRect;
  }

  @override
  void didUpdateWidget(covariant ResizableCropArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update _rect only if initialRect from the parent changes AND no active dragging is happening.
    // This ensures that when the parent (CustomCropImageScreen) dictates a new initial crop
    // (e.g., due to applying an aspect ratio or switching back to an image),
    // the ResizableCropArea properly reflects it, without interfering with ongoing user gestures.
    if (widget.initialRect != oldWidget.initialRect &&
        _activeHandle == _DragHandle.none &&
        _rectOnScaleStart == null) {
      _rect = widget.initialRect;
    }
  }

  // Determines which drag handle is being interacted with based on position.
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

    if (_rect!.contains(position))
      return _DragHandle.center; // Center for moving the whole rect.
    return _DragHandle.none;
  }

  // Called when a scale gesture starts.
  void _onScaleStart(ScaleStartDetails details) {
    _rectOnScaleStart = _rect;
    _focalPointOnScaleStart = details.focalPoint;

    if (details.pointerCount == 1) {
      _activeHandle = _getHandleForPosition(details.localFocalPoint);
    } else {
      _activeHandle =
          _DragHandle.none; // Disable handles for multi-touch scaling.
    }
  }

  // Called when a scale gesture updates.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_rectOnScaleStart == null ||
        widget.parentSize == null ||
        widget.parentSize!.isEmpty) {
      debugPrint(
        "Warning: parentSize or initial rect not set or empty during scale update.",
      );
      return;
    }

    // Only allow resizing if the aspect ratio is 'Free'.
    // If a fixed aspect ratio is selected, only allow moving.
    if (widget.aspectRatio.value != null &&
        _activeHandle != _DragHandle.center) {
      // If fixed aspect ratio is active, do not allow corner resizing.
      // We still allow moving the entire frame using the center handle or multi-touch pan.
      if (details.pointerCount == 1 && _activeHandle != _DragHandle.center) {
        return; // Prevent resizing by corner handles when fixed ratio is active.
      }
    }

    Rect newRect = _rectOnScaleStart!;
    Offset translationDelta = details.focalPoint - _focalPointOnScaleStart!;

    if (details.pointerCount == 1 && _activeHandle != _DragHandle.none) {
      // Single-pointer drag: moving or resizing from a handle.
      if (_activeHandle == _DragHandle.center) {
        // Move the entire rect.
        newRect = newRect.translate(translationDelta.dx, translationDelta.dy);
      } else {
        // Resize from a corner handle (only if 'Free' aspect ratio).
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

        // Create a new rect from the two corners and normalize it to ensure positive width/height.
        newRect = Rect.fromPoints(newCorner, oppositeCorner).normalize();

        final ratio = widget.aspectRatio.value;
        if (ratio != null) {
          // This block will now only be entered if `widget.aspectRatio.value` is null (Free).
          // If it's a fixed ratio, we prevent entering this 'else' path for corner drags above.
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

          // Ensure minimum size for the new rect.
          targetWidth = max(ResizableCropArea._minCropSize, targetWidth);
          targetHeight = max(ResizableCropArea._minCropSize, targetHeight);

          // Recreate the rect based on the adjusted width/height and the opposite corner.
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
            // bottomRight
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
      // Multi-pointer scale: zoom and pan.
      final Offset translation = translationDelta;

      double newWidth = _rectOnScaleStart!.width * details.scale;
      double newHeight = _rectOnScaleStart!.height * details.scale;

      if (widget.aspectRatio.value != null) {
        // Maintain aspect ratio during multi-touch scaling for fixed ratios.
        // For free, it can scale non-proportionally.
        final ratio = widget.aspectRatio.value!;
        if (newWidth / newHeight > ratio) {
          newWidth = newHeight * ratio;
        } else {
          newHeight = newWidth / ratio;
        }
      }

      // Clamp the new dimensions to be within min/max sizes and parent bounds.
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
      return; // No active handle and not multi-touch.
    }

    // Clamp the final rectangle to stay within the parent's boundaries and minimum size.
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
      widget.onRectChanged(_rect!); // Notify parent of the change.
    });
  }

  // Called when a scale gesture ends.
  void _onScaleEnd(ScaleEndDetails details) {
    _activeHandle = _DragHandle.none; // Reset active handle.
    _rectOnScaleStart = null; // Clear start rect.
    _focalPointOnScaleStart = null; // Clear start focal point.
  }

  @override
  Widget build(BuildContext context) {
    // If parent size or rect is not ready, just display the image.
    if (widget.parentSize == null ||
        widget.parentSize!.isEmpty ||
        _rect == null) {
      return Image.memory(widget.imageData, fit: BoxFit.contain);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Display the image itself.
        Image.memory(widget.imageData, fit: BoxFit.contain),
        // GestureDetector for handling crop area interactions.
        Positioned.fill(
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            child: CustomPaint(
              // Custom painter to draw the crop overlay and handles.
              painter: _CropRectPainter(
                rect: _rect!,
                shape: widget.shape,
                activeHandle:
                    _activeHandle, // Pass active handle for visual feedback.
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for the crop rectangle, overlay, and handles.
class _CropRectPainter extends CustomPainter {
  final Rect rect;
  final CropShape shape;
  final _DragHandle activeHandle; // NEW: To highlight the active handle.

  _CropRectPainter({
    required this.rect,
    required this.shape,
    this.activeHandle = _DragHandle.none,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    if (shape == CropShape.rectangle) {
      path.addRect(rect);
    } else {
      path.addOval(rect);
    }

    // Paint for the semi-transparent overlay outside the crop area.
    final Paint overlayPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.5)
          ..style = PaintingStyle.fill;

    // Create a path that covers the entire canvas.
    final Path fullPath = Path()..addRect(Offset.zero & size);
    // Subtract the crop area path from the full path to get the overlay shape.
    canvas.drawPath(
      Path.combine(PathOperation.difference, fullPath, path),
      overlayPaint,
    );

    // Paint for the crop area border.
    final Paint borderPaint =
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    // Draw the border of the crop area.
    canvas.drawPath(path, borderPaint);

    // Draw grid lines inside the crop area for better alignment.
    final Paint gridPaint =
        Paint()
          ..color = Colors.white54
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    if (shape == CropShape.rectangle) {
      // Horizontal grid lines.
      canvas.drawLine(
        Offset(rect.left, rect.top + rect.height / 3),
        Offset(rect.right, rect.top + rect.height / 3),
        gridPaint,
      );
      canvas.drawLine(
        Offset(rect.left, rect.top + rect.height * 2 / 3),
        Offset(rect.right, rect.top + rect.height * 2 / 3),
        gridPaint,
      );
      // Vertical grid lines.
      canvas.drawLine(
        Offset(rect.left + rect.width / 3, rect.top),
        Offset(rect.left + rect.width / 3, rect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(rect.left + rect.width * 2 / 3, rect.top),
        Offset(rect.left + rect.width * 2 / 3, rect.bottom),
        gridPaint,
      );
    }

    // Draw drag handles for resizing.
    final Paint handlePaint =
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.fill;

    final Paint activeHandlePaint =
        Paint()
          ..color =
              AppColors
                  .primary // Highlight color for active handle
          ..style = PaintingStyle.fill;

    // Helper to draw a handle, with highlighting for the active one.
    void drawHandle(Offset center, _DragHandle handleType) {
      canvas.drawCircle(
        center,
        ResizableCropArea._minCropSize / 8,
        activeHandle == handleType ? activeHandlePaint : handlePaint,
      );
    }

    // Draw corner handles.
    drawHandle(rect.topLeft, _DragHandle.topLeft);
    drawHandle(rect.topRight, _DragHandle.topRight);
    drawHandle(rect.bottomLeft, _DragHandle.bottomLeft);
    drawHandle(rect.bottomRight, _DragHandle.bottomRight);
  }

  @override
  bool shouldRepaint(covariant _CropRectPainter oldDelegate) {
    // Repaint if the rectangle, shape, or active handle changes.
    return oldDelegate.rect != rect ||
        oldDelegate.shape != shape ||
        oldDelegate.activeHandle != activeHandle;
  }
}
