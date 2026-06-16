/// Animated background with floating bubbles for home page
import 'package:flutter/material.dart';
import '../../../core/constants/constants.dart';

class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(seconds: 10),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.deepBlue.withOpacity(0.1),
                  AppColors.seaGreen.withOpacity(0.05),
                  AppColors.aqua.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        _buildFloatingBubbles(),
      ],
    );
  }

  Widget _buildFloatingBubbles() {
    return IgnorePointer(
      child: Stack(
        children: [
          _buildBubble(50, 100, 20, 4000),
          _buildBubble(150, 300, 15, 6000),
          _buildBubble(300, 200, 25, 5000),
          _buildBubble(400, 150, 18, 7000),
          _buildBubble(200, 400, 22, 5500),
        ],
      ),
    );
  }

  Widget _buildBubble(double left, double top, double size, int duration) {
    return Positioned(
      left: left,
      top: top,
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: duration),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, -value * 100),
            child: Opacity(
              opacity: 1 - value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.aqua.withOpacity(0.3),
                  border: Border.all(
                    color: AppColors.seaGreen.withOpacity(0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}