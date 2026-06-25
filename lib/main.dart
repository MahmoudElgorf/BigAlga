/// Main entry point

import 'package:flutter/material.dart';

import 'package:bioalga/core/constants/constants.dart';
import 'package:bioalga/features/home/pages/home_page.dart';
import 'package:bioalga/shared/styles/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const BioAlgaApp());
}

class BioAlgaApp extends StatelessWidget {
  const BioAlgaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: marineTheme,
      home: const HomePage(),
    );
  }
}