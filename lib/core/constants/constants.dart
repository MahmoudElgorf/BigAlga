import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

// ==================== APP COLORS ====================
class AppColors {
  // Primary Colors
  static const Color primaryBlue = Color(0xFF006994);
  static const Color secondaryBlue = Color(0xFF0081A7);
  static const Color accentGreen = Color(0xFF00AFB9);
  static const Color lightGreen = Color(0xFF00C9B1);

  // Background & Surface
  static const Color backgroundLight = Color(0xFFFDFCDC);
  static const Color surfaceLight = Color(0xFFFED9B7);
  static const Color errorRed = Color(0xFFF07167);

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);
  static const Color apiBlue = Color(0xFF1976D2);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color textLight = Color(0xFFA0AEC0);
  static const Color textWhite = Colors.white;

  // UI Elements
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border = Color(0xFFCBD5E0);
  static const Color shadow = Color(0x1A000000);

  // Algae Status
  static const Color toxicRed = Color(0xFFE53935);
  static const Color safeGreen = Color(0xFF43A047);
  static const Color unknownGray = Color(0xFF757575);

  // Confidence Level Colors
  static const Color confidenceHigh = Color(0xFF4CAF50);
  static const Color confidenceMedium = Color(0xFFFF9800);
  static const Color confidenceLow = Color(0xFFF44336);

  // Aliases for backward compatibility
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
}

// ==================== PDF COLORS ====================
class AppColorsPDF {
  static const PdfColor primaryBlue = PdfColor.fromInt(0xFF006994);
  static const PdfColor secondaryBlue = PdfColor.fromInt(0xFF0081A7);
  static const PdfColor accentGreen = PdfColor.fromInt(0xFF00AFB9);
  static const PdfColor lightGreen = PdfColor.fromInt(0xFF00C9B1);

  // Background colors
  static const PdfColor backgroundLight = PdfColor.fromInt(0xFFFDFCDC);

  // Status colors
  static const PdfColor successText = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor errorText = PdfColor.fromInt(0xFFF44336);
  static const PdfColor errorBorder = PdfColor.fromInt(0xFFF44336);
  static const PdfColor errorBackground = PdfColor.fromInt(0xFFFFEBEE);

  // Confidence colors
  static const PdfColor confidenceHigh = PdfColor.fromInt(0xFF4CAF50);
  static const PdfColor confidenceMedium = PdfColor.fromInt(0xFFFF9800);
  static const PdfColor confidenceLow = PdfColor.fromInt(0xFFF44336);

  // Info colors
  static const PdfColor infoText = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor infoBorder = PdfColor.fromInt(0xFF2196F3);
  static const PdfColor infoBackground = PdfColor.fromInt(0xFFE3F2FD);
}

// ==================== APP SIZES ====================
class AppSizes {
  // App Layout
  static const double headerHeight = 280;
  static const double buttonHeight = 60;

  // Image Processing
  static const int maxImageWidth = 1200;
  static const int maxImageHeight = 1200;
  static const int imageQuality = 80;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // UI Elements
  static const double borderRadius = 10;
  static const double cardBorderRadius = 16;
  static const double buttonBorderRadius = 15;

  // Text
  static const int maxFileNameLength = 20;
  static const int fileNamePrefixLength = 15;

  // Spacing
  static const double smallSpacing = 8;
  static const double mediumSpacing = 16;
  static const double largeSpacing = 24;
  static const double extraLargeSpacing = 32;
}

// ==================== PDF SIZES ====================
class PDFSizes {
  // Page layout
  static const double pageMargin = 20;
  static const double sectionSpacing = 16;

  // Spacing
  static const double smallSpacing = 8;
  static const double mediumSpacing = 12;
  static const double largeSpacing = 20;

  // Font sizes
  static const double xsmallFontSize = 8;
  static const double smallFontSize = 10;
  static const double mediumFontSize = 12;
  static const double largeFontSize = 14;
  static const double titleFontSize = 16;
  static const double subtitleFontSize = 11;
  static const double headerFontSize = 20;
  static const double iconFontSize = 12;

  // Dimensions
  static const double logoWidth = 60;
  static const double logoHeight = 60;
  static const double headerLogoWidth = 80;
  static const double headerLogoHeight = 80;
  static const double imageWidth = 150;
  static const double imageHeight = 150;
  static const double largeImageWidth = 300;
  static const double largeImageHeight = 200;
  static const double borderRadius = 8;

