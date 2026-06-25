/// Loading indicator widget with custom message

import 'package:flutter/material.dart';
import '../../core/constants/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    this.message = AppStrings.loading,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: AppColors.seaGreen,
              size: 42,
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}