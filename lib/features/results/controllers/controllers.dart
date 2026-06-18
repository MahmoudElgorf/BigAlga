/// Results controller for managing state and business logic
import 'dart:io';
import 'package:bioalga/features/chat_assistant/pages/chat_assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../data/models/algae_model.dart';

class ResultsController extends ChangeNotifier {
  final File imageFile;
  final AlgaeResult? preloadedResult;

  AlgaeResult? result;
  bool isLoading = true;
  String error = '';
  bool isGeneratingPDF = false;
  BuildContext? _context;
  bool _isInitialized = false;
  bool _isDisposed = false;

  ResultsController({required this.imageFile, this.preloadedResult});

  void attachContext(BuildContext context) {
    _context = context;
  }

  String getConfidenceLevel(double confidence) {
    if (confidence >= 0.90) return AppStrings.veryHigh;
    if (confidence >= 0.80) return AppStrings.highConfidence;
    if (confidence >= 0.65) return AppStrings.moderate;
    if (confidence >= 0.50) return AppStrings.lowConfidence;
    return AppStrings.veryLow;
  }

  Future<void> init() async {
    if (_isInitialized || _isDisposed) return;
    _isInitialized = true;

    try {
      await ApiService.initialize();
    } catch (e) {}

    if (_isDisposed) return;

    if (preloadedResult != null) {
      _initializeWithPreloadedResult();
    } else {
      await _analyzeImage();
    }
  }

  void _initializeWithPreloadedResult() {
    if (_isDisposed) return;
    final r = preloadedResult!;
    if (r.name.toLowerCase() == 'not_algae' ||
        r.category.toLowerCase() == 'non-algae') {
      error = 'not_algae';
      isLoading = false;
      if (!_isDisposed) notifyListeners();
      return;
    }
    result = r;
    isLoading = false;
    if (!_isDisposed) notifyListeners();
    _saveAnalysisToHistory(r);
  }

  Future<void> _analyzeImage() async {
    if (_isDisposed) return;
    try {
      final r = await MLService().classifyImage(imageFile);

      if (_isDisposed) return;

      if (r.name.toLowerCase() == 'not_algae' ||
          r.category.toLowerCase() == 'non-algae') {
        error = 'not_algae';
        isLoading = false;
        if (!_isDisposed) notifyListeners();
        return;
      }

      result = r;
      isLoading = false;
      if (!_isDisposed) notifyListeners();
      await _saveAnalysisToHistory(r);
    } catch (e) {
      if (_isDisposed) return;
      error = 'error';
      isLoading = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<void> _saveAnalysisToHistory(AlgaeResult r) async {
    if (_isDisposed) return;
    try {
      final now = DateTime.now();
      final data = {
        'id': HistoryService.generateId(),
        'date': DateFormat('yyyy-MM-dd').format(now),
        'time': DateFormat('HH:mm').format(now),
        'algaeType': r.name,
        'scientificName': r.scientificName,
        'confidence': r.confidence,
        'confidenceLevel': getConfidenceLevel(r.confidence),
        'isToxic': r.isToxic,
        'toxicityWarning': r.toxicityWarning,
        'scientificWarning': r.scientificWarning,
        'category': r.category,
        'potentialToxins': r.potentialToxins,
        'co2PerKg': r.co2PerKg,
        'sellable': r.sellable,
        'imagePath': imageFile.path,
        'benefits': r.benefits,
        'uses': r.uses,
      };
      await HistoryService.saveAnalysis(data);
    } catch (e) {}
  }

  Future<void> generatePDF() async {
    if (result == null || _isDisposed) return;
    isGeneratingPDF = true;
    if (!_isDisposed) notifyListeners();
    try {
      await PDFService.generateAndSaveReport(imageFile: imageFile, result: result!);
      if (_context != null && !_isDisposed) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(SuccessStrings.pdfSaved),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (_context != null && !_isDisposed) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(ErrorStrings.pdfSaveFailed),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      isGeneratingPDF = false;
      if (!_isDisposed) notifyListeners();
    }
  }

  void openChatAssistant(BuildContext context) {
    if (result == null || _isDisposed) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatAssistantScreen(
          algaeType: result!.name,
          classificationResult: result!.toJson(),
          analysisId: result?.id,
        ),
      ),
    );
  }

  void reset() {
    _isDisposed = true;
    isLoading = false;
    result = null;
    error = '';
    isGeneratingPDF = false;
  }

  @override
  void dispose() {
    reset();
    _context = null;
    super.dispose();
  }
}