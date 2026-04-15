// lib/data/models/algae_model.dart
import 'dart:convert';

import 'package:flutter/material.dart';

class AlgaeResult {
  final String name;
  final String scientificName;
  final double confidence;
  final String confidenceLevel;
  final List<String> benefits;
  final List<String> uses;
  final List<Map<String, dynamic>> allPredictions;
  final Map<String, dynamic> modelInfo;
  final DateTime dateTime;
  final bool isToxic;
  final String toxicityWarning;
  final String scientificWarning;      // New: accurate scientific warning
  final String category;               // New: classification (Cyanobacteria/Dinoflagellate/Diatom)
  final List<String> potentialToxins;  // New: potential toxins
  final double co2PerKg;               // New: CO2 coefficient
  final String sellable;               // New: suitable for sale? (Yes/No/Conditional)
  final String arabicName;             // New: Arabic name

  AlgaeResult({
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.confidenceLevel,
    required this.benefits,
    required this.uses,
    required this.allPredictions,
    required this.modelInfo,
    required this.dateTime,
    required this.isToxic,
    required this.toxicityWarning,
    required this.scientificWarning,
    required this.category,
    required this.potentialToxins,
    required this.co2PerKg,
    required this.sellable,
    required this.arabicName,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'scientificName': scientificName,
      'confidence': confidence,
      'confidenceLevel': confidenceLevel,
      'benefits': benefits,
      'uses': uses,
      'isToxic': isToxic,
      'toxicityWarning': toxicityWarning,
      'scientificWarning': scientificWarning,
      'category': category,
      'potentialToxins': potentialToxins,
      'co2PerKg': co2PerKg,
      'sellable': sellable,
      'arabicName': arabicName,
      'dateTime': dateTime.toIso8601String(),
      'processingTime': modelInfo['processingTime'] ?? 0,
    };
  }

  factory AlgaeResult.empty() {
    return AlgaeResult(
      name: 'Unknown',
      scientificName: 'Unknown spp.',
      confidence: 0.0,
      confidenceLevel: 'Not Available',
      benefits: [],
      uses: [],
      allPredictions: [],
      modelInfo: {},
      dateTime: DateTime.now(),
      isToxic: false,
      toxicityWarning: 'Not Specified',
      scientificWarning: 'Unable to identify. Please consult an expert.',
      category: 'Unknown',
      potentialToxins: [],
      co2PerKg: 0.0,
      sellable: 'Unknown',
      arabicName: 'Unknown',
    );
  }

  bool get isValid => name != 'Unknown' && confidence > 0.1;

  Color get toxicityColor {
    if (!isToxic) return Colors.green;
    if (name == 'Microcystis' || name == 'Karenia') return Colors.red;
    return Colors.orange;
  }
}

class PredictionResponse {
  final String prediction;
  final double confidence;

  PredictionResponse({
    required this.prediction,
    required this.confidence,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prediction': prediction,
      'confidence': confidence,
    };
  }

  String toJsonString() {
    return json.encode(toJson());
  }
}

class ApiResponse {
  final bool success;
  final String? error;
  final PredictionResponse? data;

  ApiResponse({
    required this.success,
    this.error,
    this.data,
  });

  factory ApiResponse.success(PredictionResponse data) {
    return ApiResponse(success: true, data: data);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse(success: false, error: error);
  }
}

// ============================================================
// Scientifically corrected data according to provided encyclopedia
// ============================================================

