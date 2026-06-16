/// PDF and AI Assistant buttons
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class PdfButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const PdfButton({super.key, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
          ),
        )
            : const Icon(Icons.save_alt, color: AppColors.textWhite),
        label: Text(
          isLoading ? AppStrings.savingPDF : AppStrings.savePDFReport,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textWhite),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }
}

class AiAssistantButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AiAssistantButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.assistant, color: AppColors.primaryGreen, size: 20),
        label: Text(
          AppStrings.askAIAssistant,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}