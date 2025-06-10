import 'package:flutter/material.dart';
import 'package:myco_karan/custom_widgets/responsive.dart';
import 'dart:ui';
import '../themes_colors/colors.dart';
import 'doted_line.dart';

class CustomPastAssets extends StatelessWidget {
  final String title;
  final String code;
  final String imageUrl;
  final String brand;
  final String serial;
  final List<Color> gradientContainerColor;
  final String handoverDate;
  final String takeoverDate;
  final VoidCallback? onViewMoreHandover;
  final VoidCallback? onViewMoreTakeover;

  const CustomPastAssets({
    super.key,
    required this.title,
    required this.code,
    required this.imageUrl,
    required this.brand,
    required this.serial,
    required this.handoverDate,
    required this.takeoverDate,
    this.onViewMoreHandover,
    this.onViewMoreTakeover,
    required this.gradientContainerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(12),
      // Color(0xFF29B6F6), Color(0xFF0288D1)
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
                height: getHeight(context) * .08,
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
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize ??
                            18,
                        fontFamily: 'Gilroy-Bold',
                      ),
                    ),
                    Text(
                      "($code)",
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize ??
                            14,
                        fontFamily: 'Gilroy-Medium',
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

          SizedBox(height: getHeight(context) * .02),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _info("Brand", brand, context),
                        const SizedBox(height: 8),
                        _info("Sr . No./MAC/Sim", serial, context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: getWidth(context) * .02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_info("Handover", handoverDate, context)],
                ),
                Spacer(),
                _buildFourGrid(context: context, onTap: onViewMoreHandover),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: getWidth(context) * .02),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_info("Takeover", takeoverDate, context)],
                ),
                Spacer(),
                _buildFourGrid(context: context, onTap: onViewMoreTakeover),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFourGrid({VoidCallback? onTap, required BuildContext context}) {
  return Row(
    children: [
      for (int i = 0; i < 2; i++)
        Container(
          width: getWidth(context) * .14,
          height: getWidth(context) * .14,

          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: getWidth(context) * .14,
          height: getWidth(context) * .14,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '+4',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 20,
              color: Colors.black54,
              fontFamily: 'Gilroy-SemiBold',
            ),
          ),
        ),
      ),
    ],
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
          fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 14,
          fontFamily: 'Gilroy-SemiBold',
        ),
      ),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: Theme.of(context).textTheme.bodySmall?.fontSize ?? 14,
          fontFamily: 'Gilroy-Regular',
        ),
      ),
    ],
  );
}