  // Padding
  static const double cardPadding = 10;
  static const double cardPaddingLarge = 15;
}

// ==================== APP CONSTANTS ====================
class AppConstants {
  // Storage Keys
  static const String historyKey = 'analysis_history';
  static const int maxHistoryItems = 50;

  // App Info
  static const String appName = 'BioAlga';
  static const String appVersion = '1.0.0';
}

// ==================== ASSETS PATHS ====================
class AppAssets {
  static const String appLogo = 'assets/images/App_Logo.png';
  static const String defaultAlgaeImage = 'assets/default_algae.png';
}

// ==================== API CONSTANTS ====================
class ApiConstants {
  // API Configuration
  static const String baseUrl = 'https://algea-image-classififcation.onrender.com';
  static const String predictEndpoint = '/predictApi';
  static const Duration timeout = Duration(seconds: 30);
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  // API Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}

// ==================== API VISUALS ====================
class ApiVisuals {
  // API-related Icons
  static const IconData apiIcon = Icons.cloud;
  static const IconData connectionIcon = Icons.wifi;
  static const IconData successIcon = Icons.cloud_done;
  static const IconData errorIcon = Icons.cloud_off;
  static const IconData analyzingIcon = Icons.cloud_upload;
  static const IconData serverIcon = Icons.dns;
  static const IconData networkIcon = Icons.network_check;
}

// ==================== APP STRINGS ====================
class AppStrings {
  // App Info
  static const String appName = 'BioAlga';
  static const String appSlogan = 'Discover the World of Marine Algae';
  static const String poweredBy = 'BioAlga © 2026';

  // Home Page
  static const String chooseImage = 'Choose Image from Gallery';
  static const String scientificAnalysis = 'Scientific Algae Analysis';
  static const String uploadInstructions = 'Upload algae sample image for:';
  static const String accurateClassification = '• Accurate scientific classification';
  static const String detailedInfo = '• Detailed species information';
  static const String aiAnalysis = '• Professional AI-powered analysis';

  // Status Messages
  static const String connectingToService = 'Connecting to analysis service...';
  static const String connectionMayTakeTime = 'Connection may take some time';
  static const String serviceUnavailable = 'Analysis service unavailable';
  static const String reconnect = 'Reconnect';
  static const String testingConnection = 'Testing connection to server...';

  // Results Page
  static const String resultsTitle = 'Analysis Results';
  static const String analyzing = 'Analyzing Image...';
  static const String analyzingRemote = 'Sending image for remote analysis...';
  static const String tryAgain = 'Try Again';
  static const String backToHome = 'Back to Home';
  static const String analyzeNewImage = 'Analyze New Image';
  static const String savePDFReport = 'Save PDF Report';
  static const String savingPDF = 'Saving PDF...';
  static const String originalImage = 'Original Image';
  static const String confidenceIndicator = 'Confidence Indicator';
  static const String low = 'Low';
  static const String high = 'High';

  // Error Messages
  static const String noImageSelected = 'No image selected';
  static const String imageSelectionError = 'Error selecting image';
  static const String analysisError = 'Analysis connection error';
  static const String failedToAnalyze = 'Unable to analyze image. Try again';
  static const String invalidImage = 'Image quality is not suitable';
  static const String imageRequirements = 'Please choose a clear algae image';
  static const String imageQualityInstructions =
      'Please choose a clear algae image\n'
      'Ensure:\n'
      '• Clear details\n'
      '• Good lighting\n'
      '• Appropriate size\n'
      '• Focus on the sample';

  // Algae Info
  static const String algaeInformation = 'Algae Information';
  static const String scientificName = 'Scientific Name';
  static const String description = 'Description';
  static const String characteristics = 'Characteristics';
  static const String toxicityLevel = 'Toxicity Level';
  static const String habitat = 'Habitat';
  static const String benefits = 'Benefits';
  static const String applications = 'Applications';
  static const String updatedFromDatabase = 'Updated information from database';

  // History Drawer
  static const String analysisHistory = 'Analysis History';
  static const String recentAnalysis = 'Recent Analysis';
  static const String viewDetails = 'View Details';
  static const String clearAll = 'Clear All';
  static const String refresh = 'Refresh';
  static const String noHistory = 'No analysis history';
  static const String startNewAnalysis = 'Start New Analysis';
  static const String delete = 'Delete';
  static const String confirmClear = 'Clear all history?';
  static const String cannotUndo = 'This action cannot be undone';

