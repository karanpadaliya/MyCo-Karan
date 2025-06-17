import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

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

    // Use your custom PermissionUtil
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
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        } else {
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
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
        backgroundColor: AppColors.white,
        elevation: 1,
        title: ValueListenableBuilder<List<AssetEntity>>(
          valueListenable: selectedAssets,
          builder: (_, selected, __) {
            return Text(
              'Selected: ${selected.length}/${widget.maxSelection}',
              style: const TextStyle(color: AppColors.black),
            );
          },
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(child: CustomLoader());
          }
          return GridView.builder(
            padding: const EdgeInsets.all(6),
            itemCount: mediaList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final asset = mediaList[index];
              return GestureDetector(
                onTap: () => _toggleSelection(asset),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildImage(asset),
                    ValueListenableBuilder<List<AssetEntity>>(
                      valueListenable: selectedAssets,
                      builder: (_, selected, __) {
                        final isSelected = selected.contains(asset);
                        return Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected ? Icons.check : Icons.circle_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder<List<AssetEntity>>(
        valueListenable: selectedAssets,
        builder: (context, selected, child) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
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
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
