import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/responsive.dart';
import '../themes_colors/colors.dart';
import 'doted_line.dart';
import 'inner_shadow_btn.dart';
import 'new_myco_button.dart';

class CustomAllAssets extends StatelessWidget {
  final String title;
  final String code;
  final String imageUrl;
  final String brand;
  final String category;
  final String serial;
  final String handover;
  final List<Color> gradientContainerColor;
  final VoidCallback onEdit;
  final VoidCallback onQRCode;
  final VoidCallback onViewDetails;

  const CustomAllAssets({
    super.key,
    required this.title,
    required this.code,
    required this.imageUrl,
    required this.brand,
    required this.serial,
    required this.handover,
    required this.onEdit,
    required this.onQRCode,
    required this.onViewDetails,
    required this.category,
    required this.gradientContainerColor,
  });

  @override
  Widget build(BuildContext context) {
    final r = getResponsive(context);
    final rt = getResponsiveText(context);
    final h = getHeight(context);
    // final w = getWidth(context);

    return Container(
      margin: EdgeInsets.all(r * 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r * 13),
        border: Border.all(color: AppColors.borderColor, width: r * 1.5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: r * 6,
            spreadRadius: r * 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: h * .08,
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
                    colors: gradientContainerColor,
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: r * 16,
                  vertical: r * 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.fontSize ??
                                  14,
                              fontFamily: 'Gilroy-SemiBold',
                            ),
                          ),
                          Text(
                            "($code)",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize:
                                  Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.fontSize ??
                                  14,
                              fontFamily: 'Gilroy-SemiBold',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: onEdit,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.qr_code_2,
                            color: Colors.white,
                          ),
                          onPressed: onQRCode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: r * 25,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(r * 16),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x33FFFFFF), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h * .01),
          Container(
            // padding: EdgeInsets.all(getResponsive(context) * 10),
            decoration: BoxDecoration(
              // border: Border(
              //   left: BorderSide(color: AppColors.primary),
              //   right: BorderSide(color: AppColors.primary),
              //   bottom: BorderSide(color: AppColors.primary),
              // ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    imageUrl,
                    height: getHeight(context) * .15,
                    width: getHeight(context) * .15,
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(width: 10),

                CustomPaint(
                  size: Size(4, 0),
                  painter: DotedLine(
                    dotCount: 13,
                    dotWidth: 2,
                    dotHeight: 6,
                    spacing: 4,
                    color: AppColors.primary,
                    vertical: true,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 15, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _info("Category", category, context),
                            ),
                            Container(
                              height: h * 0.08,
                              width: r * 1,
                              color: Colors.grey.shade400,
                              margin: EdgeInsets.symmetric(horizontal: r * 15),
                            ),
                            Expanded(child: _info("Brand", brand, context)),
                          ],
                        ),
                        SizedBox(height: h * 0.005),
                        _info("Sr . No./MAC/Sim", serial, context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _info("Handover", handover, context)),

                Expanded(
                  child: MyCoButton(
                    onTap: () {},
                    title: "View More",
                    boarderRadius: 100,
                  ),
                ),
                // CustomShadowButton(
                //   text: 'View Details',
                //   color: Color(0xFF00B3C6),
                //   onPressed: () {},
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(String title, String value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
            fontFamily: 'Gilroy-SemiBold',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
            fontFamily: 'Gilroy-Regular',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class CustomShadowButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final TextStyle? textStyle;

  const CustomShadowButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.width = 180,
    this.height = 50,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CustomPaint(
        painter: _InnerShadowPainter(),
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Text(
            text,
            style:
                textStyle ??
                TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize:
                      Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
                  fontFamily: 'Gilroy-SemiBold',
                ),
          ),
        ),
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outerRRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height / 2),
    );

    final shadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.black, Colors.black38],
      ).createShader(Rect.fromLTWH(10, 50, size.width, size.height))
      ..blendMode = BlendMode.dstIn;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRRect(outerRRect, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
