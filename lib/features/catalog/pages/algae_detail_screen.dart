/// Algae detail screen displaying comprehensive species information
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/catalog/controllers/detail_controller.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';

import '../widgets/detail_category_badge.dart';
import '../widgets/detail_info_row.dart';
import '../widgets/detail_list_section.dart';
import '../widgets/detail_section.dart';

class AlgaeDetailScreen extends StatefulWidget {
  final String algaeName;

  const AlgaeDetailScreen({
    super.key,
    required this.algaeName,
  });

  @override
  State<AlgaeDetailScreen> createState() => _AlgaeDetailScreenState();
}

class _AlgaeDetailScreenState extends State<AlgaeDetailScreen> {
  late final DetailController c;

  @override
  void initState() {
    super.initState();
    c = DetailController(algaeName: widget.algaeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: AppHeader(
              title: widget.algaeName,
              scientificTitle:
              c.scientificName.isNotEmpty ? c.scientificName : null,
              isToxic: c.isToxic,
              showBackButton: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                DetailCategoryBadge(
                  category: c.category,
                  isToxic: c.isToxic,
                ),
                const SizedBox(height: 24),

                if (c.scientificWarning.isNotEmpty) ...[
                  DetailSection(
                    title: AppStrings.scientificWarningTitle,
                    color: Colors.orange,
                    content: c.scientificWarning,
                    isWarning: true,
                  ),
                  const SizedBox(height: 16),
                ],

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
                    items: c.potentialToxins.map((e) => e.toString()).toList(),
                  ),
                ],

                const SizedBox(height: 16),
                DetailInfoRow(
                  label: AppStrings.classification,
                  value: c.category,
                ),
                DetailInfoRow(
                  label: AppStrings.co2SequestrationLabel,
                  value: c.co2Text,
                ),

                if (c.sellable.isNotEmpty)
                  DetailInfoRow(
                    label: AppStrings.commercialViabilityLabel,
                    value: c.sellable,
                  ),

                if (c.benefits.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DetailListSection(
                    title: AppStrings.benefitsTitle,
                    color: Colors.green,
                    items: c.benefits.map((e) => e.toString()).toList(),
                  ),
                ],

                if (c.uses.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DetailListSection(
                    title: AppStrings.applicationsTitle,
                    color: AppColors.primaryBlue,
                    items: c.uses.map((e) => e.toString()).toList(),
                  ),
                ],

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}