/// ML service for algae image classification using remote API

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:http/http.dart' as http;

class MLService {
  MLService._internal();

  static final MLService instance = MLService._internal();

  factory MLService() => instance;

  static const String _baseUrl =
      'https://algea-image-classififcation.onrender.com';

  static const String _predictEndpoint = '/predict';

  final http.Client _client = http.Client();

  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  AlgaeResult? _cachedResult;
  String? _cachedImagePath;

  Future<void> initModel() {
    if (_isInitialized) {
      return Future.value();
    }

    _initializationFuture ??= _initialize();

    return _initializationFuture!;
  }

  Future<void> _initialize() async {
    try {
      final isHealthy = await testConnection();

      if (!isHealthy) {
        throw Exception(ErrorStrings.failedToConnectToApi);
      }

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      _initializationFuture = null;
      throw Exception('${ErrorStrings.apiConnectionError}: $e');
    }
  }

  Future<AlgaeResult> classifyImage(File imageFile) async {
    final imagePath = imageFile.path;

    if (_cachedResult != null && _cachedImagePath == imagePath) {
      return _cachedResult!;
    }

    await initModel();

    try {
      final startTime = DateTime.now();

      final uri = Uri.parse('$_baseUrl$_predictEndpoint');

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
      );

      final response = await http.Response.fromStream(streamedResponse);

      final processingTime =
          DateTime.now().difference(startTime).inMilliseconds;

      if (response.statusCode != 200) {
        throw Exception(
          '${ErrorStrings.apiRequestFailed}: ${response.statusCode}',
        );
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData.containsKey('error')) {
        throw Exception(responseData['error']);
      }

      final String algaeName =
          responseData['predicted_class'] ?? AppStrings.unknown;

      final double confidence =
          ((responseData['confidence'] ?? 0) as num).toDouble() / 100;

      final algaeInfo = _safeGetAlgaeData(algaeName);

      final List<Map<String, dynamic>> allPredictions =
      _buildPredictions(responseData, algaeName, confidence, algaeInfo);

      final result = AlgaeResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: algaeName,
        scientificName: algaeInfo['scientificName'],
        confidence: confidence,
        confidenceLevel: _confidenceLevel(confidence),
        benefits: algaeInfo['benefits'],
        uses: algaeInfo['uses'],
        allPredictions: allPredictions,
        modelInfo: {
          'processingTime': processingTime,
          'apiUsed': true,
          'endpoint': _predictEndpoint,
        },
        dateTime: DateTime.now(),
        isToxic: algaeInfo['isToxic'],
        toxicityWarning: algaeInfo['toxicityWarning'],
        scientificWarning: algaeInfo['scientificWarning'],
        category: algaeInfo['category'],
        potentialToxins: algaeInfo['potentialToxins'],
        co2PerKg: algaeInfo['co2PerKg'],
        sellable: algaeInfo['sellable'],
      );

      _cachedResult = result;
      _cachedImagePath = imagePath;

      return result;
    } on TimeoutException {
      throw Exception(ErrorStrings.unableToConnectToAnalysisServer);
    } catch (e) {
      rethrow;
    }
  }

  List<Map<String, dynamic>> _buildPredictions(
      Map<String, dynamic> responseData,
      String algaeName,
      double confidence,
      Map<String, dynamic> algaeInfo,
      ) {
    final List<Map<String, dynamic>> predictions = [];

    if (responseData['top5'] is List) {
      for (final item in responseData['top5']) {
        final String className = item['class'] ?? AppStrings.unknown;

        final double classConfidence =
            ((item['confidence'] ?? 0) as num).toDouble() / 100;

        final classInfo = _safeGetAlgaeData(className);

        predictions.add({
          'label': className,
          'confidence': classConfidence,
          'isToxic': classInfo['isToxic'],
        });
      }
    }

    if (predictions.isEmpty) {
      predictions.add({
        'label': algaeName,
        'confidence': confidence,
        'isToxic': algaeInfo['isToxic'],
      });
    }

    return predictions;
  }

  Future<AlgaeResult> classifyImageWithFallback(File imageFile) async {
    try {
      return await classifyImage(imageFile);
    } catch (_) {
      return _getFallbackResult();
    }
  }

  AlgaeResult _getFallbackResult() {
    return AlgaeResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: AppStrings.unknown,
      scientificName: AppStrings.unknownSpecies,
      confidence: 0.0,
      confidenceLevel: AppStrings.notAvailable,
      benefits: [ErrorStrings.unableToConnectToAnalysisServer],
      uses: [ErrorStrings.pleaseCheckInternet],
      allPredictions: [],
      modelInfo: {'error': ErrorStrings.apiConnectionFailed},
      dateTime: DateTime.now(),
      isToxic: false,
      toxicityWarning: ErrorStrings.analysisUnavailable,
      scientificWarning: ErrorStrings.pleaseCheckInternet,
      category: AppStrings.unknown,
      potentialToxins: [],
      co2PerKg: 0.0,
      sellable: AppStrings.unknownRequiresAnalysis,
    );
  }

  Map<String, dynamic> _safeGetAlgaeData(String name) {
    try {
      final data = getAlgaeData(name);

      return {
        'scientificName':
        data['scientificName'] as String? ?? AppStrings.unknownSpecies,
        'benefits': (data['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
        'uses': (data['uses'] as List<dynamic>?)?.cast<String>() ?? [],
        'isToxic': data['isToxic'] as bool? ?? false,
        'toxicityWarning': data['toxicityWarning'] as String? ??
            ErrorStrings.noToxicityInfoAvailable,
        'scientificWarning': data['scientificWarning'] as String? ??
            ErrorStrings.noScientificInfoAvailable,
        'category': data['category'] as String? ?? AppStrings.unknown,
        'potentialToxins':
        (data['potentialToxins'] as List<dynamic>?)?.cast<String>() ?? [],
        'co2PerKg': (data['co2PerKg'] as num?)?.toDouble() ?? 0.0,
        'sellable': data['sellable'] as String? ?? AppStrings.unknown,
      };
    } catch (_) {
      return {
        'scientificName': AppStrings.unknownSpecies,
        'benefits': [],
        'uses': [],
        'isToxic': false,
        'toxicityWarning': AppStrings.informationNotAvailable,
        'scientificWarning': AppStrings.informationNotAvailable,
        'category': AppStrings.unknown,
        'potentialToxins': [],
        'co2PerKg': 0.0,
        'sellable': AppStrings.unknown,
      };
    }
  }

  String _confidenceLevel(double confidence) {
    if (confidence >= 0.9) return AppStrings.veryHigh;
    if (confidence >= 0.7) return AppStrings.highConfidence;
    if (confidence >= 0.5) return AppStrings.medium;
    if (confidence >= 0.3) return AppStrings.lowConfidence;
    return AppStrings.veryLow;
  }

  Future<bool> testConnection() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void clearCache() {
    _cachedResult = null;
    _cachedImagePath = null;
  }

  void dispose() {
    clearCache();
    _isInitialized = false;
    _initializationFuture = null;
    _client.close();
  }
}