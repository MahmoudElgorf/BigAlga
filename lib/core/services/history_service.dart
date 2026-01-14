// lib/core/services/history_service.dart
import 'dart:convert';
import 'package:bioalga/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static Future<void> saveAnalysis(Map<String, dynamic> analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getAnalysisHistory();

      history.insert(0, analysis);

      if (history.length > AppConstants.maxHistoryItems) {
        history.removeLast();
      }

      // حفظ في SharedPreferences
      final historyJson = json.encode(history);
      await prefs.setString(AppConstants.historyKey, historyJson);
    } catch (e) {
      print('Error saving analysis: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(AppConstants.historyKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error loading history: $e');
    }

    return [];
  }

  static Future<void> deleteAnalysis(String id) async {
    try {
      final history = await getAnalysisHistory();
      history.removeWhere((item) => item['id'] == id);

      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(history);
      await prefs.setString(AppConstants.historyKey, historyJson);
    } catch (e) {
      print('Error deleting analysis: $e');
    }
  }

  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.historyKey);
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}