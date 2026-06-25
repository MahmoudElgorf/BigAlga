/// About screen displaying app information, features, and credits
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/about/widgets/about_developer_section.dart';
import 'package:bioalga/features/about/widgets/about_features_section.dart';
import 'package:bioalga/features/about/widgets/about_llm_section.dart';
import 'package:bioalga/features/about/widgets/about_section_card.dart';
import 'package:bioalga/features/about/widgets/about_species_section.dart';
import 'package:bioalga/features/about/widgets/about_technology_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const double _pagePadding = 20;
  static const double _logoSize = 120;
  static const double _logoRadius = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleStyle = GoogleFonts.poppins(
      fontWeight: FontWeight.w700,
      color: isDark ? Colors.white : AppColors.primaryBlue,
    );

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkBackground : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.aboutBioAlga,
          style: titleStyle,
        ),
      ),
      body: const SafeArea(
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(_pagePadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  _AboutLogoSection(),
                  SizedBox(height: 20),
                  _AboutTitleSection(),
                  SizedBox(height: 28),
                  AboutSectionCard(
                    title: AppStrings.aboutBioAlgaTitle,
                    content: AppStrings.aboutBioAlgaContent,
                  ),
                  SizedBox(height: 20),
                  AboutFeaturesSection(),
                  SizedBox(height: 20),
                  AboutLlmSection(),
                  SizedBox(height: 20),
                  AboutSpeciesSection(),
                  SizedBox(height: 20),
                  AboutTechnologySection(),
                  SizedBox(height: 28),
                  AboutDeveloperSection(),
                  SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutLogoSection extends StatelessWidget {
  const _AboutLogoSection();

  static const double _logoSize = AboutScreen._logoSize;
  static const double _logoRadius = AboutScreen._logoRadius;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_logoRadius),
        child: Image.asset(
          AppAssets.appLogo,
          width: _logoSize,
          height: _logoSize,
          fit: BoxFit.cover,
          cacheWidth: 240,
          cacheHeight: 240,
          errorBuilder: (_, __, ___) => Container(
            width: _logoSize,
            height: _logoSize,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(_logoRadius),
            ),
            child: const Icon(
              Icons.eco,
              size: 60,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutTitleSection extends StatelessWidget {
  const _AboutTitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppStrings.bioAlgaTitle,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBlue,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppStrings.version} ${AppConstants.appVersion}',
          style: GoogleFonts.roboto(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppStrings.marineSystem,
          textAlign: TextAlign.center,
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