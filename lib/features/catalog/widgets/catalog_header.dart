/// Catalog header with title and subtitle
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';

class CatalogHeader extends StatelessWidget {
  final int totalCount;

  const CatalogHeader({super.key, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      title: AppStrings.algaeEncyclopedia,
      showBackButton: true,
      onBackPressed: () => Navigator.pop(context),
      subtitle: '${AppStrings.discover} $totalCount ${AppStrings.documentedSpecies}',
      isToxic: false,
    );
  }
}