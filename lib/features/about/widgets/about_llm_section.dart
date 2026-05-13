// lib/features/about/widgets/about_llm_section.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutLlmSection extends StatelessWidget {
  const AboutLlmSection({Key? key}) : super(key: key);

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
                'AI ASSISTANT (LLM)',
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'BioAlga integrates a conversational AI assistant powered by large language models (GPT-4o-mini). It provides accurate, science-based answers about algae species, toxicity, environmental impact, and commercial applications.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 16),
              _buildSubsectionTitle('Capabilities'),
              _buildBulletList([
                'Answer natural language questions about any supported algae species',
                'Provide detailed toxicity warnings and health effect explanations',
                'Assess commercial viability and CO2 sequestration potential',
                'Explain environmental impact, habitat, and ecological role',
                'Give safety instructions and handling recommendations',
                'Support both English and Arabic',
                'Maintain conversation context for up to 15 messages',
              ]),
              const SizedBox(height: 12),
              _buildSubsectionTitle('Usage Guidelines'),
              _buildBulletList([
                'Tap the AI Assistant button on the results page',
                'Ask specific questions for best results',
                'The assistant focuses on algae and related fields (phycology, aquatic biology, toxins)',
                'Completely unrelated topics will be politely redirected',
              ]),
              const SizedBox(height: 12),
              _buildSubsectionTitle('Limitations'),
              _buildBulletList([
                'First response may be delayed if the backend service is on a free hosting plan (cold start up to 50 seconds)',
                'Rare or poorly documented species may lack detailed information',
                'The AI provides scientific information but cannot replace professional medical or environmental advice',
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