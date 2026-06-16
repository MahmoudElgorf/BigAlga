/// Detail controller for managing algae data
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';

class DetailController {
  final String algaeName;
  late final Map<String, dynamic> data;

  DetailController({required this.algaeName}) {
    data = algaeData[algaeName] as Map<String, dynamic>;
  }

  bool get isToxic => data['isToxic'] as bool? ?? false;
  String get category => data['category'] as String? ?? AppStrings.unknown;
  String get scientificName => data['scientificName'] as String? ?? '';
  String get scientificWarning => data['scientificWarning'] as String? ?? '';
  List get potentialToxins => data['potentialToxins'] as List? ?? [];
  double get co2PerKg => (data['co2PerKg'] as num?)?.toDouble() ?? 1.83;
  String get sellable => data['sellable'] as String? ?? '';
  List get benefits => data['benefits'] as List? ?? [];
  List get uses => data['uses'] as List? ?? [];
  String get toxicityWarning => data['toxicityWarning'] ?? AppStrings.informationNotAvailable;

  String get co2Text => co2PerKg > 0
      ? '~ $co2PerKg kg CO₂/kg dry biomass'
      : AppStrings.notApplicable;
}