const algaeData = {
  // ===================== Cyanobacteria =====================

  'Anabaena': {
    'scientificName': 'Anabaena spp. (or Dolichospermum)',
    'arabicName': 'Anabaena',
    'category': 'Cyanobacteria (Blue-green bacteria)',
    'isToxic': false,  // Not all species are toxic
    'toxicityWarning': '! Toxin production depends on species/strain',
    'scientificWarning': 'Most planktonic Anabaena are now reclassified as Dolichospermum. Toxicity varies significantly between species and strains. Cannot determine without genetic/toxin analysis.',
    'potentialToxins': ['anatoxin-a (neurotoxin) - in some strains', 'Other toxins possible depending on species'],
    'co2PerKg': 1.83,  // Scientific range 1.83-1.88
    'sellable': 'Conditional - Only as controlled culture (e.g., Azolla-Anabaena symbiosis), NOT from wild blooms',
    'benefits': [
      '- Atmospheric nitrogen fixation (via heterocysts)',
      '- Used in Azolla-Anabaena symbiosis as green manure in rice fields',
      '- Improves soil fertility (when using non-toxic strains)'
    ],
    'uses': [
      '- Biofertilizers (with defined non-toxic strains)',
      '- Scientific research',
      '- Nitrogen fixation studies'
    ]
  },

  'Aphanizomenon': {
    'scientificName': 'Aphanizomenon spp.',
    'arabicName': 'Aphanizomenon',
    'category': 'Cyanobacteria (Blue-green bacteria)',
    'isToxic': false,  // Varies by strain
    'toxicityWarning': '! Some strains produce toxins, others do not',
    'scientificWarning': 'Some Aphanizomenon strains produce saxitoxins (neurotoxins) or cylindrospermopsin (hepatotoxin/nephrotoxin). Commercial AFA from Klamath Lake risks Microcystis contamination. NOT safe for sale without toxin testing.',
    'potentialToxins': ['Saxitoxins (neurotoxins)', 'Cylindrospermopsin (hepatotoxin/nephrotoxin)', 'Risk of Microcystin contamination from environment'],
    'co2PerKg': 1.83,
    'sellable': 'No - High regulatory risk without extensive toxin testing and controlled cultivation',
    'benefits': [
      '- Nitrogen fixation',
      '- Ecological role as primary producer'
    ],
    'uses': [
      '- Scientific research',
      '- Water quality monitoring',
      '- Toxin studies'
    ]
  },

  'Microcystis': {
    'scientificName': 'Microcystis spp.',
    'arabicName': 'Microcystis',
    'category': 'Cyanobacteria (Blue-green bacteria)',
    'isToxic': true,
    'toxicityWarning': '! DANGER: Produces dangerous hepatotoxins (Microcystins)',
    'scientificWarning': 'One of the most notorious cyanobacteria genera for producing microcystins (liver toxins). WHO drinking water guideline: 1 microgram/L for microcystin-LR. NOT suitable for sale as food/feed/fertilizer.',
    'potentialToxins': ['Microcystins (hepatotoxins - liver toxins)'],
    'co2PerKg': 1.83,
    'sellable': 'No - Not suitable for commercial sale as raw biomass. Used only for research and monitoring.',
    'benefits': [
      '! No direct benefits - this is a hazardous genus',
      '- Used for water quality studies and toxin research'
    ],
    'uses': [
      '- Scientific research',
      '- Environmental monitoring',
      '- Water safety management',
      '- Risk assessment'
    ]
  },

  'Nodularia': {
    'scientificName': 'Nodularia spp.',
    'arabicName': 'Nodularia',
    'category': 'Cyanobacteria (Blue-green bacteria)',
    'isToxic': true,
    'toxicityWarning': '! Produces Nodularin (hepatotoxin)',
    'scientificWarning': 'Nodularia spumigena is the most famous species, producing nodularin (cyclic peptide hepatotoxin similar to microcystins). Common in brackish waters like the Baltic Sea. Not a commercial product.',
    'potentialToxins': ['Nodularin (hepatotoxin - liver toxin)'],
    'co2PerKg': 1.83,
    'sellable': 'No - Not commercially viable. Research and monitoring only.',
    'benefits': [
      '- Nitrogen fixation (ecological role in low-nitrogen brackish systems)',
      '! No direct economic benefits'
    ],
    'uses': [
      '- Scientific research',
      '- Toxin monitoring',
      '- Bloom studies',
      '- Genomic research'
    ]
  },

  'Nostoc': {
    'scientificName': 'Nostoc spp.',
    'arabicName': 'Nostoc - Star jelly',
    'category': 'Cyanobacteria (Blue-green bacteria)',
    'isToxic': false,  // Not all species are toxic
    'toxicityWarning': '! Generally safe for known edible species, but some strains can produce toxins',
    'scientificWarning': 'Some Nostoc strains can produce microcystins or nodularin under certain conditions. Traditional edible species (e.g., Nostoc flagelliforme "Facai" in China) have long safety history, but modern products require strain identification and safety testing.',
    'potentialToxins': ['Microcystins (in some strains)', 'Nodularin (reported in some cases)'],
    'co2PerKg': 1.83,
    'sellable': 'Conditional - Only defined non-toxic strains with safety documentation',
    'benefits': [
      '- Nitrogen fixation',
      '- Soil improvement and biofertilizer potential',
      '- Protein source (traditional edible species)'
    ],
    'uses': [
      '- Biofertilizers (non-toxic strains)',
      '- Scientific research',
      '- Traditional food (specific species)',
      '- Soil reclamation'
    ]
  },

  'Oscillatoria': {
    'scientificName': 'Oscillatoria spp.',
    'arabicName': 'Oscillatoria - Oscillating algae',
    'category': 'Cyanobacteria (Blue-green bacteria)',
    'isToxic': false,  // Varies by strain
    'toxicityWarning': '! Some strains produce neurotoxins or skin irritants',
    'scientificWarning': 'Some Oscillatoria strains produce anatoxin-a (neurotoxin), microcystins, or aplysiatoxins (skin irritant). Not recommended for food/agriculture without laboratory identification and toxin testing.',
    'potentialToxins': ['Anatoxin-a (neurotoxin)', 'Microcystins (hepatotoxin)', 'Aplysiatoxins (skin irritant)'],
    'co2PerKg': 1.83,
    'sellable': 'No - Not suitable for commercial products. Research and monitoring only.',
    'benefits': [
      '- Used as environmental indicator in water pollution studies'
    ],
    'uses': [
      '- Scientific research',
      '- Environmental monitoring',
      '- Toxin studies'
    ]
  },

  // ===================== Dinoflagellates =====================

  'Gymnodinium': {
    'scientificName': 'Gymnodinium spp.',
    'arabicName': 'Gymnodinium',
    'category': 'Dinoflagellate',
    'isToxic': false,  // Some species only
    'toxicityWarning': '! Some species (e.g., G. catenatum) produce paralytic shellfish toxins',
    'scientificWarning': 'Gymnodinium catenatum is known to produce saxitoxins causing Paralytic Shellfish Poisoning (PSP). Not all Gymnodinium species are toxic. Red tide (HAB) does not automatically mean toxicity.',
    'potentialToxins': ['Saxitoxins (PST/PSP) - in some species like G. catenatum'],
    'co2PerKg': 1.83,
    'sellable': 'No - Not a commercial biomass product. Relevant for monitoring only.',
    'benefits': [
      '- Part of marine food web',
      '- Marine ecology studies'
    ],
    'uses': [
      '- Scientific research',
      '- Shellfish monitoring',
      '- Early warning systems for toxins'
    ]
  },

  'Karenia': {
    'scientificName': 'Karenia spp.',
    'arabicName': 'Karenia - Red tide algae',
    'category': 'Dinoflagellate (unarmored)',
    'isToxic': true,
    'toxicityWarning': '! DANGER: Produces Brevetoxins (neurotoxins) - causes Red Tide',
    'scientificWarning': 'Karenia brevis produces brevetoxins causing Neurotoxic Shellfish Poisoning (NSP), fish kills, marine mammal deaths, and respiratory irritation from aerosolized toxins. Major public health and environmental concern.',
    'potentialToxins': ['Brevetoxins (neurotoxins)'],
    'co2PerKg': 1.83,
    'sellable': 'No - Highly toxic. Not a commercial product. Critical for monitoring only.',
    'benefits': [
      '! No economic benefits - this is a hazardous genus',
      '- Environmental change studies'
    ],
    'uses': [
      '- Scientific research',
      '- Environmental monitoring',
      '- Public health protection',
      '- Fisheries management'
    ]
  },

  'Prorocentrum': {
    'scientificName': 'Prorocentrum spp.',
    'arabicName': 'Prorocentrum',
    'category': 'Dinoflagellate (armored/thecate)',
    'isToxic': false,  // Some species only
    'toxicityWarning': '! Some species produce Okadaic acid (DSP - Diarrhetic Shellfish Poisoning)',
    'scientificWarning': 'Some Prorocentrum species (especially benthic/mixed) produce okadaic acid and dinophysistoxins causing Diarrhetic Shellfish Poisoning (DSP). EU regulatory limit: ~160 microgram OA equivalents/kg shellfish.',
    'potentialToxins': ['Okadaic acid', 'Dinophysistoxins (DSP)'],
    'co2PerKg': 1.83,
    'sellable': 'No - Not a commercial biomass product. Monitoring only.',
    'benefits': [
      '- Marine ecology studies'
    ],
    'uses': [
      '- Scientific research',
      '- Shellfish monitoring',
      '- Toxin analysis (LC-MS/MS)'
    ]
  },

  'Noctiluca': {
    'scientificName': 'Noctiluca scintillans',
    'arabicName': 'Noctiluca - Glowing algae',
    'category': 'Dinoflagellate (heterotrophic)',
    'isToxic': false,
    'toxicityWarning': '! Not a known producer of human toxins, but blooms can cause hypoxia and fish kills',
    'scientificWarning': 'Mostly heterotrophic (feeds on plankton), not photosynthetic. Does NOT fix CO2 like photosynthetic organisms. "Green form" contains photosynthetic symbiont in some regions. Blooms can cause anoxia and ammonia release leading to marine life deaths.',
    'potentialToxins': ['No known human toxins', 'Environmental damage: hypoxia, ammonia'],
    'co2PerKg': 0.0,  // Not a photosynthetic organism - does not fix CO2 in standard sense
    'sellable': 'No - Not for commercial biomass. Valued for ecotourism (bioluminescence) only.',
    'benefits': [
      '- Bioluminescence (creates glowing sea phenomenon)',
      '- Educational value',
      '- Ecotourism attraction'
    ],
    'uses': [
      '- Scientific research',
      '- Ecotourism',
      '- Science education',
      '- Nature photography'
    ]
  },

  // ===================== Diatoms =====================

  'Skeletonema': {
    'scientificName': 'Skeletonema spp.',
    'arabicName': 'Skeletonema',
    'category': 'Diatom (centric)',
    'isToxic': false,
    'toxicityWarning': '- Generally safe. Not a human toxin producer.',
    'scientificWarning': 'Not known to produce human toxins. Dense blooms may cause environmental hypoxia after decay. One of the most practical and safe genera for aquaculture applications.',
    'potentialToxins': ['None known for humans', 'Environmental: possible hypoxia from dense blooms'],
    'co2PerKg': 1.83,
    'sellable': 'Yes - Excellent for aquaculture (live feed in hatcheries)',
    'benefits': [
      '- Rich in fatty acids',
      '- Excellent live feed for aquatic larvae',
      '- Important primary producer in coastal systems'
    ],
    'uses': [
      '- Aquaculture - Hatcheries (shrimp, shellfish larvae)',
      '- Scientific research',
      '- Marine ecology'
    ]
  },

  // ===================== General category (for flexibility) =====================

  'nontoxic': {
    'scientificName': 'Non-toxic Algae (general category)',
    'arabicName': 'Non-toxic algae',
    'category': 'General category - requires species identification',
    'isToxic': false,
    'toxicityWarning': '- Environmentally safe (based on general category)',
    'scientificWarning': 'This is a general category, not a scientific name. For commercial use, must specify exact species/strain and verify toxin-free status via LC-MS/MS or ELISA testing with source tracking (culture collection/barcode).',
    'potentialToxins': ['Should be tested to confirm absence of: Microcystins, Nodularin, Anatoxin-a, Saxitoxins, Cylindrospermopsin'],
    'co2PerKg': 1.83,
    'sellable': 'Conditional - Requires species identification and toxin testing per batch',
    'benefits': [
      '- Maintains ecological balance',
      '- Oxygen production',
      '- Food source for organisms'
    ],
    'uses': [
      '- Hydroponics',
      '- Scientific research',
      '- Aquaculture (with identification)'
    ]
  }
};

