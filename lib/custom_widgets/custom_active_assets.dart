import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/responsive.dart';
import '../themes_colors/colors.dart';
import 'doted_line.dart';

class CustomActiveAssets extends StatelessWidget {
  final String title;
  final String code;
  final String imageUrl;
  final String brand;
  final String serial;
  final String handover;
  final List<Color> gradientContainerColor;

  const CustomActiveAssets({
    super.key,
    required this.title,
    required this.code,
    required this.imageUrl,
    required this.brand,
    required this.serial,
    required this.handover,
    required this.gradientContainerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.borderColor, width: 1.5),
        color: Colors.white,
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
                // height: getHeight(context) * .08,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize ??
                            14,
                        fontFamily: 'Gilroy-SemiBold',
                      ),
                    ),
                    Text(
                      "($code)",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize ??
                            14,
                        fontFamily: 'Gilroy-SemiBold',
                      ),
                    ),
                  ],
                ),
              ),

              // Inner top shadow (white gradient)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 25,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: const LinearGradient(
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

          SizedBox(height: getHeight(context) * .01),
          Container(
            padding: EdgeInsets.all(getResponsive(context) * 12),
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
                Image.asset(
                  imageUrl,
                  height: getHeight(context) * .18,
                  width: getHeight(context) * .15,
                  fit: BoxFit.contain,
                ),

                const SizedBox(width: 12),

                CustomPaint(
                  size: Size(4, 0),
                  painter: DotedLine(
                    dotCount: 16,
                    dotWidth: 2,
                    dotHeight: 6,
                    spacing: 4,
                    color: AppColors.primary,
                    vertical: true,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 3,
                    children: [
                      _info("Brand", brand, context),
                      const SizedBox(height: 8),
                      _info("Sr . No./MAC/Sim", serial, context),
                      const SizedBox(height: 8),
                      _info("Handover", handover, context),
                    ],
                  ),
                ),
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
            fontWeight: FontWeight.w400,
            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14,
            fontFamily: 'Gilroy-SemiBold',
          ),
        ),
      ],
    );
  }
}
