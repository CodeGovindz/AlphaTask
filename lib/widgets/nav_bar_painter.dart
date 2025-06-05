import 'package:flutter/material.dart';

class NavBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final Paint border = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final double notchRadius = 36;
    final double notchCenterX = size.width / 2;
    final double barHeight = size.height - 4;
    final double cornerRadius = 28;
    final double notchDepth = 36; // How deep the cradle dips

    Path path = Path();
    // Start from bottom left
    path.moveTo(cornerRadius, barHeight);
    // Left curve up
    path.quadraticBezierTo(0, barHeight, 0, barHeight - cornerRadius);
    path.lineTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    // Line to left of notch
    path.lineTo(notchCenterX - notchRadius - 16, 0);
    // Concave cradle notch
    path.cubicTo(
      notchCenterX - notchRadius, 0,
      notchCenterX - notchRadius, notchDepth,
      notchCenterX, notchDepth,
    );
    path.cubicTo(
      notchCenterX + notchRadius, notchDepth,
      notchCenterX + notchRadius, 0,
      notchCenterX + notchRadius + 16, 0,
    );
    // Line to top right
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, barHeight - cornerRadius);
    path.quadraticBezierTo(size.width, barHeight, size.width - cornerRadius, barHeight);
    path.lineTo(cornerRadius, barHeight);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 