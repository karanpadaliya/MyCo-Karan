import 'package:flutter/material.dart';
import 'package:myco_karan/karan_file/custom_myco_button/custom_myco_button.dart';
import 'package:myco_karan/themes_colors/colors.dart';

class CustomProfileCard extends StatelessWidget {
  final String name;
  final String description;
  final String imagePath;
  final String chipLabel;
  final String buttonLabel;
  final VoidCallback onButtonPressed;
  final EdgeInsetsGeometry? cardPadding;
  final double? borderRadius;
  final double? cardHeight;
  final double? cardWidth;
  final double? imageHeight;
  final double? imageWidth;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? chipPadding;
  final Color? chipBgr;
  final TextStyle? nameTextStyle;
  final TextStyle? descTextStyle;
  final TextStyle? chipTextStyle;
  final Icon? chipIcon;
  final OutlinedBorder? shape;
  final Decoration? decoration;
  final double? imageRadius;
  final double? elevation;

  const CustomProfileCard({
    super.key,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.chipLabel,
    required this.buttonLabel,
    required this.onButtonPressed,
    this.borderRadius,
    this.cardPadding,
    this.cardHeight,
    this.cardWidth,
    this.imageHeight,
    this.imageWidth,
    this.contentPadding,
    this.chipPadding,
    this.chipBgr,
    this.nameTextStyle,
    this.descTextStyle,
    this.chipTextStyle,
    this.chipIcon,
    this.shape,
    this.decoration,
    this.imageRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardHeight ?? 270,
      width: cardWidth ?? double.infinity,
      child: Padding(
        padding: cardPadding ?? EdgeInsets.all(13.0),
        child: Card(
          elevation: elevation ?? 0,

          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.borderGrey),
          ),
          child: Stack(
            children: [
              Padding(
                padding:
                    contentPadding ??
                    EdgeInsets.only(top: 37, left: 27, right: 27, bottom: 15),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: imageHeight ?? 80,
                          height: imageWidth ?? 80,
                          decoration:
                              decoration ??
                              BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                          child: CircleAvatar(
                            backgroundImage:
                                imagePath.startsWith('http')
                                    ? NetworkImage(imagePath)
                                    : AssetImage(imagePath) as ImageProvider,
                            radius: imageRadius ?? 40,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            title: Text(
                              name,
                              style:
                                  nameTextStyle ??
                                  TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                            ),
                            subtitle: Text(
                              description,
                              style:
                                  descTextStyle ??
                                  TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.black,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 13),
                    Divider(height: 10, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    MyCoButton(
                      onTap: onButtonPressed,
                      title: buttonLabel,
                      boarderRadius: borderRadius,
                    ),
                  ],
                ),
              ),
              // Positioned Chip
              Positioned(
                top: 10,
                right: 18,
                child: Chip(
                  label: Text(
                    chipLabel,
                    style:
                        chipTextStyle ??
                        TextStyle(fontSize: 15, color: AppColors.secondary),
                  ),
                  avatar:
                      chipIcon ??
                      Icon(
                        Icons.card_giftcard,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                  padding:
                      chipPadding ??
                      EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                  backgroundColor: chipBgr ?? AppColors.primary,
                  visualDensity: VisualDensity.standard,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape:
                      shape ??
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
