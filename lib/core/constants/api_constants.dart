/// API constants and endpoints
import 'package:flutter/material.dart';

class ApiConstants {
  static const String baseUrl = 'https://bioalga-llm.onrender.com';
  static const String emulatorUrl = 'http://10.0.2.2:8000';

  static const String chat = '/chat/';
  static const String chatTypes = '/chat/types';
  static const String chatCompare = '/chat/compare';
  static const String algaeInfo = '/algae/info';
  static const String algaeToxicity = '/algae/toxicity/';
  static const String enhanceResults = '/enhance/results';
  static const String enhanceSummary = '/enhance/summary';
  static const String health = '/health';

  static const String predictEndpoint = '/predictApi';

  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration readTimeout = Duration(seconds: 60);

  static const int maxFileSize = 10 * 1024 * 1024;

  static const String contentType = 'Content-Type';
  static const String applicationJson = 'application/json';
  static const Map<String, String> headers = {
    contentType: applicationJson,
    'Accept': applicationJson,
  };
}

class ApiVisuals {
  static const IconData apiIcon = Icons.cloud;
  static const IconData connectionIcon = Icons.wifi;
  static const IconData successIcon = Icons.cloud_done;
  static const IconData errorIcon = Icons.cloud_off;
  static const IconData analyzingIcon = Icons.cloud_upload;
  static const IconData serverIcon = Icons.dns;
  static const IconData networkIcon = Icons.network_check;

  static const IconData assistantIcon = Icons.assistant;
  static const IconData sendIcon = Icons.send;
  static const IconData micIcon = Icons.mic;
  static const IconData attachIcon = Icons.attach_file;
  static const IconData toxicityIcon = Icons.warning_amber;
  static const IconData healthIcon = Icons.medical_services;
  static const IconData commercialIcon = Icons.shopping_cart;
  static const IconData environmentIcon = Icons.cloud;
  static const IconData scienceIcon = Icons.science;
  static const IconData safetyIcon = Icons.tips_and_updates;
}