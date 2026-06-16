/// Overlay for suggested questions
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_assistant_controller.dart';

class ChatSuggestionsOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(
      BuildContext context,
      GlobalKey buttonKey,
      ChatAssistantController controller,
      ) {
    remove();

    final renderBox = buttonKey.currentContext?.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    const overlayWidth = 280.0;

    double left = offset.dx - (overlayWidth / 2) + (buttonSize.width / 2);
    if (left < 10) left = 10;
    if (left + overlayWidth > screenWidth - 10) {
      left = screenWidth - overlayWidth - 10;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: remove,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height - offset.dy + buttonSize.height + (-30),
            left: left,
            child: _buildOverlayContent(context, controller),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static Widget _buildOverlayContent(BuildContext context, ChatAssistantController controller) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Center(
                child: Text(
                  AppStrings.suggestedQuestions,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.suggestedQuestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final question = controller.suggestedQuestions[index];
                  return InkWell(
                    onTap: () {
                      remove();
                      controller.sendMessage(question: question);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        question,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}