  // Toxicity Status
  static const String toxic = 'Toxic';
  static const String safe = 'Safe';
  static const String handleWithCare = 'Handle with Care';
  static const String safeForHandling = 'Safe for Handling';

  // Confidence Levels
  static const String veryHigh = 'Very High';
  static const String highConfidence = 'High';
  static const String medium = 'Medium';
  static const String lowConfidence = 'Low';
  static const String veryLow = 'Very Low';

  // API Messages
  static const String apiPowered = 'AI API Powered Analysis';
  static const String remoteAnalysis = 'Remote AI Analysis';
  static const String cloudBasedModel = 'Cloud-based AI model for enhanced accuracy';

  // PDF Reports
  static const String pdfSavedSuccessfully = 'PDF report saved successfully';
  static const String pdfSaveFailed = 'Failed to save PDF';
  static const String scientificReport = 'Scientific Algae Analysis Report';
  static const String marineSystem = 'Marine Algae Analysis System';
  static const String reportDate = 'Report Date';
  static const String reportTime = 'Report Time';
  static const String notSpecified = 'Not specified';
}

// ==================== BUTTON STRINGS ====================
class ButtonStrings {
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String confirm = 'Confirm';
  static const String delete = 'Delete';
  static const String clear = 'Clear';
  static const String ok = 'OK';
  static const String save = 'Save';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String finish = 'Finish';
}

// ==================== ERROR STRINGS ====================
class ErrorStrings {
  static const String imagePickError = 'Error picking image';
  static const String imageCheckError = 'Error checking image file';
  static const String apiConnectionError = 'API Connection Error';
  static const String imageTooLarge = 'Image too large. Maximum 10MB';
  static const String connectionTips =
      '• Check internet connection\n'
      '• Verify image validity\n'
      '• Try again';
  static const String pdfGenerationError = 'PDF generation error';
  static const String pdfSaveFailed = 'Failed to save PDF';
  static const String noDataAvailable = 'No data available for report';
}

// ==================== SUCCESS STRINGS ====================
class SuccessStrings {
  static const String pdfSaved = 'PDF saved to:';
  static const String analysisComplete = 'Analysis complete';
  static const String connectedSuccessfully = 'API connected successfully';
}

// ==================== WARNING STRINGS ====================
class WarningStrings {
  static const String pdfSaveWarning = 'Error saving PDF to downloads:';
}

// ==================== PDF STRINGS ====================
class PDFStrings {
  static const String noDataAvailable = 'No data available for report';
  static const String historicalReport = 'Historical Analysis Report';
  static const String archivedReport = 'BioAlga AI - Archived Report';
  static const String date = 'Date';
  static const String time = 'Time';
  static const String notSpecified = 'Not specified';
  static const String unknown = 'Unknown';
  static const String archivedReportTitle = 'Archived Analysis Report';
  static const String analyzedImage = 'Analyzed Image:';
  static const String analysisResults = 'Analysis Results';
  static const String algaeType = 'Algae Type:';
  static const String scientificName = 'Scientific Name:';
  static const String confidenceLevel = 'Confidence Level:';
  static const String confidenceRating = 'Confidence Rating:';
  static const String status = 'Status:';
  static const String toxicHandleCare = 'Toxic - Handle with Care';
  static const String safe = 'Safe';
  static const String remoteApiAnalysis = 'Originally analyzed using remote AI API';
  static const String benefits = 'Benefits:';
  static const String applications = 'Applications:';
  static const String note = 'Note:';
  static const String reportBasedOnAnalysis = 'This report is based on analysis conducted on';
  static const String dataAsRecorded = 'Data displayed as recorded during the original analysis.';
  static const String copyright = 'BioAlga AI ©';
  static const String allRightsReserved = 'All rights reserved';
  static const String appName = 'BioAlga AI';
  static const String marineSystem = 'Marine Algae Analysis System';
  static const String reportDate = 'Report Date:';
  static const String reportTime = 'Report Time:';
  static const String scientificReport = 'Scientific Algae Analysis Report';
  static const String toxicSpecies = 'Toxic Species - Handle with Care';
  static const String safeSpecies = 'Safe Species';
  static const String analyzedSample = 'Analyzed Sample Image';
  static const String primaryIdentification = 'Primary Identification Result';
  static const String algaeName = 'Algae Name';
  static const String safetyStatus = 'Safety Status';
  static const String handleCare = 'Handle with Care';
  static const String safeHandling = 'Safe for Handling';
  static const String scientificClassification = 'Scientific Classification';
  static const String kingdom = 'Kingdom';
  static const String phylum = 'Phylum';
  static const String classification = 'Classification';
  static const String habitat = 'Habitat';
  static const String primaryCharacteristics = 'Primary Characteristics';
  static const String protista = 'Protista';
  static const String cyanobacteria = 'Cyanobacteria';
  static const String bacillariophyta = 'Bacillariophyta/Chlorophyta';
  static const String toxicCyanobacteria = 'Toxic Cyanobacteria';
  static const String nonToxicAlgae = 'Non-toxic Algae';
  static const String freshwaterMarine = 'Freshwater/Marine environments';
  static const String aquaticOrganism = 'Aquatic photosynthetic organism';
  static const String technicalInformation = 'Technical Information';
  static const String remoteApiService = 'Analysis performed using remote AI API service';
  static const String processingTime = 'Processing time';
  static const String milliseconds = 'milliseconds';
  static const String apiEndpoint = 'API endpoint';
  static const String remoteAiAnalysis = 'Remote AI Analysis';
  static const String cloudBasedModel = 'This analysis was performed using a cloud-based AI model for enhanced accuracy';
  static const String importantNotes = 'Important Notes';
  static const String autoGenerated = 'This report was automatically generated by BioAlga AI system';
  static const String researchPurposes = 'Results are for research and educational purposes';
  static const String consultSpecialists = 'Consultation with specialists is recommended for practical applications';
  static const String cloudBasedModels = 'Cloud-based AI models ensure consistent and up-to-date analysis';

