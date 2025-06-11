import 'dart:io';

import 'package:flutter/material.dart';

double getHeight(context) {
  return MediaQuery.of(context).size.height;
}

double getWidth(context) {
  return MediaQuery.of(context).size.width;
}

double getResponsive(context) {
  return MediaQuery.of(context).size.height * 0.001;
}

double getResponsiveText(context) {
  if (Platform.isAndroid) {
    return 0.8;
  } else {
    return 0.9;
  }
}

double figmaHeightToFlutter(double figmaPx) {
  return (figmaPx / 1600) * 100; // Base height is now 1600px
}

double figmaWidthToFlutter(double figmaPx) {
  return (figmaPx / 2560) * 100; // Base width is now 2560px
}

double figmaToFlutterTextSize(double figmaSize, BuildContext context) {
  double scaleFactor = MediaQuery.of(context).textScaleFactor;
  return figmaSize / scaleFactor;
}

//
// SizedBox(height: r * 12),
// Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// Flexible(
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(
// "Created By",
// style: TextStyle(
// fontSize: r * 12 * rt,
// fontFamily: 'Gilroy-Italic',
// fontStyle: FontStyle.italic,
// fontWeight: FontWeight.bold,
// ),
// ),
// Text(
// handover,
// style: TextStyle(
// fontSize: r * 14 * rt,
// fontFamily: 'Gilroy-Regular',
// ),
// ),
// ],
// ),
// ),
// ElevatedButton(
// style: ElevatedButton.styleFrom(
// backgroundColor: AppColors.primary,
// shape: RoundedRectangleBorder(
// borderRadius: BorderRadius.circular(r * 30),
// ),
// padding: EdgeInsets.symmetric(
// horizontal: r * 20,
// vertical: r * 10,
// ),
// ),
// onPressed: onViewDetails,
// child: Text(
// "View Details",
// style: TextStyle(
// fontSize: r * 14 * rt,
// fontFamily: 'Gilroy-SemiBold',
// color: Colors.white,
// ),
// ),
// ),
// ],
// ),
//
//
//
//
//
//
//
//
//
//
//
//
//
//
// Container(
// height: h * 0.04,
// width: r * 1,
// color: Colors.grey.shade400,
// margin: EdgeInsets.symmetric(horizontal: r * 8),
// ),
//
//
//
//
// final VoidCallback onEdit;
// final VoidCallback onQRCode;
// final VoidCallback onViewDetails;
