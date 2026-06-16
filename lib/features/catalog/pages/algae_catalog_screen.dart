/// Catalog screen displaying all algae species with search and filter
import 'package:bioalga/features/catalog/controllers/catalog_controller.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/catalog_header.dart';
import '../widgets/catalog_body.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = CatalogController();
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
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
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
            const GradientBackground(child: SizedBox.shrink()),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CatalogHeader(totalCount: _controller.totalCount),
                ),
                SliverToBoxAdapter(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: CatalogBody(controller: _controller),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}