/// Algae API service for chat, info, toxicity and analysis

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bioalga/core/constants/constants.dart';

class AlgaeApiService {
  final http.Client _client = http.Client();

  Map<String, String> get _headers => {
    ApiConstants.contentType: ApiConstants.applicationJson,
    'Accept': 'application/json',
  };

  /// Check if API server is healthy and reachable
  Future<bool> healthCheck() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.health}');

    try {
      print('HEALTH URL: $url');

      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.readTimeout);

      print('HEALTH STATUS: ${response.statusCode}');
      print('HEALTH RESPONSE: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('HEALTH ERROR: $e');
      return false;
    }
  }

  /// Send a chat message with algae context to the AI assistant
  Future<Map<String, dynamic>> chat({
    required String algaeType,
    required String userQuestion,
    Map<String, dynamic>? classificationResult,
    List<Map<String, String>>? conversationHistory,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chat}');

    final body = json.encode({
      'algae_type': algaeType,
      'user_question': userQuestion,
      'classification_result': classificationResult,
      'conversation_history': conversationHistory ?? [],
    });

    try {
      print('================ CHAT REQUEST ================');
      print('CHAT URL: $url');
      print('CHAT BODY: $body');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      print('================ CHAT RESPONSE ================');
      print('CHAT STATUS: ${response.statusCode}');
      print('CHAT BODY RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'Chat failed: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('================ CHAT ERROR ================');
      print('CHAT ERROR: $e');
      rethrow;
    }
  }

  /// Fetch all available algae types from the API
  Future<List<String>> getAlgaeTypes() async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatTypes}');

    try {
      print('TYPES URL: $url');

      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.readTimeout);

      print('TYPES STATUS: ${response.statusCode}');
      print('TYPES RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['types'] ?? []);
      }

      return [];
    } catch (e) {
      print('TYPES ERROR: $e');
      return [];
    }
  }

  /// Get detailed information about a specific algae type
  Future<Map<String, dynamic>> getAlgaeInfo({
    required String algaeType,
    bool includeSources = true,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.algaeInfo}');

    final body = json.encode({
      'algae_type': algaeType,
      'include_sources': includeSources,
    });

    try {
      print('INFO URL: $url');
      print('INFO BODY: $body');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      print('INFO STATUS: ${response.statusCode}');
      print('INFO RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'Get algae info failed: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('INFO ERROR: $e');
      rethrow;
    }
  }

  /// Get toxicity level and safety information for a specific algae
  Future<Map<String, dynamic>> getToxicityLevel(String algaeType) async {
    final encodedType = Uri.encodeComponent(algaeType);

    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.algaeToxicity}$encodedType',
    );

    try {
      print('TOXICITY URL: $url');

      final response = await _client
          .get(url, headers: _headers)
          .timeout(ApiConstants.readTimeout);

      print('TOXICITY STATUS: ${response.statusCode}');
      print('TOXICITY RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'Get toxicity failed: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('TOXICITY ERROR: $e');
      rethrow;
    }
  }

  /// Enhance classification results with additional AI analysis
  Future<Map<String, dynamic>> enhanceResults({
    required String algaeType,
    required Map<String, dynamic> currentResult,
    String? customNotes,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.enhanceResults}',
    );

    final body = json.encode({
      'algae_type': algaeType,
      'current_result': currentResult,
      'custom_notes': customNotes,
    });

    try {
      print('ENHANCE URL: $url');
      print('ENHANCE BODY: $body');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      print('ENHANCE STATUS: ${response.statusCode}');
      print('ENHANCE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'Enhance results failed: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('ENHANCE ERROR: $e');
      rethrow;
    }
  }

  /// Generate a concise summary of the analysis results
  Future<String> generateSummary({
    required String algaeType,
    required Map<String, dynamic> currentResult,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.enhanceSummary}',
    );

    final body = json.encode({
      'algae_type': algaeType,
      'current_result': currentResult,
    });

    try {
      print('SUMMARY URL: $url');
      print('SUMMARY BODY: $body');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      print('SUMMARY STATUS: ${response.statusCode}');
      print('SUMMARY RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'] ?? '';
      }

      throw Exception(
        'Generate summary failed: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('SUMMARY ERROR: $e');
      return 'Unable to generate summary';
    }
  }

  /// Compare multiple algae types and get differences/similarities
  Future<Map<String, dynamic>> compareAlgaeTypes(List<String> algaeTypes) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chatCompare}');

    final body = json.encode(algaeTypes);

    try {
      print('COMPARE URL: $url');
      print('COMPARE BODY: $body');

      final response = await _client
          .post(
        url,
        headers: _headers,
        body: body,
      )
          .timeout(ApiConstants.readTimeout);

      print('COMPARE STATUS: ${response.statusCode}');
      print('COMPARE RESPONSE: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }

      throw Exception(
        'Compare failed: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('COMPARE ERROR: $e');
      rethrow;
    }
  }

  /// Close the HTTP client and release resources
  void dispose() {
    _client.close();
  }
}