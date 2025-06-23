import 'package:flutter/material.dart';
import '../../themes_colors/colors.dart';

class AppSnackbar {
  static void showError(
    BuildContext context,
    String message, {
    bool top = false,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.error.withValues(alpha: 0.9),
      icon: Icons.warning_amber_rounded,
      top: top,
    );
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    bool top = false,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.secondPrimary.withValues(alpha: 0.95),
      icon: Icons.check_circle_rounded,
      top: top,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    bool top = false,
  }) {
    _showSnackBar(
      context,
      message,
      backgroundColor: AppColors.primary.withValues(alpha: 0.95),
      icon: Icons.info_outline,
      top: top,
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required IconData icon,
    bool top = false,
  }) {
    final overlay = Overlay.of(context);

    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: top ? 100 : null,
            bottom: top ? null : 80,
            left: 20,
            right: 20,
            child: AnimatedSnackBarContent(
              message: message,
              icon: icon,
              backgroundColor: backgroundColor,
              fromTop: top,
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }
}

class AnimatedSnackBarContent extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final bool fromTop;

  const AnimatedSnackBarContent({
    super.key,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    this.fromTop = false,
  });

  @override
  State<AnimatedSnackBarContent> createState() =>
      _AnimatedSnackBarContentState();
}

class _AnimatedSnackBarContentState extends State<AnimatedSnackBarContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.fromTop ? const Offset(0, -1) : const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Material(
        elevation: 10,
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(widget.icon, color: AppColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
