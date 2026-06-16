/// Category badge widget with toxic/safe indicator
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class DetailCategoryBadge extends StatelessWidget {
  final String category;
  final bool isToxic;

  const DetailCategoryBadge({
    super.key,
    required this.category,
    required this.isToxic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isToxic ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isToxic ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Text(
              isToxic ? AppStrings.toxicBadge : AppStrings.safeBadge,
              style: TextStyle(
                fontSize: 12,
                color: isToxic ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}