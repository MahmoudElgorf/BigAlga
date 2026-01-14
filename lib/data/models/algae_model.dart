import 'dart:convert';

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
    );
  }

  bool get isValid => name != 'Unknown' && confidence > 0.1;
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

const algaeData = {
  'Anabaena': {
    'scientificName': 'Anabaena spp.',
    'isToxic': true,
    'toxicityWarning': 'Can produce neurotoxins',
    'benefits': [
      'Atmospheric nitrogen fixation',
      'Source of biofertilizers',
      'Improves soil fertility'
    ],
    'uses': [
      'Agriculture',
      'Scientific research',
      'Aquatic environments'
    ]
  },
  'Aphanizomenon': {
    'scientificName': 'Aphanizomenon spp.',
    'isToxic': true,
    'toxicityWarning': 'May produce hepatotoxins',
    'benefits': [
      'Nitrogen fixation',
      'Food source for some organisms'
    ],
    'uses': [
      'Scientific research',
      'Aquatic ecology studies'
    ]
  },
  'Gymnodinium': {
    'scientificName': 'Gymnodinium spp.',
    'isToxic': true,
    'toxicityWarning': 'May cause harmful algal blooms',
    'benefits': [
      'Part of marine food chain',
      'Marine ecology studies'
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring'
    ]
  },
  'Karenia': {
    'scientificName': 'Karenia spp.',
    'isToxic': true,
    'toxicityWarning': 'Causes red tide and can be toxic',
    'benefits': [
      'Environmental change studies',
      'Water quality monitoring'
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring'
    ]
  },
  'Microcystis': {
    'scientificName': 'Microcystis spp.',
    'isToxic': true,
    'toxicityWarning': 'Produces dangerous hepatotoxins',
    'benefits': [
      'Water pollution studies',
      'Water quality monitoring'
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring'
    ]
  },
  'Noctiluca': {
    'scientificName': 'Noctiluca scintillans',
    'isToxic': false,
    'toxicityWarning': 'Non-toxic but may cause harmful blooms',
    'benefits': [
      'Bioluminescence in the sea',
      'Part of food chain'
    ],
    'uses': [
      'Scientific research',
      'Ecotourism'
    ]
  },
  'Nodularia': {
    'scientificName': 'Nodularia spp.',
    'isToxic': true,
    'toxicityWarning': 'Produces hepatotoxins',
    'benefits': [
      'Nitrogen fixation',
      'Aquatic ecology studies'
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring'
    ]
  },
  'Nostoc': {
    'scientificName': 'Nostoc spp.',
    'isToxic': false,
    'toxicityWarning': 'Generally safe',
    'benefits': [
      'Nitrogen fixation',
      'Fertilizer source',
      'Soil improvement'
    ],
    'uses': [
      'Agriculture',
      'Gardening',
      'Scientific research'
    ]
  },
  'Oscillatoria': {
    'scientificName': 'Oscillatoria spp.',
    'isToxic': true,
    'toxicityWarning': 'May produce neurotoxins',
    'benefits': [
      'Water pollution studies',
      'Water quality monitoring'
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring'
    ]
  },
  'Prorocentrum': {
    'scientificName': 'Prorocentrum spp.',
    'isToxic': true,
    'toxicityWarning': 'May cause food poisoning',
    'benefits': [
      'Marine ecology studies',
      'Phytoplankton monitoring'
    ],
    'uses': [
      'Scientific research',
      'Environmental monitoring'
    ]
  },
  'Skeletonema': {
    'scientificName': 'Skeletonema spp.',
    'isToxic': false,
    'toxicityWarning': 'Safe',
    'benefits': [
      'Food source for fish',
      'Important part of food chain'
    ],
    'uses': [
      'Aquaculture',
      'Scientific research'
    ]
  },
  'nontoxic': {
    'scientificName': 'Non-toxic Algae',
    'isToxic': false,
    'toxicityWarning': 'Environmentally safe',
    'benefits': [
      'Maintains ecological balance',
      'Oxygen production',
      'Food source for organisms'
    ],
    'uses': [
      'Hydroponics',
      'Scientific research',
      'Aquaculture'
    ]
  }
};