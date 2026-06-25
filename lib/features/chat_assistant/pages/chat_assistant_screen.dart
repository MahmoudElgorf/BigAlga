/// AI chat assistant screen for algae-related questions

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:flutter/material.dart';

import '../controllers/chat_assistant_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
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
  late final ChatAssistantController _controller;
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();

    _controller = ChatAssistantController(
      algaeType: widget.algaeType,
      classificationResult: widget.classificationResult,
      initialMessages: widget.initialMessages,
    );
  }

  @override
  void dispose() {
    ChatSuggestionsOverlay.remove();
    _textController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();

    if (text.isEmpty || _controller.isLoading) return;

    _textController.clear();
    ChatSuggestionsOverlay.remove();

    _controller.sendMessage(question: text);
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

            const _ChatDivider(),

            Expanded(
              child: ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  return ListView.builder(
                    controller: _controller.scrollController,
                    padding: const EdgeInsets.all(16),
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _controller.messages.length,
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: ChatMessageBubble(
                          message: _controller.messages[index],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                if (!_controller.isLoading) {
                  return const SizedBox.shrink();
                }

                return const _StaticLoadingBar();
              },
            ),

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
}

class _ChatDivider extends StatelessWidget {
  const _ChatDivider();

  @override
  Widget build(BuildContext context) {
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
}

class _StaticLoadingBar extends StatelessWidget {
  const _StaticLoadingBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RepaintBoundary(
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.aqua,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}