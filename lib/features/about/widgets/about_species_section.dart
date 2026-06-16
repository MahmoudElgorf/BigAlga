/// Species section widget displaying supported algae species with categories
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_category_chip.dart';

class AboutSpeciesSection extends StatelessWidget {
  const AboutSpeciesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final speciesList = algaeData.keys
        .where((key) => key.toLowerCase() != AppStrings.notAlgae)
        .toList();
    final totalSpecies = speciesList.length;

    final categories = {
      AppStrings.cyanobacteria: 0,
      AppStrings.dinoflagellate: 0,
      AppStrings.diatom: 0,
      AppStrings.other: 0,
    };

    for (var name in speciesList) {
      final data = algaeData[name] as Map<String, dynamic>;
      final category = data['category'] as String? ?? '';
      if (category.contains(AppStrings.cyanobacteria)) {
        categories[AppStrings.cyanobacteria] =
            (categories[AppStrings.cyanobacteria] ?? 0) + 1;
      } else if (category.contains(AppStrings.dinoflagellate)) {
        categories[AppStrings.dinoflagellate] =
            (categories[AppStrings.dinoflagellate] ?? 0) + 1;
      } else if (category.contains(AppStrings.diatom)) {
        categories[AppStrings.diatom] =
            (categories[AppStrings.diatom] ?? 0) + 1;
      } else {
        categories[AppStrings.other] =
            (categories[AppStrings.other] ?? 0) + 1;
      }
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.supportedSpecies,
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 14),
            _buildTotalSpeciesCounter(totalSpecies),
            const SizedBox(height: 14),
            _buildCategoriesRow(categories),
            const SizedBox(height: 16),
            _buildSpeciesList(speciesList),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSpeciesCounter(int totalSpecies) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentGreen],
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$totalSpecies',
            style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            AppStrings.totalSpecies,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesRow(Map<String, int> categories) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AboutCategoryChip(
          label: AppStrings.cyanobacteria,
          count: categories[AppStrings.cyanobacteria] ?? 0,
          color: Colors.blue,
        ),
        AboutCategoryChip(
          label: AppStrings.dinoflagellate,
          count: categories[AppStrings.dinoflagellate] ?? 0,
          color: Colors.purple,
        ),
        AboutCategoryChip(
          label: AppStrings.diatom,
          count: categories[AppStrings.diatom] ?? 0,
          color: Colors.orange,
        ),
        if ((categories[AppStrings.other] ?? 0) > 0)
          AboutCategoryChip(
            label: AppStrings.other,
            count: categories[AppStrings.other] ?? 0,
            color: Colors.grey,
          ),
      ],
    );
  }

  Widget _buildSpeciesList(List<String> speciesList) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: speciesList.map((species) {
        final data = algaeData[species] as Map<String, dynamic>;
        final isToxic = data['isToxic'] as bool? ?? false;
        final isNontoxic = species.toLowerCase() == AppStrings.nontoxicLower;

        late final Color chipColor;
        if (isNontoxic) {
          chipColor = AppColors.infoBlue;
        } else if (isToxic) {
          chipColor = AppColors.toxicRed;
        } else {
          chipColor = AppColors.accentGreen;
        }

        final backgroundColor = chipColor.withOpacity(0.1);
        final borderColor = chipColor.withOpacity(0.3);

        final tooltipMessage = isToxic
            ? AppStrings.toxicHandleCare
            : isNontoxic
            ? AppStrings.generalNonToxic
            : AppStrings.nonToxicSpecies;

        return Tooltip(
          message: tooltipMessage,
          child: Chip(
            label: Text(
              species,
              style: GoogleFonts.roboto(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: chipColor,
              ),
            ),
            backgroundColor: backgroundColor,
            side: BorderSide(color: borderColor, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        );
      }).toList(),
    );
  }
}