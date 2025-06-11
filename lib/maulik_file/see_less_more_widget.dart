import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../themes_colors/colors.dart';

class ExpandableText extends StatefulWidget {
  final String shortText;
  final String longText;

  const ExpandableText({
    required this.shortText,
    required this.longText,
    super.key,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      style: const TextStyle(fontSize: 16, color: Colors.black),
      children:
          _expanded
              ? [
                TextSpan(text: widget.shortText),
                TextSpan(text: widget.longText),
                TextSpan(
                  text: '...see less',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _expanded = false;
                          });
                        },
                ),
              ]
              : [
                TextSpan(text: widget.shortText),
                TextSpan(
                  text: '...see more',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _expanded = true;
                          });
                        },
                ),
              ],
    ),
  );
}
