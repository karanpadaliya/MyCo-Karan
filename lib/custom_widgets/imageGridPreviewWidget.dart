import 'package:flutter/material.dart';

class ImageGridPreviewWidget extends StatelessWidget {
  final List<String> imageList;
  final int containersLength;
  final double? boxHeight;
  final double? boxWidth;
  final bool showIndicators;
  final double borderRadius;

  const ImageGridPreviewWidget({
    super.key,
    required this.imageList,
    this.boxHeight,
    this.boxWidth,
    this.showIndicators = true,
    this.containersLength = 3,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return _buildStyledImageRow(context, imageList);
  }

  Widget _buildStyledImageRow(BuildContext context, List<String> images) {
    int totalImages = images.length;
    int maxVisibleContainers = containersLength.clamp(1, totalImages);
    List<Widget> imageBoxes = [];

    for (int i = 0; i < maxVisibleContainers; i++) {
      if (i != 0) imageBoxes.add(const SizedBox(width: 12));

      bool isLastContainer = i == maxVisibleContainers - 1;
      bool shouldShowExtra = totalImages > containersLength && isLastContainer;
      int displayIndex = shouldShowExtra ? containersLength - 1 : i;

      imageBoxes.add(
        _imageBox(
          context,
          images,
          displayIndex,
          isExtraBox: shouldShowExtra,
          extraCount: totalImages - (containersLength - 1),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: imageBoxes);
  }

  Widget _imageBox(
      BuildContext context,
      List<String> images,
      int index, {
        bool isExtraBox = false,
        int extraCount = 0,
      }) {
    final height = boxHeight ?? MediaQuery.of(context).size.width * 0.20;
    final width = boxWidth ?? MediaQuery.of(context).size.width * 0.20;

    ImageProvider? backgroundImage = _getImageProvider(images[index]);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _ImagePreview(
              containersLength: containersLength,
              images: images,
              startIndex: index,
              showIndicators: showIndicators,
            ),
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(borderRadius),
          image: DecorationImage(
            image: backgroundImage,
            fit: BoxFit.cover,
            colorFilter: isExtraBox
                ? const ColorFilter.mode(
              Color.fromRGBO(0, 0, 0, 0.4),
              BlendMode.darken,
            )
                : null,
          ),
        ),
        alignment: Alignment.center,
        child: isExtraBox
            ? Text(
          '+$extraCount',
          style: TextStyle(
            fontSize:
            Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
            fontFamily: 'Gilroy-SemiBold',
            color: Colors.white,
          ),
        )
            : null,
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }
}

class _ImagePreview extends StatefulWidget {
  final List<String> images;
  final int? containersLength;
  final int startIndex;
  final bool showIndicators;

  const _ImagePreview({
    required this.images,
    required this.startIndex,
    this.showIndicators = true,
    required this.containersLength,
  });

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) => Center(
              child: InteractiveViewer(
                child: Image(
                  image: _getImageProvider(widget.images[index]),
                  fit: BoxFit.contain,
                  width: screenSize.width,
                  height: screenSize.height,
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          if (widget.showIndicators)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Visibility(
                visible: widget.images.length <= 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildIndicators(
                    widget.images.length,
                    _currentIndex,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildIndicators(int total, int current) {
    return List.generate(total, (index) {
      bool isActive = index == current;
      return _dot(isActive);
    });
  }

  Widget _dot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,

        shape: BoxShape.circle,
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    } else {
      return AssetImage(path);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    }
}