  // Algae habitat descriptions
  static const String habitatAnabaena = 'Freshwater lakes, ponds, slow-moving rivers';
  static const String habitatAphanizomenon = 'Nutrient-rich freshwater systems, lakes, reservoirs';
  static const String habitatGymnodinium = 'Marine and brackish waters worldwide';
  static const String habitatKarenia = 'Coastal marine waters, warm temperate to tropical regions';
  static const String habitatMicrocystis = 'Nutrient-rich freshwater lakes worldwide';
  static const String habitatNoctiluca = 'Coastal marine waters worldwide';
  static const String habitatNodularia = 'Brackish waters, estuaries, Baltic Sea';
  static const String habitatNostoc = 'Diverse habitats including freshwater, terrestrial';
  static const String habitatOscillatoria = 'Freshwater systems, wastewater treatment plants';
  static const String habitatProrocentrum = 'Coastal marine waters, coral reefs';
  static const String habitatSkeletonema = 'Coastal and oceanic waters worldwide';
  static const String habitatNontoxic = 'Various aquatic environments';
  static const String habitatDefault = 'Aquatic environments';

  // Algae characteristics
  static const String characteristicsAnabaena = 'Filamentous, forms chains of cells, capable of nitrogen fixation';
  static const String characteristicsAphanizomenon = 'Forms straight or slightly curved filaments, surface blooms';
  static const String characteristicsGymnodinium = 'Unarmored dinoflagellate, two flagella for movement';
  static const String characteristicsKarenia = 'Golden-brown color, unarmored, photosynthetic';
  static const String characteristicsMicrocystis = 'Forms irregular colonies, gas vesicles for buoyancy';
  static const String characteristicsNoctiluca = 'Large spherical cells, bioluminescent';
  static const String characteristicsNodularia = 'Straight filaments, barrel-shaped cells';
  static const String characteristicsNostoc = 'Forms gelatinous colonies, nitrogen-fixing';
  static const String characteristicsOscillatoria = 'Long straight filaments, gliding movement';
  static const String characteristicsProrocentrum = 'Armored with protective plates, photosynthetic';
  static const String characteristicsSkeletonema = 'Forms long chains, cylindrical cells';
  static const String characteristicsNontoxic = 'Safe for aquatic ecosystems, supports healthy food webs';
  static const String characteristicsDefault = 'Aquatic photosynthetic organism';
}