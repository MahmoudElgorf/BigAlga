// lib/features/about/widgets/about_species_section.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'about_category_chip.dart';

class AboutSpeciesSection extends StatelessWidget {
  const AboutSpeciesSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final speciesList = algaeData.keys.toList();
    final totalSpecies = speciesList.length;

    final categories = {
      'Cyanobacteria': 0,
      'Dinoflagellate': 0,
      'Diatom': 0,
    };

    for (var name in speciesList) {
      final data = algaeData[name] as Map<String, dynamic>;
      final category = data['category'] as String? ?? '';
      if (category.contains('Cyanobacteria')) {
        categories['Cyanobacteria'] = (categories['Cyanobacteria'] ?? 0) + 1;
      } else if (category.contains('Dinoflagellate')) {
        categories['Dinoflagellate'] = (categories['Dinoflagellate'] ?? 0) + 1;
      } else if (category.contains('Diatom')) {
        categories['Diatom'] = (categories['Diatom'] ?? 0) + 1;
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
              'SUPPORTED SPECIES',
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
            'Total Species',
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
    return Row(
      children: [
        AboutCategoryChip(
          label: 'Cyanobacteria',
          count: categories['Cyanobacteria'] ?? 0,
          color: Colors.blue,
        ),
        const SizedBox(width: 6),
        AboutCategoryChip(
          label: 'Dinoflagellate',
          count: categories['Dinoflagellate'] ?? 0,
          color: Colors.purple,
        ),
        const SizedBox(width: 6),
        AboutCategoryChip(
          label: 'Diatom',
          count: categories['Diatom'] ?? 0,
          color: Colors.orange,
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
        final isNontoxic = species.toLowerCase() == 'nontoxic';
        // تلوين خاص لـ Nontoxic (لون مختلف للدلالة)
        final chipColor = isNontoxic
            ? AppColors.infoBlue
            : (isToxic ? AppColors.toxicRed : AppColors.accentGreen);
        final backgroundColor = chipColor.withOpacity(0.1);
        final borderColor = chipColor.withOpacity(0.3);

        return Chip(
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
        );
      }).toList(),
    );
  }
}