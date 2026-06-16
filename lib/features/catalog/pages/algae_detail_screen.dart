/// Algae detail screen displaying comprehensive species information
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/catalog/controllers/detail_controller.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';
import '../widgets/detail_category_badge.dart';
import '../widgets/detail_section.dart';
import '../widgets/detail_list_section.dart';
import '../widgets/detail_info_row.dart';

class AlgaeDetailScreen extends StatelessWidget {
  final String algaeName;

  const AlgaeDetailScreen({
    super.key,
    required this.algaeName,
  });

  @override
  Widget build(BuildContext context) {
    final c = DetailController(algaeName: algaeName);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: algaeName,
              scientificTitle: c.scientificName.isNotEmpty ? c.scientificName : null,
              isToxic: c.isToxic,
              showBackButton: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailCategoryBadge(category: c.category, isToxic: c.isToxic),
                  const SizedBox(height: 24),
                  if (c.scientificWarning.isNotEmpty)
                    DetailSection(
                      title: AppStrings.scientificWarningTitle,
                      color: Colors.orange,
                      content: c.scientificWarning,
                      isWarning: true,
                    ),
                  const SizedBox(height: 16),
                  DetailSection(
                    title: AppStrings.toxicityAndSafety,
                    color: c.isToxic ? Colors.red : Colors.green,
                    content: c.toxicityWarning,
                  ),
                  if (c.potentialToxins.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    DetailListSection(
                      title: AppStrings.potentialToxinsTitle,
                      color: Colors.red,
                      items: c.potentialToxins.map((t) => t.toString()).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  DetailInfoRow(label: AppStrings.classification, value: c.category),
                  DetailInfoRow(label: AppStrings.co2SequestrationLabel, value: c.co2Text),
                  if (c.sellable.isNotEmpty)
                    DetailInfoRow(label: AppStrings.commercialViabilityLabel, value: c.sellable),
                  const SizedBox(height: 16),
                  if (c.benefits.isNotEmpty)
                    DetailListSection(
                      title: AppStrings.benefitsTitle,
                      color: Colors.green,
                      items: c.benefits.map((b) => b.toString()).toList(),
                    ),
                  const SizedBox(height: 16),
                  if (c.uses.isNotEmpty)
                    DetailListSection(
                      title: AppStrings.applicationsTitle,
                      color: AppColors.primaryBlue,
                      items: c.uses.map((u) => u.toString()).toList(),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}