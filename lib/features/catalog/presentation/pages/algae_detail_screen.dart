// lib/features/catalog/presentation/pages/algae_detail_screen.dart
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/models/algae_model.dart';
import 'package:flutter/material.dart';

class AlgaeDetailScreen extends StatelessWidget {
  final String algaeName;

  const AlgaeDetailScreen({
    Key? key,
    required this.algaeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = algaeData[algaeName] as Map<String, dynamic>;
    final isToxic = data['isToxic'] as bool? ?? false;
    final category = data['category'] as String? ?? 'Unknown';
    final arabicName = data['arabicName'] as String? ?? '';
    final scientificWarning = data['scientificWarning'] as String? ?? '';
    final potentialToxins = data['potentialToxins'] as List? ?? [];
    final co2PerKg = (data['co2PerKg'] as num?)?.toDouble() ?? 1.83;
    final sellable = data['sellable'] as String? ?? '';
    final benefits = data['benefits'] as List? ?? [];
    final uses = data['uses'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          arabicName.isNotEmpty ? arabicName : algaeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isToxic ? Colors.red[700] : AppColors.primaryBlue,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(algaeName, arabicName, data['scientificName'] ?? '', isToxic),
                const SizedBox(height: 16),
                _buildCategoryBadge(category, isToxic),
                const SizedBox(height: 24),
                _buildSection(
                  title: ' Scientific Warning',
                  icon: Icons.warning_amber,
                  color: Colors.orange,
                  content: scientificWarning,
                  isWarning: true,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  title: ' Toxicity & Safety',
                  icon: Icons.science,                  color: isToxic ? Colors.red : Colors.green,
                  content: data['toxicityWarning'] ?? 'Information not available',
                ),
                if (potentialToxins.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildListSection(
                    title: ' Potential Toxins',
                    icon: Icons.warning,
                    color: Colors.red,
                    items: potentialToxins.map((t) => t.toString()).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                _buildInfoRow('Classification', category),
                _buildInfoRow('CO₂ Sequestration',
                    co2PerKg > 0 ? '~ $co2PerKg kg CO₂/kg dry biomass' : 'Not applicable'),
                if (sellable.isNotEmpty)
                  _buildInfoRow('Commercial Viability', sellable),
                const SizedBox(height: 16),
                if (benefits.isNotEmpty)
                  _buildListSection(
                    title: ' Benefits',
                    icon: Icons.eco,
                    color: Colors.green,
                    items: benefits.map((b) => b.toString()).toList(),
                  ),
                const SizedBox(height: 16),
                if (uses.isNotEmpty)
                  _buildListSection(
                    title: ' Applications',
                    icon: Icons.build,
                    color: AppColors.primaryBlue,
                    items: uses.map((u) => u.toString()).toList(),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, String arabicName, String scientificName, bool isToxic) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isToxic
              ? [Colors.red[700]!, Colors.red[900]!]
              : [AppColors.primaryBlue, AppColors.secondaryBlue],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (arabicName.isNotEmpty)
            Text(
              arabicName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            scientificName,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(String category, bool isToxic) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue.withOpacity(0.3)),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isToxic ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isToxic ? Colors.red.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              isToxic ? ' TOXIC' : '✓ SAFE',
              style: TextStyle(
                fontSize: 12,
                color: isToxic ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
    bool isWarning = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isWarning ? Colors.orange.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isWarning ? Colors.orange.withOpacity(0.3) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(fontSize: 14, color: color)),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}