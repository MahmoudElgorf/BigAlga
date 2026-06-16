/// Catalog controller for managing state and data
import 'package:flutter/material.dart';
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/data/data.dart';

class CatalogController extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = AppStrings.all;
  bool _isGridView = true;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  bool get isGridView => _isGridView;

  final List<String> categories = [
    AppStrings.all,
    AppStrings.cyanobacteria,
    AppStrings.dinoflagellate,
    AppStrings.diatom,
    AppStrings.safe,
    AppStrings.toxic,
  ];

  final Map<String, String> algaeImages = {
    'Anabaena': 'assets/images/anabaena.png',
    'Aphanizomenon': 'assets/images/aphanizomenon.png',
    'Microcystis': 'assets/images/microcystis.png',
    'Nodularia': 'assets/images/nodularia.png',
    'Nostoc': 'assets/images/nostoc.png',
    'Oscillatoria': 'assets/images/oscillatoria.png',
    'Gymnodinium': 'assets/images/gymnodinium.png',
    'Karenia': 'assets/images/karenia.png',
    'Prorocentrum': 'assets/images/prorocentrum.png',
    'Noctiluca': 'assets/images/noctiluca.png',
    'Skeletonema': 'assets/images/Skeletonema.png',
    'Nontoxic': 'assets/images/Nontoxic.png',
  };

  List<String> get filteredAlgae {
    final list = algaeData.keys
        .where((key) => key.toLowerCase() != AppStrings.notAlgaeLower)
        .toList();

    return list.where((name) {
      final data = algaeData[name] as Map<String, dynamic>;
      final category = data['category'] as String? ?? '';
      final isToxic = data['isToxic'] as bool? ?? false;

      if (_selectedCategory != AppStrings.all) {
        switch (_selectedCategory) {
          case 'Cyanobacteria':
            if (!category.contains(AppStrings.cyanobacteria)) return false;
            break;
          case 'Dinoflagellate':
            if (!category.contains(AppStrings.dinoflagellate)) return false;
            break;
          case 'Diatom':
            if (!category.contains(AppStrings.diatom)) return false;
            break;
          case 'Safe':
            if (isToxic) return false;
            break;
          case 'Toxic':
            if (!isToxic) return false;
            break;
        }
      }

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final scientificName = data['scientificName'] as String? ?? '';
        return name.toLowerCase().contains(query) ||
            scientificName.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  int get totalCount => algaeData.keys
      .where((k) => k.toLowerCase() != AppStrings.notAlgaeLower)
      .length;

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleView() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  String getImagePath(String name) =>
      algaeImages[name] ?? 'assets/icons/default.png';

  Map<String, dynamic> getAlgaeDataByName(String name) =>
      algaeData[name] as Map<String, dynamic>;
}