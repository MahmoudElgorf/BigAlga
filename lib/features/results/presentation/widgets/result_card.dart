import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String name;
  final String scientificName;
  final double confidence;
  final String confidenceLevel;
  final bool isToxic;
  final String toxicityWarning;

  const ResultCard({
    Key? key,
    required this.name,
    required this.scientificName,
    required this.confidence,
    required this.confidenceLevel,
    required this.isToxic,
    required this.toxicityWarning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confidencePercentage = confidence * 100;

    return CustomPaint(
      painter: _LeafCardPainter(),
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.98),
              const Color(0xFFF1F8E9),
              const Color(0xFFE8F5E8),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(60),
            bottomLeft: Radius.circular(60),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.15),
              blurRadius: 25,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF388E3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.api,
                    color: const Color(0xFF388E3C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  AppStrings.remoteAnalysis,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: const Color(0xFF1B5E20),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Container(
              height: 2,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4CAF50).withOpacity(0.6),
                    const Color(0xFF8BC34A).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            _buildOrganicResultItem(
              Icons.cloud_upload,
              'Algae Type (API Result)',
              name,
              const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 12),

            _buildOrganicResultItem(
              Icons.science,
              AppStrings.scientificName,
              scientificName,
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildOrganicResultItem(
                    Icons.verified,
                    'Confidence Level (API)',
                    '$confidenceLevel (${confidencePercentage.toStringAsFixed(1)}%)',
                    const Color(0xFF388E3C),
                  ),
                ),
                const SizedBox(width: 12),
                _buildToxicIndicator(),
              ],
            ),
            const SizedBox(height: 20),

            _buildOrganicConfidenceBar(confidencePercentage),
            const SizedBox(height: 20),

            if (isToxic) _buildToxicityWarning(),

            _buildApiInfoBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganicResultItem(
      IconData icon,
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: const Color(0xFF1B5E20),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToxicIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isToxic ? AppColors.toxicRed.withOpacity(0.1) : AppColors.safeGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToxic ? AppColors.toxicRed : AppColors.safeGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isToxic ? Icons.warning : Icons.check_circle,
            color: isToxic ? AppColors.toxicRed : AppColors.safeGreen,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            isToxic ? AppStrings.toxic : AppStrings.safe,
            style: TextStyle(
              color: isToxic ? AppColors.toxicRed : AppColors.safeGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganicConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.insights, color: Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 8),
            Text(
              AppStrings.confidenceIndicator,
              style: TextStyle(
                color: const Color(0xFF1B5E20),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              '${confidence.toStringAsFixed(1)}%',
              style: TextStyle(
                color: const Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 12,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.1),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    width: (confidence / 100) * constraints.maxWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getConfidenceColor(confidence),
                          _getConfidenceColor(confidence).withOpacity(0.8)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: _getConfidenceColor(confidence).withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.low,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            Text(
              AppStrings.high,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) return AppColors.confidenceHigh;
    if (confidence >= 60) return const Color(0xFF8BC34A);
    if (confidence >= 40) return AppColors.confidenceMedium;
    return AppColors.confidenceLow;
  }

  Widget _buildToxicityWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.toxicRed.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.toxicRed.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.toxicRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber,
              color: AppColors.toxicRed,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warning: Toxic Algae',
                  style: TextStyle(
                    color: AppColors.toxicRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  toxicityWarning,
                  style: TextStyle(
                    color: AppColors.toxicRed.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ Avoid human or animal consumption',
                  style: TextStyle(
                    color: AppColors.toxicRed.withOpacity(0.8),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiInfoBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.apiBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.apiBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud,
            color: AppColors.apiBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            AppStrings.apiPowered,
            style: TextStyle(
              color: AppColors.apiBlue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(size.width * 0.8, size.height * 0.1);
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.05,
      size.width * 0.95,
      size.height * 0.15,
    );
    path.quadraticBezierTo(
      size.width,
      size.height * 0.2,
      size.width * 0.9,
      size.height * 0.25,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.3,
      size.width * 0.8,
      size.height * 0.2,
    );
    path.close();

    path.moveTo(size.width * 0.1, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.8,
      size.width * 0.1,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.15,
      size.height * 0.95,
      size.width * 0.25,
      size.height * 0.9,
    );
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.85,
      size.width * 0.2,
      size.height * 0.75,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}