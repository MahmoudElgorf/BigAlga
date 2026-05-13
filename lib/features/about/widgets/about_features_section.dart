// lib/features/about/presentation/widgets/about_features_section.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutFeaturesSection extends StatelessWidget {
  const AboutFeaturesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final features = [
      'AI-powered algae classification',
      'Real-time image analysis',
      'Comprehensive algae encyclopedia',
      'Toxicity warnings and safety info',
      'Commercial viability assessment',
      'CO₂ sequestration calculator',
      'PDF report generation',
      'Analysis history tracking',
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KEY FEATURES',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            ...features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified, size: 18, color: AppColors.accentGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}