// lib/core/services/history_service.dart
import 'dart:convert';
import 'package:bioalga/core/constants/constants.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  // Keys for SharedPreferences
  static const String _analysisHistoryKey = 'analysis_history';
  static const String _chatHistoryKey = 'chat_history';

  // ==================== ANALYSIS HISTORY ====================

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
    } catch (e) {
      print('Error saving analysis: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getAnalysisHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_analysisHistoryKey);

      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        return historyList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error loading analysis history: $e');
    }
    return [];
  }

  static Future<void> deleteAnalysis(String id) async {
    try {
      final history = await getAnalysisHistory();
      history.removeWhere((item) => item['id'] == id);

      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(history);
      await prefs.setString(_analysisHistoryKey, historyJson);
    } catch (e) {
      print('Error deleting analysis: $e');
    }
  }

  static Future<void> clearAllHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_analysisHistoryKey);
    } catch (e) {
      print('Error clearing analysis history: $e');
    }
  }

  // ==================== CHAT HISTORY ====================

  static Future<void> saveChatConversation({
    required String algaeType,
    required Map<String, dynamic>? classificationResult,
    required List<Map<String, dynamic>> messages,
    String? analysisId,  // المعرف الفريد للتحليل المرتبط بهذا الشات
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistory = await getChatHistory();

      // Serialize messages properly
      final serializedMessages = messages.map((msg) {
        return {
          'text': msg['text']?.toString() ?? '',
          'isUser': msg['isUser'] == true,
          'timestamp': msg['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
          'recommendations': msg['recommendations'] is List
              ? List<String>.from(msg['recommendations'])
              : [],
          'isError': msg['isError'] == true,
        };
      }).toList();

      final chatId = analysisId ?? '${algaeType}_${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();

      final newChat = {
        'id': chatId,
        'algaeType': algaeType,
        'classificationResult': classificationResult,
        'messages': serializedMessages,
        'messageCount': serializedMessages.length,
        'lastMessage': serializedMessages.isNotEmpty
            ? (serializedMessages.last['text'] ?? 'No messages')
            : 'No messages',
        'date': DateFormat('yyyy-MM-dd').format(now),
        'time': DateFormat('HH:mm').format(now),
        'timestamp': now.millisecondsSinceEpoch,
      };

      // Remove existing chat with same ID (for update)
      chatHistory.removeWhere((chat) => chat['id'] == chatId);

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
        List<dynamic> decoded = json.decode(data);
        return decoded.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Error loading chat history: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>?> getChatByAnalysisId(String analysisId) async {
    try {
      final chats = await getChatHistory();
      return chats.firstWhere(
            (chat) => chat['id'] == analysisId,
        orElse: () => {},
      );
    } catch (e) {
      print('Error getting chat by analysis ID: $e');
      return null;
    }
  }

  static Future<void> updateChat(String chatId, List<Map<String, dynamic>> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistory = await getChatHistory();

      final index = chatHistory.indexWhere((chat) => chat['id'] == chatId);

      if (index != -1) {
        final serializedMessages = messages.map((msg) {
          return {
            'text': msg['text']?.toString() ?? '',
            'isUser': msg['isUser'] == true,
            'timestamp': msg['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
            'recommendations': msg['recommendations'] is List
                ? List<String>.from(msg['recommendations'])
                : [],
            'isError': msg['isError'] == true,
          };
        }).toList();

        chatHistory[index] = {
          ...chatHistory[index],
          'messages': serializedMessages,
          'messageCount': serializedMessages.length,
          'lastMessage': serializedMessages.isNotEmpty
              ? (serializedMessages.last['text'] ?? 'No messages')
              : 'No messages',
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        };

        // Move to top
        final updatedChat = chatHistory.removeAt(index);
        chatHistory.insert(0, updatedChat);

        await prefs.setString(_chatHistoryKey, json.encode(chatHistory));
      }
    } catch (e) {
      print('Error updating chat: $e');
    }
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

  static Future<void> deleteChatByAnalysisId(String analysisId) async {
    try {
      final chats = await getChatHistory();
      chats.removeWhere((chat) => chat['id'] == analysisId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chatHistoryKey, json.encode(chats));
    } catch (e) {
      print('Error deleting chat by analysis ID: $e');
    }
  }

  // ==================== UTILITIES ====================

  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_analysisHistoryKey);
      await prefs.remove(_chatHistoryKey);
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  static Future<int> getTotalAnalysesCount() async {
    final history = await getAnalysisHistory();
    return history.length;
  }

  static Future<int> getTotalChatsCount() async {
    final chats = await getChatHistory();
    return chats.length;
  }
}