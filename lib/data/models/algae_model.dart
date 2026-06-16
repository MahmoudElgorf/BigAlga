/// Algae data models
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bioalga/core/constants/constants.dart';

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
      name: AppStrings.unknown,
      scientificName: AppStrings.unknownSpp,
      confidence: 0.0,
      confidenceLevel: AppStrings.notAvailable,
      benefits: [],
      uses: [],
      allPredictions: [],
      modelInfo: {},
      dateTime: DateTime.now(),
      isToxic: false,
      toxicityWarning: AppStrings.notSpecified,
      scientificWarning: AppStrings.unableToIdentify,
      category: AppStrings.unknown,
      potentialToxins: [],
      co2PerKg: 0.0,
      sellable: AppStrings.unknown,
    );
  }

  bool get isValid => name != AppStrings.unknown && confidence > 0.1;

  Color get toxicityColor {
    if (!isToxic) return Colors.green;
    if (name == 'Microcystis' || name == 'Karenia') return Colors.red;
    return Colors.orange;
  }
}

class PredictionResponse {
  final String predictedClass;
  final double confidence;
  final List<Map<String, dynamic>> top5;

  PredictionResponse({
    required this.predictedClass,
    required this.confidence,
    this.top5 = const [],
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> top5List = [];
    if (json.containsKey('top5') && json['top5'] is List) {
      top5List = (json['top5'] as List).map((item) {
        return {
          'class': item['class'] as String,
          'confidence': (item['confidence'] as num).toDouble(),
        };
      }).toList();
    }
    return PredictionResponse(
      predictedClass: json['predicted_class'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      top5: top5List,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predicted_class': predictedClass,
      'confidence': confidence,
      'top5': top5,
    };
  }

  String toJsonString() => json.encode(toJson());
}

class ApiResponse {
  final bool success;
  final String? error;
  final PredictionResponse? data;

  ApiResponse({required this.success, this.error, this.data});

  factory ApiResponse.success(PredictionResponse data) =>
      ApiResponse(success: true, data: data);

  factory ApiResponse.error(String error) =>
      ApiResponse(success: false, error: error);
}