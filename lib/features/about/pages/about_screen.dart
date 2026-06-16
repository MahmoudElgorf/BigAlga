/// About screen displaying app information, features, and credits
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/about/widgets/about_developer_section.dart';
import 'package:bioalga/features/about/widgets/about_features_section.dart';
import 'package:bioalga/features/about/widgets/about_section_card.dart';
import 'package:bioalga/features/about/widgets/about_species_section.dart';
import 'package:bioalga/features/about/widgets/about_technology_section.dart';
import 'package:bioalga/features/about/widgets/about_llm_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppStrings.aboutBioAlga,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.primaryBlue,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLogoSection(),
            const SizedBox(height: 20),
            _buildAppTitleSection(),
            const SizedBox(height: 28),
            AboutSectionCard(
              title: AppStrings.aboutBioAlgaTitle,
              content: AppStrings.aboutBioAlgaContent,
            ),
            const SizedBox(height: 20),
            const AboutFeaturesSection(),
            const SizedBox(height: 20),
            const AboutLlmSection(),
            const SizedBox(height: 20),
            const AboutSpeciesSection(),
            const SizedBox(height: 20),
            const AboutTechnologySection(),
            const SizedBox(height: 28),
            const AboutDeveloperSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: 120,
      height: 120,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.asset(
          AppAssets.appLogo,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.eco,
                size: 60,
                color: AppColors.primaryBlue,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppTitleSection() {
    return Column(
      children: [
        Text(
          AppStrings.bioAlgaTitle,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBlue,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppStrings.version} ${AppConstants.appVersion}',
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.marineSystem,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.accentGreen,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}