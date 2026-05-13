// lib/features/catalog/presentation/screens/algae_catalog_screen.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
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
      duration: const Duration(milliseconds: 500),
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
        switch (_selectedCategory) {
          case 'Cyanobacteria':
            if (!category.contains('Cyanobacteria')) return false;
            break;
          case 'Dinoflagellate':
            if (!category.contains('Dinoflagellate')) return false;
            break;
          case 'Diatom':
            if (!category.contains('Diatom')) return false;
            break;
          case 'Safe':
            if (isToxic) return false;
            break;
          case 'Toxic':
            if (!isToxic) return false;
            break;
        }
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

  final Map<String, String> algaeImages = {
    "Anabaena": "assets/images/anabaena.png",
    "Aphanizomenon": "assets/images/aphanizomenon.png",
    "Microcystis": "assets/images/microcystis.png",
    "Nodularia": "assets/images/nodularia.png",
    "Nostoc": "assets/images/nostoc.png",
    "Oscillatoria": "assets/images/oscillatoria.png",
    "Gymnodinium": "assets/images/gymnodinium.png",
    "Karenia": "assets/images/karenia.png",
    "Prorocentrum": "assets/images/prorocentrum.png",
    "Noctiluca": "assets/images/noctiluca.png",
    "Skeletonema": "assets/images/Skeletonema.png",
    "Nontoxic": "assets/images/Nontoxic.png",
  };

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
            const GradientBackground(child: SizedBox.shrink()),
            CustomScrollView(
              slivers: [
                // استخدام الهيدر الموحد بدلاً من SliverAppBar
                SliverToBoxAdapter(
                  child: AppHeader(
                    title: 'Algae Encyclopedia',
                    showBackButton: true,
                    onBackPressed: () {
                      print('Back button pressed');
                      Navigator.pop(context);
                    },
                    subtitle: 'Discover ${algaeData.length} documented species',
                    isToxic: false,
                  ),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
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
          ),
          Container(
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
              isSelected: [!_isGridView, _isGridView],
              onPressed: (index) {
                setState(() => _isGridView = index == 1);
                HapticFeedback.lightImpact();
              },
              borderRadius: BorderRadius.circular(30),
              selectedColor: AppColors.primaryBlue,
              fillColor: Colors.transparent,
              color: Colors.grey[600],
              constraints: const BoxConstraints(minWidth: 50, minHeight: 40),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.view_list, size: 18, color: !_isGridView ? AppColors.primaryBlue : Colors.grey[600]),
                      if (!_isGridView) ...[
                        const SizedBox(width: 4),
                        const Text('List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      Icon(Icons.grid_view, size: 18, color: _isGridView ? AppColors.primaryBlue : Colors.grey[600]),
                      if (_isGridView) ...[
                        const SizedBox(width: 4),
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
                child: Icon(
                  Icons.search_off,
                  size: 50,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No results found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filter',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isGridView) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final name = filtered[index];
            final data = algaeData[name] as Map<String, dynamic>;
            final imagePath = algaeImages[name] ?? 'assets/icons/default.png';
            return AlgaeCard(
              name: name,
              scientificName: data['scientificName'] as String? ?? '$name spp.',
              category: data['category'] as String? ?? 'Unknown',
              isToxic: data['isToxic'] as bool? ?? false,
              imagePath: imagePath,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AlgaeDetailScreen(algaeName: name),
                  ),
                );
              },
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
            final imagePath = algaeImages[name] ?? 'assets/icons/default.png';
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AlgaeCard(
                name: name,
                scientificName: data['scientificName'] as String? ?? '$name spp.',
                category: data['category'] as String? ?? 'Unknown',
                isToxic: data['isToxic'] as bool? ?? false,
                imagePath: imagePath,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AlgaeDetailScreen(algaeName: name),
                    ),
                  );
                },
              ),
            );
          },
          childCount: filtered.length,
        ),
      );
    }
  }
}