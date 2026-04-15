// lib/about/presentation/pages/about_screen.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0F1C) : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'About BioAlga',
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
            Container(
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
                    // لو الصورة مش موجودة، يظهر أيقونة بديلة بدون خلفية
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
            ),
            const SizedBox(height: 20),

            Text(
              'BIOALGA',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryBlue,
                letterSpacing: 2.0,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Version 1.0.0',
              style: GoogleFonts.roboto(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                letterSpacing: 1.0,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Marine Algae Analysis System',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.accentGreen,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 28),

            _buildSectionCard(
              title: 'ABOUT BIOALGA',
              content:
              'BioAlga is an intelligent mobile application that uses deep learning to classify algae species from images. '
                  'The app provides scientific information about each species, including benefits, applications, toxicity warnings, '
                  'and commercial viability. It supports researchers, students, and marine biologists in identifying and studying algae species.',
            ),

            const SizedBox(height: 20),

            _buildFeaturesSection(),

            const SizedBox(height: 20),

            _buildSpeciesSection(),

            const SizedBox(height: 20),

            _buildTechnologySection(),

            const SizedBox(height: 28),

            // ✅ Developer Section (مبسط - فقط NextStep Team)
            _buildDeveloperSection(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ================= Section Cards =================

  Widget _buildSectionCard({
    required String title,
    required String content,
  }) {
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
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                content,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      '🔬 AI-powered algae classification',
      '📸 Real-time image analysis',
      '📚 Comprehensive algae encyclopedia',
      '⚠️ Toxicity warnings & safety info',
      '💰 Commercial viability assessment',
      '🌍 CO₂ sequestration calculator',
      '📄 PDF report generation',
      '📊 Analysis history tracking',
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

  Widget _buildSpeciesSection() {
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
      if (category.contains('Cyanobacteria')) categories['Cyanobacteria'] = (categories['Cyanobacteria'] ?? 0) + 1;
      else if (category.contains('Dinoflagellate')) categories['Dinoflagellate'] = (categories['Dinoflagellate'] ?? 0) + 1;
      else if (category.contains('Diatom')) categories['Diatom'] = (categories['Diatom'] ?? 0) + 1;
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

            Container(
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
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _buildCategoryChip('Cyanobacteria', categories['Cyanobacteria'] ?? 0, Colors.blue),
                const SizedBox(width: 6),
                _buildCategoryChip('Dinoflagellate', categories['Dinoflagellate'] ?? 0, Colors.purple),
                const SizedBox(width: 6),
                _buildCategoryChip('Diatom', categories['Diatom'] ?? 0, Colors.orange),
              ],
            ),

            const SizedBox(height: 14),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: speciesList.take(6).map((species) {
                final data = algaeData[species] as Map<String, dynamic>;
                final isToxic = data['isToxic'] as bool? ?? false;
                return Chip(
                  label: Text(
                    species,
                    style: GoogleFonts.roboto(fontSize: 10, fontWeight: FontWeight.w500),
                  ),
                  backgroundColor: isToxic
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.accentGreen.withOpacity(0.1),
                  side: BorderSide(
                    color: isToxic
                        ? Colors.red.withOpacity(0.3)
                        : AppColors.accentGreen.withOpacity(0.3),
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                );
              }).toList(),
            ),

            if (totalSpecies > 6)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+ ${totalSpecies - 6} more species',
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.roboto(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnologySection() {
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

  // ✅ Developer Section مبسط (بدون أيقونات وحسابات)
  Widget _buildDeveloperSection() {
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
              AppColors.primaryBlue.withOpacity(0.05),
              AppColors.accentGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentGreen],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.group,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "DEVELOPED BY",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "NextStep Team",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryBlue,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 2,
                width: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentGreen],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}