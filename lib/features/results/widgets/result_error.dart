/// Error widgets for results page
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ResultNotAlgaeError extends StatelessWidget {
  const ResultNotAlgaeError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.no_photography, size: 50, color: Colors.blue),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.noAlgaeDetectedTitle,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    AppStrings.noAlgaeDetectedMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text(
                    AppStrings.tipsForBetterResults,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 12),
                  _buildTip(Icons.center_focus_strong, AppStrings.tipFocus),
                  _buildTip(Icons.light_mode, AppStrings.tipLighting),
                  _buildTip(Icons.crop_free, AppStrings.tipCenter),
                  _buildTip(Icons.photo_camera, AppStrings.tipNoBlur),
                  _buildTip(Icons.water_drop, AppStrings.tipIsAlgae),
                  _buildTip(Icons.grid_on, AppStrings.tipBackground),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.blue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class ResultGenericError extends StatelessWidget {
  const ResultGenericError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline, size: 50, color: AppColors.errorRed),
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.analysisFailed,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.errorRed),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorRed.withOpacity(0.3)),
              ),
              child: const Text(
                AppStrings.analysisErrorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}