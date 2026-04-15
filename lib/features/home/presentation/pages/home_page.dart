// lib/features/home/presentation/pages/home_page.dart
import 'dart:io';
import 'package:bioalga/about/presentation/pages/about_screen.dart';
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/core/utils/utils.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:bioalga/shared/widgets/wave_painter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/services/ml_service.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../results/presentation/pages/results_page.dart';
import '../../../catalog/presentation/pages/algae_catalog_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/history_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  bool _isModelReady = false;
  bool _isTestingConnection = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      setState(() => _isTestingConnection = true);
      await MLService().initModel();
      setState(() {
        _isModelReady = true;
        _isTestingConnection = false;
      });
      print('✅ Model ready for use');
    } catch (e) {
      setState(() => _isTestingConnection = false);
      print('❌ Error loading model: $e');
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          'Unable to connect to analysis service. Check internet and try again',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HistoryDrawer(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              const Positioned.fill(child: AnimatedBackground()),
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 40),
                      _buildMainContent(context),
                      const SizedBox(height: 40),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: AppSizes.headerHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.secondaryBlue,
            AppColors.accentGreen,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildHeaderWaves(),
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Builder(
                      builder: (context) => Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: Theme.of(context)
                                .textTheme
                                .displayLarge!
                                .copyWith(
                              color: AppColors.textWhite,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: AppColors.primaryBlue.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.appSlogan,
                            style: TextStyle(
                              color: AppColors.textWhite.withOpacity(0.95),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildDecorativeWave(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHeaderWaves() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 40,
        child: CustomPaint(
          painter: WavePainter(),
        ),
      ),
    );
  }

  Widget _buildDecorativeWave() {
    return Container(
      height: 4,
      width: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lightGreen,
            AppColors.textWhite.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildFloatingCard(context),
          const SizedBox(height: 30),
          _buildActionButton(context),
          const SizedBox(height: 16),
          _buildEncyclopediaButton(),
          const SizedBox(height: 20),
          _buildModelStatus(),
        ],
      ),
    );
  }

  Widget _buildEncyclopediaButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue,
            AppColors.secondaryBlue,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AlgaeCatalogScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Algae Encyclopedia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Explore ${algaeData.length} documented species',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCard(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.science,
            size: 50,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.scientificAnalysis,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: AppColors.primaryBlue,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${AppStrings.uploadInstructions}\n'
                '${AppStrings.accurateClassification}\n'
                '${AppStrings.detailedInfo}\n'
                '${AppStrings.aiAnalysis}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return PrimaryButton(
      text: AppStrings.chooseImage,
      icon: Icons.photo_library,
      onPressed: () async {
        if (_isModelReady) {
          await _pickImageFromGallery(context);
        } else {
          AppUtils.showErrorSnackBar(
            context,
            'Connecting to analysis service. Please wait...',
          );
        }
      },
      color: _isModelReady ? AppColors.primaryBlue : Colors.grey,
    );
  }

  Widget _buildModelStatus() {
    if (_isTestingConnection) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.testingConnection,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.connectionMayTakeTime,
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      );
    } else if (!_isModelReady) {
      return Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.serviceUnavailable,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _initializeModel,
            child: Text(
              AppStrings.reconnect,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontSize: 12,
              ),
            ),
          ),
        ],
      );
    }
    return Container();
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFooterWaves(),
          const SizedBox(height: 12),

          // ✅ حقوق الملكية (قابلة للنقر - تفتح About)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  width: 0.5,
                ),
              ),
              child: Text(
                'BioAlga © ${DateTime.now().year}',
                style: TextStyle(
                  color: AppColors.primaryBlue.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterWaves() {
    return Container(
      height: 20,
      child: CustomPaint(
        painter: WavePainter(reverse: true),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.lightGreen,
              strokeWidth: 4,
            ),
            SizedBox(height: 20),
            Text(
              AppStrings.analyzing,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.analyzingRemote,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    if (!_isModelReady) {
      AppUtils.showErrorSnackBar(
        context,
        'Analysis service not available. Try again later',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final imageFile = await AppUtils.pickImage(ImageSource.gallery);

      if (imageFile != null) {
        print('📸 Image selected: ${imageFile.path}');

        final isValid = await _validateImage(imageFile);

        if (isValid) {
          await _processImageAndNavigate(context, imageFile);
        } else {
          AppUtils.showImageTooLargeSnackBar(context);
        }
      } else {
        print('❌ No image selected');
        if (mounted) {
          AppUtils.showErrorSnackBar(context, AppStrings.noImageSelected);
        }
      }
    } catch (e) {
      print('❌ Error selecting image: $e');
      if (mounted) {
        AppUtils.showErrorSnackBar(
          context,
          AppStrings.imageSelectionError,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _validateImage(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      if (fileSize > AppSizes.maxFileSize) {
        return false;
      }
      if (!await imageFile.exists()) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _processImageAndNavigate(
      BuildContext context, File imageFile) async {
    try {
      print('🎯 Starting image analysis...');

      final mlService = MLService();

      print('🌐 Testing server connection...');
      final isConnected = await mlService.testConnection();

      if (!isConnected) {
        print('❌ No server connection');
        if (mounted) {
          await AppUtils.showConnectionRetryDialog(
            context,
            title: ErrorStrings.apiConnectionError,
            message: 'Unable to connect to analysis server',
            onRetry: () => _processImageAndNavigate(context, imageFile),
            onCancel: () => setState(() => _isLoading = false),
          );
        }
        return;
      }

      print('✅ Server connection successful, starting image analysis...');

      final result = await mlService.classifyImage(imageFile);

      print('✅ Analysis complete: ${result.name} - Confidence: ${result.confidence}');

      if (result.isValid) {
        if (mounted) {
          AppUtils.navigateTo(
            context,
            ResultsPage(imageFile: imageFile, result: result),
          );
        }
      } else {
        print('❌ Invalid result');
        if (mounted) {
          AppUtils.showErrorSnackBar(
            context,
            AppStrings.failedToAnalyze,
          );
        }
      }
    } catch (e) {
      print('❌ Error analyzing image: $e');
      if (mounted) {
        AppUtils.showApiErrorSnackBar(
          context,
          '${AppStrings.analysisError}: ${e.toString()}',
        );
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}