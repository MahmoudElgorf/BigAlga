import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class WavePainter extends CustomPainter {
  final bool reverse;

  WavePainter({this.reverse = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = reverse ? AppColors.foam : AppColors.deepBlue
      ..style = PaintingStyle.fill;

    final path = Path();

    if (reverse) {
      path.moveTo(0, size.height);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height);
      path.quadraticBezierTo(size.width * 0.75, size.height * 1.5, size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, 0);
      path.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.5, 0);
      path.quadraticBezierTo(size.width * 0.75, -size.height * 0.5, size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}