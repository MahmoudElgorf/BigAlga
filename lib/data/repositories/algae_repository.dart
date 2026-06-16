/// Algae repository for local data access
class AlgaeRepository {
  static Map<String, dynamic> getLocalAlgaeInfo(String type) {
    final data = _getAlgaeDataMap();
    return data[type] ?? data['default']!;
  }

  static String getHabitatForType(String type) {
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

  static Map<String, dynamic> _getAlgaeDataMap() {
    return {
      'Anabaena': {
        'scientificName': 'Anabaena spp. (or Dolichospermum)',
        'arabicName': 'Anabaena',
        'category': 'Cyanobacteria',
        'isToxic': false,
        'toxicityWarning': '! Toxin production depends on species/strain',
        'scientificWarning':
        'Most planktonic Anabaena are now reclassified as Dolichospermum. Toxicity varies significantly between species and strains.',
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
        'scientificWarning':
        'Some strains produce saxitoxins or cylindrospermopsin. Commercial products risk Microcystis contamination.',
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
        'scientificWarning':
        'Produces microcystins (liver toxins). WHO guideline: 1 microgram/L in drinking water.',
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
        'scientificWarning':
        'Produces brevetoxins causing Neurotoxic Shellfish Poisoning and respiratory irritation.',
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
        'scientificWarning':
        'Produces nodularin (hepatotoxin). Common in brackish waters like the Baltic Sea.',
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
        'scientificWarning':
        'Some strains can produce toxins. Traditional edible species have long safety history.',
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
        'toxicityWarning': 'Some strains produce toxins',
        'scientificWarning':
        'Some strains produce anatoxin-a or microcystins. Not for food/agriculture without testing.',
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
        'scientificWarning':
        'Gymnodinium catenatum produces saxitoxins (PSP). Not all species are toxic.',
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
        'scientificWarning':
        'Some species produce okadaic acid causing Diarrhetic Shellfish Poisoning.',
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
        'scientificWarning':
        'Heterotrophic - does NOT fix CO2 like photosynthetic organisms. Blooms can cause fish kills.',
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
        'scientificWarning':
        'Not known to produce human toxins. Excellent for aquaculture.',
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
        'scientificWarning':
        'Requires species identification and toxin testing per batch.',
        'potentialToxins': [
          'Test for: Microcystins, Nodularin, Anatoxin-a, Saxitoxins'
        ],
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
        'scientificWarning':
        'Scientific analysis underway for accurate identification.',
        'potentialToxins': ['Analysis pending'],
        'co2PerKg': 1.83,
        'sellable': 'Unknown - Requires identification',
        'benefits': ['Information being updated'],
        'uses': ['Information being updated'],
        'habitat': 'Analysis ongoing',
      },
    };
  }
}