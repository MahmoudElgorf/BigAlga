class AlgaePrediction {
  final String label;
  final double confidence;
  final DateTime timestamp;
  final String imagePath;

  AlgaePrediction({
    required this.label,
    required this.confidence,
    required this.timestamp,
    required this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory AlgaePrediction.fromJson(Map<String, dynamic> json) {
    return AlgaePrediction(
      label: json['label'],
      confidence: json['confidence'],
      timestamp: DateTime.parse(json['timestamp']),
      imagePath: json['imagePath'],
    );
  }
}

class AlgaeInfo {
  final String type;
  final String scientificName;
  final String description;
  final List<String> benefits;
  final List<String> uses;
  final String habitat;

  AlgaeInfo({
    required this.type,
    required this.scientificName,
    required this.description,
    required this.benefits,
    required this.uses,
    required this.habitat,
  });
}