// Helper function to get algae data by name
Map<String, dynamic> getAlgaeData(String name) {
  if (algaeData.containsKey(name)) {
    return algaeData[name] as Map<String, dynamic>;
  }
  return algaeData['nontoxic'] as Map<String, dynamic>;
}

// Function to convert result to AlgaeResult
AlgaeResult createAlgaeResultFromPrediction(String predictedName, double confidence, double processingTime) {
  final data = getAlgaeData(predictedName);

  return AlgaeResult(
    name: predictedName,
    scientificName: data['scientificName'] as String,
    confidence: confidence,
    confidenceLevel: confidence > 0.8 ? 'High' : (confidence > 0.6 ? 'Medium' : 'Low'),
    benefits: List<String>.from(data['benefits']),
    uses: List<String>.from(data['uses']),
    allPredictions: [],
    modelInfo: {'processingTime': processingTime},
    dateTime: DateTime.now(),
    isToxic: data['isToxic'] as bool,
    toxicityWarning: data['toxicityWarning'] as String,
    scientificWarning: data['scientificWarning'] as String,
    category: data['category'] as String,
    potentialToxins: List<String>.from(data['potentialToxins']),
    co2PerKg: (data['co2PerKg'] as num).toDouble(),
    sellable: data['sellable'] as String,
    arabicName: data['arabicName'] as String,
  );
}