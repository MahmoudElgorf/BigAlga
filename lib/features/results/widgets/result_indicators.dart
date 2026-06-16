/// Confidence and sellable indicators
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ConfidenceIndicator extends StatelessWidget {
  final double confidence;

  const ConfidenceIndicator({super.key, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    final isConfident = confidence >= 0.70;
    final color = isConfident ? AppColors.successGreen : AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                AppStrings.confidenceIndicator,
                style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                percentage,
                style: TextStyle(
                  color: AppColors.darkText.withOpacity(0.9),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  color: AppColors.darkText.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isConfident ? AppStrings.confidenceSufficient : AppStrings.confidenceVerify,
            style: TextStyle(color: AppColors.darkText.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class SellableIndicator extends StatelessWidget {
  final String sellable;

  const SellableIndicator({super.key, required this.sellable});

  @override
  Widget build(BuildContext context) {
    final normalized = sellable.toLowerCase();
    late final Color color;
    late final IconData icon;
    late final String message;

    if (normalized.startsWith('not') ||
        normalized.contains('not suitable') ||
        normalized.contains('not recommended')) {
      color = AppColors.errorRed;
      icon = Icons.cancel_outlined;
      message = AppStrings.sellableNotRecommended;
    } else if (normalized.startsWith('suitable') || normalized.startsWith('yes')) {
      color = AppColors.successGreen;
      icon = Icons.check_circle_outline;
      message = AppStrings.sellableSuitable;
    } else {
      color = AppColors.warningOrange;
      icon = Icons.warning_amber_outlined;
      message = AppStrings.sellableConditional;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}