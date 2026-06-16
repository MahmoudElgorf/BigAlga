/// Algae result factory
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:bioalga/data/models/algae_database.dart';

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
        ? AppStrings.confidenceHigh
        : confidence > 0.6
        ? AppStrings.confidenceMedium
        : AppStrings.confidenceLow,
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
  );
}