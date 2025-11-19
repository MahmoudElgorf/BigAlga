import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';

class AlgaeInfo extends StatelessWidget {
  final String algaeType;

  const AlgaeInfo({Key? key, required this.algaeType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final info = _getAlgaeInfo(algaeType);

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
              Color(0xFFF0F8F0),
              Color(0xFFE8F5E8),
            ],
          ),
          borderRadius: BorderRadius.only(
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
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with leaf icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF2E7D32).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    shape: BoxShape.rectangle,
                  ),
                  child: Icon(
                    Icons.eco,
                    color: Color(0xFF2E7D32),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Scientific Profile',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Color(0xFF1B5E20),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Leaf vein divider
            Container(
              height: 2,
              width: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50).withOpacity(0.6),
                    Color(0xFF8BC34A).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Scientific Name
            _buildLeafVeinItem(
              Icons.emoji_nature,
              'Scientific Name',
              info['scientificName'] ?? 'Not available',
              Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),

            // Description
            _buildLeafVeinItem(
              Icons.water_drop,
              'Description',
              info['description'] ?? 'Information collection in progress',
              Color(0xFF388E3C),
            ),
            const SizedBox(height: 16),

            // Characteristics
            _buildLeafVeinItem(
              Icons.visibility,
              'Characteristics',
              info['characteristics'] ?? 'Characteristics analysis in progress',
              Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),

            // Toxicity
            _buildLeafVeinItem(
              Icons.warning,
              'Toxicity Level',
              info['toxicity'] ?? 'Toxicity analysis in progress',
              Color(0xFF8BC34A),
            ),
            const SizedBox(height: 16),

            // Habitat
            _buildLeafVeinItem(
              Icons.location_on,
              'Habitat',
              info['habitat'] ?? 'Habitat information updating soon',
              Color(0xFF2E7D32),
            ),
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
                    color: Color(0xFF1B5E20),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    color: Color(0xFF424242),
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

  Map<String, String> _getAlgaeInfo(String type) {
    final algaeData = {
      'Anabaena': {
        'scientificName': 'Anabaena spp.',
        'description': 'Filamentous cyanobacteria known for forming specialized cells called heterocysts for nitrogen fixation.',
        'characteristics': 'Filamentous, forms chains of cells, capable of nitrogen fixation, produces specialized heterocyst cells.',
        'toxicity': 'Can produce neurotoxins (anatoxins) and hepatotoxins. Potentially toxic blooms require monitoring.',
        'habitat': 'Freshwater lakes, ponds, slow-moving rivers. Forms surface blooms in nutrient-rich waters.',
      },
      'Aphanizomenon': {
        'scientificName': 'Aphanizomenon spp.',
        'description': 'Filamentous cyanobacteria forming straight or slightly curved trichomes, often forming dense surface scums.',
        'characteristics': 'Forms rafts or bundles of filaments, gas vesicles for buoyancy, straight trichome structure.',
        'toxicity': 'Can produce neurotoxins (saxitoxins) and cytotoxins. Some strains are toxic to animals and humans.',
        'habitat': 'Eutrophic freshwater systems, lakes, reservoirs. Prefers calm, nutrient-rich waters.',
      },
      'Gymnodinium': {
        'scientificName': 'Gymnodinium spp.',
        'description': 'Unarmored dinoflagellate with distinctive swimming behavior and diverse ecological roles.',
        'characteristics': 'Naked cell without thecal plates, two flagella for movement, mixotrophic capabilities.',
        'toxicity': 'Some species produce potent neurotoxins. Can cause harmful algal blooms (red tides).',
        'habitat': 'Marine and brackish waters worldwide. Both coastal and open ocean environments.',
      },
      'Karenia': {
        'scientificName': 'Karenia spp.',
        'description': 'Unarmored dinoflagellate genus including species responsible for major red tide events.',
        'characteristics': 'Golden-brown color, unarmored, photosynthetic, forms dense surface aggregations.',
        'toxicity': 'Produces brevetoxins that affect nervous system. Causes fish kills and respiratory irritation.',
        'habitat': 'Coastal marine waters, particularly in warm temperate to tropical regions.',
      },
      'Microcystis': {
        'scientificName': 'Microcystis spp.',
        'description': 'Colonial cyanobacteria forming irregular-shaped colonies with gas vesicles for buoyancy control.',
        'characteristics': 'Forms spherical or irregular colonies, cells embedded in gelatinous matrix, gas vesicles present.',
        'toxicity': 'Produces microcystins - potent hepatotoxins. Major concern for drinking water safety.',
        'habitat': 'Eutrophic freshwater lakes, reservoirs worldwide. Thrives in warm, nutrient-rich conditions.',
      },
      'Noctiluca': {
        'scientificName': 'Noctiluca scintillans',
        'description': 'Large, bioluminescent dinoflagellate known for creating spectacular "sea sparkle" displays at night.',
        'characteristics': 'Large spherical cells (up to 2mm), bioluminescent, phagotrophic feeding on other plankton.',
        'toxicity': 'Generally non-toxic but can cause ecological disruptions through massive bloom formations.',
        'habitat': 'Coastal marine waters worldwide. Often forms red or green tides in nutrient-rich areas.',
      },
      'Nodularia': {
        'scientificName': 'Nodularia spp.',
        'description': 'Filamentous cyanobacteria with barrel-shaped cells and specialized nitrogen-fixing heterocysts.',
        'characteristics': 'Straight filaments, barrel-shaped cells, forms heterocysts, gas vesicles for buoyancy.',
        'toxicity': 'Produces nodularin, a potent hepatotoxin similar to microcystin. Toxic to liver tissues.',
        'habitat': 'Brackish waters, estuaries, Baltic Sea. Tolerant of varying salinity conditions.',
      },
      'Nostoc': {
        'scientificName': 'Nostoc spp.',
        'description': 'Filamentous cyanobacteria forming gelatinous colonies, capable of nitrogen fixation in specialized cells.',
        'characteristics': 'Forms gelatinous colonies, beads-on-string appearance, heterocysts for nitrogen fixation.',
        'toxicity': 'Generally non-toxic. Some strains may produce minor toxins but not typically harmful.',
        'habitat': 'Diverse habitats including freshwater, terrestrial environments, and symbiotic associations.',
      },
      'Oscillatoria': {
        'scientificName': 'Oscillatoria spp.',
        'description': 'Filamentous cyanobacteria exhibiting oscillating movement, forming dense mats in aquatic systems.',
        'characteristics': 'Long, straight filaments, gliding motility, forms surface scums and benthic mats.',
        'toxicity': 'Some species produce microcystins and other toxins. Toxicity varies among strains.',
        'habitat': 'Freshwater systems, wastewater treatment plants, benthic zones of lakes and rivers.',
      },
      'Prorocentrum': {
        'scientificName': 'Prorocentrum spp.',
        'description': 'Armored dinoflagellate with distinctive valve structure, important in marine plankton communities.',
        'characteristics': 'Bivalve thecal plates, flagella insertion, photosynthetic, some species mixotrophic.',
        'toxicity': 'Some species produce okadaic acid causing diarrhetic shellfish poisoning (DSP).',
        'habitat': 'Coastal marine waters, coral reefs, mangrove ecosystems worldwide.',
      },
      'Skeletonema': {
        'scientificName': 'Skeletonema spp.',
        'description': 'Centric diatom forming long chains connected by marginal processes, important in marine food webs.',
        'characteristics': 'Forms long chains, cylindrical cells, marginal linking processes, silica frustule.',
        'toxicity': 'Non-toxic. Important primary producer supporting marine food webs.',
        'habitat': 'Coastal and oceanic waters worldwide. Often dominates spring phytoplankton blooms.',
      },
      'nontoxic': {
        'scientificName': 'Non-toxic Algae Species',
        'description': 'This algae specimen has been classified as non-toxic based on current analysis methods.',
        'characteristics': 'Safe for aquatic ecosystems, does not produce harmful toxins, supports healthy food webs.',
        'toxicity': 'Non-toxic - Safe for environment and human contact',
        'habitat': 'Various aquatic environments including freshwater, marine, and brackish systems.',
      },
      'default': {
        'scientificName': 'Classification in progress',
        'description': 'Scientific analysis and microscopic examination ongoing for precise species identification.',
        'characteristics': 'Detailed morphological and genetic analysis underway for comprehensive characterization.',
        'toxicity': 'Toxicity assessment in progress using advanced detection methods and bioassays.',
        'habitat': 'Ecological habitat analysis and environmental preferences under investigation.',
      },
    };

    return algaeData[type] ?? algaeData['default']!;
  }
}

class LeafShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4CAF50).withOpacity(0.05)
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