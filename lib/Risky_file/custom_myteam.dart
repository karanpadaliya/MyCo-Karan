import 'package:flutter/material.dart';
import 'package:myco_karan/themes_colors/colors.dart';

class PersonData {
  final String firstName;
  final String lastName;
  final String imagePath;
  final bool isActive;

  PersonData({
    this.isActive = false,
    required this.firstName,
    required this.lastName,
    required this.imagePath,
  });
}

class OverlappingPeopleCard extends StatelessWidget {
  final List<PersonData> people;
  final Color? cardBgr;
  final OutlinedBorder? cardShape;
  final double? cardElevation;
  final EdgeInsetsGeometry? cardMargin;
  final EdgeInsetsGeometry? cardPadding;
  final double? cardHeight;
  final double? cardWidth;
  final TextStyle? firstNameStyle;
  final TextStyle? lastNameStyle;
  final double? imageHeight;
  final double? imageWidth;
  final Decoration? decoration;
  final double? statusHeight;
  final double? statusWidth;

  const OverlappingPeopleCard(
      {super.key,
      required this.people,
      this.cardBgr,
      this.cardShape,
      this.cardElevation,
      this.cardMargin,
      this.cardPadding,
      this.cardHeight,
      this.cardWidth,
      this.firstNameStyle,
      this.lastNameStyle,
      this.imageHeight,
      this.imageWidth,
      this.decoration,
      this.statusHeight,
      this.statusWidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBgr ?? Colors.white,
      shape: cardShape ??
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.borderGrey)),
      elevation: cardElevation ?? 0,
      margin: cardMargin ?? EdgeInsets.all(16),
      child: Padding(
        padding: cardPadding ?? EdgeInsets.all(16),
        child: Column(
          children: [
            // Centered overlapping avatars with names below
            Center(
              child: SizedBox(
                height: cardHeight ?? 145,
                width: cardWidth ?? double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(people.length, (index) {
                    final person = people[index];
                    final Color statusColor =
                        person.isActive ? Color(0xFF1CE742) : Colors.red;
                    return Positioned(
                      left: index * 75, // Controls horizontal overlap
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: imageWidth ?? 100,
                                height: imageHeight ?? 90,
                                decoration: decoration ??
                                    BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image:
                                            person.imagePath.startsWith('http')
                                                ? NetworkImage(person.imagePath)
                                                : AssetImage(person.imagePath)
                                                    as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                    ),
                              ),
                              Positioned(
                                bottom: -3,
                                right: 44,
                                child: Container(
                                  width: statusHeight ?? 12,
                                  height: statusWidth ?? 18,
                                  decoration: decoration ??
                                      BoxDecoration(
                                        color: statusColor,
                                        shape: BoxShape.circle,
                                        // border: Border.all(color: Colors.white, width: 2),
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 90,
                            child: Column(
                              children: [
                                Text(
                                  person.firstName,
                                  style: firstNameStyle ??
                                      TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  person.lastName,
                                  style: lastNameStyle ??
                                      TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
