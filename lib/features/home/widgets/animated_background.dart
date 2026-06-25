/// Lightweight animated background

import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepBlue.withOpacity(0.08),
              AppColors.seaGreen.withOpacity(0.04),
              AppColors.aqua.withOpacity(0.08),
            ],
          ),
        ),
        child: Stack(
          children: const [
            _Bubble(left: 50, top: 100, size: 22),
            _Bubble(left: 170, top: 260, size: 14),
            _Bubble(left: 320, top: 180, size: 26),
            _Bubble(left: 120, top: 430, size: 18),
            _Bubble(left: 270, top: 520, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double left;
  final double top;
  final double size;

  const _Bubble({
    required this.left,
    required this.top,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.aqua.withOpacity(.15),
          border: Border.all(
            color: AppColors.seaGreen.withOpacity(.25),
          ),
        ),
      ),
    );
  }
}