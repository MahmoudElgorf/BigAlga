/// Catalog body with grid/list view and filters
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/catalog/controllers/catalog_controller.dart';
import 'package:bioalga/features/catalog/pages/algae_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/algae_card.dart';
import 'catalog_filter_chips.dart';
import 'catalog_search_bar.dart';

class CatalogBody extends StatelessWidget {
  final CatalogController controller;

  const CatalogBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final filtered = controller.filteredAlgae;
        final total = controller.totalCount;

        return Column(
          children: [
            const SizedBox(height: 16),
            CatalogSearchBar(
              onSearchChanged: (query) {
                controller.updateSearch(query);
                HapticFeedback.lightImpact();
              },
            ),
            const SizedBox(height: 16),
            CatalogFilterChips(
              categories: controller.categories,
              selectedCategory: controller.selectedCategory,
              onCategorySelected: (category) {
                controller.updateCategory(category);
                HapticFeedback.selectionClick();
              },
            ),
            const SizedBox(height: 12),
            _buildHeaderBar(filtered.length, total),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              controller.isGridView
                  ? _buildGridView(context, filtered)
                  : _buildListView(context, filtered),
          ],
        );
      },
    );
  }

  Widget _buildHeaderBar(int filteredCount, int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCounter(filteredCount, totalCount),
          _buildViewToggle(),
        ],
      ),
    );
  }

  Widget _buildCounter(int filtered, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        filtered == total
            ? '$filtered ${AppStrings.species}'
            : '$filtered ${AppStrings.of} $total',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ToggleButtons(
        isSelected: [!controller.isGridView, controller.isGridView],
        onPressed: (index) {
          controller.toggleView();
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(30),
        selectedColor: AppColors.primaryBlue,
        fillColor: Colors.transparent,
        color: Colors.grey[600],
        constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
        children: [
          _buildToggleButton(Icons.view_list, !controller.isGridView, AppStrings.list),
          _buildToggleButton(Icons.grid_view, controller.isGridView, AppStrings.grid),
        ],
      ),
    );
  }

  Widget _buildToggleButton(IconData icon, bool isSelected, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: isSelected ? AppColors.primaryBlue : Colors.grey[600]),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off, size: 50, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.noResultsFound,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tryAdjustingSearch,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context, List<String> filtered) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildCard(context, filtered[index]),
    );
  }

  Widget _buildListView(BuildContext context, List<String> filtered) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildCard(context, filtered[index]),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String name) {
    final data = controller.getAlgaeDataByName(name);
    return AlgaeCard(
      name: name,
      scientificName: data['scientificName'] as String? ?? '$name spp.',
      category: data['category'] as String? ?? AppStrings.unknown,
      isToxic: data['isToxic'] as bool? ?? false,
      imagePath: controller.getImagePath(name),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AlgaeDetailScreen(algaeName: name),
          ),
        );
      },
    );
  }
}