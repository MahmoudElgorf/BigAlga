/// History service for managing analysis history using SharedPreferences
import 'dart:convert';
import 'package:bioalga/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _analysisHistoryKey = 'analysis_history';

  /// Save a new analysis to history
  static Future<void> saveAnalysis(Map<String, dynamic> analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = await getAnalysisHistory();

      history.insert(0, analysis);

      if (history.length > AppConstants.maxHistoryItems) {
        history.removeLast();
      }

      final historyJson = json.encode(history);
      await prefs.setString(_analysisHistoryKey, historyJson);
    } catch (e) {}
  }

  /// Get all analysis history
  static Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_analysisHistoryKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {}
    return [];
  }

  /// Delete a specific analysis by ID
  static Future<void> deleteAnalysis(String id) async {
    try {
      final history = await getAnalysisHistory();
      history.removeWhere((item) => item['id'] == id);

      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(history);
      await prefs.setString(_analysisHistoryKey, historyJson);
    } catch (e) {}
  }

  /// Clear all analysis history
  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_analysisHistoryKey);
    } catch (e) {}
  }

  /// Generate a unique ID based on timestamp
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get total number of analyses stored
  static Future<int> getTotalAnalysesCount() async {
    final history = await getAnalysisHistory();
    return history.length;
  }

  /// Clear all data from SharedPreferences
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_analysisHistoryKey);
    } catch (e) {}
  }
}