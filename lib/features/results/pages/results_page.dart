/// Results page displaying algae classification results with PDF and AI assistant

import 'dart:io';

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';
import 'package:bioalga/features/results/controllers/controllers.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:bioalga/shared/widgets/gradient_background.dart';
import 'package:bioalga/shared/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';

import '../widgets/algae_info.dart';
import '../widgets/result_buttons.dart';
import '../widgets/result_card.dart';
import '../widgets/result_error.dart';
import '../widgets/result_image.dart';
import '../widgets/result_indicators.dart';

class ResultsPage extends StatefulWidget {
  final File imageFile;
  final AlgaeResult? result;

  const ResultsPage({
    super.key,
    required this.imageFile,
    this.result,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  late final ResultsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ResultsController(
      imageFile: widget.imageFile,
      preloadedResult: widget.result,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _controller.attachContext(context);
      _controller.init();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final result = _controller.result;
            final isLoadingWithoutResult =
                _controller.isLoading && result == null;

            return Column(
              children: [
                AppHeader(
                  title: AppStrings.resultsTitle,
                  isToxic: result?.isToxic ?? false,
                  showBackButton: true,
                ),
                Expanded(
                  child: _buildContent(
                    context,
                    result,
                    isLoadingWithoutResult,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      AlgaeResult? result,
      bool isLoadingWithoutResult,
      ) {
    if (isLoadingWithoutResult) {
      return const LoadingIndicator(
        message: AppStrings.analyzing,
      );
    }

    if (_controller.error == 'not_algae') {
      return const ResultNotAlgaeError();
    }

    if (_controller.error == 'error') {
      return const ResultGenericError();
    }

    if (result == null) {
      return const SizedBox.shrink();
    }

    return _ResultsContent(
      imageFile: widget.imageFile,
      result: result,
      controller: _controller,
    );
  }
}

class _ResultsContent extends StatelessWidget {
  final File imageFile;
  final AlgaeResult result;
  final ResultsController controller;

  const _ResultsContent({
    required this.imageFile,
    required this.result,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ResultImagePreview(imageFile: imageFile),
            const SizedBox(height: 20),

            ResultCard(
              name: result.name,
              scientificName: result.scientificName,
              confidence: result.confidence,
              confidenceLevel: controller.getConfidenceLevel(
                result.confidence,
              ),
              isToxic: result.isToxic,
              toxicityWarning: result.toxicityWarning,
            ),

            const SizedBox(height: 16),

            AlgaeInfo(
              algaeType: result.name,
              fullResult: result,
            ),

            const SizedBox(height: 16),

            ConfidenceIndicator(
              confidence: result.confidence,
            ),

            if (result.sellable.isNotEmpty &&
                result.sellable != AppStrings.unknown) ...[
              const SizedBox(height: 16),
              SellableIndicator(
                sellable: result.sellable,
              ),
            ],

            const SizedBox(height: 16),

            ListenableBuilder(
              listenable: controller,
              builder: (context, _) {
                return PdfButton(
                  isLoading: controller.isGeneratingPDF,
                  onPressed: controller.generatePDF,
                );
              },
            ),

            const SizedBox(height: 12),

            AiAssistantButton(
              onPressed: () => controller.openChatAssistant(context),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}