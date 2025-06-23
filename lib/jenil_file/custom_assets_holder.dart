import 'package:flutter/material.dart';
import 'package:myco_karan/jenil_file/responsive.dart';
import '../themes_colors/colors.dart';
import 'doted_line.dart';

class CustomAssetsHolder extends StatefulWidget {
  final String userName;
  final String designation;
  final String location;
  final String title;
  final String brand;
  final String serial;
  final String handoverDate;
  final String imageUrl;
  final List<Color> gradientContainerColor;
  final VoidCallback? onViewMore;

  const CustomAssetsHolder({
    super.key,
    required this.userName,
    required this.designation,
    required this.location,
    required this.title,
    required this.brand,
    required this.serial,
    required this.handoverDate,
    required this.imageUrl,
    this.onViewMore,
    required this.gradientContainerColor,
  });

  @override
  State<CustomAssetsHolder> createState() => _CustomAssetsHolderState();
}

class _CustomAssetsHolderState extends State<CustomAssetsHolder> {
  List<String> imageList = [
    "assets/girl.jpg",
    "assets/laptop.png",
    "assets/tiger.jpeg",
    "assets/mail.png",
    "assets/mail1.png",
    "assets/mail2.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.borderColor, width: 1.2),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: getHeight(context) * .06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.gradientContainerColor,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize ??
                            18,
                        fontFamily: 'Gilroy-SemiBold',
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 25,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x33FFFFFF), // 20% white
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage("assets/girl.jpg"),
                  radius: 35,
                ),

                SizedBox(width: getWidth(context) * .050),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userName,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize ??
                            16,
                        fontFamily: 'Gilroy-SemiBold',
                      ),
                    ),
                    Text(
                      widget.designation,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize ??
                            12,
                        fontFamily: 'Gilroy-Medium',
                      ),
                    ),

                    Text(
                      widget.location,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize ??
                            12,
                        fontFamily: 'Gilroy-Medium',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize ??
                            18,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        widget.imageUrl,
                        width: getWidth(context) * .30,
                        height: getWidth(context) * .30,
                        fit: BoxFit.contain,
                      ),
                    ),
                    _buildImageGrid(context, imageList),
                    // _buildFourGrid(context: context, onTap: onViewMore),
                    // _buildFourGrid(context: context, imageUrls: images),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CustomPaint(
                    size: Size(4, 0),
                    painter: DotedLine(
                      dotCount: 18,
                      dotWidth: 2,
                      dotHeight: 6,
                      spacing: 4,
                      color: AppColors.primary,
                      vertical: true,
                    ),
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getHeight(context) * .02),
                      _info("Brand", widget.brand),
                      SizedBox(height: getHeight(context) * .01),

                      _info("Sr . No./MAC/Sim", widget.serial),
                      SizedBox(height: getHeight(context) * .01),

                      _info("Handover", widget.handoverDate),
                      SizedBox(height: getHeight(context) * .01),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _info(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 14,
            fontFamily: 'Gilroy-SemiBold',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 12,
            fontFamily: 'Gilroy-Regular',
          ),
        ),
      ],
    );
  }

  //
  Widget _buildImageGrid(BuildContext context, List<String> images) {
    int showCount = images.length > 3 ? 2 : images.length;
    int extra = images.length - 2;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < showCount; i++)
          _buildImageBox(
            context,
            imagePath: images[i],
            onTap: () => _openPreviewDialog(context, images, startIndex: i),
          ),
        if (images.length > 2)
          GestureDetector(
            onTap: () => _openPreviewDialog(context, images, startIndex: 2),
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black,

                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(images[2]),
                  fit: BoxFit.cover,

                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.4),
                    BlendMode.darken,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '+$extra',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize:
                      Theme.of(context).textTheme.bodySmall?.fontSize ?? 16,
                  fontFamily: 'Gilroy-Medium',
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageBox(
    BuildContext context, {
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _openPreviewDialog(
    BuildContext context,
    List<String> images, {
    required int startIndex,
  }) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: _ImagePreview(images: images, startIndex: startIndex),
      ),
    );
  }
}

//
// Widget _buildFourGrid({VoidCallback? onTap, required BuildContext context}) {
//   return Row(
//     children: [
//       for (int i = 0; i < 2; i++)
//         Container(
//           width: getWidth(context) * .10,
//           height: getWidth(context) * .10,
//
//           margin: const EdgeInsets.only(right: 8),
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(6),
//           ),
//         ),
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: getWidth(context) * .10,
//           height: getWidth(context) * .10,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: const Text(
//             '+4',
//             style: TextStyle(
//               fontWeight: FontWeight.w400,
//               fontSize: 20,
//               color: Colors.black54,
//               fontFamily: 'Gilroy-SemiBold',
//             ),
//           ),
//         ),
//       ),
//     ],
//   );
// }

class _ImagePreview extends StatefulWidget {
  final List<String> images;
  final int startIndex;

  const _ImagePreview({required this.images, required this.startIndex});

  @override
  State<_ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<_ImagePreview> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.startIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: widget.images.length,
          itemBuilder: (context, index) => InteractiveViewer(
            child: Image.asset(widget.images[index], fit: BoxFit.contain),
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
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
