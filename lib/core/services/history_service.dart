// lib/core/services/history_service.dart
import 'dart:convert';
import 'package:bioalga/core/constants/constants.dart';
import 'package:intl/intl.dart';
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

  // في history_service.dart أضف:

  static const String _chatHistoryKey = 'chat_history';

  static Future<void> saveChatConversation({
    required String algaeType,
    required Map<String, dynamic>? classificationResult,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistory = await getChatHistory();

      final newChat = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'algaeType': algaeType,
        'classificationResult': classificationResult,
        'messages': messages,
        'messageCount': messages.length,
        'lastMessage': messages.last['text'],
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'time': DateFormat('HH:mm').format(DateTime.now()),
      };

      chatHistory.insert(0, newChat);

      // Keep only last 50 chats
      if (chatHistory.length > 50) {
        chatHistory.removeRange(50, chatHistory.length);
      }

      await prefs.setString(_chatHistoryKey, json.encode(chatHistory));
    } catch (e) {
      print('Error saving chat: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_chatHistoryKey);
      if (data != null) {
        return List<Map<String, dynamic>>.from(json.decode(data));
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
    return [];
  }

  static Future<void> deleteChat(String id) async {
    try {
      final chats = await getChatHistory();
      chats.removeWhere((chat) => chat['id'] == id);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chatHistoryKey, json.encode(chats));
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  static Future<void> clearAllChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
    } catch (e) {
      print('Error clearing chat history: $e');
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