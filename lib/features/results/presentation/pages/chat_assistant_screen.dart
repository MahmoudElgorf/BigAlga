import 'package:bioalga/core/services/history_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bioalga/core/services/api_service.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:bioalga/core/constants/constants.dart';

class ChatAssistantScreen extends StatefulWidget {
  final String algaeType;
  final Map<String, dynamic>? classificationResult;
  final List<Map<String, dynamic>>? initialMessages;
  final String? analysisId;  // إضافة معرف التحليل الفريد

  const ChatAssistantScreen({
    Key? key,
    required this.algaeType,
    this.classificationResult,
    this.initialMessages,
    this.analysisId,  // جديد
  }) : super(key: key);

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _buttonKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  final List<String> _suggestedQuestions = [
    'Is this algae toxic? What are the dangers?',
    'What are the health effects if exposed?',
    'Can this algae be used commercially? Is it sellable?',
    'What is the environmental impact of this algae?',
    'Tell me about the scientific classification.',
    'How should I handle this algae safely?',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      for (var msg in widget.initialMessages!) {
        _messages.add(ChatMessage(
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
    _messages.add(ChatMessage(
      text: 'Hello! I am your BioAlga AI Assistant. I specialize in ${widget.algaeType} algae. Feel free to ask me anything about toxicity, applications, environmental impact, or safety.',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage({String? question}) async {
    final messageText = question ?? _messageController.text.trim();
    if (messageText.isEmpty) return;

    if (question == null) {
      _messageController.clear();
    }

    _removeOverlay();

    setState(() {
      _messages.add(ChatMessage(
        text: messageText,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await ApiService.algae.chat(
        algaeType: widget.algaeType,
        userQuestion: messageText,
        classificationResult: widget.classificationResult,
        conversationHistory: _buildConversationHistory(),
      );

      setState(() {
        _messages.add(ChatMessage(
          text: response['response'],
          isUser: false,
          timestamp: DateTime.now(),
          recommendations: response['recommendations'] != null
              ? List<String>.from(response['recommendations'])
              : [],
        ));
        _isLoading = false;
      });
      _scrollToBottom();

    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Sorry, I encountered an error. Please try again later.',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  List<Map<String, String>> _buildConversationHistory() {
    return _messages.map((msg) {
      return {
        'role': msg.isUser ? 'user' : 'assistant',
        'content': msg.text,
      };
    }).toList();
  }

  void _showQuestionsOverlay() {
    _removeOverlay();

    final RenderBox renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size buttonSize = renderBox.size;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double overlayWidth = 280.0;

    double leftPosition = offset.dx - (overlayWidth / 2) + (buttonSize.width / 2);

    if (leftPosition < 10) {
      leftPosition = 10;
    }

    if (leftPosition + overlayWidth > screenWidth - 10) {
      leftPosition = screenWidth - overlayWidth - 10;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height - offset.dy + buttonSize.height + (-30),
            left: leftPosition,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: overlayWidth,
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
                          'Suggested Questions',
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
                        itemCount: _suggestedQuestions.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade200,
                        ),
                        itemBuilder: (context, index) {
                          final question = _suggestedQuestions[index];
                          return InkWell(
                            onTap: () {
                              _removeOverlay();
                              _sendMessage(question: question);
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
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            AppHeader(
              title: 'AI Assistant',
              subtitle: 'Ask about ${widget.algaeType}',
              isToxic: false,
              showBackButton: true,
            ),

            Container(
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
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            if (_isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LinearProgressIndicator(
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.aqua),
                ),
              ),

            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final backgroundColor = isUser
        ? AppColors.primaryGreen
        : AppColors.sand.withOpacity(0.85);
    final textColor = isUser ? AppColors.textWhite : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (message.recommendations.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warningOrange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warningOrange.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.lightbulb, size: 14, color: AppColors.warningOrange),
                              const SizedBox(width: 6),
                              Text(
                                'Recommendations',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...message.recommendations.map((rec) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '• ',
                                  style: TextStyle(color: AppColors.warningOrange, fontSize: 11),
                                ),
                                Expanded(
                                  child: Text(
                                    rec,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 6),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
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
          top: BorderSide(
            color: AppColors.aqua.withOpacity(0.2),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            key: _buttonKey,
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
                onPressed: _showQuestionsOverlay,
                tooltip: 'Suggested Questions',
              ),
            ),
          ),
          const SizedBox(width: 8),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.textWhite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: AppColors.aqua.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Ask about ${widget.algaeType}...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),

          Container(
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
                onPressed: _isLoading ? null : () => _sendMessage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

// lib/features/results/presentation/pages/chat_assistant_screen.dart

  @override
  void dispose() {
    if (_messages.length > 1) {
      final messagesToSave = _messages.map((msg) => {
        'text': msg.text,
        'isUser': msg.isUser,
        'timestamp': msg.timestamp.toIso8601String(),
        'recommendations': msg.recommendations,
        'isError': msg.isError,
      }).toList();

      HistoryService.saveChatConversation(
        algaeType: widget.algaeType,
        classificationResult: widget.classificationResult,
        messages: messagesToSave,
        analysisId: widget.analysisId,
      );
    }

    _messageController.dispose();
    _scrollController.dispose();
    _removeOverlay();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String> recommendations;
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendations = const [],
    this.isError = false,
  });
}