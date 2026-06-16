import 'package:bioalga/features/home/pages/home_page.dart';
import 'package:bioalga/shared/styles/theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BioAlga',
      theme: marineTheme,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}