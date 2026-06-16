/// App color constants
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF006994);
  static const Color secondaryBlue = Color(0xFF0081A7);
  static const Color accentGreen = Color(0xFF00AFB9);
  static const Color lightGreen = Color(0xFF00C9B1);
  static const Color primaryGreen = Color(0xFF2E7D32);

  static const Color backgroundLight = Color(0xFFFDFCDC);
  static const Color surfaceLight = Color(0xFFFED9B7);
  static const Color errorRed = Color(0xFFF07167);

  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color apiBlue = Color(0xFF1976D2);

  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textWhite = Colors.white;

  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E0);
  static const Color shadow = Color(0x1A000000);

  static const Color toxicRed = Color(0xFFE53935);
  static const Color safeGreen = Color(0xFF43A047);
  static const Color unknownGray = Color(0xFF757575);

  static const Color confidenceHigh = Color(0xFF4CAF50);
  static const Color confidenceMedium = Color(0xFFFF9800);
  static const Color confidenceLow = Color(0xFFF44336);

  static const Color deepBlue = primaryBlue;
  static const Color oceanBlue = secondaryBlue;
  static const Color seaGreen = accentGreen;
  static const Color aqua = lightGreen;
  static const Color foam = backgroundLight;
  static const Color sand = surfaceLight;
  static const Color coral = errorRed;
  static const Color cloudBlue = infoBlue;
  static const Color primary = primaryBlue;
  static const Color secondary = accentGreen;
  static const Color background = backgroundLight;
  static const Color white = textWhite;
  static const Color darkText = textPrimary;
  static const Color greyText = textSecondary;

  static const Color darkBackground = Color(0xFF0A0F1C);

}

class AppColorsPDF {
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF006994);
  static const PdfColor secondaryBlue = PdfColor.fromInt(0xFF0081A7);
  static const PdfColor accentGreen = PdfColor.fromInt(0xFF00AFB9);
  static const PdfColor lightGreen = PdfColor.fromInt(0xFF00C9B1);
  static const PdfColor warningOrange = PdfColor.fromInt(0xFFFF9800);

  static const PdfColor backgroundLight = PdfColor.fromInt(0xFFFDFCDC);

  static const PdfColor successText = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor errorText = PdfColor.fromInt(0xFFF44336);
  static const PdfColor errorBorder = PdfColor.fromInt(0xFFF44336);
  static const PdfColor errorBackground = PdfColor.fromInt(0xFFFFEBEE);

  static const PdfColor confidenceHigh = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor confidenceMedium = PdfColor.fromInt(0xFFFF9800);
  static const PdfColor confidenceLow = PdfColor.fromInt(0xFFF44336);

  static const PdfColor infoText = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor infoBorder = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor infoBackground = PdfColor.fromInt(0xFFE3F2FD);
}