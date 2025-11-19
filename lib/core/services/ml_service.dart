import 'dart:io';
import '../constants/constants.dart';

class MLService {
  static Future<Map<String, dynamic>?> classifyImage(File image) async {
    // محاكاة وقت المعالجة
    await Future.delayed(Duration(seconds: 2));

    // بيانات وهمية للاختبار
    return {
      'topPrediction': {
        'label': 'Spirulina',
        'confidence': 0.92,
      },
      'allPredictions': [
        {'label': 'Spirulina', 'confidence': 0.92},
        {'label': 'Chlorella', 'confidence': 0.05},
        {'label': 'Nori', 'confidence': 0.02},
        {'label': 'Kelp', 'confidence': 0.01},
      ],
      'isConfident': true,
    };
  }

  static void dispose() {
  }
}