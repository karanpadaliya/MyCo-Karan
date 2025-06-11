import 'dart:ui';

import 'package:flutter/material.dart';

@immutable
class CustomDropdownTheme extends ThemeExtension<CustomDropdownTheme> {
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final Color? dropdownBackgroundColor;
  final ShapeBorder? dropdownShape;
  final double? dropdownElevation;

  const CustomDropdownTheme({
    this.textStyle,
    this.decoration,
    this.dropdownBackgroundColor,
    this.dropdownShape,
    this.dropdownElevation,
  });

  @override
  CustomDropdownTheme copyWith({
    TextStyle? textStyle,
    InputDecoration? decoration,
    Color? dropdownBackgroundColor,
    ShapeBorder? dropdownShape,
    double? dropdownElevation,
  }) {
    return CustomDropdownTheme(
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      dropdownBackgroundColor:
          dropdownBackgroundColor ?? this.dropdownBackgroundColor,
      dropdownShape: dropdownShape ?? this.dropdownShape,
      dropdownElevation: dropdownElevation ?? this.dropdownElevation,
    );
  }

  @override
  CustomDropdownTheme lerp(
      ThemeExtension<CustomDropdownTheme>? other, double t) {
    if (other is! CustomDropdownTheme) return this;
    return CustomDropdownTheme(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      decoration: decoration,
      dropdownBackgroundColor:
          Color.lerp(dropdownBackgroundColor, other.dropdownBackgroundColor, t),
      dropdownShape: dropdownShape,
      dropdownElevation:
          lerpDouble(dropdownElevation, other.dropdownElevation, t),
    );
  }
}
