/// Home controller for managing state and business logic

import 'dart:io';

import 'package:bioalga/features/results/pages/results_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/utils/utils.dart';

class HomeController extends ChangeNotifier {
  bool isLoading = false;
  bool isModelReady = false;
  bool isTestingConnection = false;

  bool _isInitializing = false;
  BuildContext? _context;

  final MLService _mlService = MLService.instance;

  void attachContext(BuildContext context) {
    _context = context;
  }

  Future<void> initializeModel() async {
    if (_isInitializing || isModelReady) return;

    _isInitializing = true;
    isTestingConnection = true;
    notifyListeners();

    while (!isModelReady) {
      try {
        await _mlService.initModel();
        isModelReady = true;
      } catch (_) {
        isModelReady = false;
        await Future.delayed(const Duration(seconds: 3));
      }

      notifyListeners();
    }

    _isInitializing = false;
    isTestingConnection = false;
    notifyListeners();
  }

  void retryConnection() {
    initializeModel();
  }
  Future<void> pickImageFromGallery() async {
    if (!isModelReady) {
      await initializeModel();

      if (!isModelReady) {
        if (_context != null) {
          AppUtils.showErrorSnackBar(
            _context!,
            ErrorStrings.serviceNotAvailable,
          );
        }
        return;
      }
    }

    isLoading = true;
    notifyListeners();

    try {
      final imageFile = await AppUtils.pickImage(ImageSource.gallery);

      if (imageFile == null) {
        isLoading = false;
        notifyListeners();

        if (_context != null) {
          AppUtils.showErrorSnackBar(
            _context!,
            AppStrings.noImageSelected,
          );
        }
        return;
      }

      final isValid = await _validateImage(imageFile);

      if (!isValid) {
        isLoading = false;
        notifyListeners();

        if (_context != null) {
          AppUtils.showImageTooLargeSnackBar(_context!);
        }
        return;
      }

      await _processImageAndNavigate(imageFile);
    } catch (_) {
      isLoading = false;
      notifyListeners();

      if (_context != null) {
        AppUtils.showErrorSnackBar(
          _context!,
          AppStrings.imageSelectionError,
        );
      }
    }
  }

  Future<bool> _validateImage(File imageFile) async {
    try {
      if (!await imageFile.exists()) return false;

      final fileSize = await imageFile.length();

      return fileSize <= AppSizes.maxFileSize;
    } catch (_) {
      return false;
    }
  }

  Future<void> _processImageAndNavigate(File imageFile) async {
    try {
      final result = await _mlService.classifyImage(imageFile);

      isLoading = false;
      notifyListeners();

      if (result.isValid && _context != null) {
        await AppUtils.navigateTo(
          _context!,
          ResultsPage(
            imageFile: imageFile,
            result: result,
          ),
        );
        return;
      }

      if (_context != null) {
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

  @override
  void dispose() {
    _context = null;
    super.dispose();
  }
}