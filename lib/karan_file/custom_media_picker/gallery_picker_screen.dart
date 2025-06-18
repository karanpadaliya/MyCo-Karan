import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shimmer/shimmer.dart';

import '../../themes_colors/colors.dart';
import '../app_permissions/app_permissions.dart';
import '../custom_loader/custom_loader.dart';

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

  @override
  void initState() {
    super.initState();
    _loadGallery(context);
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
      if (currentList.length < widget.maxSelection) {
        selectedAssets.value = List.from(currentList)..add(asset);
      }
    }
  }

  Widget _buildImage(AssetEntity asset) {
    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailDataWithSize(const ThumbnailSize(300, 300)),
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
          // Shimmer loading effect
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

  @override
  void dispose() {
    selectedAssets.dispose();
    _isLoading.dispose();
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
              'Selected: ${selected.length}/${widget.maxSelection}',
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
                                  width: 1.2,
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
                                size: 18,
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
                  widget.onSelectionDone(selected);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please select at least 1 image"),
                    ),
                  );
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
