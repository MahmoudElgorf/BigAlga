/// History drawer displaying analysis history with PDF generation and details
import 'dart:io';
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/results/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:bioalga/core/services/pdf_service.dart';
import 'package:bioalga/core/services/history_service.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:image_picker/image_picker.dart';

class HistoryDrawer extends StatefulWidget {
  const HistoryDrawer({super.key});

  @override
  _HistoryDrawerState createState() => _HistoryDrawerState();
}

class _HistoryDrawerState extends State<HistoryDrawer> {
  List<Map<String, dynamic>> _analysisHistory = [];
  bool _isLoading = true;
  bool _isPickingImage = false;

  static const Map<String, String> _algaeImages = {
    'Anabaena': 'assets/images/anabaena.png',
    'Aphanizomenon': 'assets/images/aphanizomenon.png',
    'Microcystis': 'assets/images/microcystis.png',
    'Nodularia': 'assets/images/nodularia.png',
    'Nostoc': 'assets/images/nostoc.png',
    'Oscillatoria': 'assets/images/oscillatoria.png',
    'Gymnodinium': 'assets/images/gymnodinium.png',
    'Karenia': 'assets/images/karenia.png',
    'Prorocentrum': 'assets/images/prorocentrum.png',
    'Noctiluca': 'assets/images/noctiluca.png',
    'Skeletonema': 'assets/images/Skeletonema.png',
    'Nontoxic': 'assets/images/Nontoxic.png',
  };

