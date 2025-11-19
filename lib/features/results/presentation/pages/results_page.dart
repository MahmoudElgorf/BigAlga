import 'dart:io';
import 'package:intl/intl.dart';
import 'package:bioalga/features/results/presentation/widgets/algae_info.dart';
import 'package:bioalga/features/results/presentation/widgets/result_card.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../core/services/pdf_service.dart';
import '../../../../core/services/history_service.dart';
import '../../../../shared/widgets/widgets.dart';

class ResultsPage extends StatefulWidget {
  final File imageFile;
  final Map<String, dynamic>? preloadedResults;

  const ResultsPage({
    Key? key,
    required this.imageFile,
    this.preloadedResults,
  }) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  Map<String, dynamic>? _results;
  bool _isLoading = true;
  String _error = '';
  bool _isGeneratingPDF = false;

  @override
  void initState() {
    super.initState();
    if (widget.preloadedResults != null) {
      // استخدام البيانات المسبقة إذا وجدت
      setState(() {
        _results = widget.preloadedResults;
        _isLoading = false;
      });
    } else {
      // تحليل الصورة الجديدة
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    try {
      final results = await MLService.classifyImage(widget.imageFile);
      setState(() {
        _results = results;
        _isLoading = false;
      });

      if (results != null) { // ⬅️ التحقق من أن results ليست null
        await _saveAnalysisToHistory(results);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed To Analyze Image: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAnalysisToHistory(Map<String, dynamic> results) async {
    try {
      if (results['topPrediction'] != null) {
        final analysisData = {
          'id': HistoryService.generateId(),
          'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
          'time': DateFormat('HH:mm').format(DateTime.now()),
          'algaeType': results['topPrediction']['label'] ?? 'Unknown',
          'confidence': results['topPrediction']['confidence'] ?? 0.0,
          'imagePath': widget.imageFile.path,
          'results': results,
        };

        await HistoryService.saveAnalysis(analysisData);
      }
    } catch (e) {
      print('Error saving analysis to history: $e');
      // لا نعرض خطأ للمستخدم لأن هذه وظيفة ثانوية
    }
  }

  Future<void> _generatePDF() async {
    if (_results == null) return;

    setState(() {
      _isGeneratingPDF = true;
    });

    try {
      await PDFService.generateAndSaveReport(_results!, widget.imageFile);

      // رسالة نجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved successfully to Downloads folder'),
          backgroundColor: AppColors.seaGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save PDF: $e'),
          backgroundColor: AppColors.coral,
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPDF = false;
      });
    }
  }

  void _navigateBackToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _analyzeNewImage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: AppText.results,
        actions: _results != null ? [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white),
            onPressed: _navigateBackToHome,
            tooltip: 'Back to Home',
          ),
        ] : null,
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
    return LoadingIndicator(message: AppText.analyzing);
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
              color: AppColors.coral,
            ),
            const SizedBox(height: 20),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkText,
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
                    backgroundColor: AppColors.deepBlue,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Try Again'),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _navigateBackToHome,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.deepBlue,
                    side: BorderSide(color: AppColors.deepBlue),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: Text('Back to Home'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    final topPrediction = _results?['topPrediction'] ?? {'label': 'Analysis in progress', 'confidence': 0.0};
    final isConfident = _results?['isConfident'] ?? false;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildImagePreview(),
                const SizedBox(height: 30),

                ResultCard(results: topPrediction),
                const SizedBox(height: 20),

                AlgaeInfo(algaeType: topPrediction['label']),
                const SizedBox(height: 20),

                _buildConfidenceIndicator(isConfident),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),

        // زر الحفظ في الأسفل
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildConfidenceIndicator(bool isConfident) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isConfident ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isConfident ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConfident ? Icons.verified : Icons.warning_amber,
            color: isConfident ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isConfident
                  ? 'High confidence analysis - Results are reliable'
                  : 'Moderate confidence - Consider verifying with additional samples',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
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
        color: Colors.white.withOpacity(0.05),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // زر حفظ PDF
          _buildPrintButton(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPrintButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isGeneratingPDF ? null : _generatePDF,
        icon: _isGeneratingPDF
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Icon(Icons.save_alt, color: Colors.white),
        label: Text(
          _isGeneratingPDF ? 'Saving PDF...' : 'Save PDF Report',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
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
            color: AppColors.deepBlue.withOpacity(0.2),
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
            // Overlay للمظهر الأفضل
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
          ],
        ),
      ),
    );
  }
}