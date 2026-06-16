/// LLM AI Assistant section widget explaining the conversational AI capabilities
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutLlmSection extends StatelessWidget {
  const AboutLlmSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.backgroundLight.withOpacity(0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.aiAssistantTitle,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.aiAssistantDescription,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildSubsectionTitle(AppStrings.capabilities),
              _buildBulletList([
                AppStrings.capabilityAnswerQuestions,
                AppStrings.capabilityToxicityWarnings,
                AppStrings.capabilityCommercialViability,
                AppStrings.capabilityEnvironmentalImpact,
                AppStrings.capabilitySafetyInstructions,
                AppStrings.capabilityBilingual,
                AppStrings.capabilityConversationContext,
              ]),
              const SizedBox(height: 12),
              _buildSubsectionTitle(AppStrings.usageGuidelines),
              _buildBulletList([
                AppStrings.guidelineTapAssistant,
                AppStrings.guidelineSpecificQuestions,
                AppStrings.guidelineFocusArea,
                AppStrings.guidelineRedirect,
              ]),
              const SizedBox(height: 12),
              _buildSubsectionTitle(AppStrings.limitations),
              _buildBulletList([
                AppStrings.limitationColdStart,
                AppStrings.limitationRareSpecies,
                AppStrings.limitationProfessionalAdvice,
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubsectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.accentGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildBulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryBlue,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}