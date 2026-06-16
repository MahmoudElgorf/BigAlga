/// Image preview widget
import 'dart:io';
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/material.dart';

class ResultImagePreview extends StatelessWidget {
  final File imageFile;

  const ResultImagePreview({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          imageFile,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              color: Colors.grey[300],
              child: Icon(Icons.error_outline, color: Colors.grey[600], size: 50),
            );
          },
        ),
      ),
    );
  }
}