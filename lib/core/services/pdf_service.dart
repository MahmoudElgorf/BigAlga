import 'dart:io';
import 'dart:typed_data';
import 'package:bioalga/core/constants/constants.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../data/models/algae_model.dart';

class PDFService {
  // Main function
  static Future<void> generateAndSaveReport({
    required File imageFile,
    AlgaeResult? result,
    Map<String, dynamic>? historyData,
  }) async {
    try {
      // Load font
      final fontData = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
      final font = pw.Font.ttf(fontData);

      if (result != null) {
        await _generateFromAlgaeResult(result, imageFile, font);
      } else if (historyData != null) {
        await _generateFromHistoryData(historyData, imageFile, font);
      } else {
        throw Exception(PDFStrings.noDataAvailable);
      }
    } catch (e) {
      print('${ErrorStrings.pdfGenerationError}: $e');
      rethrow;
    }
  }

  // Generate from AlgaeResult
  static Future<void> _generateFromAlgaeResult(
      AlgaeResult result,
      File imageFile,
      pw.Font font,
      ) async {
    final pdf = pw.Document();

    // Load logo
    final logoBytes = await rootBundle.load(AppAssets.appLogo);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Read image
    Uint8List? imageBytes;
    if (await imageFile.exists()) {
      imageBytes = await imageFile.readAsBytes();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(PDFSizes.pageMargin),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with logo
              _buildHeader(logo, result.dateTime, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Title
              _buildTitle(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Image section
              if (imageBytes != null) _buildImageSection(imageBytes, font),

              pw.SizedBox(height: PDFSizes.largeSpacing),

              // Main result
              _buildMainResult(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Scientific information
              _buildScientificInfo(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Benefits and Uses
              _buildBenefitsAndUses(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Technical information
              _buildTechnicalInfo(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // API Information badge
              _buildApiInfoBadge(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Footer
              _buildFooter(font),
            ],
          );
        },
      ),
    );

    await _savePDF(pdf, 'Algae_Analysis_${result.name}');
  }

  // Generate from History Data
  static Future<void> _generateFromHistoryData(
      Map<String, dynamic> historyData,
      File imageFile,
      pw.Font font,
      ) async {
    final pdf = pw.Document();

    // Load logo
    final logoBytes = await rootBundle.load(AppAssets.appLogo);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Read image
    Uint8List? imageBytes;
    if (await imageFile.exists()) {
      imageBytes = await imageFile.readAsBytes();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(PDFSizes.pageMargin),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(logo, width: PDFSizes.logoWidth, height: PDFSizes.logoHeight),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        PDFStrings.historicalReport,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: PDFSizes.titleFontSize,
                          fontWeight: pw.FontWeight.bold,
                          color: AppColorsPDF.primaryBlue,
                        ),
                      ),
                      pw.Text(
                        PDFStrings.archivedReport,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: PDFSizes.subtitleFontSize,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.SizedBox(height: PDFSizes.smallSpacing),
                      pw.Text(
                        '${PDFStrings.date}: ${historyData['date'] ?? PDFStrings.notSpecified}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: PDFSizes.smallFontSize,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        '${PDFStrings.time}: ${historyData['time'] ?? PDFStrings.notSpecified}',
                        style: pw.TextStyle(
                          font: font,
                          fontSize: PDFSizes.smallFontSize,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Title
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
                decoration: pw.BoxDecoration(
                  color: AppColorsPDF.backgroundLight,
                  borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
                  border: pw.Border.all(color: AppColorsPDF.primaryBlue),
                ),
                child: pw.Text(
                  PDFStrings.archivedReportTitle,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.largeFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: AppColorsPDF.primaryBlue,
                  ),
                ),
              ),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Image
              if (imageBytes != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      PDFStrings.analyzedImage,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.mediumFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: PDFSizes.smallSpacing),
                    pw.Image(
                      pw.MemoryImage(imageBytes),
                      width: PDFSizes.imageWidth,
                      height: PDFSizes.imageHeight,
                      fit: pw.BoxFit.cover,
                    ),
                    pw.SizedBox(height: PDFSizes.sectionSpacing),
                  ],
                ),

              // Analysis results
              pw.Container(
                padding: const pw.EdgeInsets.all(PDFSizes.cardPaddingLarge),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      PDFStrings.analysisResults,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.mediumFontSize,
                        fontWeight: pw.FontWeight.bold,
                        color: AppColorsPDF.primaryBlue,
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey400),
                    pw.SizedBox(height: PDFSizes.mediumSpacing),

                    _buildHistoryRow(PDFStrings.algaeType, historyData['name'] ?? PDFStrings.unknown, font),
                    _buildHistoryRow(PDFStrings.scientificName, historyData['scientificName'] ?? PDFStrings.unknown, font),
                    _buildHistoryRow(PDFStrings.confidenceLevel, '${((historyData['confidence'] as num?)?.toDouble() ?? 0.0) * 100}%', font),
                    _buildHistoryRow(PDFStrings.confidenceRating, historyData['confidenceLevel'] ?? PDFStrings.notSpecified, font),
                    _buildHistoryRow(PDFStrings.status, (historyData['isToxic'] == true) ? PDFStrings.toxicHandleCare : PDFStrings.safe, font),
                  ],
                ),
              ),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // API Information
              pw.Container(
                padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
                decoration: pw.BoxDecoration(
                  color: AppColorsPDF.infoBackground,
                  borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
                  border: pw.Border.all(color: AppColorsPDF.infoBorder),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      '🌐 ',
                      style: pw.TextStyle(fontSize: PDFSizes.iconFontSize),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        PDFStrings.remoteApiAnalysis,
                        style: pw.TextStyle(
                          font: font,
                          fontSize: PDFSizes.smallFontSize,
                          color: AppColorsPDF.infoText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: PDFSizes.mediumSpacing),

              // Benefits
              if (historyData['benefits'] is List && (historyData['benefits'] as List).isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      PDFStrings.benefits,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.mediumFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: PDFSizes.smallSpacing),
                    ...(historyData['benefits'] as List).map((benefit) =>
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('• ', style: pw.TextStyle(font: font)),
                              pw.Expanded(
                                child: pw.Text(
                                  benefit.toString(),
                                  style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize),
                                ),
                              ),
                            ],
                          ),
                        )
                    ).toList(),
                    pw.SizedBox(height: PDFSizes.mediumSpacing),
                  ],
                ),

              // Uses
              if (historyData['uses'] is List && (historyData['uses'] as List).isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      PDFStrings.applications,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.mediumFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: PDFSizes.smallSpacing),
                    ...(historyData['uses'] as List).map((use) =>
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 4),
                          child: pw.Row(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('• ', style: pw.TextStyle(font: font)),
                              pw.Expanded(
                                child: pw.Text(
                                  use.toString(),
                                  style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize),
                                ),
                              ),
                            ],
                          ),
                        )
                    ).toList(),
                  ],
                ),

              pw.SizedBox(height: PDFSizes.largeSpacing),

              // Footer note
              pw.Container(
                padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      PDFStrings.note,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.smallFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: PDFSizes.smallSpacing),
                    pw.Text(
                      '${PDFStrings.reportBasedOnAnalysis} ${historyData['date']}. '
                          '${PDFStrings.dataAsRecorded}',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.xsmallFontSize,
                        color: PdfColors.grey600,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: PDFSizes.mediumSpacing),

              pw.Text(
                '${PDFStrings.copyright} ${DateTime.now().year} - ${PDFStrings.allRightsReserved}',
                style: pw.TextStyle(fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey500),
              ),
            ],
          );
        },
      ),
    );

    await _savePDF(pdf, 'History_${historyData['date']}_${historyData['name']}');
  }

  // ================= Helper Functions =================

  static pw.Widget _buildHeader(pw.ImageProvider logo, DateTime dateTime, pw.Font font) {
    final year = dateTime.year;
    final month = _twoDigits(dateTime.month);
    final day = _twoDigits(dateTime.day);
    final hour = _twoDigits(dateTime.hour);
    final minute = _twoDigits(dateTime.minute);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Image(logo, width: PDFSizes.headerLogoWidth, height: PDFSizes.headerLogoHeight),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              PDFStrings.appName,
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.headerFontSize,
                fontWeight: pw.FontWeight.bold,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
            pw.Text(
              PDFStrings.marineSystem,
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.subtitleFontSize,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: PDFSizes.smallSpacing),
            pw.Text(
              '${PDFStrings.reportDate}: $year-$month-$day',
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.xsmallFontSize,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              '${PDFStrings.reportTime}: $hour:$minute',
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.xsmallFontSize,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTitle(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPaddingLarge),
      decoration: pw.BoxDecoration(
        color: result.isToxic ? AppColorsPDF.errorBackground : AppColorsPDF.backgroundLight,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(
          color: result.isToxic ? AppColorsPDF.errorBorder : AppColorsPDF.accentGreen,
          width: 2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            PDFStrings.scientificReport,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.largeFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Text(
            result.isToxic ? PDFStrings.toxicSpecies : PDFStrings.safeSpecies,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              color: result.isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildImageSection(Uint8List imageBytes, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          PDFStrings.analyzedSample,
          style: pw.TextStyle(
            font: font,
            fontSize: PDFSizes.mediumFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: PDFSizes.smallSpacing),
        pw.Container(
          decoration: pw.BoxDecoration(
            borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
            border: pw.Border.all(color: PdfColors.grey300),
            boxShadow: const [
              pw.BoxShadow(
                color: PdfColors.grey400,
                blurRadius: 5,
              ),
            ],
          ),
          child: pw.Image(
            pw.MemoryImage(imageBytes),
            width: PDFSizes.largeImageWidth,
            height: PDFSizes.largeImageHeight,
            fit: pw.BoxFit.cover,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildMainResult(AlgaeResult result, pw.Font font) {
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);
    final confidenceColor = _getConfidenceColor(result.confidence);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPaddingLarge),
      decoration: pw.BoxDecoration(
        color: AppColorsPDF.backgroundLight,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: AppColorsPDF.lightGreen, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            PDFStrings.primaryIdentification,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.largeFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: AppColorsPDF.lightGreen, thickness: 1),
          pw.SizedBox(height: PDFSizes.mediumSpacing),

          _buildInfoRow(PDFStrings.algaeName, result.name, font),
          _buildInfoRow(PDFStrings.scientificName, result.scientificName, font),

          pw.SizedBox(height: PDFSizes.mediumSpacing),

          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetricCard(
                  PDFStrings.confidenceLevel,
                  '$confidencePercent%',
                  confidenceColor,
                  result.confidenceLevel,
                  font,
                ),
              ),
              pw.SizedBox(width: PDFSizes.smallSpacing),
              pw.Expanded(
                child: _buildMetricCard(
                  PDFStrings.safetyStatus,
                  result.isToxic ? AppStrings.toxic : PDFStrings.safe,
                  result.isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
                  result.isToxic ? PDFStrings.handleCare : PDFStrings.safeHandling,
                  font,
                ),
              ),
            ],
          ),

          if (result.isToxic)
            pw.Container(
              margin: const pw.EdgeInsets.only(top: PDFSizes.mediumSpacing),
              padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
              decoration: pw.BoxDecoration(
                color: AppColorsPDF.errorBackground,
                borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
                border: pw.Border.all(color: AppColorsPDF.errorBorder),
              ),
              child: pw.Row(
                children: [
                  pw.SizedBox(width: PDFSizes.smallSpacing),
                  pw.Expanded(
                    child: pw.Text(
                      result.toxicityWarning,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.smallFontSize,
                        color: AppColorsPDF.errorText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildScientificInfo(AlgaeResult result, pw.Font font) {
    final algaeInfo = _getDetailedAlgaeInfo(result.name);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPaddingLarge),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            PDFStrings.scientificClassification,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.largeFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400, thickness: 1),
          pw.SizedBox(height: PDFSizes.mediumSpacing),

          _buildInfoRow(PDFStrings.kingdom, PDFStrings.protista, font),
          _buildInfoRow(PDFStrings.phylum, _getPhylum(result.name), font),
          _buildInfoRow(PDFStrings.classification, result.isToxic ? PDFStrings.toxicCyanobacteria : PDFStrings.nonToxicAlgae, font),
          _buildInfoRow(PDFStrings.habitat, algaeInfo['habitat'] ?? PDFStrings.freshwaterMarine, font),
          _buildInfoRow(PDFStrings.primaryCharacteristics, algaeInfo['characteristics'] ?? PDFStrings.aquaticOrganism, font),
        ],
      ),
    );
  }

  static pw.Widget _buildBenefitsAndUses(AlgaeResult result, pw.Font font) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
            decoration: pw.BoxDecoration(
              color: AppColorsPDF.backgroundLight,
              borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
              border: pw.Border.all(color: AppColorsPDF.accentGreen),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  PDFStrings.benefits,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.mediumFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: AppColorsPDF.primaryBlue,
                  ),
                ),
                pw.SizedBox(height: PDFSizes.smallSpacing),
                ...result.benefits.map((benefit) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ', style: pw.TextStyle(font: font)),
                      pw.Expanded(
                        child: pw.Text(
                          benefit,
                          style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),

        pw.SizedBox(width: PDFSizes.smallSpacing),

        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
            decoration: pw.BoxDecoration(
              color: AppColorsPDF.backgroundLight,
              borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
              border: pw.Border.all(color: AppColorsPDF.lightGreen),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  PDFStrings.applications,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.mediumFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: AppColorsPDF.primaryBlue,
                  ),
                ),
                pw.SizedBox(height: PDFSizes.smallSpacing),
                ...result.uses.map((use) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ', style: pw.TextStyle(font: font)),
                      pw.Expanded(
                        child: pw.Text(
                          use,
                          style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTechnicalInfo(AlgaeResult result, pw.Font font) {
    final modelInfo = result.modelInfo;
    final isApiUsed = modelInfo['apiUsed'] == true;

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            PDFStrings.technicalInformation,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),

          if (isApiUsed)
            pw.Text(
              PDFStrings.remoteApiService,
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.xsmallFontSize,
                color: AppColorsPDF.infoText,
              ),
            ),

          pw.Text(
            '${PDFStrings.processingTime}: ${modelInfo['processingTime'] ?? 0} ${PDFStrings.milliseconds}',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.xsmallFontSize,
              color: PdfColors.grey600,
            ),
          ),

          if (modelInfo.containsKey('endpoint'))
            pw.Text(
              '${PDFStrings.apiEndpoint}: ${modelInfo['endpoint']}',
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.xsmallFontSize,
                color: PdfColors.grey600,
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildApiInfoBadge(AlgaeResult result, pw.Font font) {
    if (result.modelInfo['apiUsed'] != true) return pw.SizedBox.shrink();

    return pw.Container(
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: AppColorsPDF.infoBackground,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: AppColorsPDF.infoBorder),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            '🌐 ',
            style: pw.TextStyle(fontSize: PDFSizes.iconFontSize),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  PDFStrings.remoteAiAnalysis,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.smallFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: AppColorsPDF.infoText,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  PDFStrings.cloudBasedModel,
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.xsmallFontSize,
                    color: AppColorsPDF.infoText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: PDFSizes.sectionSpacing),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            PDFStrings.importantNotes,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.smallFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Text(
            '• ${PDFStrings.autoGenerated}\n'
                '• ${PDFStrings.researchPurposes}\n'
                '• ${PDFStrings.consultSpecialists}\n'
                '• ${PDFStrings.cloudBasedModels}',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.xsmallFontSize,
              color: PdfColors.grey600,
            ),
          ),
          pw.SizedBox(height: PDFSizes.mediumSpacing),
          pw.Text(
            '${PDFStrings.copyright} ${DateTime.now().year} - ${PDFStrings.allRightsReserved}',
            style: pw.TextStyle(fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ================= Helper Methods =================

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: PDFSizes.smallFontSize,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.smallFontSize,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHistoryRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: font,
              fontWeight: pw.FontWeight.bold,
              fontSize: PDFSizes.smallFontSize,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(width: 15),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.smallFontSize,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMetricCard(
      String title,
      String value,
      PdfColor color,
      String subtitle,
      pw.Font font,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.xsmallFontSize,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: PDFSizes.largeFontSize,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.xsmallFontSize,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  static String _getPhylum(String algaeName) {
    if (algaeName == 'Anabaena' || algaeName == 'Nostoc') {
      return PDFStrings.cyanobacteria;
    }
    return PDFStrings.bacillariophyta;
  }

  static PdfColor _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppColorsPDF.confidenceHigh;
    if (confidence >= 0.7) return AppColorsPDF.confidenceMedium;
    return AppColorsPDF.confidenceLow;
  }

  // Detailed algae information
  static Map<String, String> _getDetailedAlgaeInfo(String type) {
    final algaeData = {
      'Anabaena': {
        'habitat': PDFStrings.habitatAnabaena,
        'characteristics': PDFStrings.characteristicsAnabaena,
      },
      'Aphanizomenon': {
        'habitat': PDFStrings.habitatAphanizomenon,
        'characteristics': PDFStrings.characteristicsAphanizomenon,
      },
      'Gymnodinium': {
        'habitat': PDFStrings.habitatGymnodinium,
        'characteristics': PDFStrings.characteristicsGymnodinium,
      },
      'Karenia': {
        'habitat': PDFStrings.habitatKarenia,
        'characteristics': PDFStrings.characteristicsKarenia,
      },
      'Microcystis': {
        'habitat': PDFStrings.habitatMicrocystis,
        'characteristics': PDFStrings.characteristicsMicrocystis,
      },
      'Noctiluca': {
        'habitat': PDFStrings.habitatNoctiluca,
        'characteristics': PDFStrings.characteristicsNoctiluca,
      },
      'Nodularia': {
        'habitat': PDFStrings.habitatNodularia,
        'characteristics': PDFStrings.characteristicsNodularia,
      },
      'Nostoc': {
        'habitat': PDFStrings.habitatNostoc,
        'characteristics': PDFStrings.characteristicsNostoc,
      },
      'Oscillatoria': {
        'habitat': PDFStrings.habitatOscillatoria,
        'characteristics': PDFStrings.characteristicsOscillatoria,
      },
      'Prorocentrum': {
        'habitat': PDFStrings.habitatProrocentrum,
        'characteristics': PDFStrings.characteristicsProrocentrum,
      },
      'Skeletonema': {
        'habitat': PDFStrings.habitatSkeletonema,
        'characteristics': PDFStrings.characteristicsSkeletonema,
      },
      'nontoxic': {
        'habitat': PDFStrings.habitatNontoxic,
        'characteristics': PDFStrings.characteristicsNontoxic,
      },
    };

    return algaeData[type] ?? {
      'habitat': PDFStrings.habitatDefault,
      'characteristics': PDFStrings.characteristicsDefault,
    };
  }

  // Helper for two-digit formatting
  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // Save PDF file
  static Future<void> _savePDF(pw.Document pdf, String name) async {
    try {
      final dir = await getDownloadsDirectory();

      // Create unique filename
      final now = DateTime.now();
      final timestamp = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}';

      final fileName = '${name}_$timestamp.pdf';
      final filePath = '${dir?.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(filePath);

      print('${SuccessStrings.pdfSaved}: $filePath');
    } catch (e) {
      print('${WarningStrings.pdfSaveWarning}: $e');

      // Try saving to app directory
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'BioAlga_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);

        await file.writeAsBytes(await pdf.save());
        await OpenFile.open(filePath);

        print('${SuccessStrings.pdfSaved}: $filePath');
      } catch (e2) {
        print('${ErrorStrings.pdfSaveFailed}: $e2');
        rethrow;
      }
    }
  }
}