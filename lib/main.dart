import 'package:flutter/material.dart';
import 'package:myco_karan/screen/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFF2F648E),
          selectionColor: Color(0xFF2F648E),
          selectionHandleColor: Color(0xFF2F648E),
        ),
      ),
      home: HomePage(),
    );
  }
}

// class ImageGridPreviewWidget extends StatelessWidget {
//   final List<String> imageList;
//   final double? boxHeight;
//   final double? boxWidth;
//   final bool showIndicators;
//
//   const ImageGridPreviewWidget({
//     super.key,
//     required this.imageList,
//     this.boxHeight,
//     this.boxWidth,
//     this.showIndicators = true,
//   });
//
//   // @override
//   // Widget build(BuildContext context) {
//   //   return _buildStyledImageRow(context, imageList);
//   // }
//
//   // Widget _buildStyledImageRow(BuildContext context, List<String> images) {
//   //   return Row(
//   //     mainAxisSize: MainAxisSize.min,
//   //     children: [
//   //       if (images.isNotEmpty) _imageBox(context, images, 0),
//   //       if (images.length > 1) ...[
//   //         const SizedBox(width: 12),
//   //         _imageBox(context, images, 1),
//   //       ],
//   //       if (images.length > 2) ...[
//   //         const SizedBox(width: 12),
//   //         _imageBox(context, images, 2),
//   //       ],
//   //     ],
//   //   );
//   // }
//
//   Widget _imageBox(
//     BuildContext context,
//     List<String> images,
//     int index,
//     //   {
//     //   // bool isExtraBox = false,
//     // }
//   ) {
//     final total = images.length;
//     final height = boxHeight ?? MediaQuery.of(context).size.width * 0.20;
//     final width = boxWidth ?? MediaQuery.of(context).size.width * 0.20;
//
//     bool showImage = index < total;
//     bool isThirdBox = index == 2;
//     bool showExtraCountOverlay = isThirdBox && total > 3;
//     int extraCount = total - 2;
//
//     ImageProvider? backgroundImage;
//     if (showExtraCountOverlay && total > 3) {
//       backgroundImage = _getImageProvider(images[2]);
//     } else if (showImage) {
//       backgroundImage = _getImageProvider(images[index]);
//     }
//
//     return GestureDetector(
//       onTap: () {
//         if (showImage) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder:
//                   (_) => _ImagePreview(
//                     images: images,
//                     startIndex: index,
//                     showIndicators: showIndicators,
//                   ),
//             ),
//           );
//         }
//       },
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.grey.shade300,
//           borderRadius: BorderRadius.circular(16),
//           image:
//               backgroundImage != null
//                   ? DecorationImage(
//                     image: backgroundImage,
//                     fit: BoxFit.cover,
//                     colorFilter:
//                         showExtraCountOverlay
//                             ? ColorFilter.mode(
//                               Color.fromRGBO(0, 0, 0, 0.4),
//                               BlendMode.darken,
//                             )
//                             : null,
//                   )
//                   : null,
//         ),
//         alignment: Alignment.center,
//         child:
//             showExtraCountOverlay
//                 ? Text(
//                   '+$extraCount',
//                   style: TextStyle(
//                     // fontWeight: FontWeight.bold,
//                     fontSize:
//                         Theme.of(context).textTheme.titleLarge?.fontSize ?? 20,
//                     fontFamily: 'Gilroy-SemiBold',
//                     color: Colors.white,
//                   ),
//                 )
//                 : null,
//       ),
//     );
//   }
//
//   ImageProvider _getImageProvider(String path) {
//     if (path.startsWith('http://') || path.startsWith('https://')) {
//       return NetworkImage(path);
//     } else {
//       return AssetImage(path);
//     }
//   }
// }

///image preview widget
class _ImagePreview extends StatefulWidget {
  final List<String> images;
  final int startIndex;
  final bool showIndicators;

  const _ImagePreview({
    required this.images,
    required this.startIndex,
    this.showIndicators = true,
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
            itemBuilder:
                (context, index) => Center(
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
