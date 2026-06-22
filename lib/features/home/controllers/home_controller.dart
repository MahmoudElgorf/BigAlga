/// Home controller for managing state and business logic
import 'dart:io';
import 'package:bioalga/features/results/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/constants/constants.dart';

class HomeController extends ChangeNotifier {
  bool isLoading = false;
  bool isModelReady = false;
  bool isTestingConnection = false;
  BuildContext? _context;

  final MLService _mlService = MLService();

  void attachContext(BuildContext context) {
    _context = context;
  }

  Future<void> checkModelStatus() async {
    try {
      final isHealthy = await _mlService.testConnection();
      isModelReady = isHealthy;
      notifyListeners();
    } catch (e) {
      isModelReady = false;
      notifyListeners();
    }
  }

  Future<void> initializeModel() async {
    try {
      isTestingConnection = true;
      notifyListeners();

      final isHealthy = await _mlService.testConnection();
      isModelReady = isHealthy;
      isTestingConnection = false;
      notifyListeners();
    } catch (e) {
      try {
        await _mlService.initModel();
        isModelReady = true;
      } catch (e2) {
        isModelReady = false;
        if (_context != null) {
          AppUtils.showErrorSnackBar(
            _context!,
            ErrorStrings.unableToConnectService,
          );
        }
      }
      isTestingConnection = false;
      notifyListeners();
    }
  }

  Future<void> pickImageFromGallery() async {
    if (!isModelReady) {
      await initializeModel();
      if (!isModelReady) {
        AppUtils.showErrorSnackBar(
          _context!,
          ErrorStrings.serviceNotAvailable,
        );
        return;
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final imageFile = await AppUtils.pickImage(ImageSource.gallery);

      if (imageFile != null) {
        final isValid = await _validateImage(imageFile);
        if (isValid) {
          await _processImageAndNavigate(imageFile);
        } else {
          AppUtils.showImageTooLargeSnackBar(_context!);
          isLoading = false;
          notifyListeners();
        }
      } else {
        if (_context != null) {
          AppUtils.showErrorSnackBar(_context!, AppStrings.noImageSelected);
        }
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      if (_context != null) {
        AppUtils.showErrorSnackBar(
          _context!,
          AppStrings.imageSelectionError,
        );
      }
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _validateImage(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      if (fileSize > AppSizes.maxFileSize) return false;
      if (!await imageFile.exists()) return false;
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _processImageAndNavigate(File imageFile) async {
    try {
      final isConnected = await _mlService.testConnection();

      if (!isConnected) {
        if (_context != null) {
          await AppUtils.showConnectionRetryDialog(
            _context!,
            title: ErrorStrings.apiConnectionError,
            message: ErrorStrings.unableToConnectToAnalysisServer,
            onRetry: () => _processImageAndNavigate(imageFile),
            onCancel: () {
              isLoading = false;
              notifyListeners();
            },
          );
        }
        return;
      }

      final result = await _mlService.classifyImage(imageFile);

      isLoading = false;
      notifyListeners();

      if (result.isValid && _context != null) {
        await AppUtils.navigateTo(
          _context!,
          ResultsPage(imageFile: imageFile, result: result),
        );
      } else if (_context != null) {
        AppUtils.showErrorSnackBar(
          _context!,
          AppStrings.failedToAnalyze,
        );
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (_context != null) {
        AppUtils.showApiErrorSnackBar(
          _context!,
          '${AppStrings.analysisError}: ${e.toString()}',
        );
      }
    }
  }

  void retryConnection() {
    initializeModel();
  }

  @override
  void dispose() {
    _context = null;
    super.dispose();
  }
}