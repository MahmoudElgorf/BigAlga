// lib/features/catalog/presentation/widgets/algae_card.dart
import 'package:flutter/material.dart';

class AlgaeCard extends StatelessWidget {
  final String name;
  final String arabicName;
  final String scientificName;
  final String category;
  final bool isToxic;
  final VoidCallback onTap;

  const AlgaeCard({
    Key? key,
    required this.name,
    required this.arabicName,
    required this.scientificName,
    required this.category,
    required this.isToxic,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored header - height reduced
            Container(
              height: 70,  // تم التخفيض من 80 إلى 70
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isToxic
                      ? [Colors.red[400]!, Colors.red[700]!]
                      : [Colors.green[400]!, Colors.green[700]!],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: Icon(
                  isToxic ? Icons.warning_amber : Icons.eco,
                  color: Colors.white,
                  size: 32,  // تم التخفيض من 40 إلى 32
                ),
              ),
            ),
            // Content - with proper constraints
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arabic name (if exists)
                  if (arabicName.isNotEmpty)
                    Text(
                      arabicName,
                      style: const TextStyle(
                        fontSize: 14,  // تم التخفيض من 16 إلى 14
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  // Scientific name (always shown)
                  Text(
                    arabicName.isNotEmpty ? name : name,
                    style: TextStyle(
                      fontSize: arabicName.isNotEmpty ? 11 : 13,  // تم التخفيض
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isToxic
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getShortCategory(category),
                      style: TextStyle(
                        fontSize: 10,  // تم التخفيض من 11 إلى 10
                        color: isToxic ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to shorten category names
  String _getShortCategory(String category) {
    if (category.contains('Cyanobacteria')) return 'Cyanobacteria';
    if (category.contains('Dinoflagellate')) return 'Dinoflagellate';
    if (category.contains('Diatom')) return 'Diatom';
    if (category.contains('Unknown')) return 'Algae';
    return category.split(' ').first;
  }
}