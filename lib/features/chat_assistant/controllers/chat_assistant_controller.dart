/// Chat assistant controller with optimized dynamic questions

import 'dart:async';

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/core/services/api_service.dart';
import 'package:bioalga/features/chat_assistant/widgets/chat_message.dart';
import 'package:bioalga/features/chat_assistant/widgets/comparison_selection_sheet.dart';
import 'package:flutter/material.dart';

class ChatAssistantController extends ChangeNotifier {
  final String algaeType;
  final Map<String, dynamic>? classificationResult;
  final List<Map<String, dynamic>>? initialMessages;

  final ScrollController scrollController = ScrollController();
  final GlobalKey suggestionsButtonKey = GlobalKey();

  final List<ChatMessage> messages = [];

  bool isLoading = false;
  bool isLoadingQuestions = false;
  bool _isDisposed = false;

  List<Map<String, dynamic>> suggestedQuestions = [];
  List<String> availableAlgaeTypes = [];

  ChatAssistantController({
    required this.algaeType,
    this.classificationResult,
    this.initialMessages,
  }) {
    _initMessages();

    Future.microtask(() async {
      await _loadInitialData();
    });
  }

  void _initMessages() {
    if (initialMessages != null && initialMessages!.isNotEmpty) {
      for (final msg in initialMessages!) {
        messages.add(
          ChatMessage(
            text: msg['text'] ?? '',
            isUser: msg['isUser'] ?? false,
            timestamp: DateTime.tryParse(msg['timestamp'] ?? '') ??
                DateTime.now(),
            recommendations: List<String>.from(
              msg['recommendations'] ?? [],
            ),
            isError: msg['isError'] ?? false,
          ),
        );
      }
      return;
    }

    messages.add(
      ChatMessage(
        text:
        '${AppStrings.chatWelcome} $algaeType ${AppStrings.chatWelcomeSuffix}',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    if (_isDisposed) return;

    isLoadingQuestions = true;
    _safeNotify();

    try {
      final results = await Future.wait([
        ApiService.algae.getAlgaeInfo(
          algaeType: algaeType,
          includeSources: true,
        ),
        ApiService.algae.getToxicityLevel(algaeType).catchError((_) => {}),
        ApiService.algae.getAlgaeTypes().catchError((_) => <String>[]),
      ]);

      if (_isDisposed) return;

      final info = results[0] as Map<String, dynamic>;
      final toxicity = results[1] as Map<String, dynamic>;
      availableAlgaeTypes = List<String>.from(results[2] as List);

      suggestedQuestions = _generateQuestionsFromAllSources(
        info: info,
        toxicity: toxicity,
      );
    } catch (_) {
      if (_isDisposed) return;
      suggestedQuestions = _getDefaultQuestions(algaeType);
    } finally {
      isLoadingQuestions = false;
      _safeNotify();
    }
  }

  List<Map<String, dynamic>> _generateQuestionsFromAllSources({
    required Map<String, dynamic> info,
    required Map<String, dynamic> toxicity,
  }) {
    final questions = <Map<String, dynamic>>[];
    final name = info['scientificName'] ?? algaeType;

    final isToxic = toxicity['is_toxic'] ?? info['isToxic'] ?? false;

    questions.add({
      'id': 'toxicity',
      'icon': Icons.warning_amber,
      'title': isToxic ? 'Toxicity Alert' : 'Safety Check',
      'color': isToxic ? '#E53935' : '#4CAF50',
      'question': isToxic
          ? 'How toxic is $name? What are the specific dangers?'
          : 'Is $name completely safe for humans and animals?',
      'endpoint': 'toxicity',
      'data': toxicity,
      'isInteractive': false,
    });

    if (isToxic) {
      questions.add({
        'id': 'health_effects',
        'icon': Icons.medical_services,
        'title': 'Health Effects',
        'color': '#FF9800',
        'question': 'What are the health effects of exposure to $name?',
        'endpoint': 'toxicity',
        'data': toxicity,
        'isInteractive': false,
      });
    }

    final benefits = info['benefits'];
    if (benefits is List && benefits.isNotEmpty) {
      questions.add({
        'id': 'benefits',
        'icon': Icons.medical_services,
        'title': 'Benefits',
        'color': '#2E7D32',
        'question':
        'What are the main benefits of $name? (${benefits.take(3).join(', ')})',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final uses = info['uses'];
    if (uses is List && uses.isNotEmpty) {
      questions.add({
        'id': 'applications',
        'icon': Icons.build,
        'title': 'Applications',
        'color': '#1565C0',
        'question':
        'How is $name used in industry and research? (${uses.take(3).join(', ')})',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final sellable = info['sellable']?.toString() ?? '';
    if (sellable.isNotEmpty) {
      final isSellable =
          sellable.contains('Yes') || sellable.contains('Suitable');

      questions.add({
        'id': 'commercial',
        'icon': Icons.shopping_cart,
        'title': isSellable ? 'Commercial Use' : 'Commercial Restrictions',
        'color': isSellable ? '#2E7D32' : '#E53935',
        'question': 'Can $name be used commercially? $sellable',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final co2 = info['co2PerKg'] ?? 0;
    if (co2 is num && co2 > 0) {
      questions.add({
        'id': 'co2',
        'icon': Icons.cloud,
        'title': 'CO2 Sequestration',
        'color': '#0288D1',
        'question': 'How much CO2 does $name absorb? (~$co2 kg CO2/kg biomass)',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final habitat = info['habitat']?.toString() ?? '';
    if (habitat.isNotEmpty) {
      questions.add({
        'id': 'habitat',
        'icon': Icons.location_on,
        'title': 'Habitat',
        'color': '#00897B',
        'question': 'Where does $name naturally grow? $habitat',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final category = info['category']?.toString() ?? '';
    if (category.isNotEmpty) {
      questions.add({
        'id': 'classification',
        'icon': Icons.science,
        'title': 'Classification',
        'color': '#7B1FA2',
        'question': 'What is the scientific classification of $name? ($category)',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final toxins = info['potentialToxins'];
    if (toxins is List && toxins.isNotEmpty) {
      questions.add({
        'id': 'toxins',
        'icon': Icons.biotech,
        'title': 'Potential Toxins',
        'color': '#D32F2F',
        'question':
        'What toxins does $name contain? ${toxins.take(3).join(', ')}',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    questions.add({
      'id': 'safety',
      'icon': Icons.tips_and_updates,
      'title': 'Safety Tips',
      'color': '#00897B',
      'question': isToxic
          ? 'How should I handle $name safely? What precautions are needed?'
          : 'How should I handle $name? Any special considerations?',
      'endpoint': isToxic ? 'toxicity' : 'info',
      'data': isToxic ? toxicity : info,
      'isInteractive': false,
    });

    questions.add({
      'id': 'environment',
      'icon': Icons.eco,
      'title': 'Environmental Impact',
      'color': '#2E7D32',
      'question': 'What is the environmental impact of $name?',
      'endpoint': 'info',
      'data': info,
      'isInteractive': false,
    });

    if (sellable.contains('Yes') || sellable.contains('Suitable')) {
      questions.add({
        'id': 'cultivation',
        'icon': Icons.grass,
        'title': 'Cultivation',
        'color': '#33691E',
        'question': 'How can I cultivate $name? What are the optimal conditions?',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    final otherTypes = availableAlgaeTypes
        .where(
          (t) => t != algaeType && t != 'not_algae' && t != 'Nontoxic',
    )
        .take(8)
        .toList();

    if (otherTypes.isNotEmpty) {
      questions.add({
        'id': 'compare_interactive',
        'icon': Icons.compare_arrows,
        'title': 'Compare Species',
        'color': '#D32F2F',
        'question':
        'Compare $name with other algae species. Select which ones to compare:',
        'endpoint': 'compare',
        'data': {
          'mainType': algaeType,
          'availableTypes': otherTypes,
          'selectedTypes': <String>[],
        },
        'isInteractive': true,
        'isComparison': true,
      });
    }

    questions.add({
      'id': 'research',
      'icon': Icons.school,
      'title': 'Research',
      'color': '#1565C0',
      'question': 'What scientific research has been done on $name?',
      'endpoint': 'info',
      'data': info,
      'isInteractive': false,
    });

    final seen = <String>{};

    return questions.where((q) {
      final id = q['id'] as String;
      if (seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _getDefaultQuestions(String type) {
    return [
      {
        'id': 'toxicity',
        'icon': Icons.warning_amber,
        'title': 'Toxicity',
        'color': '#E53935',
        'question': 'Is this algae toxic? What are the dangers?',
        'endpoint': 'info',
        'data': {},
        'isInteractive': false,
      },
      {
        'id': 'health',
        'icon': Icons.medical_services,
        'title': 'Health Effects',
        'color': '#FF9800',
        'question': 'What are the health effects if exposed?',
        'endpoint': 'info',
        'data': {},
        'isInteractive': false,
      },
      {
        'id': 'commercial',
        'icon': Icons.shopping_cart,
        'title': 'Commercial Use',
        'color': '#2E7D32',
        'question': 'Can this algae be used commercially? Is it sellable?',
        'endpoint': 'info',
        'data': {},
        'isInteractive': false,
      },
      {
        'id': 'environment',
        'icon': Icons.eco,
        'title': 'Environmental Impact',
        'color': '#2E7D32',
        'question': 'What is the environmental impact of this algae?',
        'endpoint': 'info',
        'data': {},
        'isInteractive': false,
      },
      {
        'id': 'classification',
        'icon': Icons.science,
        'title': 'Classification',
        'color': '#7B1FA2',
        'question': 'Tell me about the scientific classification.',
        'endpoint': 'info',
        'data': {},
        'isInteractive': false,
      },
      {
        'id': 'safety',
        'icon': Icons.tips_and_updates,
        'title': 'Safety',
        'color': '#00897B',
        'question': 'How should I handle this algae safely?',
        'endpoint': 'info',
        'data': {},
        'isInteractive': false,
      },
    ];
  }

  Future<void> compareSelectedTypes({
    required String mainType,
    required List<String> selectedTypes,
  }) async {
    if (selectedTypes.isEmpty || isLoading) return;

    final allTypes = [mainType, ...selectedTypes];

    final question =
        'Compare ${allTypes.join(", ")}. What are the key differences and similarities between these algae species in terms of toxicity, benefits, applications, and commercial value?';

    await sendMessage(question: question);
  }

  void showComparisonDialog(BuildContext context) {
    final compareData = suggestedQuestions.firstWhere(
          (q) => q['id'] == 'compare_interactive',
      orElse: () => {},
    );

    if (compareData.isEmpty) return;

    final data = compareData['data'] as Map<String, dynamic>? ?? {};

    final available = List<String>.from(data['availableTypes'] ?? []);
    final mainType = data['mainType'] ?? algaeType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (_) {
        return ComparisonSelectionSheet(
          mainType: mainType,
          availableTypes: available,
          onCompare: (selected) {
            compareSelectedTypes(
              mainType: mainType,
              selectedTypes: selected,
            );
          },
        );
      },
    );
  }

  Future<void> sendMessage({String? question}) async {
    final messageText = question?.trim() ?? '';

    if (messageText.isEmpty || isLoading || _isDisposed) return;

    messages.add(
      ChatMessage(
        text: messageText,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    isLoading = true;
    _safeNotify();
    _scrollToBottom();

    try {
      final response = await ApiService.algae.chat(
        algaeType: algaeType,
        userQuestion: messageText,
        classificationResult: classificationResult,
        conversationHistory: _buildConversationHistory(),
      );

      if (_isDisposed) return;

      messages.add(
        ChatMessage(
          text: response['response'] ?? AppStrings.chatError,
          isUser: false,
          timestamp: DateTime.now(),
          recommendations: response['recommendations'] != null
              ? List<String>.from(response['recommendations'])
              : [],
        ),
      );
    } catch (_) {
      if (_isDisposed) return;

      messages.add(
        ChatMessage(
          text: AppStrings.chatError,
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ),
      );
    } finally {
      isLoading = false;
      _safeNotify();
      _scrollToBottom();
    }
  }

  List<Map<String, String>> _buildConversationHistory() {
    return messages
        .map(
          (msg) => {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      },
    )
        .toList();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed || !scrollController.hasClients) return;

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    scrollController.dispose();
    super.dispose();
  }
}