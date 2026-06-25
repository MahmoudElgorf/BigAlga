/// Results controller for managing state and business logic

import 'dart:io';

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/core/services/api_service.dart';
import 'package:bioalga/core/services/history_service.dart';
import 'package:bioalga/core/services/ml_service.dart';
import 'package:bioalga/core/services/pdf_service.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:bioalga/features/chat_assistant/pages/chat_assistant_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResultsController extends ChangeNotifier {
  final File imageFile;
  final AlgaeResult? preloadedResult;

  AlgaeResult? result;
  bool isLoading;
  String error = '';
  bool isGeneratingPDF = false;

  BuildContext? _context;
  bool _isInitialized = false;
  bool _isDisposed = false;
  bool _isHistorySaved = false;

  ResultsController({
    required this.imageFile,
    this.preloadedResult,
  }) : isLoading = preloadedResult == null;

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

    if (preloadedResult != null) {
      _initializeWithPreloadedResult(preloadedResult!);
      return;
    }

    await _analyzeImage();
  }

  void _initializeWithPreloadedResult(AlgaeResult preloaded) {
    if (_isDisposed) return;

    if (_isNotAlgae(preloaded)) {
      error = 'not_algae';
      result = null;
      isLoading = false;
      _safeNotify();
      return;
    }

    result = preloaded;
    isLoading = false;
    _safeNotify();

    _saveAnalysisToHistory(preloaded);
  }

  Future<void> _analyzeImage() async {
    if (_isDisposed) return;

    isLoading = true;
    _safeNotify();

    try {
      final analyzedResult = await MLService.instance.classifyImage(imageFile);

      if (_isDisposed) return;

      if (_isNotAlgae(analyzedResult)) {
        error = 'not_algae';
        result = null;
        isLoading = false;
        _safeNotify();
        return;
      }

      result = analyzedResult;
      isLoading = false;
      _safeNotify();

      await _saveAnalysisToHistory(analyzedResult);
    } catch (_) {
      if (_isDisposed) return;

      error = 'error';
      result = null;
      isLoading = false;
      _safeNotify();
    }
  }

  bool _isNotAlgae(AlgaeResult r) {
    return r.name.toLowerCase() == 'not_algae' ||
        r.category.toLowerCase() == 'non-algae';
  }

  Future<void> _saveAnalysisToHistory(AlgaeResult r) async {
    if (_isDisposed || _isHistorySaved) return;

    _isHistorySaved = true;

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
    } catch (_) {
      _isHistorySaved = false;
    }
  }

  Future<void> generatePDF() async {
    if (result == null || _isDisposed || isGeneratingPDF) return;

    isGeneratingPDF = true;
    _safeNotify();

    try {
      await PDFService.generateAndSaveReport(
        imageFile: imageFile,
        result: result!,
      );

      if (_context != null && !_isDisposed) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(SuccessStrings.pdfSaved),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (_) {
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
      _safeNotify();
    }
  }

  void openChatAssistant(BuildContext context) {
    if (result == null || _isDisposed) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatAssistantScreen(
          algaeType: result!.name,
          classificationResult: result!.toJson(),
          analysisId: result!.id,
        ),
      ),
    );
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _context = null;
    super.dispose();
  }
}