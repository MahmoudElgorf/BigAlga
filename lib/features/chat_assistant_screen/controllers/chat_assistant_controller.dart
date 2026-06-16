/// Chat assistant controller for managing state and API calls
import 'package:bioalga/features/chat_assistant_screen/widgets/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:bioalga/core/services/api_service.dart';
import 'package:bioalga/core/constants/constants.dart';

class ChatAssistantController extends ChangeNotifier {
  final String algaeType;
  final Map<String, dynamic>? classificationResult;
  final List<Map<String, dynamic>>? initialMessages;

  List<ChatMessage> messages = [];
  bool isLoading = false;
  final ScrollController scrollController = ScrollController();
  final GlobalKey suggestionsButtonKey = GlobalKey();

  final List<String> suggestedQuestions = [
    AppStrings.questionToxicity,
    AppStrings.questionHealthEffects,
    AppStrings.questionCommercial,
    AppStrings.questionEnvironmental,
    AppStrings.questionClassification,
    AppStrings.questionSafety,
  ];

  ChatAssistantController({
    required this.algaeType,
    this.classificationResult,
    this.initialMessages,
  }) {
    _initMessages();
  }

  void _initMessages() {
    if (initialMessages != null && initialMessages!.isNotEmpty) {
      for (var msg in initialMessages!) {
        messages.add(ChatMessage(
          text: msg['text'],
          isUser: msg['isUser'],
          timestamp: DateTime.parse(msg['timestamp']),
          recommendations: List<String>.from(msg['recommendations'] ?? []),
          isError: msg['isError'] ?? false,
        ));
      }
    } else {
      _addWelcomeMessage();
    }
  }

  void _addWelcomeMessage() {
    messages.add(ChatMessage(
      text: '${AppStrings.chatWelcome} $algaeType ${AppStrings.chatWelcomeSuffix}',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage({String? question}) async {
    final messageText = question ?? '';
    if (messageText.isEmpty) return;

    messages.add(ChatMessage(
      text: messageText,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    isLoading = true;
    notifyListeners();
    scrollToBottom();

    try {
      final response = await ApiService.algae.chat(
        algaeType: algaeType,
        userQuestion: messageText,
        classificationResult: classificationResult,
        conversationHistory: _buildConversationHistory(),
      );

      messages.add(ChatMessage(
        text: response['response'],
        isUser: false,
        timestamp: DateTime.now(),
        recommendations: response['recommendations'] != null
            ? List<String>.from(response['recommendations'])
            : [],
      ));
      isLoading = false;
      notifyListeners();
      scrollToBottom();
    } catch (e) {
      messages.add(ChatMessage(
        text: AppStrings.chatError,
        isUser: false,
        timestamp: DateTime.now(),
        isError: true,
      ));
      isLoading = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  List<Map<String, String>> _buildConversationHistory() {
    return messages.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      };
    }).toList();
  }

  void removeOverlay() {
    // Will be handled by the overlay widget
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}