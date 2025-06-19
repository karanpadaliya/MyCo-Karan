import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;

// Define the CustomCropImageScreen StatefulWidget
class CustomCropImageScreen extends StatefulWidget {
  // List of AssetEntity objects to be cropped
  final List<AssetEntity> assets;
  // Callback function to return the list of cropped (or original) File objects
  final Function(List<File>) onCropped;

  const CustomCropImageScreen({
    Key? key,
    required this.assets,
    required this.onCropped,
  }) : super(key: key);

  @override
  State<CustomCropImageScreen> createState() => _CustomCropImageScreenState();
}

// State class for CustomCropImageScreen
class _CustomCropImageScreenState extends State<CustomCropImageScreen> {
  // Map to store cropped files, keyed by the original AssetEntity.
  // This allows us to easily associate the cropped file with its source asset.
  final Map<AssetEntity, File> _processedFiles = {};
  // Flag to indicate if a cropping operation is currently in progress
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    // Initialize _processedFiles with original files when the screen loads.
    // This ensures that even if an image isn't explicitly cropped, its original
    // file is included in the final list returned by _onFinish.
    _initializeProcessedFiles();
  }

  // Asynchronously initializes the _processedFiles map with original AssetEntity files.
  Future<void> _initializeProcessedFiles() async {
    for (final asset in widget.assets) {
      final file = await asset.file;
      if (file != null) {
        // Use a post-frame callback to avoid calling setState during build,
        // especially if this method completes very quickly.
        if (mounted) {
          setState(() {
            _processedFiles[asset] = file;
          });
        }
      }
    }
  }

  // Handles the cropping process for a given AssetEntity.
  Future<void> _cropImage(AssetEntity assetToCrop) async {
    // Prevent multiple cropping operations from starting simultaneously
    if (_isCropping) return;

    setState(() => _isCropping = true);

    // Get the original file from the AssetEntity
    final originFile = await assetToCrop.file;

    // Check if the original file exists
    if (originFile == null || !await originFile.exists()) {
      if (mounted) _showSnackBar('Image not found.');
      if (mounted) setState(() => _isCropping = false);
      return;
    }

    // Create a temporary copy of the image file.
    // ImageCropper sometimes works better with a file path that it can manage,
    // and this also preserves the original if the cropping is cancelled.
    final tempDir = Directory.systemTemp;
    final copiedFilePath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${assetToCrop.id}.jpg';
    final copiedFile = await originFile.copy(copiedFilePath);

    // Call the ImageCropper to perform the cropping operation
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: copiedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90, // Compress the output image quality
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false, // Allow flexible aspect ratio
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(title: 'Crop Image', aspectRatioLockEnabled: false),
      ],
    );

    // Ensure the widget is still mounted before calling setState
    if (!mounted) return;

    setState(() => _isCropping = false);

    if (croppedFile != null) {
      // If cropping was successful, update the _processedFiles map with the new cropped file
      setState(() {
        _processedFiles[assetToCrop] = File(croppedFile.path);
      });
    } else {
      // If cropping was cancelled
      _showSnackBar('Cropping cancelled.');
    }

    // Clean up the temporary copied file after cropping (whether successful or cancelled)
    if (await copiedFile.exists()) {
      await copiedFile.delete();
    }
  }

  // Called when the "Finish & Return" button is pressed.
  void _onFinish() {
    if (!mounted) return;

    // Collect all files from _processedFiles.
    // Since _processedFiles is initialized with original files and updated with cropped ones,
    // this list will contain either the cropped version or the original for each asset.
    final List<File> finalFiles = widget.assets.map((asset) {
      return _processedFiles[asset]!; // '!' is safe because _processedFiles is pre-populated
    }).toList();

    // Call the onCropped callback to return the list of files to the previous screen.
    widget.onCropped(finalFiles);
  }

  // Displays a SnackBar message at the bottom of the screen.
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Helper function to format file size for display.
  String _getFileSize(int bytes) {
    const kb = 1024;
    const mb = 1024 * 1024;
    if (bytes >= mb) return "${(bytes / mb).toStringAsFixed(2)} MB";
    if (bytes >= kb) return "${(bytes / kb).toStringAsFixed(2)} KB";
    return "$bytes B";
  }

  // Builds an info card displaying title and value.
  Widget _buildInfoCard(String title, String value, {double maxWidth = 100}) {
    return Container(
      width: maxWidth,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        border: Border.all(color: Colors.deepPurple.shade100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Builds a tile for each image, showing its preview and cropping button.
  Widget _buildImageTile(int index) {
    final asset = widget.assets[index];
    // Determine which file to display: the processed (cropped) one if it exists,
    // otherwise the original file from the AssetEntity.
    final File? fileToDisplay = _processedFiles[asset];

    return FutureBuilder<File?>(
      // If fileToDisplay is already available, use it directly, otherwise fetch from asset.
      future: fileToDisplay != null ? Future.value(fileToDisplay) : asset.file,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Unable to load image"));
        }

        final file = snapshot.data!;
        final fileName = p.basename(file.path);
        final extension =
        p.extension(file.path).replaceAll('.', '').toUpperCase();
        final fileSize = _getFileSize(file.lengthSync());

        // Check if the currently displayed file is a cropped version (different from original)
        // This relies on the _processedFiles map correctly tracking the current state.
        final bool isCropped = _processedFiles.containsKey(asset) &&
            _processedFiles[asset] != file;


        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard("Format", extension),
                    _buildInfoCard("Size", fileSize),
                    _buildInfoCard("Name", fileName),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  // Button is disabled if a cropping operation is in progress
                  onPressed: _isCropping ? null : () => _cropImage(asset),
                  icon: const Icon(Icons.crop),
                  label: Text(
                    isCropped ? "Cropped" : "Crop Image",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCropped ? Colors.grey : Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crop Selected Images"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: widget.assets.length,
        padding: const EdgeInsets.all(12),
        itemBuilder: (_, index) => _buildImageTile(index),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ElevatedButton.icon(
            // The "Finish & Return" button is always enabled now,
            // as _onFinish correctly handles both cropped and uncropped images.
            onPressed: _onFinish,
            icon: const Icon(Icons.check),
            label: const Text("Finish & Return"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
