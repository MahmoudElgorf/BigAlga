// lib/core/services/ml_service.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import '../../data/models/algae_model.dart';

class MLService {
  // ================= SINGLETON =================
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  bool _isInitialized = false;
  static const String _baseUrl = 'https://algea-image-classififcation.onrender.com';
  static const String _predictEndpoint = '/predictApi';

  // ================= INITIALIZE =================
  Future<void> initModel() async {
    if (_isInitialized) return;

    try {
      final response = await http.get(Uri.parse('$_baseUrl/'));
      if (response.statusCode == 200) {
        _isInitialized = true;
        print('API connected successfully');
      } else {
        throw Exception('Failed to connect to API');
      }
    } catch (e) {
      throw Exception('API connection error: $e');
    }
  }

  // ================= CLASSIFY =================
  Future<AlgaeResult> classifyImage(File imageFile) async {
    if (!_isInitialized) {
      await initModel();
    }

    try {
      final startTime = DateTime.now();

      // Create multipart request
      final uri = Uri.parse('$_baseUrl$_predictEndpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add image file
      final stream = http.ByteStream(imageFile.openRead());
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'fileup',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final processingTime = DateTime.now().difference(startTime).inMilliseconds;

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        if (responseData.containsKey('error')) {
          throw Exception(responseData['error']);
        }

        // Parse API response
        final predictionResponse = PredictionResponse.fromJson(responseData);

        // Get algae data with full scientific information
        final algaeName = predictionResponse.prediction;
        final algaeInfo = getAlgaeData(algaeName);

        // Prepare all predictions (for future multi-label support)
        final allPredictions = [
          {
            'label': algaeName,
            'confidence': predictionResponse.confidence,
            'isToxic': algaeInfo['isToxic'],
          }
        ];

        // Build AlgaeResult with ALL fields
        return AlgaeResult(
          name: algaeName,
          scientificName: algaeInfo['scientificName'] as String,
          confidence: predictionResponse.confidence,
          confidenceLevel: _confidenceLevel(predictionResponse.confidence),
          benefits: (algaeInfo['benefits'] as List<dynamic>).cast<String>().toList(),
          uses: (algaeInfo['uses'] as List<dynamic>).cast<String>().toList(),
          allPredictions: allPredictions,
          modelInfo: {
            'processingTime': processingTime,
            'apiUsed': true,
            'endpoint': _predictEndpoint,
          },
          dateTime: DateTime.now(),
          isToxic: algaeInfo['isToxic'] as bool,
          toxicityWarning: algaeInfo['toxicityWarning'] as String,
          // NEW FIELDS:
          scientificWarning: algaeInfo['scientificWarning'] as String,
          category: algaeInfo['category'] as String,
          potentialToxins: (algaeInfo['potentialToxins'] as List<dynamic>).cast<String>().toList(),
          co2PerKg: (algaeInfo['co2PerKg'] as num).toDouble(),
          sellable: algaeInfo['sellable'] as String,
          arabicName: algaeInfo['arabicName'] as String,
        );
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error classifying image: $e');
      rethrow;
    }
  }

  // ================= CLASSIFY WITH FALLBACK =================
  // استخدام البيانات المحلية في حالة فشل الاتصال بالـ API
  Future<AlgaeResult> classifyImageWithFallback(File imageFile) async {
    try {
      return await classifyImage(imageFile);
    } catch (e) {
      print('API failed, using fallback: $e');
      // في حالة فشل الـ API، نرجع نتيجة افتراضية
      return _getFallbackResult();
    }
  }

  AlgaeResult _getFallbackResult() {
    return AlgaeResult(
      name: 'Unknown',
      scientificName: 'Unknown spp.',
      confidence: 0.0,
      confidenceLevel: 'Not Available',
      benefits: ['Unable to connect to analysis server'],
      uses: ['Please check your internet connection and try again'],
      allPredictions: [],
      modelInfo: {'error': 'API connection failed'},
      dateTime: DateTime.now(),
      isToxic: false,
      toxicityWarning: 'Analysis unavailable',
      scientificWarning: 'Could not connect to the classification server. Please check your internet connection.',
      category: 'Unknown',
      potentialToxins: [],
      co2PerKg: 0.0,
      sellable: 'Unknown - requires analysis',
      arabicName: 'غير معروف',
    );
  }

  // ================= HELPERS =================
  String _confidenceLevel(double c) {
    if (c >= 0.9) return 'Very High';
    if (c >= 0.7) return 'High';
    if (c >= 0.5) return 'Medium';
    return 'Low';
  }

  // ================= DISPOSE =================
  void dispose() {
    _isInitialized = false;
  }

  // ================= TEST CONNECTION =================
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