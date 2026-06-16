/// Results page displaying algae classification results with PDF and AI assistant
import 'dart:io';
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';
import 'package:bioalga/features/results/controllers/controllers.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/result_error.dart';
import '../widgets/result_indicators.dart';
import '../widgets/result_buttons.dart';
import '../widgets/result_image.dart';
import '../widgets/algae_info.dart';
import '../widgets/result_card.dart';

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
  late ResultsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ResultsController(
      imageFile: widget.imageFile,
      preloadedResult: widget.result,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
            return Column(
              children: [
                AppHeader(
                  title: AppStrings.resultsTitle,
                  isToxic: _controller.result?.isToxic ?? false,
                  showBackButton: true,
                ),
                Expanded(
                  child: _controller.isLoading
                      ? LoadingIndicator(message: AppStrings.analyzing)
                      : _controller.error == 'not_algae'
                      ? const ResultNotAlgaeError()
                      : _controller.error == 'error'
                      ? const ResultGenericError()
                      : _buildResults(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    final r = _controller.result!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ResultImagePreview(imageFile: widget.imageFile),
          const SizedBox(height: 20),
          ResultCard(
            name: r.name,
            scientificName: r.scientificName,
            confidence: r.confidence,
            confidenceLevel: _controller.getConfidenceLevel(r.confidence),
            isToxic: r.isToxic,
            toxicityWarning: r.toxicityWarning,
          ),
          const SizedBox(height: 16),
          AlgaeInfo(algaeType: r.name, fullResult: r),
          const SizedBox(height: 16),
          ConfidenceIndicator(confidence: r.confidence),
          const SizedBox(height: 16),
          if (r.sellable.isNotEmpty && r.sellable != AppStrings.unknown)
            SellableIndicator(sellable: r.sellable),
          const SizedBox(height: 16),
          PdfButton(
            isLoading: _controller.isGeneratingPDF,
            onPressed: _controller.generatePDF,
          ),
          const SizedBox(height: 12),
          AiAssistantButton(
            onPressed: () => _controller.openChatAssistant(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}