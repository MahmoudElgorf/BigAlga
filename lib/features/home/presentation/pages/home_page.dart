import 'dart:io';
import 'package:bioalga/features/home/presentation/widgets/animated_background.dart';
import 'package:bioalga/features/home/presentation/widgets/history_drawer.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/utils/utils.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../results/presentation/pages/results_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HistoryDrawer(), // ⬅️ الشريط الجانبي الجديد
      body: Stack(
        children: [
          const AnimatedBackground(),
          GradientBackground(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 40),
                _buildMainContent(context),
                const Spacer(),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: AppSizes.headerHeight,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.deepBlue,
            AppColors.oceanBlue,
            AppColors.seaGreen,
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
            color: AppColors.deepBlue.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildHeaderWaves(),
          Positioned(
            top: 80,
            left: 30,
            right: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // زر القائمة الجديد
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
                            'BioAlga',
                            style: Theme.of(context).textTheme.displayLarge!.copyWith(
                              color: AppColors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: AppColors.deepBlue.withOpacity(0.5),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppText.appSlogan,
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.95),
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
      width: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.aqua,
            AppColors.white.withOpacity(0.8),
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
        ],
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
            color: AppColors.deepBlue.withOpacity(0.1),
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
            color: AppColors.deepBlue,
          ),
          const SizedBox(height: 16),
          Text(
            'Scientific Algae Analysis',
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
              color: AppColors.deepBlue,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Upload algae sample image for:\n'
                '• Accurate scientific classification\n'
                '• Detailed species information\n'
                '• Professional AI-powered analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.greyText,
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
      text: AppText.fromGallery,
      icon: Icons.photo_library,
      onPressed: () => _pickImageFromGallery(context),
      color: AppColors.deepBlue,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildFooterWaves(),
          const SizedBox(height: 10),
          Text(
            AppText.poweredBy,
            style: const TextStyle(
              color: AppColors.greyText,
              fontSize: 12,
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

  Future<void> _pickImageFromGallery(BuildContext context) async {
    final imageFile = await AppUtils.pickImage(ImageSource.gallery);
    if (imageFile != null) {
      _navigateToResults(context, imageFile);
    } else {
      AppUtils.showErrorSnackBar(context, 'No image selected');
    }
  }

  void _navigateToResults(BuildContext context, File imageFile) {
    AppUtils.navigateTo(
      context,
      ResultsPage(imageFile: imageFile),
    );
  }
}