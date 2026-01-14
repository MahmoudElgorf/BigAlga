import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AlgaeInfo extends StatelessWidget {
  final String algaeType;
  final List<String>? benefits;
  final List<String>? uses;

  const AlgaeInfo({
    Key? key,
    required this.algaeType,
    this.benefits,
    this.uses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = _getAlgaeInfo(algaeType);
    final displayBenefits = benefits ?? info['benefits'] ?? _getDefaultBenefits(algaeType);
    final displayUses = uses ?? info['uses'] ?? _getDefaultUses(algaeType);

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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    shape: BoxShape.rectangle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.algaeInformation,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

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

            _buildLeafVeinItem(
              Icons.emoji_nature,
              AppStrings.scientificName,
              info['scientificName'] ?? AppStrings.notSpecified,
              const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),

            _buildLeafVeinItem(
              Icons.water_drop,
              AppStrings.description,
              info['description'] ?? 'Information being collected',
              const Color(0xFF388E3C),
            ),
            const SizedBox(height: 16),

            if (displayBenefits.isNotEmpty) ...[
              _buildMultiLineLeafVeinItem(
                Icons.medical_services,
                AppStrings.benefits,
                displayBenefits,
                const Color(0xFF2E7D32),
              ),
              const SizedBox(height: 16),
            ],

            if (displayUses.isNotEmpty) ...[
              _buildMultiLineLeafVeinItem(
                Icons.build,
                AppStrings.applications,
                displayUses,
                const Color(0xFF4CAF50),
              ),
              const SizedBox(height: 16),
            ],

            _buildLeafVeinItem(
              Icons.visibility,
              AppStrings.characteristics,
              info['characteristics'] ?? 'Characteristics being analyzed',
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),

            _buildLeafVeinItem(
              Icons.warning,
              AppStrings.toxicityLevel,
              info['toxicity'] ?? 'Toxicity being analyzed',
              const Color(0xFF8BC34A),
            ),
            const SizedBox(height: 16),

            _buildLeafVeinItem(
              Icons.location_on,
              AppStrings.habitat,
              info['habitat'] ?? 'Habitat information being updated',
              const Color(0xFF2E7D32),
            ),

            _buildApiSourceBadge(),
          ],
        ),
      ),
    );
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
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
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
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF424242),
                    fontSize: 14,
                    height: 1.5,
                    letterSpacing: 0.3,
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
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
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
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: const Color(0xFF424242),
                                fontSize: 14,
                                height: 1.5,
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

  List<String> _getDefaultBenefits(String type) {
    final benefitsData = {
      'Anabaena': [
        'Atmospheric nitrogen fixation',
        'Improves soil fertility',
        'Production of bioactive compounds',
        'Source of essential amino acids',
      ],
      'Aphanizomenon': [
        'Rich source of phycocyanin',
        'Strong antioxidant properties',
        'Supports immune system health',
        'Food source for marine organisms',
      ],
      'Gymnodinium': [
        'Vital part of marine food chain',
        'Oxygen production through photosynthesis',
        'Supports marine biodiversity',
      ],
      'Karenia': [
        'Environmental indicator for climate changes',
        'Study of red tide phenomena',
        'Harmful algal bloom research',
      ],
      'Microcystis': [
        'Study of environmental changes in freshwater',
        'Water quality and lake monitoring',
        'Aquatic toxicity research',
      ],
      'Noctiluca': [
        'Distinctive bioluminescence phenomenon',
        'Attracts ecotourism and scientific tourism',
        'Indicator of high water fertility',
      ],
      'Nodularia': [
        'Nitrogen fixation in aquatic environments',
        'Production of active chemical compounds',
        'Environmental studies in lakes',
      ],
      'Nostoc': [
        'Atmospheric nitrogen fixation',
        'Improves agricultural soil fertility',
        'Traditional food source in some cultures',
      ],
      'Oscillatoria': [
        'Sensitive indicator of water pollution',
        'Aquatic ecology studies',
        'Production of natural pigments',
      ],
      'Prorocentrum': [
        'Part of marine phytoplankton',
        'Supports marine biodiversity',
        'Food source for small fish',
      ],
      'Skeletonema': [
        'Main food source for mollusks and shellfish',
        'Accurate indicator of ecosystem health',
        'Research on marine food chains',
      ],
      'nontoxic': [
        'Safe for human and animal use',
        'Suitable for educational and laboratory purposes',
        'Does not pose environmental risk',
      ],
    };

    return benefitsData[type] ?? [
      'Marine food source',
      'Oxygen production',
      'Supports marine ecosystem',
    ];
  }

  List<String> _getDefaultUses(String type) {
    final usesData = {
      'Anabaena': [
        'Soil fertilization in agriculture',
        'Biological nitrogen fixation research',
        'Biofertilizer production',
      ],
      'Aphanizomenon': [
        'Dietary supplements rich in antioxidants',
        'Medical and therapeutic research',
        'Aquatic environment monitoring',
      ],
      'Gymnodinium': [
        'Marine environment monitoring',
        'Scientific research on plankton',
        'Red tide phenomenon study',
      ],
      'Karenia': [
        'Early warning of red tide phenomena',
        'Coastal monitoring and fishery protection',
        'Algal toxicity research',
      ],
      'Microcystis': [
        'Freshwater pollution monitoring',
        'Early warning of harmful algal blooms',
        'Water treatment research',
      ],
      'Noctiluca': [
        'Ecotourism and scientific tourism',
        'Bioluminescence studies',
        'Bays and coastal areas monitoring',
      ],
      'Nodularia': [
        'Freshwater and lake monitoring',
        'Aquatic ecology research',
        'Climate change studies',
      ],
      'Nostoc': [
        'Sustainable and organic agriculture',
        'Biofertilizers',
        'Traditional and folk medicine',
      ],
      'Oscillatoria': [
        'Environmental pollution monitoring',
        'Wastewater treatment',
        'Metal bioaccumulation research',
      ],
      'Prorocentrum': [
        'Fish feed for aquaculture',
        'Marine environment monitoring',
        'Marine microbiology research',
      ],
      'Skeletonema': [
        'Shellfish feeding and aquaculture',
        'Marine water fertility monitoring',
        'Aquaculture research',
      ],
      'nontoxic': [
        'Educational purposes in schools and universities',
        'Safe laboratory experiments',
        'Scientific gardens and research centers',
      ],
    };

    return usesData[type] ?? [
      'Scientific research',
      'Environmental monitoring',
      'Educational purposes',
    ];
  }

  Map<String, dynamic> _getAlgaeInfo(String type) {
    final algaeData = {
      'Anabaena': {
        'scientificName': 'Anabaena spp.',
        'description': 'Filamentous blue-green algae known for forming specialized cells called heterocysts for nitrogen fixation.',
        'characteristics': 'Filamentous, forms chains of cells, capable of nitrogen fixation, produces specialized heterocyst cells.',
        'toxicity': 'Can produce neurotoxins (anatoxins) and hepatotoxins. Toxic blooms require monitoring.',
        'habitat': 'Freshwater lakes, ponds, slow-moving rivers. Forms surface blooms in nutrient-rich waters.',
        'benefits': _getDefaultBenefits('Anabaena'),
        'uses': _getDefaultUses('Anabaena'),
      },
      'Aphanizomenon': {
        'scientificName': 'Aphanizomenon spp.',
        'description': 'Filamentous algae forming straight or slightly curved filaments, often forming dense surface layers.',
        'characteristics': 'Forms bundles or packets of filaments, gas vesicles for buoyancy, straight filamentous structure.',
        'toxicity': 'Can produce neurotoxins (saxitoxins) and cytotoxins. Some strains are toxic to animals and humans.',
        'habitat': 'Nutrient-rich freshwater systems, lakes, reservoirs. Prefers calm, nutrient-rich waters.',
        'benefits': _getDefaultBenefits('Aphanizomenon'),
        'uses': _getDefaultUses('Aphanizomenon'),
      },
      'Gymnodinium': {
        'scientificName': 'Gymnodinium spp.',
        'description': 'Unarmored dinoflagellate characterized by distinctive swimming behavior and diverse ecological roles.',
        'characteristics': 'Naked cells without protective plates, two flagella for movement, mixotrophic capabilities.',
        'toxicity': 'Some species produce potent neurotoxins. Can cause harmful algal blooms (red tide).',
        'habitat': 'Marine and brackish waters worldwide. Coastal and oceanic environments.',
        'benefits': _getDefaultBenefits('Gymnodinium'),
        'uses': _getDefaultUses('Gymnodinium'),
      },
      'Karenia': {
        'scientificName': 'Karenia spp.',
        'description': 'Genus of unarmored dinoflagellates including species responsible for major red tide events.',
        'characteristics': 'Golden-brown color, unarmored, photosynthetic, forms dense surface aggregations.',
        'toxicity': 'Produces brevetoxins affecting the nervous system. Causes fish kills and respiratory irritation.',
        'habitat': 'Coastal marine waters, especially in warm temperate to tropical regions.',
        'benefits': _getDefaultBenefits('Karenia'),
        'uses': _getDefaultUses('Karenia'),
      },
      'Microcystis': {
        'scientificName': 'Microcystis spp.',
        'description': 'Filamentous algae forming irregularly shaped colonies with gas vesicles for buoyancy control.',
        'characteristics': 'Forms spherical or irregular colonies, cells embedded in gelatinous matrix, gas vesicles present.',
        'toxicity': 'Produces microcystins - potent hepatotoxins. Major concern for drinking water safety.',
        'habitat': 'Nutrient-rich freshwater lakes, reservoirs worldwide. Thrives in warm, nutrient-rich conditions.',
        'benefits': _getDefaultBenefits('Microcystis'),
        'uses': _getDefaultUses('Microcystis'),
      },
      'Noctiluca': {
        'scientificName': 'Noctiluca scintillans',
        'description': 'Large bioluminescent dinoflagellate known for creating stunning "sea sparkle" displays at night.',
        'characteristics': 'Large spherical cells (up to 2mm), bioluminescent, phagotrophic feeding on other plankton.',
        'toxicity': 'Generally non-toxic but can cause ecological disturbances through massive bloom formation.',
        'habitat': 'Coastal marine waters worldwide. Often forms red or green tides in nutrient-rich areas.',
        'benefits': _getDefaultBenefits('Noctiluca'),
        'uses': _getDefaultUses('Noctiluca'),
      },
      'Nodularia': {
        'scientificName': 'Nodularia spp.',
        'description': 'Filamentous algae with barrel-shaped cells and specialized cells for nitrogen fixation.',
        'characteristics': 'Straight filaments, barrel-shaped cells, forms heterocysts, gas vesicles for buoyancy.',
        'toxicity': 'Produces nodularin, a potent hepatotoxin similar to microcystin. Toxic to liver tissues.',
        'habitat': 'Brackish waters, estuaries, Baltic Sea. Tolerant of varying salinity conditions.',
        'benefits': _getDefaultBenefits('Nodularia'),
        'uses': _getDefaultUses('Nodularia'),
      },
      'Nostoc': {
        'scientificName': 'Nostoc spp.',
        'description': 'Filamentous algae forming gelatinous colonies, capable of nitrogen fixation in specialized cells.',
        'characteristics': 'Forms gelatinous colonies, bead-on-string appearance, heterocysts for nitrogen fixation.',
        'toxicity': 'Generally non-toxic. Some strains may produce minor toxins but not typically harmful.',
        'habitat': 'Diverse habitats including freshwater, terrestrial environments, and symbiotic relationships.',
        'benefits': _getDefaultBenefits('Nostoc'),
        'uses': _getDefaultUses('Nostoc'),
      },
      'Oscillatoria': {
        'scientificName': 'Oscillatoria spp.',
        'description': 'Filamentous algae showing oscillating movement, forming dense mats in aquatic systems.',
        'characteristics': 'Long straight filaments, gliding movement, forms surface layers and benthic mats.',
        'toxicity': 'Some species produce microcystins and other toxins. Toxicity varies between strains.',
        'habitat': 'Freshwater systems, wastewater treatment plants, benthic areas of lakes and rivers.',
        'benefits': _getDefaultBenefits('Oscillatoria'),
        'uses': _getDefaultUses('Oscillatoria'),
      },
      'Prorocentrum': {
        'scientificName': 'Prorocentrum spp.',
        'description': 'Armored dinoflagellate with distinctive valvate structure, important in marine plankton communities.',
        'characteristics': 'Protective shell plates, flagellar insertion, photosynthetic, some species mixotrophic.',
        'toxicity': 'Some species produce okadaic acid causing diarrhetic shellfish poisoning (DSP).',
        'habitat': 'Coastal marine waters, coral reefs, mangrove systems worldwide.',
        'benefits': _getDefaultBenefits('Prorocentrum'),
        'uses': _getDefaultUses('Prorocentrum'),
      },
      'Skeletonema': {
        'scientificName': 'Skeletonema spp.',
        'description': 'Centric diatom forming long chains connected by marginal processes, important in marine food webs.',
        'characteristics': 'Forms long chains, cylindrical cells, marginal linking processes, silica skeleton.',
        'toxicity': 'Non-toxic. Important primary producer supporting marine food webs.',
        'habitat': 'Coastal and oceanic waters worldwide. Often dominates spring plankton blooms.',
        'benefits': _getDefaultBenefits('Skeletonema'),
        'uses': _getDefaultUses('Skeletonema'),
      },
      'nontoxic': {
        'scientificName': 'Non-toxic Algae Species',
        'description': 'This algae sample has been classified as non-toxic based on current analysis methods.',
        'characteristics': 'Safe for aquatic ecosystems, does not produce harmful toxins, supports healthy food webs.',
        'toxicity': 'Non-toxic - safe for environment and human contact',
        'habitat': 'Various aquatic environments including freshwater, marine, and brackish systems.',
        'benefits': _getDefaultBenefits('nontoxic'),
        'uses': _getDefaultUses('nontoxic'),
      },
      'default': {
        'scientificName': 'Classification in progress',
        'description': 'Scientific analysis and microscopic examination underway for accurate species identification.',
        'characteristics': 'Detailed morphological and genetic analysis in progress for comprehensive characterization.',
        'toxicity': 'Toxicity assessment ongoing using advanced detection methods and bioassays.',
        'habitat': 'Ecological habitat analysis and environmental preferences being studied.',
        'benefits': ['Benefits information being updated from database'],
        'uses': ['Uses information being updated from database'],
      },
    };

    return algaeData[type] ?? algaeData['default']!;
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