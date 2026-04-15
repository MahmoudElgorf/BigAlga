// lib/features/catalog/presentation/pages/algae_catalog_screen.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/algae_card.dart';
import '../widgets/catalog_filter_chips.dart';
import '../widgets/catalog_search_bar.dart';
import 'algae_detail_screen.dart';

class AlgaeCatalogScreen extends StatefulWidget {
  const AlgaeCatalogScreen({Key? key}) : super(key: key);

  @override
  State<AlgaeCatalogScreen> createState() => _AlgaeCatalogScreenState();
}

class _AlgaeCatalogScreenState extends State<AlgaeCatalogScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isGridView = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _categories = [
    'All',
    'Cyanobacteria',
    'Dinoflagellate',
    'Diatom',
    'Safe',
    'Toxic',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<String> get _filteredAlgae {
    final algaeList = algaeData.keys.toList();

    return algaeList.where((name) {
      final data = algaeData[name] as Map<String, dynamic>;
      final category = data['category'] as String? ?? '';
      final isToxic = data['isToxic'] as bool? ?? false;
      final arabicName = data['arabicName'] as String? ?? '';

      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Cyanobacteria' &&
            !category.contains('Cyanobacteria')) return false;
        if (_selectedCategory == 'Dinoflagellate' &&
            !category.contains('Dinoflagellate')) return false;
        if (_selectedCategory == 'Diatom' && !category.contains('Diatom'))
          return false;
        if (_selectedCategory == 'Safe' && isToxic) return false;
        if (_selectedCategory == 'Toxic' && !isToxic) return false;
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return name.toLowerCase().contains(query) ||
            arabicName.toLowerCase().contains(query) ||
            (data['scientificName'] as String? ?? '').toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            GradientBackground(child: Container()),
            CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        CatalogSearchBar(
                          onSearchChanged: (query) {
                            setState(() => _searchQuery = query);
                            HapticFeedback.lightImpact();
                          },
                        ),
                        const SizedBox(height: 16),
                        CatalogFilterChips(
                          categories: _categories,
                          selectedCategory: _selectedCategory,
                          onCategorySelected: (category) {
                            setState(() => _selectedCategory = category);
                            HapticFeedback.selectionClick();
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildHeaderBar(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _buildAlgaeGridOrList(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Algae Encyclopedia',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryBlue,
                AppColors.secondaryBlue,
                AppColors.accentGreen,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Icon(
                  Icons.eco,
                  size: 40,
                  color: Colors.white.withOpacity(0.15),
                ),
              ),
              Positioned(
                left: 30,
                top: 30,
                child: Icon(
                  Icons.water_drop,
                  size: 30,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              Positioned(
                right: 60,
                top: 50,
                child: Icon(
                  Icons.bubble_chart,
                  size: 25,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBar() {
    final filteredCount = _filteredAlgae.length;
    final totalCount = algaeData.keys.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search,
                    size: 14,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  filteredCount == totalCount
                      ? '$filteredCount species'
                      : '$filteredCount of $totalCount',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: AppColors.primaryBlue.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: ToggleButtons(
              isSelected: [!_isGridView, _isGridView],
              onPressed: (index) {
                setState(() => _isGridView = index == 1);
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(30),
              selectedColor: Colors.white,
              fillColor: AppColors.primaryBlue,
              color: AppColors.primaryBlue,
              constraints: const BoxConstraints(minWidth: 50, minHeight: 42),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.view_list, size: 18),
                      if (!_isGridView) ...[
                        const SizedBox(width: 6),
                        const Text('List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.grid_view, size: 18),
                      if (_isGridView) ...[
                        const SizedBox(width: 6),
                        const Text('Grid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgaeGridOrList() {
    final filtered = _filteredAlgae;

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.scale(scale: value, child: child),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryBlue.withOpacity(0.1),
                        AppColors.accentGreen.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.search_off,
                    size: 60,
                    color: AppColors.primaryBlue.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No species found',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different search term',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.accentGreen],
                    ),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _selectedCategory = 'All';
                      });
                      HapticFeedback.lightImpact();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 8),
                        Text('Clear Filters'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isGridView) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.78,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final name = filtered[index];
            final data = algaeData[name] as Map<String, dynamic>;
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 30)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: AlgaeCard(
                name: name,
                arabicName: data['arabicName'] as String? ?? '',
                scientificName: data['scientificName'] as String? ?? '$name spp.',
                category: data['category'] as String? ?? 'Unknown',
                isToxic: data['isToxic'] as bool? ?? false,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => AlgaeDetailScreen(algaeName: name),
                      transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
                      transitionDuration: const Duration(milliseconds: 350),
                    ),
                  );
                },
              ),
            );
          },
          childCount: filtered.length,
        ),
      );
    } else {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final name = filtered[index];
            final data = algaeData[name] as Map<String, dynamic>;
            return TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 40)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(30 * (1 - value), 0),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: _buildListCard(name, data),
            );
          },
          childCount: filtered.length,
        ),
      );
    }
  }

  Widget _buildListCard(String name, Map<String, dynamic> data) {
    final isToxic = data['isToxic'] as bool? ?? false;
    final arabicName = data['arabicName'] as String? ?? '';
    final category = data['category'] as String? ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, a1, a2) => AlgaeDetailScreen(algaeName: name),
                transitionsBuilder: (context, a1, a2, child) => FadeTransition(opacity: a1, child: child),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'icon_$name',
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isToxic
                            ? [const Color(0xFFE53935), const Color(0xFFC62828)]
                            : [const Color(0xFF43A047), const Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (isToxic ? Colors.red : Colors.green).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      isToxic ? Icons.warning_rounded : Icons.eco_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (arabicName.isNotEmpty)
                        Text(
                          arabicName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: arabicName.isNotEmpty ? 11 : 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isToxic ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isToxic ? Icons.warning : Icons.check_circle,
                              size: 9,
                              color: isToxic ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                _getShortCategory(category),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isToxic ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.w600,
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
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getShortCategory(String category) {
    if (category.contains('Cyanobacteria')) return 'Cyanobacteria';
    if (category.contains('Dinoflagellate')) return 'Dinoflagellate';
    if (category.contains('Diatom')) return 'Diatom';
    if (category.contains('Unknown')) return 'Algae';
    return category.split(' ').first;
  }
}