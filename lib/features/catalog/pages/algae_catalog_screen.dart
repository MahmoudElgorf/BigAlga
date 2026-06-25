/// Catalog screen displaying all algae species with search and filter
import 'package:bioalga/features/catalog/controllers/catalog_controller.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/catalog_body.dart';
import '../widgets/catalog_header.dart';

class AlgaeCatalogScreen extends StatefulWidget {
  const AlgaeCatalogScreen({super.key});

  @override
  State<AlgaeCatalogScreen> createState() => _AlgaeCatalogScreenState();
}

class _AlgaeCatalogScreenState extends State<AlgaeCatalogScreen>
    with SingleTickerProviderStateMixin {
  late final CatalogController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  static const _systemUiOverlayStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  );

  @override
  void initState() {
    super.initState();

    _controller = CatalogController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: _systemUiOverlayStyle,
      child: Scaffold(
        body: Stack(
          children: [
            GradientBackground(child: SizedBox.expand()),
            _CatalogContent(),
          ],
        ),
      ),
    );
  }
}

class _CatalogContent extends StatefulWidget {
  const _CatalogContent();

  @override
  State<_CatalogContent> createState() => _CatalogContentState();
}

class _CatalogContentState extends State<_CatalogContent>
    with SingleTickerProviderStateMixin {
  late final CatalogController _controller;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = CatalogController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: CatalogHeader(
              totalCount: _controller.totalCount,
            ),
          ),
          CatalogBody(controller: _controller),
          const SliverToBoxAdapter(
            child: SizedBox(height: 40),
          ),
        ],
      ),
    );
  }
}