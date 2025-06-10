import 'package:flutter/material.dart';

/// --- THEME EXTENSION SECTION ---
class NoDataViewTheme {
  final TextStyle labelStyle;
  final double imageHeight;

  const NoDataViewTheme({
    required this.labelStyle,
    required this.imageHeight,
  });
}

extension NoDataThemeExtension on ThemeData {
  NoDataViewTheme get noDataViewTheme => NoDataViewTheme(
        labelStyle: textTheme.bodyLarge!.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        imageHeight: 100,
      );
}

class NoDataView extends StatelessWidget {
  final String label;
  final Widget? image;
  final AxisDirection imagePosition;

  /// Optional image size customization
  final double? imageWidth;
  final double? imageHeight;

  /// Custom button widget
  final Widget? button;
  final double? spacing;

  const NoDataView({
    super.key,
    required this.label,
    this.image,
    this.imagePosition = AxisDirection.up,
    this.imageWidth,
    this.imageHeight,
    this.button,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return screenHeight < 1100
        ? _NoDataViewMobile(
            label: label,
            image: image,
            imagePosition: imagePosition,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            button: button,
            spacing: spacing,
          )
        : _NoDataViewTablet(
            label: label,
            image: image,
            imagePosition: imagePosition,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            button: button,
            spacing: spacing,
          );
  }
}

class _NoDataViewMobile extends StatelessWidget {
  final String label;
  final Widget? image;
  final AxisDirection imagePosition;

  /// Optional image size customization
  final double? imageWidth;
  final double? imageHeight;

  /// Custom button widget
  final Widget? button;
  final double? spacing;
  const _NoDataViewMobile({
    required this.label,
    this.image,
    this.imagePosition = AxisDirection.up,
    this.imageWidth,
    this.imageHeight,
    this.button,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final noDataTheme = Theme.of(context).noDataViewTheme;

    List<Widget> content = [];

    if (image != null) {
      content.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          height: imageHeight ?? noDataTheme.imageHeight,
          width: imageWidth,
          child: image,
        ),
      ));
      content.add(SizedBox(height: spacing ?? 0));
    }

    content.add(
      Text(
        label,
        textAlign: TextAlign.center,
        style: noDataTheme.labelStyle,
      ),
    );
    content.add(SizedBox(height: spacing ?? 0));

    if (button != null) {
      content.add(const SizedBox(height: 20));
      content.add(button!);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
      ),
    );
  }
}

class _NoDataViewTablet extends StatelessWidget {
  final String label;
  final Widget? image;
  final AxisDirection imagePosition;
  final double? imageWidth;
  final double? imageHeight;
  final Widget? button;
  final double? spacing;
  const _NoDataViewTablet({
    required this.label,
    this.image,
    this.imagePosition = AxisDirection.up,
    this.imageWidth,
    this.imageHeight,
    this.button,
    this.spacing,
  });
  @override
  Widget build(BuildContext context) {
    final noDataTheme = Theme.of(context).noDataViewTheme;

    List<Widget> content = [];

    if (image != null) {
      content.add(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          height: imageHeight ?? noDataTheme.imageHeight,
          width: imageWidth,
          child: image,
        ),
      ));
      content.add(SizedBox(height: spacing ?? 0));
    }

    content.add(
      Text(
        label,
        textAlign: TextAlign.center,
        style: noDataTheme.labelStyle,
      ),
    );
    content.add(SizedBox(height: spacing ?? 0));

    if (button != null) {
      content.add(const SizedBox(height: 20));
      content.add(button!);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: content,
        ),
      ),
    );
  }
}
