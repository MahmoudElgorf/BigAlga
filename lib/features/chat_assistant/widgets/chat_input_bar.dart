/// Chat input bar with text field and send button
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';
import '../controllers/chat_assistant_controller.dart';
import '../widgets/chat_suggestions_overlay.dart';

class ChatInputBar extends StatelessWidget {
  final ChatAssistantController controller;
  final TextEditingController textController;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.textController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.foam.withOpacity(0.2),
            AppColors.sand.withOpacity(0.15),
          ],
        ),
        border: Border(
          top: BorderSide(color: AppColors.aqua.withOpacity(0.2), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          _buildSuggestionsButton(context),
          const SizedBox(width: 8),
          _buildTextField(),
          const SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSuggestionsButton(BuildContext context) {
    return Container(
      key: controller.suggestionsButtonKey,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.accentGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 22,
        child: IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
          onPressed: () => ChatSuggestionsOverlay.show(
            context,
            controller.suggestionsButtonKey,
            controller,
          ),
          tooltip: AppStrings.suggestedQuestions,
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.textWhite.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.aqua.withOpacity(0.3), width: 1),
        ),
        child: TextField(
          controller: textController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '${AppStrings.askAbout} ${controller.algaeType}...',
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: null,
          textInputAction: TextInputAction.send,
          onSubmitted: (_) => onSend(),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.aqua],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 22,
        child: IconButton(
          icon: const Icon(Icons.send, color: Colors.white, size: 18),
          onPressed: controller.isLoading ? null : onSend,
        ),
      ),
    );
  }
}