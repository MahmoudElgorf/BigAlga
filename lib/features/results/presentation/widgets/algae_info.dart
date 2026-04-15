// lib/features/results/presentation/widgets/algae_info.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:flutter/material.dart';

class AlgaeInfo extends StatelessWidget {
  final String algaeType;
  final AlgaeResult? fullResult; // New: receiving the full result from classification

  const AlgaeInfo({
    Key? key,
    required this.algaeType,
    this.fullResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use data from fullResult if available, otherwise use local data
    final displayData = fullResult != null
        ? _getInfoFromResult(fullResult!)
        : _getLocalAlgaeInfo(algaeType);

    final toxicityColor = fullResult?.toxicityColor ??
        (displayData['isToxic'] == true ? Colors.red : Colors.green);

    return CustomPaint(
      painter: LeafShapePainter(),
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.98),
              const Color(0xFFF0F8F0),
              const Color(0xFFE8F5E8),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(60),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header with Arabic name if available
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: toxicityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    fullResult?.isToxic == true ? Icons.warning_amber : Icons.eco,
                    color: toxicityColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (displayData['arabicName'] != null && displayData['arabicName'] != '')
                        Text(
                          displayData['arabicName'],
                          style: Theme.of(context).textTheme.displayMedium!.copyWith(
                            color: const Color(0xFF1B5E20),
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        displayData['scientificName'] ?? AppStrings.algaeInformation,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Confidence badge (if available)
            if (fullResult != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(fullResult!.confidence).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Confidence: ${(fullResult!.confidence * 100).toInt()}% (${fullResult!.confidenceLevel})',
                  style: TextStyle(
                    color: _getConfidenceColor(fullResult!.confidence),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            const SizedBox(height: 16),
            Container(
              height: 2,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.6),
                    const Color(0xFF8BC34A).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // ===== NEW: Scientific Warning (most important) =====
            if (displayData['scientificWarning'] != null && displayData['scientificWarning'] != '')
              _buildWarningItem(
                Icons.science,
                '! Scientific Warning',
                displayData['scientificWarning'],
                Colors.orange,
              ),
            const SizedBox(height: 16),

            // ===== NEW: Toxicity Status with color =====
            _buildLeafVeinItem(
              fullResult?.isToxic == true ? Icons.warning : Icons.check_circle,
              'Toxicity Status',
              displayData['toxicityWarning'] ?? 'Under analysis',
              toxicityColor,
            ),
            const SizedBox(height: 16),

            // ===== NEW: Potential Toxins =====
            if (displayData['potentialToxins'] != null && (displayData['potentialToxins'] as List).isNotEmpty)
              _buildMultiLineLeafVeinItem(
                Icons.warning,
                '! Potential Toxins',
                List<String>.from(displayData['potentialToxins']),
                Colors.red.shade400,
              ),
            const SizedBox(height: 16),

            // Category
            if (displayData['category'] != null && displayData['category'] != '')
              _buildLeafVeinItem(
                Icons.category,
                'Classification',
                displayData['category'],
                const Color(0xFF2E7D32),
              ),
            const SizedBox(height: 16),

            // ===== NEW: CO2 per Kg =====
            if (displayData['co2PerKg'] != null)
              _buildLeafVeinItem(
                Icons.cloud,
                'CO2 Sequestration',
                displayData['co2PerKg'] > 0
                    ? '~ ${displayData['co2PerKg']} kg CO2 per kg dry biomass'
                    : 'Not applicable (heterotrophic organism)',
                const Color(0xFF0288D1),
              ),
            const SizedBox(height: 16),

            // ===== NEW: Sellable Status =====
            if (displayData['sellable'] != null && displayData['sellable'] != '')
              _buildLeafVeinItem(
                Icons.shopping_cart,
                'Commercial Viability',
                displayData['sellable'],
                _getSellableColor(displayData['sellable']),
              ),
            const SizedBox(height: 16),

            // Benefits
            if (displayData['benefits'] != null && (displayData['benefits'] as List).isNotEmpty)
              _buildMultiLineLeafVeinItem(
                Icons.medical_services,
                AppStrings.benefits,
                List<String>.from(displayData['benefits']),
                const Color(0xFF2E7D32),
              ),
            const SizedBox(height: 16),

            // Uses
            if (displayData['uses'] != null && (displayData['uses'] as List).isNotEmpty)
              _buildMultiLineLeafVeinItem(
                Icons.build,
                AppStrings.applications,
                List<String>.from(displayData['uses']),
                const Color(0xFF4CAF50),
              ),
            const SizedBox(height: 16),

            // Habitat
            if (displayData['habitat'] != null && displayData['habitat'] != '')
              _buildLeafVeinItem(
                Icons.location_on,
                AppStrings.habitat,
                displayData['habitat'],
                const Color(0xFF2E7D32),
              ),
            const SizedBox(height: 16),

            _buildApiSourceBadge(),
          ],
        ),
      ),
    );
  }

  // Convert AlgaeResult to Map for display
  Map<String, dynamic> _getInfoFromResult(AlgaeResult result) {
    return {
      'scientificName': result.scientificName,
      'arabicName': result.arabicName,
      'category': result.category,
      'isToxic': result.isToxic,
      'toxicityWarning': result.toxicityWarning,
      'scientificWarning': result.scientificWarning,
      'potentialToxins': result.potentialToxins,
      'co2PerKg': result.co2PerKg,
      'sellable': result.sellable,
      'benefits': result.benefits,
      'uses': result.uses,
      'habitat': _getHabitatForType(result.name),
    };
  }

  // Local data (fallback if fullResult is not available)
  Map<String, dynamic> _getLocalAlgaeInfo(String type) {
    final localData = _getAlgaeDataMap();
    return localData[type] ?? localData['default']!;
  }

  Map<String, dynamic> _getAlgaeDataMap() {
    return {
      'Anabaena': {
        'scientificName': 'Anabaena spp. (or Dolichospermum)',
        'arabicName': 'Anabaena',
        'category': 'Cyanobacteria',
        'isToxic': false,
        'toxicityWarning': '! Toxin production depends on species/strain',
        'scientificWarning': 'Most planktonic Anabaena are now reclassified as Dolichospermum. Toxicity varies significantly between species and strains.',
        'potentialToxins': ['Anatoxin-a (neurotoxin) - in some strains'],
        'co2PerKg': 1.83,
        'sellable': 'Conditional - Only as controlled culture (Azolla-Anabaena)',
        'benefits': ['Atmospheric nitrogen fixation', 'Improves soil fertility'],
        'uses': ['Biofertilizers', 'Scientific research'],
        'habitat': 'Freshwater lakes, ponds, slow-moving rivers',
      },
      'Aphanizomenon': {
        'scientificName': 'Aphanizomenon spp.',
        'arabicName': 'Aphanizomenon',
        'category': 'Cyanobacteria',
        'isToxic': false,
        'toxicityWarning': '! Some strains produce toxins, others do not',
        'scientificWarning': 'Some strains produce saxitoxins or cylindrospermopsin. Commercial products risk Microcystis contamination.',
        'potentialToxins': ['Saxitoxins', 'Cylindrospermopsin'],
        'co2PerKg': 1.83,
        'sellable': 'No - High regulatory risk',
        'benefits': ['Nitrogen fixation', 'Ecological role'],
        'uses': ['Scientific research', 'Water quality monitoring'],
        'habitat': 'Nutrient-rich freshwater systems',
      },
      'Microcystis': {
        'scientificName': 'Microcystis spp.',
        'arabicName': 'Microcystis',
        'category': 'Cyanobacteria',
        'isToxic': true,
        'toxicityWarning': '! DANGER: Produces dangerous hepatotoxins',
        'scientificWarning': 'Produces microcystins (liver toxins). WHO guideline: 1 microgram/L in drinking water.',
        'potentialToxins': ['Microcystins (hepatotoxins)'],
        'co2PerKg': 1.83,
        'sellable': 'No - Not suitable for commercial sale',
        'benefits': ['Research only'],
        'uses': ['Scientific research', 'Environmental monitoring'],
        'habitat': 'Nutrient-rich freshwater lakes',
      },
      'Karenia': {
        'scientificName': 'Karenia spp.',
        'arabicName': 'Karenia',
        'category': 'Dinoflagellate',
        'isToxic': true,
        'toxicityWarning': '! DANGER: Produces Brevetoxins',
        'scientificWarning': 'Produces brevetoxins causing Neurotoxic Shellfish Poisoning and respiratory irritation.',
        'potentialToxins': ['Brevetoxins (neurotoxins)'],
        'co2PerKg': 1.83,
        'sellable': 'No - Highly toxic',
        'benefits': ['Environmental monitoring'],
        'uses': ['Research', 'Red tide monitoring'],
        'habitat': 'Coastal marine waters',
      },
      'Nodularia': {
        'scientificName': 'Nodularia spp.',
        'arabicName': 'Nodularia',
        'category': 'Cyanobacteria',
        'isToxic': true,
        'toxicityWarning': '! Produces Nodularin',
        'scientificWarning': 'Produces nodularin (hepatotoxin). Common in brackish waters like the Baltic Sea.',
        'potentialToxins': ['Nodularin (hepatotoxin)'],
        'co2PerKg': 1.83,
        'sellable': 'No - Research only',
        'benefits': ['Nitrogen fixation'],
        'uses': ['Scientific research', 'Toxin monitoring'],
        'habitat': 'Brackish waters, estuaries',
      },
      'Nostoc': {
        'scientificName': 'Nostoc spp.',
        'arabicName': 'Nostoc',
        'category': 'Cyanobacteria',
        'isToxic': false,
        'toxicityWarning': '! Generally safe for known edible species',
        'scientificWarning': 'Some strains can produce toxins. Traditional edible species have long safety history.',
        'potentialToxins': ['Microcystins (in some strains)'],
        'co2PerKg': 1.83,
        'sellable': 'Conditional - Only defined non-toxic strains',
        'benefits': ['Nitrogen fixation', 'Soil improvement', 'Protein source'],
        'uses': ['Biofertilizers', 'Traditional food'],
        'habitat': 'Freshwater and terrestrial environments',
      },
      'Oscillatoria': {
        'scientificName': 'Oscillatoria spp.',
        'arabicName': 'Oscillatoria',
        'category': 'Cyanobacteria',
        'isToxic': false,
        'toxicityWarning': '! Some strains produce toxins',
        'scientificWarning': 'Some strains produce anatoxin-a or microcystins. Not for food/agriculture without testing.',
        'potentialToxins': ['Anatoxin-a', 'Microcystins', 'Aplysiatoxins'],
        'co2PerKg': 1.83,
        'sellable': 'No - Research only',
        'benefits': ['Water pollution indicator'],
        'uses': ['Environmental monitoring'],
        'habitat': 'Freshwater, wastewater systems',
      },
      'Gymnodinium': {
        'scientificName': 'Gymnodinium spp.',
        'arabicName': 'Gymnodinium',
        'category': 'Dinoflagellate',
        'isToxic': false,
        'toxicityWarning': '! Some species produce toxins',
        'scientificWarning': 'Gymnodinium catenatum produces saxitoxins (PSP). Not all species are toxic.',
        'potentialToxins': ['Saxitoxins - in some species'],
        'co2PerKg': 1.83,
        'sellable': 'No - Monitoring only',
        'benefits': ['Part of marine food web'],
        'uses': ['Research', 'Shellfish monitoring'],
        'habitat': 'Marine and brackish waters',
      },
      'Prorocentrum': {
        'scientificName': 'Prorocentrum spp.',
        'arabicName': 'Prorocentrum',
        'category': 'Dinoflagellate',
        'isToxic': false,
        'toxicityWarning': '! Some species cause DSP',
        'scientificWarning': 'Some species produce okadaic acid causing Diarrhetic Shellfish Poisoning.',
        'potentialToxins': ['Okadaic acid', 'Dinophysistoxins'],
        'co2PerKg': 1.83,
        'sellable': 'No - Monitoring only',
        'benefits': ['Marine ecology studies'],
        'uses': ['Research', 'Shellfish monitoring'],
        'habitat': 'Coastal marine waters, coral reefs',
      },
      'Noctiluca': {
        'scientificName': 'Noctiluca scintillans',
        'arabicName': 'Noctiluca',
        'category': 'Dinoflagellate (heterotrophic)',
        'isToxic': false,
        'toxicityWarning': '! Blooms can cause hypoxia',
        'scientificWarning': 'Heterotrophic - does NOT fix CO2 like photosynthetic organisms. Blooms can cause fish kills.',
        'potentialToxins': ['No human toxins', 'Environmental: hypoxia'],
        'co2PerKg': 0.0,
        'sellable': 'No - Valued for ecotourism only',
        'benefits': ['Bioluminescence', 'Ecotourism'],
        'uses': ['Research', 'Ecotourism', 'Education'],
        'habitat': 'Coastal marine waters',
      },
      'Skeletonema': {
        'scientificName': 'Skeletonema spp.',
        'arabicName': 'Skeletonema',
        'category': 'Diatom',
        'isToxic': false,
        'toxicityWarning': '- Generally safe',
        'scientificWarning': 'Not known to produce human toxins. Excellent for aquaculture.',
        'potentialToxins': ['None known'],
        'co2PerKg': 1.83,
        'sellable': 'Yes - Excellent for aquaculture',
        'benefits': ['Rich in fatty acids', 'Live feed for larvae'],
        'uses': ['Aquaculture hatcheries', 'Research'],
        'habitat': 'Coastal and oceanic waters',
      },
      'nontoxic': {
        'scientificName': 'Non-toxic Algae (general)',
        'arabicName': 'Non-toxic algae',
        'category': 'General category',
        'isToxic': false,
        'toxicityWarning': '- Environmentally safe',
        'scientificWarning': 'Requires species identification and toxin testing per batch.',
        'potentialToxins': ['Test for: Microcystins, Nodularin, Anatoxin-a, Saxitoxins'],
        'co2PerKg': 1.83,
        'sellable': 'Conditional - Requires testing',
        'benefits': ['Oxygen production', 'Ecological balance'],
        'uses': ['Hydroponics', 'Research'],
        'habitat': 'Various aquatic environments',
      },
      'default': {
        'scientificName': 'Classification in progress',
        'arabicName': 'Classification in progress',
        'category': 'Unknown',
        'isToxic': false,
        'toxicityWarning': 'Toxicity assessment ongoing',
        'scientificWarning': 'Scientific analysis underway for accurate identification.',
        'potentialToxins': ['Analysis pending'],
        'co2PerKg': 1.83,
        'sellable': 'Unknown - Requires identification',
        'benefits': ['Information being updated'],
        'uses': ['Information being updated'],
        'habitat': 'Analysis ongoing',
      },
    };
  }

  String _getHabitatForType(String type) {
    final habitats = {
      'Anabaena': 'Freshwater lakes, ponds, slow-moving rivers',
      'Aphanizomenon': 'Nutrient-rich freshwater systems, lakes',
      'Gymnodinium': 'Marine and brackish waters worldwide',
      'Karenia': 'Coastal marine waters, warm temperate regions',
      'Microcystis': 'Nutrient-rich freshwater lakes, reservoirs',
      'Noctiluca': 'Coastal marine waters worldwide',
      'Nodularia': 'Brackish waters, estuaries, Baltic Sea',
      'Nostoc': 'Freshwater and terrestrial environments',
      'Oscillatoria': 'Freshwater, wastewater systems',
      'Prorocentrum': 'Coastal marine waters, coral reefs',
      'Skeletonema': 'Coastal and oceanic waters',
      'nontoxic': 'Various aquatic environments',
    };
    return habitats[type] ?? 'Analysis ongoing';
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return const Color(0xFF2E7D32);
    if (confidence >= 0.6) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  Color _getSellableColor(String sellable) {
    if (sellable.contains('Yes')) return const Color(0xFF2E7D32);
    if (sellable.contains('No')) return const Color(0xFFF44336);
    return const Color(0xFFFF9800);
  }

  Widget _buildLeafVeinItem(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF424242),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF424242),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultiLineLeafVeinItem(IconData icon, String title, List<String> items, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            title.contains('!') ? Icons.warning : Icons.check_circle,
                            size: 14,
                            color: title.contains('!') ? Colors.orange : color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: const Color(0xFF424242),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiSourceBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.infoBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.storage,
            color: AppColors.infoBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.updatedFromDatabase,
            style: TextStyle(
              color: AppColors.infoBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class LeafShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.1, size.height * 0.3);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.1, size.width * 0.2, size.height * 0.05);
    path.quadraticBezierTo(size.width * 0.4, 0, size.width * 0.6, size.height * 0.02);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.05, size.width * 0.9, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.95, size.height * 0.4, size.width * 0.8, size.height * 0.6);
    path.quadraticBezierTo(size.width * 0.7, size.height * 0.8, size.width * 0.5, size.height * 0.9);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.95, size.width * 0.1, size.height * 0.8);
    path.quadraticBezierTo(0, size.height * 0.6, size.width * 0.1, size.height * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}