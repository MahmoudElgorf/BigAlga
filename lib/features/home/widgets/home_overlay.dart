/// Loading overlay widget

import 'package:flutter/material.dart';
import 'package:bioalga/core/constants/constants.dart';

class HomeLoadingOverlay extends StatelessWidget {
  const HomeLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: ColoredBox(
        color: Color(0x88000000),
        child: Center(
          child: _LoadingContent(),
        ),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircularProgressIndicator(
          color: AppColors.lightGreen,
          strokeWidth: 3,
        ),
        SizedBox(height: 20),
        Text(
          AppStrings.analyzing,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          AppStrings.analyzingRemote,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}