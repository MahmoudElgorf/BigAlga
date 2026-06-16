/// Home page footer with waves and copyright
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/about/pages/about_screen.dart';
import 'package:bioalga/shared/widgets/wave_painter.dart';
import 'package:flutter/material.dart';

class HomeFooter extends StatelessWidget {
  const HomeFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFooterWaves(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                '${AppStrings.poweredBy} ${DateTime.now().year}',
                style: TextStyle(
                  color: AppColors.primaryBlue.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterWaves() {
    return Container(
      height: 20,
      child: CustomPaint(
        painter: WavePainter(reverse: true),
      ),
    );
  }
}