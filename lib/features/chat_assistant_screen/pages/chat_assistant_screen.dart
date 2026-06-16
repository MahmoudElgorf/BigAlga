/// AI chat assistant screen for algae-related questions
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';
import '../controllers/chat_assistant_controller.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_suggestions_overlay.dart';

class ChatAssistantScreen extends StatefulWidget {
  final String algaeType;
  final Map<String, dynamic>? classificationResult;
  final List<Map<String, dynamic>>? initialMessages;
  final String? analysisId;

  const ChatAssistantScreen({
    super.key,
    required this.algaeType,
    this.classificationResult,
    this.initialMessages,
    this.analysisId,
  });

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  late ChatAssistantController _controller;
  final TextEditingController _textController = TextEditingController();
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = ChatAssistantController(
      algaeType: widget.algaeType,
      classificationResult: widget.classificationResult,
      initialMessages: widget.initialMessages,
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ChatSuggestionsOverlay.remove();
    _controller.sendMessage(question: text);
  }

  void _showSuggestions() {
    ChatSuggestionsOverlay.show(context, _buttonKey, _controller);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            AppHeader(
              title: AppStrings.aiAssistantTitleShort,
              subtitle: '${AppStrings.askAbout} ${widget.algaeType}',
              isToxic: false,
              showBackButton: true,
            ),
            _buildDivider(),
            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return ListView.builder(
                    controller: _controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageBubble(
                        message: _controller.messages[index],
                      );
                    },
                  );
                },
              ),
            ),
            if (_controller.isLoading) _buildProgressIndicator(),
            ChatInputBar(
              controller: _controller,
              textController: _textController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            AppColors.primaryBlue.withOpacity(0.3),
            AppColors.aqua.withOpacity(0.3),
            AppColors.primaryBlue.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LinearProgressIndicator(
        backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.aqua),
      ),
    );
  }
}