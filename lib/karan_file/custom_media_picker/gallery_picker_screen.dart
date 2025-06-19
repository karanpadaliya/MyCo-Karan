import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path/path.dart' as path;
import '../../themes_colors/colors.dart';
import '../app_permissions/app_permissions.dart';
import '../custom_loader/custom_loader.dart';
import '../custom_myco_button/custom_myco_button.dart';

class GalleryPickerScreen extends StatefulWidget {
  final int maxSelection;
  final Function(List<AssetEntity>) onSelectionDone;

  const GalleryPickerScreen({
    Key? key,
    required this.maxSelection,
    required this.onSelectionDone,
  }) : super(key: key);

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  final ValueNotifier<List<AssetEntity>> selectedAssets = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  List<AssetPathEntity> albums = [];
  List<AssetEntity> mediaList = [];
  int _currentMaxSelection = 0;

  @override
  void initState() {
    super.initState();
    _currentMaxSelection = widget.maxSelection;
    _loadGallery(context);
  }

  @override
  void didUpdateWidget(covariant GalleryPickerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxSelection != widget.maxSelection) {
      setState(() {
        _currentMaxSelection = widget.maxSelection;
      });
    }
  }

  Future<void> _loadGallery(BuildContext context) async {
    _isLoading.value = true;
    bool hasPermission = await PermissionUtil.checkPermissionByPickerType(
      'gallery',
      context,
    );

    if (!hasPermission) {
      _isLoading.value = false;
      return;
    }

    try {
      albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      mediaList = await albums.first.getAssetListPaged(page: 0, size: 200);
    } catch (e) {
      debugPrint("Error loading gallery: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  void _toggleSelection(AssetEntity asset) {
    final currentList = selectedAssets.value;
    if (currentList.contains(asset)) {
      selectedAssets.value = List.from(currentList)..remove(asset);
    } else {
      if (currentList.length < _currentMaxSelection) {
        selectedAssets.value = List.from(currentList)..add(asset);
      } else {
        //   AppSnackbar.showError(
        //     context,
        //     "You can only select up to $_currentMaxSelection images",
        //     top: true
        //   );
      }
    }
  }

  Future<void> _validateAndSubmitSelection(List<AssetEntity> assets) async {
    List<File> allFiles = [];
    Map<File, AssetEntity> fileToAsset = {};

    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) {
        allFiles.add(file);
        fileToAsset[file] = asset;
      }
    }

    // Assuming validateAndHandleImages returns a Map with 'validFiles' and 'invalidFiles'
    final validationResult = await validateAndHandleImages(
      context: context,
      files: allFiles,
    );

    final List<File> validFiles = validationResult['validFiles'] as List<File>;
    final List<Map<String, dynamic>> invalidFilesWithReasons =
        validationResult['invalidFiles'] as List<Map<String, dynamic>>;

    final validAssets = validFiles.map((f) => fileToAsset[f]!).toList();

    if (invalidFilesWithReasons.isNotEmpty && validAssets.isNotEmpty) {
      _showInvalidFilesBottomSheet(invalidFilesWithReasons, validAssets);
    } else if (validAssets.isNotEmpty) {
      widget.onSelectionDone(validAssets);
    } else {
      _showInvalidFilesBottomSheet(invalidFilesWithReasons, validAssets);
    }
  }

  void _showInvalidFilesBottomSheet(
    List<Map<String, dynamic>> invalidFiles,
    List<AssetEntity> validAssets,
  ) {
    // Calling the new static bottom sheet directly
    _GalleryPickerBottomSheet.showInvalidFilesBottomSheet(
      context,
      invalidFiles,
      () => widget.onSelectionDone(validAssets),
    );
  }

  final Map<AssetEntity, Future<Uint8List?>> _thumbnailCache = {};

  Widget _buildImage(AssetEntity asset) {
    // Cache the future
    _thumbnailCache.putIfAbsent(
      asset,
      () => asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
    );

    return FutureBuilder<Uint8List?>(
      future: _thumbnailCache[asset],
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        } else {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white,
              ),
            ),
          );
        }
      },
    );
  }

  void _clearThumbnailsCache() {
    _thumbnailCache.clear();
  }

  @override
  void dispose() {
    selectedAssets.dispose();
    _isLoading.dispose();
    _clearThumbnailsCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        title: ValueListenableBuilder<List<AssetEntity>>(
          valueListenable: selectedAssets,
          builder: (_, selected, __) {
            return Text(
              'Selected: ${selected.length}/$_currentMaxSelection',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            );
          },
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CustomLoader());
          }
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: mediaList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final asset = mediaList[index];
              return GestureDetector(
                onTap: () => _toggleSelection(asset),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _buildImage(asset),
                      ),
                      ValueListenableBuilder<List<AssetEntity>>(
                        valueListenable: selectedAssets,
                        builder: (_, selected, __) {
                          final isSelected = selected.contains(asset);
                          return Positioned(
                            top: 6,
                            right: 6,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.white.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.check
                                    : Icons.radio_button_unchecked,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                size: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder<List<AssetEntity>>(
        valueListenable: selectedAssets,
        builder: (context, selected, child) {
          return AnimatedOpacity(
            opacity: selected.isNotEmpty ? 1.0 : 0.6,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 36,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 6,
              ),
              onPressed: () {
                if (selected.isNotEmpty) {
                  _validateAndSubmitSelection(selected);
                } else {
                  // AppSnackbar.showError(
                  //   context,
                  //   "Please select at least 1 image",
                  // );
                }
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// New static bottom sheet class
class _GalleryPickerBottomSheet {
  static void showInvalidFilesBottomSheet(
    BuildContext context,
    List<Map<String, dynamic>> invalidFiles,
    VoidCallback onProceedWithValid,
  ) {
    if (invalidFiles.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // make background transparent for animation
      builder: (context) {
        return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.4,
              maxChildSize: 0.85,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'File(s) Restriction',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Description
                      const Text(
                        'Some files were discarded because they are either WebP format or larger than 5MB. Please select files under 5MB in supported formats.',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Scrollable Images
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children:
                                invalidFiles.map((item) {
                                  final File file = item['file'];
                                  final String reason = item['reason'];
                                  final String reasonLabel =
                                      reason == 'format'
                                          ? 'due to .webp'
                                          : 'due to size';

                                  return Container(
                                    width: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            file,
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (_, __, ___) => const Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          reasonLabel,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Close Button
                      SizedBox(
                        height: 45,
                        width: double.infinity,
                        child: MyCoButton(
                          onTap: () {
                            Navigator.pop(context);
                            onProceedWithValid();
                          },
                          title: 'Close',
                          textStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          boarderRadius: 20,
                          isShadowBottomLeft: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Future<Map<String, dynamic>> validateAndHandleImages({
  required BuildContext context,
  required List<File> files,
}) async {
  List<File> validFiles = [];
  List<Map<String, dynamic>> invalidFiles = [];

  for (File file in files) {
    String fileName = path.basename(file.path);
    if (fileName.toLowerCase().endsWith('.webp')) {
      invalidFiles.add({'file': file, 'reason': 'format'});
    } else {
      // Simulate size check
      int fileSizeInBytes = await file.length();
      if (fileSizeInBytes > 5 * 1024 * 1024) {
        // 5MB
        invalidFiles.add({'file': file, 'reason': 'size'});
      } else {
        validFiles.add(file);
      }
    }
  }

  return {'validFiles': validFiles, 'invalidFiles': invalidFiles};
}
