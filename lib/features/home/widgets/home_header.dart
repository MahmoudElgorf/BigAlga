/// Home page header with app name and decorative waves
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/shared/widgets/wave_painter.dart';
import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.headerHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.secondaryBlue,
            AppColors.accentGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildHeaderWaves(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMenuRow(context),
                const SizedBox(height: 30),
                _buildDecorativeWave(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWaves() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 40,
        child: CustomPaint(
          painter: WavePainter(),
        ),
      ),
    );
  }

  Widget _buildMenuRow(BuildContext context) {
    return Row(
      children: [
        Builder(
          builder: (context) => Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(
                Icons.menu,
                color: Colors.white,
                size: 24,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(
                  color: AppColors.textWhite,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: AppColors.primaryBlue.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.appSlogan,
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.95),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecorativeWave() {
    return Container(
      height: 4,
      width: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightGreen,
            AppColors.textWhite.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}