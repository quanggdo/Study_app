import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 44),
      decoration: const BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Decorative circles ──
          Positioned(
            right: -20,
            top: -20,
            child: _DecorCircle(size: 130, opacity: 0.06),
          ),
          Positioned(
            right: 40,
            bottom: -10,
            child: _DecorCircle(size: 80, opacity: 0.08),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: _DecorCircle(size: 100, opacity: 0.05),
          ),

          // ── Content ──
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon container with glow
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.20),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 32, color: Colors.white),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      delay: 100.ms,
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  style:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withOpacity(0.78),
                        height: 1.4,
                      ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple decorative semi-transparent circle.
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}

/// A small radial "starburst" painter to add subtle texture behind the header.
class _StarburstPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const int lines = 24;
    final center = Offset(size.width * 0.85, size.height * 0.3);
    const double radius = 90;

    for (int i = 0; i < lines; i++) {
      final angle = (i / lines) * 2 * math.pi;
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
