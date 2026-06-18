/// Chat assistant controller with dynamic questions using all endpoints
import 'package:bioalga/features/chat_assistant/widgets/chat_message.dart';
import 'package:bioalga/features/chat_assistant/widgets/comparison_selection_sheet.dart';
import 'package:flutter/material.dart';
import 'package:bioalga/core/services/api_service.dart';
import 'package:bioalga/core/constants/constants.dart';

class ChatAssistantController extends ChangeNotifier {
  final String algaeType;
  final Map<String, dynamic>? classificationResult;
  final List<Map<String, dynamic>>? initialMessages;

  List<ChatMessage> messages = [];
  bool isLoading = false;
  bool isLoadingQuestions = false;
  final ScrollController scrollController = ScrollController();
  final GlobalKey suggestionsButtonKey = GlobalKey();

  List<Map<String, dynamic>> suggestedQuestions = [];
  List<String> availableAlgaeTypes = [];

  ChatAssistantController({
    required this.algaeType,
    this.classificationResult,
    this.initialMessages,
  }) {
    _initMessages();
    _loadSuggestedQuestions();
    _loadAvailableTypes();
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

  Future<void> _loadAvailableTypes() async {
    try {
      availableAlgaeTypes = await ApiService.algae.getAlgaeTypes();
    } catch (e) {
      availableAlgaeTypes = [];
    }
  }

  Future<void> _loadSuggestedQuestions() async {
    isLoadingQuestions = true;
    notifyListeners();

    try {
      final info = await ApiService.algae.getAlgaeInfo(
        algaeType: algaeType,
        includeSources: true,
      );

      Map<String, dynamic> toxicityData = {};
      try {
        toxicityData = await ApiService.algae.getToxicityLevel(algaeType);
      } catch (e) {}

      suggestedQuestions = _generateQuestionsFromAllSources(
        info: info,
        toxicity: toxicityData,
      );
    } catch (e) {
      suggestedQuestions = _getDefaultQuestions(algaeType);
    }

    isLoadingQuestions = false;
    notifyListeners();
  }

  List<Map<String, dynamic>> _generateQuestionsFromAllSources({
    required Map<String, dynamic> info,
    required Map<String, dynamic> toxicity,
  }) {
    final questions = <Map<String, dynamic>>[];
    final name = info['scientificName'] ?? algaeType;

    // 1. Toxicity
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

    // 2. Benefits
    if (info['benefits'] != null && info['benefits'].isNotEmpty) {
      final benefits = (info['benefits'] as List).take(3).join(', ');
      questions.add({
        'id': 'benefits',
        'icon': Icons.medical_services,
        'title': 'Benefits',
        'color': '#2E7D32',
        'question': 'What are the main benefits of $name? ($benefits)',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    // 3. Applications
    if (info['uses'] != null && info['uses'].isNotEmpty) {
      final uses = (info['uses'] as List).take(3).join(', ');
      questions.add({
        'id': 'applications',
        'icon': Icons.build,
        'title': 'Applications',
        'color': '#1565C0',
        'question': 'How is $name used in industry and research? ($uses)',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    // 4. Commercial Viability
    final sellable = info['sellable'] ?? '';
    if (sellable.isNotEmpty) {
      final isSellable = sellable.contains('Yes') || sellable.contains('Suitable');
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

    // 5. CO2 Sequestration
    final co2 = info['co2PerKg'] ?? 0;
    if (co2 > 0) {
      questions.add({
        'id': 'co2',
        'icon': Icons.cloud,
        'title': 'CO2 Sequestration',
        'color': '#0288D1',
        'question': 'How much CO2 does $name absorb? (~${co2} kg CO2/kg biomass)',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    // 6. Habitat
    if (info['habitat'] != null && info['habitat'].isNotEmpty) {
      questions.add({
        'id': 'habitat',
        'icon': Icons.location_on,
        'title': 'Habitat',
        'color': '#00897B',
        'question': 'Where does $name naturally grow? ${info['habitat']}',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    // 7. Scientific Classification
    if (info['category'] != null && info['category'].isNotEmpty) {
      questions.add({
        'id': 'classification',
        'icon': Icons.science,
        'title': 'Classification',
        'color': '#7B1FA2',
        'question': 'What is the scientific classification of $name? (${info['category']})',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    // 8. Potential Toxins
    final toxins = info['potentialToxins'] ?? [];
    if (toxins.isNotEmpty) {
      final toxinList = (toxins as List).take(3).join(', ');
      questions.add({
        'id': 'toxins',
        'icon': Icons.biotech,
        'title': 'Potential Toxins',
        'color': '#D32F2F',
        'question': 'What toxins does $name contain? $toxinList',
        'endpoint': 'info',
        'data': info,
        'isInteractive': false,
      });
    }

    // 9. Safety Tips
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

    // 10. Environmental Impact
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

    // 11. Cultivation
    if (sellable.toString().contains('Yes') || sellable.toString().contains('Suitable')) {
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

    // 12. Interactive Compare
    if (availableAlgaeTypes.isNotEmpty) {
      final otherTypes = availableAlgaeTypes
          .where((t) => t != algaeType && t != 'not_algae' && t != 'Nontoxic')
          .take(8)
          .toList();

      if (otherTypes.isNotEmpty) {
        questions.add({
          'id': 'compare_interactive',
          'icon': Icons.compare_arrows,
          'title': 'Compare Species',
          'color': '#D32F2F',
          'question': 'Compare $name with other algae species. Select which ones to compare:',
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
    }

    // 13. Research
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

    // Remove duplicates
    final seen = <String>{};
    final uniqueQuestions = questions.where((q) {
      final id = q['id'] as String;
      if (seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();

    return uniqueQuestions;
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
    if (selectedTypes.isEmpty) return;

    final allTypes = [mainType, ...selectedTypes];
    final question = 'Compare ${allTypes.join(", ")}. What are the key differences and similarities between these algae species in terms of toxicity, benefits, applications, and commercial value?';

    await sendMessage(question: question);
  }

  void showComparisonDialog(BuildContext context) {
    final compareData = suggestedQuestions.firstWhere(
          (q) => q['id'] == 'compare_interactive',
      orElse: () => {},
    );

    if (compareData.isEmpty) return;

    final available = List<String>.from(compareData['data']['availableTypes'] ?? []);
    final mainType = compareData['data']['mainType'] ?? algaeType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ComparisonSelectionSheet(
        mainType: mainType,
        availableTypes: available,
        onCompare: (selected) {
          compareSelectedTypes(mainType: mainType, selectedTypes: selected);
        },
      ),
    );
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}