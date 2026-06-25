/// Gradient background widget with foam, sand, and aqua colors

import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  static final LinearGradient _gradient = LinearGradient(
    colors: [
      AppColors.foam,
      AppColors.sand.withOpacity(0.3),
      AppColors.aqua.withOpacity(0.1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: _gradient,
        ),
        child: SizedBox.expand(
          child: child,
        ),
      ),
    );
  }
}