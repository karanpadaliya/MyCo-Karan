import 'package:flutter/material.dart';
import 'package:myco_karan/jenil_file/responsive.dart';
import '../themes_colors/colors.dart';

class CustomAssetsHistory extends StatelessWidget {
  final String userName;
  final String designation;
  final String location;
  final String takeoverDate;
  final String handoverDate;
  final List<Color> gradientContainerColor;
  final VoidCallback? onViewMore;

  const CustomAssetsHistory({
    super.key,
    required this.userName,
    required this.designation,
    required this.location,
    required this.takeoverDate,
    required this.handoverDate,
    this.onViewMore,
    required this.gradientContainerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    colors: gradientContainerColor,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
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

          ListTile(
            leading: const CircleAvatar(
              backgroundImage: AssetImage("assets/girl.jpg"),
              radius: 35,
            ),
            title: Text(
              userName,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize ?? 14,
                fontFamily: 'Gilroy-SemiBold',
              ),
            ),
            subtitle: Text('$designation\n$location'),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _info("Takeover Date", takeoverDate, context),
                _info("Handover Date", handoverDate, context),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 12),
            child: _buildFourGrid(onTap: onViewMore, context: context),
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

  Widget _buildFourGrid({VoidCallback? onTap, required BuildContext context}) {
    return Row(
      children: [
        for (int i = 0; i < 2; i++)
          Container(
            width: getWidth(context) * .15,
            height: getWidth(context) * .15,

            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: getWidth(context) * .15,
            height: getWidth(context) * .15,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              '+4',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: 'Gilroy-SemiBold',
              ),
            ),
          ),
        ),
      ],
    );
  }
}
