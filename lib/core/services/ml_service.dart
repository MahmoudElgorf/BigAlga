/// ML service for algae image classification using remote API
import 'dart:io';
import 'dart:convert';
import 'package:bioalga/data/data.dart';
import 'package:http/http.dart' as http;
import 'package:bioalga/core/constants/constants.dart';
import '../../data/models/algae_model.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;
  static const String _baseUrl = 'https://algea-image-classififcation.onrender.com';
  static const String _predictEndpoint = '/predict';

   AlgaeResult? _cachedResult;
  String? _cachedImagePath;

  /// Initialize the ML service and check API connection
  Future<void> initModel() async {
    if (_isInitialized) return;
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _isInitializing = true;

    try {
      final response = await http.get(Uri.parse('$_baseUrl/'));
      if (response.statusCode == 200) {
        _isInitialized = true;
      } else {
        throw Exception(ErrorStrings.failedToConnectToApi);
      }
    } catch (e) {
      throw Exception('${ErrorStrings.apiConnectionError}: $e');
    } finally {
      _isInitializing = false;
    }
  }

  /// Classify an algae image using the remote API
  Future<AlgaeResult> classifyImage(File imageFile) async {
    final imagePath = imageFile.path;
    if (_cachedResult != null && _cachedImagePath == imagePath) {
      return _cachedResult!;
    }

    if (!_isInitialized) {
      await initModel();
    }

    try {
      final startTime = DateTime.now();

      final uri = Uri.parse('$_baseUrl$_predictEndpoint');
      final request = http.MultipartRequest('POST', uri);

      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('error')) {
          throw Exception(responseData['error']);
        }

        final String algaeName = responseData['predicted_class'] ?? AppStrings.unknown;
        final double confidence = (responseData['confidence'] ?? 0) / 100;

        final algaeInfo = _safeGetAlgaeData(algaeName);

        final List<Map<String, dynamic>> allPredictions = [];

        if (responseData.containsKey('top5') && responseData['top5'] is List) {
          for (var item in responseData['top5']) {
            final String className = item['class'] ?? AppStrings.unknown;
            final double classConfidence = (item['confidence'] ?? 0) / 100;
            final classInfo = _safeGetAlgaeData(className);

            allPredictions.add({
              'label': className,
              'confidence': classConfidence,
              'isToxic': classInfo['isToxic'],
            });
          }
        } else {
          allPredictions.add({
            'label': algaeName,
            'confidence': confidence,
            'isToxic': algaeInfo['isToxic'],
          });
        }

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
      } else {
        throw Exception('${ErrorStrings.apiRequestFailed}: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Classify image with fallback result if API fails
  Future<AlgaeResult> classifyImageWithFallback(File imageFile) async {
    try {
      return await classifyImage(imageFile);
    } catch (e) {
      return _getFallbackResult();
    }
  }

  /// Return a fallback result when API is unavailable
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

  /// Safely get algae data with fallback for missing values
  Map<String, dynamic> _safeGetAlgaeData(String name) {
    try {
      final data = getAlgaeData(name);
      return {
        'scientificName': data['scientificName'] as String? ?? AppStrings.unknownSpecies,
        'benefits': (data['benefits'] as List<dynamic>?)?.cast<String>() ?? [],
        'uses': (data['uses'] as List<dynamic>?)?.cast<String>() ?? [],
        'isToxic': data['isToxic'] as bool? ?? false,
        'toxicityWarning': data['toxicityWarning'] as String? ?? ErrorStrings.noToxicityInfoAvailable,
        'scientificWarning': data['scientificWarning'] as String? ?? ErrorStrings.noScientificInfoAvailable,
        'category': data['category'] as String? ?? AppStrings.unknown,
        'potentialToxins': (data['potentialToxins'] as List<dynamic>?)?.cast<String>() ?? [],
        'co2PerKg': (data['co2PerKg'] as num?)?.toDouble() ?? 0.0,
        'sellable': data['sellable'] as String? ?? AppStrings.unknown,
      };
    } catch (e) {
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

  /// Get confidence level string based on confidence value
  String _confidenceLevel(double c) {
    if (c >= 0.9) return AppStrings.veryHigh;
    if (c >= 0.7) return AppStrings.highConfidence;
    if (c >= 0.5) return AppStrings.medium;
    if (c >= 0.3) return AppStrings.lowConfidence;
    return AppStrings.veryLow;
  }

  /// Dispose and reset initialization state
  void dispose() {
    _isInitialized = false;
    _isInitializing = false;
    _cachedResult = null;
    _cachedImagePath = null;
  }

  /// Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}