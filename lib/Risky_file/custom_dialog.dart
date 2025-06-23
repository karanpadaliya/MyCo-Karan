import 'package:flutter/material.dart';

class MyCoDialog extends StatelessWidget {
  final String title;
  final String description;
  final Widget? image;
  final List<Widget> actions;
  final EdgeInsetsGeometry ? padding;

  const MyCoDialog({
    required this.title, required this.description, required this.actions, super.key,
    this.image,this.padding,
  });

  @override
  Widget build(BuildContext context) => _MyCoDialogMobile(
            title: title,
            description: description,
            image: image,
            actions: actions,
          );
}

class _MyCoDialogMobile extends StatelessWidget {
  final String title;
  final String description;
  final Widget? image;
  final List<Widget> actions;
  final EdgeInsetsGeometry ? padding;

  const _MyCoDialogMobile({
    required this.title,
    required this.description,
    required this.actions, this.image,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogTheme = theme.dialogTheme;

    return Dialog(
      shape: dialogTheme.shape ??
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: dialogTheme.backgroundColor ?? theme.cardColor,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (image != null) ...[
              // const SizedBox(height: 16),
              image!,
            ],
            const SizedBox(height: 22),
            // Title
            Text(
              title,
              style: theme.dialogTheme.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.dialogTheme.contentTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 35),
            // if (image != null) ...[
            //   // const SizedBox(height: 16),
            //   image!,
            // ],
            // const SizedBox(height: 24),

            // Buttons grid
            GridView.builder(
              shrinkWrap: true,
              itemCount: actions.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: actions.length >= 3 ? 3 : actions.length,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
              ),
              itemBuilder: (context, index) => actions[index],
            )
          ],
        ),
      ),
    );
  }
}
