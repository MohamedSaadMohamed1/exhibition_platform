import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Beautiful dark purple background with flowing abstract shapes
class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0A0014), // Near-black deep purple
            const Color(0xFF160030), // Dark purple family
            const Color(0xFF220045), // Slightly lighter deep purple
            const Color(0xFF0A0014), // Near-black deep purple
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Abstract flowing shapes
          Positioned(
            top: -100,
            right: -150,
            child: _buildGlowingOrb(
              size: 350,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: _buildGlowingOrb(
              size: 300,
              color: AppColors.primaryDark.withOpacity(0.25),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -80,
            child: _buildGlowingOrb(
              size: 200,
              color: const Color(0xFF6218B0).withOpacity(0.2),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            left: -60,
            child: _buildGlowingOrb(
              size: 180,
              color: AppColors.primaryDark.withOpacity(0.15),
            ),
          ),
          // Flowing curves
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: FlowingCurvesPainter(),
          ),
          // Child content
          child,
        ],
      ),
    );
  }

  Widget _buildGlowingOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withOpacity(0.5),
            color.withOpacity(0.0),
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
    );
  }
}

/// Custom painter for flowing curves
class FlowingCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // First flowing curve - purple
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF8C30E8).withOpacity(0.0),
        const Color(0xFF8C30E8).withOpacity(0.4),
        const Color(0xFF6218B0).withOpacity(0.3),
        const Color(0xFF6218B0).withOpacity(0.0),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path1 = Path();
    path1.moveTo(0, size.height * 0.3);
    path1.cubicTo(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.4,
      size.width * 0.75,
      size.height * 0.35,
    );
    path1.cubicTo(
      size.width * 0.9,
      size.height * 0.32,
      size.width,
      size.height * 0.4,
      size.width * 1.1,
      size.height * 0.5,
    );
    canvas.drawPath(path1, paint);

    // Second flowing curve
    paint.shader = LinearGradient(
      colors: [
        const Color(0xFF6218B0).withOpacity(0.0),
        const Color(0xFF6218B0).withOpacity(0.3),
        const Color(0xFF8C30E8).withOpacity(0.4),
        const Color(0xFF8C30E8).withOpacity(0.0),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path2 = Path();
    path2.moveTo(-50, size.height * 0.7);
    path2.cubicTo(
      size.width * 0.2,
      size.height * 0.65,
      size.width * 0.4,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.75,
    );
    path2.cubicTo(
      size.width * 0.8,
      size.height * 0.7,
      size.width * 0.95,
      size.height * 0.85,
      size.width * 1.1,
      size.height * 0.9,
    );
    canvas.drawPath(path2, paint);

    // Third subtle curve
    paint.strokeWidth = 0.8;
    paint.shader = LinearGradient(
      colors: [
        Colors.white.withOpacity(0.0),
        Colors.white.withOpacity(0.05),
        Colors.white.withOpacity(0.08),
        Colors.white.withOpacity(0.0),
      ],
      stops: const [0.0, 0.3, 0.7, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path3 = Path();
    path3.moveTo(0, size.height * 0.5);
    path3.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.45,
      size.width,
      size.height * 0.55,
    );
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
