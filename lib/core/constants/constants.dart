import 'package:flutter/material.dart';

class AppColors {
  static const Color deepBlue = Color(0xFF006994);
  static const Color oceanBlue = Color(0xFF0081A7);
  static const Color seaGreen = Color(0xFF00AFB9);
  static const Color aqua = Color(0xFF00C9B1);
  static const Color foam = Color(0xFFFDFCDC);
  static const Color sand = Color(0xFFFED9B7);
  static const Color coral = Color(0xFFF07167);

  static const Color primary = deepBlue;
  static const Color secondary = seaGreen;
  static const Color accentGreen = aqua;
  static const Color background = foam;
  static const Color white = Colors.white;
  static const Color darkText = Color(0xFF2D3748);
  static const Color greyText = Color(0xFF718096);
}

class AppSizes {
  static const double headerHeight = 280;
  static const double buttonHeight = 60;
}
class AppConstants {
  static const String historyKey = 'analysis_history';
  static const int maxHistoryItems = 50;
}

class AppText {
  static const String appSlogan = 'Discover the World of Marine Algae';
  static const String fromGallery = 'Choose Image from Gallery';
  static const String poweredBy = 'BioAlga © 2026';
  static const String analyzing = 'Analyzing Image...';
  static const String results = 'Analysis Results';
}

class ModelConstants {
  static const String modelPath = 'assets/models/algae_model.tflite';
  static const String labelsPath = 'assets/models/labels.txt';
  static const int inputSize = 224;
  static const double confidenceThreshold = 0.7;
}