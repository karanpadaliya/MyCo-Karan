import 'dart:io';

import 'package:flutter/material.dart';

double getHeight(context) => MediaQuery.of(context).size.height;

double getWidth(context) => MediaQuery.of(context).size.width;

double getResponsive(context) => MediaQuery.of(context).size.height * 0.001;

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
  final double scaleFactor = MediaQuery.of(context).textScaleFactor;
  return figmaSize / scaleFactor;
}
