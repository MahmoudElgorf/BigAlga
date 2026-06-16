/// Chat assistant constants
import 'package:flutter/material.dart';

class ChatAssistantConstants {
  static const int maxHistoryMessages = 50;
  static const Duration typingDelay = Duration(milliseconds: 500);
  static const Duration scrollDuration = Duration(milliseconds: 300);

  static const List<Map<String, dynamic>> questionTemplates = [
    {
      'icon': Icons.warning_amber,
      'title': 'Toxicity',
      'question': 'Is this algae toxic? What are the dangers?',
      'color': '#E53935',
    },
    {
      'icon': Icons.medical_services,
      'title': 'Health Effects',
      'question': 'What are the health effects if exposed to this algae?',
      'color': '#FF9800',
    },
    {
      'icon': Icons.shopping_cart,
      'title': 'Commercial Use',
      'question': 'Can this algae be used commercially? Is it sellable?',
      'color': '#4CAF50',
    },
    {
      'icon': Icons.cloud,
      'title': 'Environmental Impact',
      'question': 'What is the environmental impact of this algae?',
      'color': '#2196F3',
    },
    {
      'icon': Icons.science,
      'title': 'Scientific Info',
      'question': 'Tell me more about the scientific classification of this algae.',
      'color': '#9C27B0',
    },
    {
      'icon': Icons.tips_and_updates,
      'title': 'Safety Tips',
      'question': 'How should I handle this algae safely?',
      'color': '#00897B',
    },
  ];
}