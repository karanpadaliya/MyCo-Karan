import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes_colors/app_theme.dart';
import '../themes_colors/colors.dart';
import '../karan_file/new_myco_button.dart';

void showCustomEmailVerificationSheet({
  required BuildContext context,
  required String emailAddress,
  required void Function(String otp) onSubmit,
  required VoidCallback onResend,
  required VoidCallback onVerifyButtonPressed,
  bool isDialog = false,
  int length = 6,
}) {
  isDialog
      ? showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              backgroundColor: AppColors.white,
              content: _EmailVerificationContent(
                emailAddress: emailAddress,
                length: length,
                onSubmit: onSubmit,
                onResend: onResend,
                onVerifyButtonPressed: onVerifyButtonPressed,
              ),
            ),
      )
      : showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder:
            (context) => _EmailVerificationContent(
              emailAddress: emailAddress,
              length: length,
              onSubmit: onSubmit,
              onResend: onResend,
              onVerifyButtonPressed: onVerifyButtonPressed,
            ),
      );
}

class _EmailVerificationContent extends StatefulWidget {
  final String emailAddress;
  final void Function(String otp) onSubmit;
  final VoidCallback onResend;
  final VoidCallback onVerifyButtonPressed;
  final int length;

  const _EmailVerificationContent({
    required this.emailAddress,
    required this.onSubmit,
    required this.onResend,
    required this.onVerifyButtonPressed,
    required this.length,
  });

  @override
  State<_EmailVerificationContent> createState() =>
      _EmailVerificationContentState();
}

class _EmailVerificationContentState extends State<_EmailVerificationContent> {
  String currentOtp = "";

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 48,
            left: 20,
            right: 20,
            bottom: mediaQuery.viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                "Email Verification Sent!",
                style: TextStyle(
                  fontSize: AppTheme.lightTheme.textTheme.titleLarge!.fontSize,
                  color: AppColors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "A verification code will be sent to the email${widget.emailAddress} for your account verification process.",
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: AppTheme.lightTheme.textTheme.bodyMedium!.fontSize,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              OTPInputField(
                length: widget.length,
                onCompleted: (_) {},
                onChanged: (code) {
                  setState(() {
                    currentOtp = code;
                  });
                },
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Haven't received the code? ",
                    style: TextStyle(
                      fontSize:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onResend,
                    child: Text(
                      "Resend it.",
                      style: TextStyle(
                        fontSize:
                            AppTheme.lightTheme.textTheme.bodyMedium!.fontSize,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              MyCoButton(
                height: 40,
                // width: 150,
                onTap:
                    currentOtp.length == widget.length
                        ? () {
                          widget.onVerifyButtonPressed();
                          widget.onSubmit(currentOtp);
                          Navigator.pop(context);
                        }
                        : null,
                title: 'Submit',
                boarderRadius: 50,
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "signin with different method? ",
                    style: TextStyle(
                      fontSize:
                          AppTheme.lightTheme.textTheme.bodyMedium!.fontSize,
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onResend,
                    child: Text(
                      "Here",
                      style: TextStyle(
                        fontSize:
                            AppTheme.lightTheme.textTheme.bodyMedium!.fontSize,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        Positioned(
          top: -30,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              height: 64,
              width: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/mail1.png',
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OTPInputField extends StatefulWidget {
  final int length;
  final void Function(String code) onCompleted;
  final void Function(String code)? onChanged;

  const OTPInputField({
    Key? key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
  }) : super(key: key);

  @override
  State<OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<OTPInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
  }

  void _onKeyPress(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      widget.onChanged?.call(_controllers.map((c) => c.text).join());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 5,
      children: List.generate(widget.length, (index) {
        return Expanded(
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyPress(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              maxLength: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.primary,width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) => _onChanged(index, val),
            ),
          ),
        );
      }),
    );
  }
}
