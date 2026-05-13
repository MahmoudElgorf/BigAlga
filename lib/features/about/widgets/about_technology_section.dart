// lib/features/about/presentation/widgets/about_technology_section.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutTechnologySection extends StatelessWidget {
  const AboutTechnologySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final technologies = [
      'Flutter & Dart',
      'Deep Learning (CNN)',
      'TensorFlow Lite',
      'REST API Integration',
      'SQLite / Local Storage',
      'PDF Generation',
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
              'TECHNOLOGY STACK',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: technologies.map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentGreen],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    tech,
                    style: GoogleFonts.roboto(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}