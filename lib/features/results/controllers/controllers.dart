/// Results controller for managing state and business logic
import 'dart:io';
import 'package:bioalga/features/chat_assistant_screen/pages/chat_assistant_screen.dart';
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
    try {
      await ApiService.initialize();
    } catch (e) {}

    if (preloadedResult != null) {
      _initializeWithPreloadedResult();
    } else {
      await _analyzeImage();
    }
  }

  void _initializeWithPreloadedResult() {
    final r = preloadedResult!;
    if (r.name.toLowerCase() == AppStrings.notAlgaeLower) {
      error = 'not_algae';
      isLoading = false;
      notifyListeners();
      return;
    }
    result = r;
    isLoading = false;
    notifyListeners();
    _saveAnalysisToHistory(r);
  }

  Future<void> _analyzeImage() async {
    try {
      final r = await MLService().classifyImage(imageFile);
      if (r.name.toLowerCase() == AppStrings.notAlgaeLower) {
        error = 'not_algae';
        isLoading = false;
        notifyListeners();
        return;
      }
      result = r;
      isLoading = false;
      notifyListeners();
      await _saveAnalysisToHistory(r);
    } catch (e) {
      error = 'error';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAnalysisToHistory(AlgaeResult r) async {
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
    if (result == null) return;
    isGeneratingPDF = true;
    notifyListeners();
    try {
      await PDFService.generateAndSaveReport(imageFile: imageFile, result: result!);
      if (_context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(SuccessStrings.pdfSaved),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (_context != null) {
        ScaffoldMessenger.of(_context!).showSnackBar(
          SnackBar(
            content: Text(ErrorStrings.pdfSaveFailed),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      isGeneratingPDF = false;
      notifyListeners();
    }
  }

  void openChatAssistant(BuildContext context) {
    if (result == null) return;
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

  @override
  void dispose() {
    _context = null;
    super.dispose();
  }
}