/// Algae card widget displaying species information in grid/list view
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class AlgaeCard extends StatelessWidget {
  final String name;
  final String scientificName;
  final String category;
  final bool isToxic;
  final String imagePath;
  final VoidCallback onTap;

  const AlgaeCard({
    super.key,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.isToxic,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'algae_$name',
        child: Card(
          elevation: 2,
          color: Colors.white,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: double.infinity,
                    height: constraints.maxWidth * 0.75,
                    color: Colors.white,
                    child: Image.asset(
                      imagePath,
                      width: double.infinity,
                      height: constraints.maxWidth * 0.65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: constraints.maxWidth * 0.65,
                          color: const Color(0xFFF5F5F5),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bubble_chart,
                                  size: 30,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.noImage,
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                            letterSpacing: -0.2,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          scientificName,
                          style: TextStyle(
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: (isToxic ? const Color(0xFFE65100) : const Color(0xFF2E7D32)).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isToxic ? Icons.warning_amber_rounded : Icons.check_circle,
                                    size: 10,
                                    color: isToxic ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isToxic ? AppStrings.toxic : AppStrings.safe,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isToxic ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                _getShortCategory(category),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getShortCategory(String category) {
    if (category.contains(AppStrings.cyanobacteria)) return AppStrings.cyanobacteria;
    if (category.contains(AppStrings.dinoflagellate)) return AppStrings.dinoflagellate;
    if (category.contains(AppStrings.diatom)) return AppStrings.diatom;
    if (category.contains(AppStrings.unknown)) return AppStrings.algae;
    return category;
  }
}