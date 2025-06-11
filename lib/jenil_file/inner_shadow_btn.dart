// import 'package:flutter/material.dart';
//
// class ExactInnerShadowButton extends StatelessWidget {
//   final String text;
//   final VoidCallback onPressed;
//
//   const ExactInnerShadowButton({
//     super.key,
//     required this.text,
//     required this.onPressed,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       child: Stack(
//         children: [
//           Positioned.fill(
//             child: ClipRRect(
//               // borderRadius: BorderRadius.circular(20),
//               child: CustomPaint(painter: _InnerShadowPainter()),
//             ),
//           ),
//
//           // Top-right mask to hide inner shadow
//           Positioned(
//             top: 0,
//             right: 3,
//             left: 3,
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
//               child: Container(
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Color(0xFF33BFA1),
//                   borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(100),
//                     topLeft: Radius.circular(100),
//                     bottomLeft: Radius.circular(100),
//                     bottomRight: Radius.circular(100),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(50),
//               enableFeedback: false,
//
//               onTap: onPressed,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 32),
//                 decoration: BoxDecoration(
//                   // borderRadius: BorderRadius.circular(10),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   text,
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 18,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _InnerShadowPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Offset.zero & size;
//     final radius = Radius.circular(40);
//     final rrect = RRect.fromRectAndRadius(rect, radius);
//
//     final basePaint = Paint()
//       ..color = const Color(0xFF33BFA1)
//       ..style = PaintingStyle.fill;
//     canvas.drawRRect(rrect, basePaint);
//
//     final shadowPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.bottomLeft,
//         end: Alignment.topRight,
//         colors: [Colors.black, Colors.transparent],
//         stops: [0.0, 0.7],
//       ).createShader(rect)
//       ..blendMode = BlendMode.dstIn
//       ..maskFilter = const MaskFilter.blur(BlurStyle.inner, 12);
//
//     canvas.restore();
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
