import 'package:flutter/material.dart';

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
  final Color? cardbgr;
  final OutlinedBorder? cardshape;
  final double? cardelevation;
  final EdgeInsetsGeometry? cardmargin;
  final EdgeInsetsGeometry? cardpadding;
  final double? cardheight;
  final double? cardwidth;
  final TextStyle? firstnamestyle;
  final TextStyle? lastnamestyle;
  final double? imageheight;
  final double? imagewidth;
  final Decoration? decoration;
  final double? statusheight;
  final double? statuswidth;

  const OverlappingPeopleCard(
      {super.key,
      required this.people,
      this.cardbgr,
      this.cardshape,
      this.cardelevation,
      this.cardmargin,
      this.cardpadding,
      this.cardheight,
      this.cardwidth,
      this.firstnamestyle,
      this.lastnamestyle,
      this.imageheight,
      this.imagewidth,
      this.decoration,
      this.statusheight,
      this.statuswidth});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardbgr ?? Colors.white,
      shape: cardshape ??
          RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade400)),
      elevation: cardelevation ?? 0,
      margin: cardmargin ?? EdgeInsets.all(16),
      child: Padding(
        padding: cardpadding ?? EdgeInsets.all(16),
        child: Column(
          children: [
            // Centered overlapping avatars with names below
            Center(
              child: SizedBox(
                height: cardheight ?? 145,
                width: cardwidth ?? double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(people.length, (index) {
                    final person = people[index];
                    final Color statusColor =
                        person.isActive ? Color(0xFF1CE742) : Colors.red;
                    return Positioned(
                      left: index * 77, // Controls horizontal overlap
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: imagewidth ?? 100,
                                height: imageheight ?? 90,
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
                                  width: statusheight ?? 12,
                                  height: statuswidth ?? 18,
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
                                  style: firstnamestyle ??
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
                                  style: lastnamestyle ??
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