  String _getAlgaeImagePath(String algaeType) {
    if (algaeType.toLowerCase() == AppStrings.nontoxicLower) {
      return 'nontoxic_icon';
    }
    if (_algaeImages.containsKey(algaeType)) {
      return _algaeImages[algaeType]!;
    }
    return AppAssets.appLogo;
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getAnalysisHistory();
    setState(() {
      _analysisHistory = history;
      _isLoading = false;
    });
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.pop(context);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              imageFile: File(image.path),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(ErrorStrings.imagePickError, AppColors.errorRed);
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmClear),
        content: const Text(AppStrings.cannotUndo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(ButtonStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              ButtonStrings.delete,
              style: TextStyle(color: AppColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.clearAllHistory();
      await _loadHistory();
      _showSnackBar(AppStrings.historyCleared, AppColors.successGreen);
    }
  }

  Future<void> _generatePDF(Map<String, dynamic> analysis) async {
    try {
      final algaeResult = _createAlgaeResultFromHistory(analysis);
      await PDFService.generateAndSaveReport(
        imageFile: File(analysis['imagePath']),
        result: algaeResult,
      );
      _showSnackBar(AppStrings.pdfSavedSuccessfully, AppColors.successGreen);
    } catch (e) {
      _showSnackBar(ErrorStrings.pdfSaveFailed, AppColors.errorRed);
    }
  }

  AlgaeResult _createAlgaeResultFromHistory(Map<String, dynamic> analysis) {
    final name = analysis['algaeType'] ?? AppStrings.unknown;
    final scientificName = analysis['scientificName'] ?? '$name spp.';
    final confidence = (analysis['confidence'] is double
        ? analysis['confidence']
        : double.parse(analysis['confidence'].toString()));
    final confidenceLevel = analysis['confidenceLevel'] ?? AppStrings.medium;
    final benefits = analysis['benefits'] is List<String>
        ? analysis['benefits']
        : (analysis['benefits'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final uses = analysis['uses'] is List<String>
        ? analysis['uses']
        : (analysis['uses'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final isToxic = analysis['isToxic'] ?? false;
    final toxicityWarning = analysis['toxicityWarning'] ??
        (isToxic ? AppStrings.handleWithCare : AppStrings.safe);
    final scientificWarning = analysis['scientificWarning'] ??
        AppStrings.defaultScientificWarning;
    final category = analysis['category'] ??
        (name == 'Skeletonema' ? AppStrings.diatom :
        name == 'Noctiluca' ? 'Dinoflagellate (heterotrophic)' :
        'Cyanobacteria / Dinoflagellate');
    final potentialToxins = analysis['potentialToxins'] is List<String>
        ? analysis['potentialToxins']
        : (analysis['potentialToxins'] as List?)?.map((e) => e.toString()).toList() ??
        _getDefaultPotentialToxins(name);
    final co2PerKg = (analysis['co2PerKg'] ??
        (name == 'Noctiluca' ? 0.0 : 1.83)).toDouble();
    final sellable = analysis['sellable'] ?? _getDefaultSellable(name);

    return AlgaeResult(
      id: analysis['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      scientificName: scientificName,
      confidence: confidence,
      confidenceLevel: confidenceLevel,
      benefits: benefits,
      uses: uses,
      allPredictions: [],
      modelInfo: {
        'apiUsed': true,
        'processingTime': 0,
        'source': 'From history',
      },
      dateTime: DateTime.now(),
      isToxic: isToxic,
      toxicityWarning: toxicityWarning,
      scientificWarning: scientificWarning,
      category: category,
      potentialToxins: potentialToxins,
      co2PerKg: co2PerKg,
      sellable: sellable,
    );
  }

  List<String> _getDefaultPotentialToxins(String name) {
    switch (name) {
      case 'Microcystis':
        return ['Microcystins (hepatotoxins)'];
      case 'Karenia':
        return ['Brevetoxins (neurotoxins)'];
      case 'Nodularia':
        return ['Nodularin (hepatotoxin)'];
      case 'Anabaena':
        return ['Anatoxin-a (in some strains)'];
      case 'Aphanizomenon':
        return ['Saxitoxins', 'Cylindrospermopsin'];
      case 'Nostoc':
        return ['Microcystins (in some strains)'];
      case 'Oscillatoria':
        return ['Anatoxin-a', 'Microcystins'];
      case 'Gymnodinium':
        return ['Saxitoxins (in some species)'];
      case 'Prorocentrum':
        return ['Okadaic acid', 'Dinophysistoxins'];
      case 'Noctiluca':
        return ['No human toxins', 'Environmental: hypoxia'];
      case 'Skeletonema':
        return ['None known'];
      default:
        return ['Test for: Microcystins, Nodularin, Anatoxin-a, Saxitoxins'];
    }
  }

  String _getDefaultSellable(String name) {
    switch (name) {
      case 'Skeletonema':
        return 'Yes - Excellent for aquaculture';
      case 'Nostoc':
        return 'Conditional - Only defined non-toxic strains';
      case 'Anabaena':
        return 'Conditional - Only as controlled culture';
      case 'Microcystis':
      case 'Karenia':
      case 'Nodularia':
      case 'Oscillatoria':
      case 'Gymnodinium':
      case 'Prorocentrum':
        return 'No - Research only';
      case 'Noctiluca':
        return 'No - Valued for ecotourism only';
      default:
        return 'Conditional - Requires testing';
    }
  }

  void _viewAnalysisDetails(Map<String, dynamic> analysis) {
    final imageFile = File(analysis['imagePath']);
    if (!imageFile.existsSync()) {
      _showSnackBar(ErrorStrings.imageFileNotFound, AppColors.errorRed);
      return;
    }
    final algaeResult = _createAlgaeResultFromHistory(analysis);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          imageFile: imageFile,
          result: algaeResult,
        ),
      ),
    );
  }

  void _deleteAnalysis(String id) async {
    await HistoryService.deleteAnalysis(id);
    await _loadHistory();
    _showSnackBar(AppStrings.analysisDeleted, AppColors.successGreen);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryBlue.withOpacity(0.95),
              AppColors.secondaryBlue.withOpacity(0.95),
              AppColors.accentGreen.withOpacity(0.95),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _analysisHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.history, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.analysisHistory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_analysisHistory.length} ${AppStrings.savedAnalyses}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return RefreshIndicator(
      onRefresh: _loadHistory,
      backgroundColor: AppColors.primaryBlue,
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _analysisHistory.length,
        itemBuilder: (context, index) {
          final analysis = _analysisHistory[index];
          return _buildHistoryCard(analysis);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> analysis) {
    final confidence = (analysis['confidence'] is double
        ? analysis['confidence']
        : double.parse(analysis['confidence'].toString())) * 100;
    final confidenceInt = confidence.toInt();
    final algaeType = analysis['algaeType'] ?? AppStrings.unknown;
    final isNontoxic = algaeType.toLowerCase() == AppStrings.nontoxicLower;
    final imagePath = _getAlgaeImagePath(algaeType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewAnalysisDetails(analysis),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isNontoxic
                            ? AppColors.successGreen.withOpacity(0.15)
                            : AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        image: !isNontoxic && imagePath != AppAssets.appLogo && imagePath != 'nontoxic_icon'
                            ? DecorationImage(
                          image: AssetImage(imagePath),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: isNontoxic
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/Nontoxic.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.successGreen.withOpacity(0.2),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.verified,
                                  size: 28,
                                  color: AppColors.successGreen,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                          : (imagePath == 'assets/images/Nontoxic.png'
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/Nontoxic.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                          : null),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        algaeType,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteAnalysis(analysis['id']),
                      icon: Icon(Icons.delete_outline,
                          color: AppColors.errorRed.withOpacity(0.7), size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(confidenceInt),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$confidenceInt%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${analysis['date']} - ${analysis['time']}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (analysis['isToxic'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.toxicRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.toxicRed, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning,
                                size: 12, color: AppColors.toxicRed),
                            const SizedBox(width: 4),
                            Text(
                              AppStrings.toxic,
                              style: TextStyle(
                                color: AppColors.toxicRed,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 0.85 - 60) * 0.7,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewAnalysisDetails(analysis),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text(AppStrings.viewDetails),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width * 0.85 - 60) * 0.25,
                      child: ElevatedButton.icon(
                        onPressed: () => _generatePDF(analysis),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text(AppStrings.pdf),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.loadingHistory,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.4),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.noAnalysesYet,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              AppStrings.startNewAnalysisToSee,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _analysisHistory.isEmpty ? null : _clearAllHistory,
              icon: const Icon(Icons.delete_sweep, size: 20),
              label: const Text(ButtonStrings.clear),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) return AppColors.confidenceHigh;
    if (confidence >= 70) return AppColors.confidenceMedium;
    return AppColors.confidenceLow;
  }
}