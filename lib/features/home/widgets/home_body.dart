/// Home page main content with cards and buttons

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';
import 'package:bioalga/features/catalog/pages/algae_catalog_screen.dart';
import 'package:bioalga/features/home/controllers/home_controller.dart';
import 'package:bioalga/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class HomeBody extends StatelessWidget {
  final HomeController controller;

  const HomeBody({
    super.key,
    required this.controller,
  });

  static final int _totalSpecies = algaeData.keys
      .where((key) => key.toLowerCase() != AppStrings.notAlgaeLower)
      .length;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _FloatingInfoCard(),
          const SizedBox(height: 16),
          _ActionButton(controller: controller),
          const SizedBox(height: 16),
          _EncyclopediaButton(totalSpecies: _totalSpecies),
          _ModelStatus(controller: controller),
        ],
      ),
    );
  }
}

class _FloatingInfoCard extends StatelessWidget {
  const _FloatingInfoCard();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),
              Text(
                AppStrings.scientificAnalysis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${AppStrings.uploadInstructions}\n'
                    '${AppStrings.accurateClassification}\n'
                    '${AppStrings.detailedInfo}\n'
                    '${AppStrings.aiAnalysis}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -25,
          left: 0,
          right: 0,
          child: Center(
            child: Image.asset(
              AppAssets.appLogo,
              width: 150,
              height: 150,
              cacheWidth: 300,
              cacheHeight: 300,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final HomeController controller;

  const _ActionButton({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final bool canClassify =
            controller.isModelReady && !controller.isLoading;

        return PrimaryButton(
          text: controller.isModelReady
              ? AppStrings.chooseImage
              : AppStrings.testingConnection,
          icon: Icons.photo_library,
          onPressed: () {
            if (!canClassify) return;
            controller.pickImageFromGallery();
          },
          color: canClassify ? AppColors.primaryBlue : Colors.grey,
          isLoading: controller.isLoading,
        );
      },
    );
  }
}

class _EncyclopediaButton extends StatelessWidget {
  final int totalSpecies;

  const _EncyclopediaButton({
    required this.totalSpecies,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue,
              AppColors.secondaryBlue,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlgaeCatalogScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.algaeEncyclopedia,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${AppStrings.explore} $totalSpecies ${AppStrings.documentedSpecies}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModelStatus extends StatelessWidget {
  final HomeController controller;

  const _ModelStatus({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.isTestingConnection) {
          return const _StatusMessage(
            color: Colors.orange,
            title: AppStrings.testingConnection,
            subtitle: AppStrings.connectionMayTakeTime,
          );
        }

        if (!controller.isModelReady) {
          return Column(
            children: [
              const _StatusMessage(
                color: Colors.red,
                title: AppStrings.serviceUnavailable,
              ),
              TextButton(
                onPressed: controller.retryConnection,
                child: Text(
                  AppStrings.reconnect,
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final Color color;
  final String title;
  final String? subtitle;

  const _StatusMessage({
    required this.color,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}