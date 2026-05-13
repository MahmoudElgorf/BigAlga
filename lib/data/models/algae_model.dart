// lib/data/models/algae_model.dart
import 'dart:convert';

import 'package:flutter/material.dart';

class AlgaeResult {
  final String id;
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
  final String scientificWarning;
  final String category;
  final List<String> potentialToxins;
  final double co2PerKg;
  final String sellable;

  AlgaeResult({
    required this.id,
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
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'dateTime': dateTime.toIso8601String(),
      'processingTime': modelInfo['processingTime'] ?? 0,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'confidence': confidence,
      'confidenceLevel': confidenceLevel,
      'isToxic': isToxic,
      'toxicityWarning': toxicityWarning,
      'scientificWarning': scientificWarning,
      'category': category,
      'potentialToxins': potentialToxins,
      'co2PerKg': co2PerKg,
      'sellable': sellable,
      'benefits': benefits,
      'uses': uses,
      'allPredictions': allPredictions,
      'modelInfo': modelInfo,
      'dateTime': dateTime.toIso8601String(),
    };
  }

  factory AlgaeResult.empty() {
    return AlgaeResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      toxicityWarning: 'Not specified',
      scientificWarning: 'Unable to identify the sample. Expert verification is recommended.',
      category: 'Unknown',
      potentialToxins: [],
      co2PerKg: 0.0,
      sellable: 'Unknown',
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
// Scientific reference data
// ============================================================

const Map<String, Map<String, dynamic>> algaeData = {
  // ===================== Cyanobacteria =====================

  'Anabaena': {
    'scientificName': 'Anabaena spp. or Dolichospermum spp.',
    'category': 'Cyanobacteria',
    'isToxic': false,
    'toxicityWarning': 'Toxin production depends on the species and strain.',
    'scientificWarning':
    'Most planktonic Anabaena species are now classified as Dolichospermum. Toxicity varies significantly between species and strains. Genetic or toxin analysis is required for reliable safety assessment.',
    'potentialToxins': [
      'Anatoxin-a in some strains',
      'Other toxins may occur depending on species and strain',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Conditional. Suitable only as a controlled and verified culture. Wild bloom biomass is not recommended.',
    'benefits': [
      'Atmospheric nitrogen fixation through heterocysts',
      'Potential use in Azolla-Anabaena symbiosis as green manure in rice fields',
      'Soil fertility improvement when verified non-toxic strains are used',
    ],
    'uses': [
      'Biofertilizer research using defined non-toxic strains',
      'Scientific research',
      'Nitrogen fixation studies',
    ],
  },

  'Aphanizomenon': {
    'scientificName': 'Aphanizomenon spp.',
    'category': 'Cyanobacteria',
    'isToxic': false,
    'toxicityWarning': 'Some strains may produce toxins, while others may not.',
    'scientificWarning':
    'Some Aphanizomenon strains produce saxitoxins or cylindrospermopsin. Commercial Aphanizomenon flos-aquae biomass may also carry contamination risks from other cyanobacteria such as Microcystis. Commercial use requires controlled cultivation and toxin testing.',
    'potentialToxins': [
      'Saxitoxins',
      'Cylindrospermopsin',
      'Possible microcystin contamination from environmental sources',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not recommended without controlled cultivation, strain verification, and extensive toxin testing.',
    'benefits': [
      'Nitrogen fixation',
      'Ecological role as a primary producer',
    ],
    'uses': [
      'Scientific research',
      'Water quality monitoring',
      'Toxin studies',
    ],
  },

  'Microcystis': {
    'scientificName': 'Microcystis spp.',
    'category': 'Cyanobacteria',
    'isToxic': true,
    'toxicityWarning': 'High risk. This genus may produce hepatotoxins known as microcystins.',
    'scientificWarning':
    'Microcystis is one of the most significant cyanobacterial genera associated with microcystin production. It is not suitable for use as food, feed, fertilizer, or raw commercial biomass.',
    'potentialToxins': [
      'Microcystins',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not suitable for commercial sale as raw biomass. Appropriate only for research and environmental monitoring.',
    'benefits': [
      'No direct commercial benefit is recommended due to safety concerns',
      'Useful for water quality studies and toxin research',
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring',
      'Water safety management',
      'Risk assessment',
    ],
  },

  'Nodularia': {
    'scientificName': 'Nodularia spp.',
    'category': 'Cyanobacteria',
    'isToxic': true,
    'toxicityWarning': 'High risk. Some species produce nodularin, a hepatotoxin.',
    'scientificWarning':
    'Nodularia spumigena is known for producing nodularin, a cyclic peptide hepatotoxin. This genus is commonly associated with brackish water blooms and is not recommended for commercial biomass use.',
    'potentialToxins': [
      'Nodularin',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not commercially recommended. Suitable only for research and environmental monitoring.',
    'benefits': [
      'Nitrogen fixation in low-nitrogen brackish systems',
      'Ecological research value',
    ],
    'uses': [
      'Scientific research',
      'Toxin monitoring',
      'Bloom studies',
      'Genomic research',
    ],
  },

  'Nostoc': {
    'scientificName': 'Nostoc spp.',
    'category': 'Cyanobacteria',
    'isToxic': false,
    'toxicityWarning': 'Some strains may produce toxins under specific conditions.',
    'scientificWarning':
    'Certain Nostoc species have a history of traditional use, but some strains may produce cyanotoxins. Modern commercial use requires strain identification, controlled cultivation, and safety testing.',
    'potentialToxins': [
      'Microcystins in some strains',
      'Nodularin reported in some cases',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Conditional. Suitable only for defined non-toxic strains with safety documentation.',
    'benefits': [
      'Nitrogen fixation',
      'Potential soil improvement and biofertilizer applications',
      'Potential protein source for verified edible species',
    ],
    'uses': [
      'Biofertilizers using verified non-toxic strains',
      'Scientific research',
      'Traditional food applications for specific verified species',
      'Soil reclamation research',
    ],
  },

  'Oscillatoria': {
    'scientificName': 'Oscillatoria spp.',
    'category': 'Cyanobacteria',
    'isToxic': false,
    'toxicityWarning': 'Some strains may produce neurotoxins or skin-irritating compounds.',
    'scientificWarning':
    'Some Oscillatoria strains have been associated with anatoxin-a, microcystins, or skin-irritating compounds. Food or agricultural use is not recommended without laboratory identification and toxin testing.',
    'potentialToxins': [
      'Anatoxin-a',
      'Microcystins',
      'Aplysiatoxins',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not recommended for commercial products. Suitable mainly for research and monitoring.',
    'benefits': [
      'Useful as an environmental indicator in water pollution studies',
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring',
      'Toxin studies',
    ],
  },

  // ===================== Dinoflagellates =====================

  'Gymnodinium': {
    'scientificName': 'Gymnodinium spp.',
    'category': 'Dinoflagellate',
    'isToxic': false,
    'toxicityWarning': 'Some species may produce paralytic shellfish toxins.',
    'scientificWarning':
    'Gymnodinium catenatum is known to produce saxitoxins associated with paralytic shellfish poisoning. Toxicity cannot be generalized to all Gymnodinium species and requires species-level verification.',
    'potentialToxins': [
      'Saxitoxins in some species',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not recommended as a commercial biomass product. Relevant mainly for monitoring and research.',
    'benefits': [
      'Part of marine food webs',
      'Useful for marine ecology studies',
    ],
    'uses': [
      'Scientific research',
      'Shellfish safety monitoring',
      'Early warning systems for harmful algal blooms',
    ],
  },

  'Karenia': {
    'scientificName': 'Karenia spp.',
    'category': 'Dinoflagellate',
    'isToxic': true,
    'toxicityWarning': 'High risk. Some species produce brevetoxins.',
    'scientificWarning':
    'Karenia brevis produces brevetoxins associated with neurotoxic shellfish poisoning, fish kills, marine mammal mortality, and respiratory irritation from aerosolized toxins. This genus is a significant public health and environmental concern.',
    'potentialToxins': [
      'Brevetoxins',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not suitable for commercial use. Relevant mainly for monitoring, public health, and environmental management.',
    'benefits': [
      'No direct commercial benefit is recommended due to safety concerns',
      'Useful for environmental change and harmful bloom studies',
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring',
      'Public health protection',
      'Fisheries management',
    ],
  },

  'Prorocentrum': {
    'scientificName': 'Prorocentrum spp.',
    'category': 'Dinoflagellate',
    'isToxic': false,
    'toxicityWarning': 'Some species may produce okadaic acid and related toxins.',
    'scientificWarning':
    'Some Prorocentrum species produce okadaic acid and dinophysistoxins associated with diarrhetic shellfish poisoning. Species-level identification and toxin analysis are required for risk assessment.',
    'potentialToxins': [
      'Okadaic acid',
      'Dinophysistoxins',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Not recommended as a commercial biomass product. Relevant mainly for monitoring and toxin analysis.',
    'benefits': [
      'Useful for marine ecology studies',
    ],
    'uses': [
      'Scientific research',
      'Shellfish safety monitoring',
      'Toxin analysis',
    ],
  },

  'Noctiluca': {
    'scientificName': 'Noctiluca scintillans',
    'category': 'Dinoflagellate',
    'isToxic': false,
    'toxicityWarning':
    'Not known as a major producer of human toxins, but dense blooms may cause environmental damage.',
    'scientificWarning':
    'Noctiluca scintillans is mostly heterotrophic and does not fix carbon dioxide in the same way as photosynthetic algae. Dense blooms may contribute to hypoxia or ammonia release, which can affect marine life.',
    'potentialToxins': [
      'No major human toxins known',
      'Environmental risks may include hypoxia and ammonia release during blooms',
    ],
    'co2PerKg': 0.0,
    'sellable':
    'Not recommended for commercial biomass use. It may have educational or ecotourism relevance due to bioluminescence.',
    'benefits': [
      'Bioluminescence with educational and ecotourism value',
      'Useful for plankton ecology studies',
    ],
    'uses': [
      'Scientific research',
      'Ecotourism',
      'Science education',
      'Nature photography',
    ],
  },

  // ===================== Diatoms =====================

  'Skeletonema': {
    'scientificName': 'Skeletonema spp.',
    'category': 'Diatom',
    'isToxic': false,
    'toxicityWarning': 'Generally considered safe and not known as a human toxin producer.',
    'scientificWarning':
    'Skeletonema is not known to produce major human toxins. However, very dense blooms may contribute to environmental hypoxia after biomass decay.',
    'potentialToxins': [
      'No major human toxins known',
      'Dense blooms may contribute to hypoxia after decay',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Suitable for controlled aquaculture applications, especially as live feed in hatcheries.',
    'benefits': [
      'Rich in beneficial fatty acids',
      'Valuable live feed for aquatic larvae',
      'Important primary producer in coastal systems',
    ],
    'uses': [
      'Aquaculture hatcheries',
      'Shellfish and shrimp larval feeding',
      'Scientific research',
      'Marine ecology studies',
    ],
  },

  // ===================== General category =====================

  'Nontoxic': {
    'scientificName': 'Non-toxic algae general category',
    'category': 'General category requiring species identification',
    'isToxic': false,
    'toxicityWarning': 'No toxicity indicated based on the general classification.',
    'scientificWarning':
    'This is a general category and not a species-level identification. Commercial or environmental use requires exact species or strain identification and batch-level toxin testing.',
    'potentialToxins': [
      'Microcystins should be tested',
      'Nodularin should be tested',
      'Anatoxin-a should be tested',
      'Saxitoxins should be tested',
      'Cylindrospermopsin should be tested',
    ],
    'co2PerKg': 1.83,
    'sellable':
    'Conditional. Requires species identification, controlled source tracking, and toxin testing for each batch.',
    'benefits': [
      'May support ecological balance',
      'May contribute to oxygen production',
      'May serve as a food source for aquatic organisms',
    ],
    'uses': [
      'Hydroponics after safety verification',
      'Scientific research',
      'Aquaculture after species identification and safety testing',
    ],
  },
};

Map<String, dynamic> getAlgaeData(String name) {
  if (algaeData.containsKey(name)) {
    return algaeData[name] as Map<String, dynamic>;
  }

  return algaeData['Nontoxic'] as Map<String, dynamic>;
}

AlgaeResult createAlgaeResultFromPrediction(
    String predictedName,
    double confidence,
    double processingTime,
    ) {
  final data = getAlgaeData(predictedName);

  return AlgaeResult(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: predictedName,
    scientificName: data['scientificName'] as String,
    confidence: confidence,
    confidenceLevel: confidence > 0.8
        ? 'High'
        : confidence > 0.6
        ? 'Medium'
        : 'Low',
    benefits: List<String>.from(data['benefits']),
    uses: List<String>.from(data['uses']),
    allPredictions: [],
    modelInfo: {
      'processingTime': processingTime,
    },
    dateTime: DateTime.now(),
    isToxic: data['isToxic'] as bool,
    toxicityWarning: data['toxicityWarning'] as String,
    scientificWarning: data['scientificWarning'] as String,
    category: data['category'] as String,
    potentialToxins: List<String>.from(data['potentialToxins']),
    co2PerKg: (data['co2PerKg'] as num).toDouble(),
    sellable: data['sellable'] as String,
  );
}