import 'dart:io';
import 'package:bioalga/core/constants/constants.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/history_service.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/gradient_background.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../../../../data/models/algae_model.dart';
import '../widgets/algae_info.dart';
import '../widgets/result_card.dart';

class ResultsPage extends StatefulWidget {
  final File imageFile;
  final AlgaeResult? result;

  const ResultsPage({
    Key? key,
    required this.imageFile,
    this.result,
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  AlgaeResult? _result;
  bool _isLoading = true;
  String _error = '';
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();

    if (widget.result != null) {
      _initializeWithPreloadedResult();
    } else {
      _analyzeImage();
    }
  }

  void _initializeWithPreloadedResult() {
    setState(() {
      _result = widget.result;
      _isLoading = false;
    });

    if (_result != null) {
      _saveAnalysisToHistory(_result!);
    }
  }

  Future<void> _analyzeImage() async {
    try {
      final mlService = MLService();
      final result = await mlService.classifyImage(widget.imageFile);

      setState(() {
        _result = result;
        _isLoading = false;
      });

      await _saveAnalysisToHistory(result);

    } catch (e) {
      setState(() {
        _error = '${AppStrings.failedToAnalyze}: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAnalysisToHistory(AlgaeResult result) async {
    try {
      final analysisData = {
        'id': HistoryService.generateId(),
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'time': DateFormat('HH:mm').format(DateTime.now()),
        'algaeType': result.name,
        'scientificName': result.scientificName,
        'confidence': result.confidence,
        'confidenceLevel': result.confidenceLevel,
        'isToxic': result.isToxic,
        'imagePath': widget.imageFile.path,
        'benefits': result.benefits,
        'uses': result.uses,
      };

      await HistoryService.saveAnalysis(analysisData);

    } catch (e) {
      print('Error saving analysis to history: $e');
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(SuccessStrings.pdfSaved),
          backgroundColor: AppColors.successGreen,
        ),
      );
    } catch (e) {
      print('❌ Error generating PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorStrings.pdfSaveFailed),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.resultsTitle,
        actions: _result != null ? [] : null,
      ),
      body: GradientBackground(
        child: _isLoading
            ? _buildLoading()
            : _error.isNotEmpty
            ? _buildError()
            : _buildResults(),
      ),
    );
  }

  Widget _buildLoading() {
    return LoadingIndicator(message: AppStrings.analyzing);
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 20),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text(ButtonStrings.retry),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Navigator.popUntil(
                      context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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

  Widget _buildResults() {
    if (_result == null) {
      return _buildError();
    }

    final result = _result!;
    final isConfident = result.confidence >= 0.7;

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
                  confidence: result.confidence,
                  confidenceLevel: result.confidenceLevel,
                  isToxic: result.isToxic,
                  toxicityWarning: result.toxicityWarning,
                ),
                const SizedBox(height: 20),

                AlgaeInfo(
                  algaeType: result.name,
                  benefits: result.benefits,
                  uses: result.uses,
                ),
                const SizedBox(height: 20),

                _buildConfidenceIndicator(isConfident, result.confidence),
                const SizedBox(height: 20),

              ],
            ),
          ),
        ),

        _buildActionButtons(),
      ],
    );
  }

  Widget _buildConfidenceIndicator(bool isConfident, double confidence) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfident
            ? AppColors.successGreen.withOpacity(0.1)
            : AppColors.warningOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfident ? AppColors.successGreen : AppColors.warningOrange,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isConfident ? Icons.verified : Icons.warning_amber,
                color: isConfident ? AppColors.successGreen : AppColors.warningOrange,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                isConfident ? 'High Confidence Result' : 'Medium Confidence Result',
                style: TextStyle(
                  color: isConfident ? AppColors.successGreen : AppColors.warningOrange,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence Level: ${(confidence * 100).toStringAsFixed(1)}%',
            style: TextStyle(
              color: AppColors.darkText.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isConfident
                ? '✓ Result is reliable and can be trusted'
                : '️Consider verifying with additional samples',
            style: TextStyle(
              color: AppColors.darkText.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.lightGreen,
              side: BorderSide(color: AppColors.lightGreen),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_back, size: 20),
                SizedBox(width: 8),
                Text(
                  AppStrings.analyzeNewImage,
                  style: TextStyle(fontSize: 16),
                ),
              ],
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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
          ),
        )
            : const Icon(Icons.save_alt, color: AppColors.textWhite),
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
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
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
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.originalImage,
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