import 'package:flutter/material.dart';

class AlgaeCard extends StatelessWidget {
  final String name;
  final String scientificName;
  final String category;
  final bool isToxic;
  final String imagePath;
  final VoidCallback onTap;

  const AlgaeCard({
    Key? key,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.isToxic,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'algae_$name',
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image container: flexible height
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFFFFFFF),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFFFFFFF),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.bubble_chart,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'No Image',
                                  style: TextStyle(
                                    fontSize: 10,
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
                ),

                // Flexible content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        scientificName,
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isToxic ? Icons.warning_amber_rounded : Icons.check_circle,
                                size: 12,
                                color: isToxic ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isToxic ? 'Toxic' : 'Safe',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isToxic ? const Color(0xFFE65100) : const Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 3,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.grey[400],
                              shape: BoxShape.circle,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _getShortCategory(category),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
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
            ),
          ),
        ),
      ),
    );
  }

  String _getShortCategory(String category) {
    if (category.contains('Cyanobacteria')) return 'Cyanobacteria';
    if (category.contains('Dinoflagellate')) return 'Dinoflagellate';
    if (category.contains('Diatom')) return 'Diatom';
    if (category.contains('Unknown')) return 'Algae';
    return category;
  }
}