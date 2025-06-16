import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const ModalBarrier(
          dismissible: false,
          color: Colors.black38,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Lottie.asset(
              'assets/loader/myco_splash.json',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
