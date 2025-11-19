import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../../../core/constants/constants.dart';

class ResultCard extends StatelessWidget {
  final Map<String, dynamic> results;

  const ResultCard({Key? key, required this.results}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confidence = (results['confidence'] as double) * 100;

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
              Color(0xFFF1F8E9),
              Color(0xFFE8F5E8),
            ],
          ),
          borderRadius: BorderRadius.only(
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
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with plant icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(0xFF388E3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.psychology,
                    color: Color(0xFF388E3C),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analysis Results',
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                    color: Color(0xFF1B5E20),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Organic divider
            Container(
              height: 2,
              width: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF4CAF50).withOpacity(0.6),
                    Color(0xFF8BC34A).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Algae Type
            _buildOrganicResultItem(
              Icons.eco,
              'Algae Type',
              results['label'],
              Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),

            // Confidence Level
            _buildOrganicResultItem(
              Icons.verified,
              'Confidence Level',
              '${confidence.toStringAsFixed(1)}%',
              Color(0xFF388E3C),
            ),
            const SizedBox(height: 20),

            // Confidence Bar with organic styling
            _buildOrganicConfidenceBar(confidence),
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
                    color: Color(0xFF1B5E20),
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

  Widget _buildOrganicConfidenceBar(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.insights, color: Color(0xFF4CAF50), size: 18),
            const SizedBox(width: 8),
            Text(
              'Confidence Score',
              style: TextStyle(
                color: Color(0xFF1B5E20),
                fontWeight: FontWeight.w600,
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
            color: Color(0xFFE8F5E9),
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
              // Background
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              // Progress - احذف MediaQuery واستخدم LayoutBuilder بدلاً منه
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    width: (confidence / 100) * constraints.maxWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4CAF50).withOpacity(0.3),
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
              'Low',
              style: TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
            Text(
              'High',
              style: TextStyle(color: Color(0xFF757575), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _LeafCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4CAF50).withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw organic leaf-like shapes in corners
    final path = Path();

    // Top-right leaf shape
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

    // Bottom-left leaf shape
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
