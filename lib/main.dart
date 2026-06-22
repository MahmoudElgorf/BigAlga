/// Main entry point
import 'dart:async';

import 'package:bioalga/features/home/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/shared/styles/theme.dart';
import 'package:bioalga/core/services/ml_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  unawaited(MLService().initModel());

  runApp(const BioAlgaApp());
}

class BioAlgaApp extends StatelessWidget {
  const BioAlgaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: marineTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}