import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bioalga/core/constants/constants.dart';
class AlgaeApiService {
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    ApiConstants.contentType: ApiConstants.applicationJson,
  };

  Future<bool> healthCheck() async {
    try {
      final response = await _client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.health}'),
      )
          .timeout(ApiConstants.readTimeout);

      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> chat({
    required String algaeType,
    required String userQuestion,
    Map<String, dynamic>? classificationResult,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final body = json.encode({
        'algae_type': algaeType,
        'user_question': userQuestion,
        'classification_result': classificationResult,
        'conversation_history': conversationHistory,
      });

      final response = await _client
          .post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chat}'),
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Chat failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Chat error: $e');
      rethrow;
    }
  }

  Future<List<String>> getAlgaeTypes() async {
    try {
      final response = await _client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatTypes}'),
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['types']);
      } else {
        return [];
      }
    } catch (e) {
      print('Get algae types error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getAlgaeInfo({
    required String algaeType,
    bool includeSources = true,
  }) async {
    try {
      final body = json.encode({
        'algae_type': algaeType,
        'include_sources': includeSources,
      });

      final response = await _client
          .post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.algaeInfo}'),
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Get algae info failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Get algae info error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getToxicityLevel(String algaeType) async {
    try {
      final response = await _client
          .get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.algaeToxicity}$algaeType'),
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Get toxicity failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Get toxicity error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> enhanceResults({
    required String algaeType,
    required Map<String, dynamic> currentResult,
    String? customNotes,
  }) async {
    try {
      final body = json.encode({
        'algae_type': algaeType,
        'current_result': currentResult,
        'custom_notes': customNotes,
      });

      final response = await _client
          .post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.enhanceResults}'),
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Enhance results failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Enhance results error: $e');
      rethrow;
    }
  }

  Future<String> generateSummary({
    required String algaeType,
    required Map<String, dynamic> currentResult,
  }) async {
    try {
      final body = json.encode({
        'algae_type': algaeType,
        'current_result': currentResult,
      });

      final response = await _client
          .post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.enhanceSummary}'),
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'] ?? '';
      } else {
        throw Exception('Generate summary failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Generate summary error: $e');
      return 'Unable to generate summary';
    }
  }

  Future<Map<String, dynamic>> compareAlgaeTypes(List<String> algaeTypes) async {
    try {
      final response = await _client
          .post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatCompare}'),
        headers: _headers,
        body: json.encode(algaeTypes),
      )
          .timeout(ApiConstants.readTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Compare failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Compare error: $e');
      rethrow;
    }
  }

  void dispose() {
    _client.close();
  }
}