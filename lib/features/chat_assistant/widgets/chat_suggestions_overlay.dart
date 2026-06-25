/// Overlay for suggested questions with interactive support

import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

import '../controllers/chat_assistant_controller.dart';
import 'comparison_selection_sheet.dart';

class ChatSuggestionsOverlay {
  static OverlayEntry? _overlayEntry;

  static void show(
      BuildContext context,
      GlobalKey buttonKey,
      ChatAssistantController controller,
      ) {
    remove();

    final renderBox =
    buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.hasSize) return;

    final offset = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.sizeOf(context);

    final overlayWidth = screenSize.width < 390 ? screenSize.width - 20 : 360.0;

    double left = offset.dx - (overlayWidth / 2) + (buttonSize.width / 2);

    if (left < 10) left = 10;

    if (left + overlayWidth > screenSize.width - 10) {
      left = screenSize.width - overlayWidth - 10;
    }

    final bottom =
        screenSize.height - offset.dy + buttonSize.height - 30;

    _overlayEntry = OverlayEntry(
      builder: (_) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: remove,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              bottom: bottom,
              left: left,
              child: _SuggestionsContent(
                width: overlayWidth,
                controller: controller,
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  static void remove() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  static Color _getColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryBlue;
    }
  }
}

class _SuggestionsContent extends StatelessWidget {
  final double width;
  final ChatAssistantController controller;

  const _SuggestionsContent({
    required this.width,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: RepaintBoundary(
        child: Container(
          width: width,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.55,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: controller.isLoadingQuestions
              ? const _LoadingQuestions()
              : _QuestionsList(controller: controller),
        ),
      ),
    );
  }
}

class _LoadingQuestions extends StatelessWidget {
  const _LoadingQuestions();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            size: 34,
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: 12),
          Text(
            'Loading questions...',
            style: TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _QuestionsList extends StatelessWidget {
  final ChatAssistantController controller;

  const _QuestionsList({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final questions = controller.suggestedQuestions;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(count: questions.length),

        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: questions.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              thickness: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              return _QuestionTile(
                question: questions[index],
                controller: controller,
              );
            },
          ),
        ),

        const _Footer(),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final int count;

  const _Header({
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.help_outline,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          const Text(
            'Suggested Questions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final Map<String, dynamic> question;
  final ChatAssistantController controller;

  const _QuestionTile({
    required this.question,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isInteractive = question['isInteractive'] == true;
    final isComparison = question['isComparison'] == true;
    final title = question['title'] as String? ?? 'Question';
    final text = question['question'] as String? ?? '';
    final endpoint = question['endpoint'] as String?;
    final color = ChatSuggestionsOverlay._getColor(
      question['color'] as String? ?? '#1565C0',
    );

    return InkWell(
      onTap: () {
        ChatSuggestionsOverlay.remove();

        if (isComparison) {
          controller.showComparisonDialog(context);
          return;
        }

        if (text.isNotEmpty) {
          controller.sendMessage(question: text);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                question['icon'] as IconData? ?? Icons.help_outline,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: color,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                      if (isInteractive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Interactive',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 2),

                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (endpoint != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  endpoint,
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            if (isComparison) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Center(
        child: Text(
          'Tap a question to ask • Interactive ones open selection',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}