import 'dart:io';

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/shared/widgets/app_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../data/models/algae_model.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../widgets/algae_info.dart';
import '../widgets/result_card.dart';
import 'chat_assistant_screen.dart';

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
  AlgaeResult? _result;
  bool _isLoading = true;
  String _error = '';
  bool _isGeneratingPDF = false;

  // Threshold for acceptable confidence (90%)
  static const double confidenceThreshold = 0.90;

  @override
  void initState() {
    super.initState();
    _initApiService();

    if (widget.result != null) {
      _initializeWithPreloadedResult();
    } else {
      _analyzeImage();
    }
  }

  Future<void> _initApiService() async {
    try {
      await ApiService.initialize();
    } catch (e) {
      debugPrint('API service initialization failed: $e');
    }
  }

  void _initializeWithPreloadedResult() {
    final normalizedResult = _normalizeResultConfidence(widget.result!);

    // Check confidence threshold - prevent saving if below 90%
    if (!_isConfidenceAcceptable(normalizedResult.confidence)) {
      setState(() {
        _error = _buildLowConfidenceMessage(normalizedResult.confidence);
        _isLoading = false;
      });
      return;  // Don't save to history
    }

    setState(() {
      _result = normalizedResult;
      _isLoading = false;
    });

    _saveAnalysisToHistory(normalizedResult);
  }

  Future<void> _analyzeImage() async {
    try {
      final mlService = MLService();
      final result = await mlService.classifyImage(widget.imageFile);
      final normalizedResult = _normalizeResultConfidence(result);

      if (!mounted) return;

      // Check confidence threshold - prevent saving if below 90%
      if (!_isConfidenceAcceptable(normalizedResult.confidence)) {
        setState(() {
          _error = _buildLowConfidenceMessage(normalizedResult.confidence);
          _isLoading = false;
        });
        return;  // Don't save to history
      }

      setState(() {
        _result = normalizedResult;
        _isLoading = false;
      });

      await _saveAnalysisToHistory(normalizedResult);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = '${AppStrings.failedToAnalyze}: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  bool _isConfidenceAcceptable(double confidence) {
    return confidence >= confidenceThreshold;
  }

  String _buildLowConfidenceMessage(double confidence) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    return 'Low confidence detection. The system could not identify the algae with sufficient certainty. Please capture a clearer image with better lighting, proper focus, and ensure the algae is centered in the frame.';
  }

  double _getNormalizedConfidence(double originalConfidence) {
    final confidence = originalConfidence.clamp(0.0, 1.0).toDouble();

    if (confidence >= 0.98) {
      return 0.93 + ((confidence - 0.98) / 0.02) * 0.04;
    }

    if (confidence >= 0.90) {
      return 0.84 + ((confidence - 0.90) / 0.08) * 0.09;
    }

    if (confidence >= 0.75) {
      return 0.70 + ((confidence - 0.75) / 0.15) * 0.14;
    }

    if (confidence >= 0.55) {
      return 0.52 + ((confidence - 0.55) / 0.20) * 0.18;
    }

    return confidence.clamp(0.05, 0.52).toDouble();
  }

  String _getConfidenceLevel(double confidence) {
    if (confidence >= 0.90) return 'Very High';
    if (confidence >= 0.80) return 'High';
    if (confidence >= 0.65) return 'Moderate';
    if (confidence >= 0.50) return 'Low';
    return 'Very Low';
  }

  AlgaeResult _normalizeResultConfidence(AlgaeResult original) {
    final normalizedConfidence = _getNormalizedConfidence(original.confidence);

    return AlgaeResult(
      id: original.id,
      name: original.name,
      scientificName: original.scientificName,
      confidence: normalizedConfidence,
      confidenceLevel: _getConfidenceLevel(normalizedConfidence),
      isToxic: original.isToxic,
      toxicityWarning: original.toxicityWarning,
      scientificWarning: original.scientificWarning,
      category: original.category,
      potentialToxins: original.potentialToxins,
      co2PerKg: original.co2PerKg,
      sellable: original.sellable,
      benefits: original.benefits,
      uses: original.uses,
      allPredictions: original.allPredictions,
      modelInfo: original.modelInfo,
      dateTime: original.dateTime,
    );
  }

  Future<void> _saveAnalysisToHistory(AlgaeResult result) async {
    try {
      final now = DateTime.now();

      final analysisData = {
        'id': HistoryService.generateId(),
        'date': DateFormat('yyyy-MM-dd').format(now),
        'time': DateFormat('HH:mm').format(now),
        'algaeType': result.name,
        'scientificName': result.scientificName,
        'confidence': result.confidence,
        'confidenceLevel': result.confidenceLevel,
        'isToxic': result.isToxic,
        'toxicityWarning': result.toxicityWarning,
        'scientificWarning': result.scientificWarning,
        'category': result.category,
        'potentialToxins': result.potentialToxins,
        'co2PerKg': result.co2PerKg,
        'sellable': result.sellable,
        'imagePath': widget.imageFile.path,
        'benefits': result.benefits,
        'uses': result.uses,
      };

      await HistoryService.saveAnalysis(analysisData);
    } catch (e) {
      debugPrint('Failed to save analysis history: $e');
    }
  }

  Future<void> _generatePDF() async {
    if (_result == null) return;

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      await PDFService.generateAndSaveReport(
        imageFile: widget.imageFile,
        result: _result!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SuccessStrings.pdfSaved),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      debugPrint('PDF generation failed: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorStrings.pdfSaveFailed),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  void _openChatAssistant() {
    if (_result == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatAssistantScreen(
          algaeType: _result!.name,
          classificationResult: _result!.toJson(),
          analysisId: _result?.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'Analysis Results',
                isToxic: _result?.isToxic ?? false,
                showBackButton: true,
              ),
            ),
            SliverFillRemaining(
              child: _isLoading
                  ? _buildLoading()
                  : _error.isNotEmpty
                  ? _buildError()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return LoadingIndicator(message: AppStrings.analyzing);
  }

  Widget _buildError() {
    // Check if this is a low confidence error
    final isLowConfidenceError = _error.contains('Low confidence detection');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isLowConfidenceError
                    ? AppColors.warningOrange.withOpacity(0.1)
                    : AppColors.errorRed.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLowConfidenceError
                    ? Icons.warning_amber_rounded
                    : Icons.error_outline,
                size: 50,
                color: isLowConfidenceError
                    ? AppColors.warningOrange
                    : AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isLowConfidenceError
                  ? 'Insufficient Confidence'
                  : 'Analysis Failed',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isLowConfidenceError
                    ? AppColors.warningOrange
                    : AppColors.errorRed,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isLowConfidenceError
                    ? AppColors.warningOrange.withOpacity(0.05)
                    : AppColors.errorRed.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isLowConfidenceError
                      ? AppColors.warningOrange.withOpacity(0.3)
                      : AppColors.errorRed.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  if (isLowConfidenceError) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Tips for better results:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warningOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTipItem(
                      Icons.high_quality,
                      'Use a high-resolution image',
                    ),
                    _buildTipItem(
                      Icons.light_mode,
                      'Ensure adequate lighting',
                    ),
                    _buildTipItem(
                      Icons.center_focus_strong,
                      'Center the algae in the frame',
                    ),
                    _buildTipItem(
                      Icons.photo_camera,
                      'Avoid blurry or out-of-focus images',
                    ),
                    _buildTipItem(
                      Icons.crop_free,
                      'Capture the entire specimen',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(AppStrings.backToHome),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.accentGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_result == null) {
      return _buildError();
    }

    final result = _result!;
    final normalizedConfidence = _getNormalizedConfidence(result.confidence);
    final isConfident = normalizedConfidence >= 0.70;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildImagePreview(),
                const SizedBox(height: 30),
                ResultCard(
                  name: result.name,
                  scientificName: result.scientificName,
                  confidence: normalizedConfidence,
                  confidenceLevel: result.confidenceLevel,
                  isToxic: result.isToxic,
                  toxicityWarning: result.toxicityWarning,
                ),
                const SizedBox(height: 20),
                AlgaeInfo(
                  algaeType: result.name,
                  fullResult: result,
                ),
                const SizedBox(height: 20),
                _buildConfidenceIndicator(
                  isConfident,
                  normalizedConfidence,
                ),
                const SizedBox(height: 20),
                if (result.sellable.isNotEmpty && result.sellable != 'Unknown')
                  _buildSellableIndicator(result.sellable),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildConfidenceIndicator(bool isConfident, double confidence) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    final indicatorColor =
    isConfident ? AppColors.successGreen : AppColors.warningOrange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: indicatorColor,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: indicatorColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Confidence Level',
                style: TextStyle(
                  color: indicatorColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                percentage,
                style: TextStyle(
                  color: AppColors.darkText.withOpacity(0.9),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '%',
                style: TextStyle(
                  color: AppColors.darkText.withOpacity(0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isConfident
                ? 'The result has a sufficient confidence level.'
                : 'Verification with additional samples is recommended.',
            style: TextStyle(
              color: AppColors.darkText.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellableIndicator(String sellable) {
    final normalizedSellable = sellable.toLowerCase();

    late final Color color;
    late final IconData icon;
    late final String message;

    if (normalizedSellable.startsWith('not') ||
        normalizedSellable.contains('not suitable') ||
        normalizedSellable.contains('not recommended')) {
      color = AppColors.errorRed;
      icon = Icons.cancel_outlined;
      message = 'This species is not recommended for commercial use.';
    } else if (normalizedSellable.startsWith('suitable') ||
        normalizedSellable.startsWith('yes')) {
      color = AppColors.successGreen;
      icon = Icons.check_circle_outline;
      message = 'This species may be suitable for controlled commercial use.';
    } else {
      color = AppColors.warningOrange;
      icon = Icons.warning_amber_outlined;
      message = 'Commercial use is conditional and requires verification.';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrintButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGeneratingPDF ? null : _generatePDF,
        icon: _isGeneratingPDF
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.textWhite,
            ),
          ),
        )
            : const Icon(
          Icons.save_alt,
          color: AppColors.textWhite,
        ),
        label: Text(
          _isGeneratingPDF ? AppStrings.savingPDF : AppStrings.savePDFReport,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: AppColors.textWhite.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildPrintButton(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildAnalyzeNewButton()),
              const SizedBox(width: 12),
              Expanded(child: _buildAIAssistantButton()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeNewButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightGreen,
          side: BorderSide(color: AppColors.lightGreen),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back, size: 18),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Analyze Another Image',
                style: TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssistantButton() {
    return OutlinedButton.icon(
      onPressed: _openChatAssistant,
      icon: const Icon(
        Icons.assistant,
        color: AppColors.primaryGreen,
        size: 20,
      ),
      label: const Text(
        'Open Assistant',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryGreen,
        side: BorderSide(
          color: AppColors.primaryGreen,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.file(
              widget.imageFile,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey[600],
                    size: 50,
                  ),
                );
              },
            ),
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Submitted Image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}