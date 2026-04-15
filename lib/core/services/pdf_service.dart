// lib/core/services/pdf_service.dart
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
      // Load font (Cairo for Arabic support)
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

  // ================= GENERATE FROM AlgaeResult (COMPLETE) =================
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

              // Title with Arabic name
              _buildTitle(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Image section
              if (imageBytes != null) _buildImageSection(imageBytes, font),

              pw.SizedBox(height: PDFSizes.largeSpacing),

              // Main result card
              _buildMainResult(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // NEW: Scientific Warning (important)
              if (result.scientificWarning.isNotEmpty)
                _buildScientificWarning(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // NEW: Toxins and Safety Details
              _buildToxinsAndSafety(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Scientific classification
              _buildScientificInfo(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // NEW: CO2 and Commercial Info
              _buildEnvironmentalAndCommercialInfo(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Benefits and Uses
              _buildBenefitsAndUses(result, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Technical information
              _buildTechnicalInfo(result, font),

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

  // ================= GENERATE FROM HISTORY DATA =================
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

              _buildHistoryTitle(historyData, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Image
              if (imageBytes != null) _buildImageSection(imageBytes, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Analysis results container
              _buildHistoryResults(historyData, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              // Benefits and Uses from history
              if (historyData['benefits'] is List && (historyData['benefits'] as List).isNotEmpty)
                _buildHistoryBenefitsAndUses(historyData, font),

              pw.SizedBox(height: PDFSizes.sectionSpacing),

              _buildHistoryFooter(font, historyData),
            ],
          );
        },
      ),
    );

    await _savePDF(pdf, 'History_${historyData['date']}_${historyData['algaeType']}');
  }

  // ================= BUILDER FUNCTIONS =================

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
              AppStrings.appName,
              style: pw.TextStyle(
                font: font,
                fontSize: PDFSizes.headerFontSize,
                fontWeight: pw.FontWeight.bold,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
            pw.Text(
              AppStrings.marineSystem,
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
          // Arabic name
          if (result.arabicName.isNotEmpty)
            pw.Text(
              result.arabicName,
              style: pw.TextStyle(
                font: font,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
          // Scientific name
          pw.Text(
            result.scientificName,
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: result.isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              result.isToxic ? 'TOXIC SPECIES' : 'NON-TOXIC',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
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
            color: AppColorsPDF.primaryBlue,
          ),
        ),
        pw.SizedBox(height: PDFSizes.smallSpacing),
        pw.Center(
          child: pw.Container(
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
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
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: AppColorsPDF.primaryBlue, width: 1.5),
        boxShadow: const [
          pw.BoxShadow(
            color: PdfColors.grey200,
            blurRadius: 4,
          ),
        ],
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'PRIMARY IDENTIFICATION RESULT',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: AppColorsPDF.lightGreen, thickness: 1),
          pw.SizedBox(height: PDFSizes.mediumSpacing),

          _buildInfoRow('Algae Name', result.name, font),
          _buildInfoRow('Scientific Name', result.scientificName, font),
          if (result.arabicName.isNotEmpty)
            _buildInfoRow('Arabic Name', result.arabicName, font),
          _buildInfoRow('Category', result.category, font),

          pw.SizedBox(height: PDFSizes.mediumSpacing),

          pw.Row(
            children: [
              pw.Expanded(
                child: _buildMetricCard(
                  'Confidence',
                  '$confidencePercent%',
                  confidenceColor,
                  result.confidenceLevel,
                  font,
                ),
              ),
              pw.SizedBox(width: PDFSizes.smallSpacing),
              pw.Expanded(
                child: _buildMetricCard(
                  'Safety Status',
                  result.isToxic ? 'TOXIC' : 'SAFE',
                  result.isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
                  result.isToxic ? 'Handle with Care' : 'Safe for Handling',
                  font,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildScientificWarning(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: AppColorsPDF.errorBackground,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: AppColorsPDF.errorBorder, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Text(
                '! ',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.Text(
                'SCIENTIFIC WARNING',
                style: pw.TextStyle(
                  font: font,
                  fontSize: PDFSizes.mediumFontSize,
                  fontWeight: pw.FontWeight.bold,
                  color: AppColorsPDF.errorText,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Text(
            result.scientificWarning,
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.smallFontSize,
              color: AppColorsPDF.errorText,
              lineSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildToxinsAndSafety(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'TOXINS AND SAFETY INFORMATION',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: PDFSizes.smallSpacing),

          _buildInfoRow('Toxicity Warning', result.toxicityWarning, font),

          if (result.potentialToxins.isNotEmpty) ...[
            pw.SizedBox(height: PDFSizes.smallSpacing),
            pw.Text(
              'Potential Toxins:',
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: PDFSizes.smallFontSize,
              ),
            ),
            pw.SizedBox(height: 4),
            ...result.potentialToxins.map((toxin) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
              child: pw.Row(
                children: [
                  pw.Text('- ', style: pw.TextStyle(font: font)),
                  pw.Expanded(
                    child: pw.Text(
                      toxin,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.smallFontSize,
                        color: result.isToxic ? AppColorsPDF.errorText : PdfColors.grey700,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildScientificInfo(AlgaeResult result, pw.Font font) {
    final algaeInfo = _getDetailedAlgaeInfo(result.name);

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SCIENTIFIC CLASSIFICATION',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: PDFSizes.smallSpacing),

          _buildInfoRow('Domain', 'Bacteria / Eukaryota', font),
          _buildInfoRow('Phylum', _getPhylum(result.name), font),
          _buildInfoRow('Class', _getClass(result.name), font),
          _buildInfoRow('Order', _getOrder(result.name), font),
          _buildInfoRow('Family', _getFamily(result.name), font),
          _buildInfoRow('Genus', result.name, font),
          _buildInfoRow('Habitat', algaeInfo['habitat'] ?? 'Various aquatic environments', font),
        ],
      ),
    );
  }

  static pw.Widget _buildEnvironmentalAndCommercialInfo(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: AppColorsPDF.infoBackground,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: AppColorsPDF.infoBorder),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ENVIRONMENTAL AND COMMERCIAL INFORMATION',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.infoText,
            ),
          ),
          pw.Divider(color: AppColorsPDF.infoBorder),
          pw.SizedBox(height: PDFSizes.smallSpacing),

          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'CO2 Sequestration',
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: PDFSizes.smallFontSize,
                      ),
                    ),
                    pw.Text(
                      result.co2PerKg > 0
                          ? '~ ${result.co2PerKg.toStringAsFixed(2)} kg CO2/kg dry biomass'
                          : 'Not applicable (heterotrophic)',
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.smallFontSize,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: PDFSizes.smallSpacing),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Commercial Viability',
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: PDFSizes.smallFontSize,
                      ),
                    ),
                    pw.Text(
                      result.sellable,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: PDFSizes.smallFontSize,
                        color: result.sellable.contains('Yes') ? AppColorsPDF.successText :
                        (result.sellable.contains('No') ? AppColorsPDF.errorText : AppColorsPDF.warningOrange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                  'BENEFITS',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.mediumFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: AppColorsPDF.primaryBlue,
                  ),
                ),
                pw.SizedBox(height: PDFSizes.smallSpacing),
                ...result.benefits.map((benefit) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('- ', style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize)),
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
                  'APPLICATIONS',
                  style: pw.TextStyle(
                    font: font,
                    fontSize: PDFSizes.mediumFontSize,
                    fontWeight: pw.FontWeight.bold,
                    color: AppColorsPDF.primaryBlue,
                  ),
                ),
                pw.SizedBox(height: PDFSizes.smallSpacing),
                ...result.uses.map((use) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 6),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('- ', style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize)),
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
            'TECHNICAL INFORMATION',
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
              '- Analysis performed using remote AI API service',
              style: pw.TextStyle(font: font, fontSize: PDFSizes.xsmallFontSize, color: AppColorsPDF.infoText),
            ),

          pw.Text(
            '- Processing time: ${modelInfo['processingTime'] ?? 0} milliseconds',
            style: pw.TextStyle(font: font, fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey600),
          ),

          if (modelInfo.containsKey('endpoint'))
            pw.Text(
              '- API endpoint: ${modelInfo['endpoint']}',
              style: pw.TextStyle(font: font, fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey600),
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
            'IMPORTANT NOTES',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.smallFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Text(
            '- This report was automatically generated by BioAlga AI system\n'
                '- Results are for research and educational purposes only\n'
                '- Consultation with specialists is recommended for practical applications\n'
                '- Cloud-based AI models ensure consistent and up-to-date analysis',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.xsmallFontSize,
              color: PdfColors.grey600,
              lineSpacing: 1.2,
            ),
          ),
          pw.SizedBox(height: PDFSizes.mediumSpacing),
          pw.Text(
            '(c) ${DateTime.now().year} BioAlga - All Rights Reserved',
            style: pw.TextStyle(fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ================= HISTORY BUILDERS =================

  static pw.Widget _buildHistoryTitle(Map<String, dynamic> historyData, pw.Font font) {
    final isToxic = historyData['isToxic'] == true;
    final name = historyData['algaeType'] ?? 'Unknown';
    final arabicName = historyData['arabicName'] ?? '';

    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(PDFSizes.cardPaddingLarge),
      decoration: pw.BoxDecoration(
        color: isToxic ? AppColorsPDF.errorBackground : AppColorsPDF.backgroundLight,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: isToxic ? AppColorsPDF.errorBorder : AppColorsPDF.accentGreen, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (arabicName.isNotEmpty)
            pw.Text(
              arabicName,
              style: pw.TextStyle(
                font: font,
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
          pw.Text(
            name,
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: pw.BoxDecoration(
              color: isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              isToxic ? 'TOXIC SPECIES (Archived)' : 'NON-TOXIC (Archived)',
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildHistoryResults(Map<String, dynamic> historyData, pw.Font font) {
    final confidence = ((historyData['confidence'] as num?)?.toDouble() ?? 0.0) * 100;
    final isToxic = historyData['isToxic'] == true;
    final scientificWarning = historyData['scientificWarning'] ?? 'Toxicity depends on specific strain. Consult expert for verification.';

    return pw.Container(
      padding: const pw.EdgeInsets.all(PDFSizes.cardPaddingLarge),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
        border: pw.Border.all(color: AppColorsPDF.primaryBlue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ANALYSIS RESULTS',
            style: pw.TextStyle(
              font: font,
              fontSize: PDFSizes.mediumFontSize,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: PDFSizes.mediumSpacing),

          _buildInfoRow('Algae Type', historyData['algaeType'] ?? 'Unknown', font),
          _buildInfoRow('Scientific Name', historyData['scientificName'] ?? 'Unknown', font),
          if (historyData['arabicName'] != null)
            _buildInfoRow('Arabic Name', historyData['arabicName'], font),
          _buildInfoRow('Confidence', '${confidence.toStringAsFixed(1)}%', font),
          _buildInfoRow('Status', isToxic ? 'TOXIC - Handle with Care' : 'SAFE', font),

          if (scientificWarning.isNotEmpty) ...[
            pw.SizedBox(height: PDFSizes.mediumSpacing),
            pw.Container(
              padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
              decoration: pw.BoxDecoration(
                color: AppColorsPDF.errorBackground,
                borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
                border: pw.Border.all(color: AppColorsPDF.errorBorder),
              ),
              child: pw.Text(
                '! $scientificWarning',
                style: pw.TextStyle(
                  font: font,
                  fontSize: PDFSizes.smallFontSize,
                  color: AppColorsPDF.errorText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildHistoryBenefitsAndUses(Map<String, dynamic> historyData, pw.Font font) {
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
                pw.Text('BENEFITS', style: pw.TextStyle(font: font, fontSize: PDFSizes.mediumFontSize, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: PDFSizes.smallSpacing),
                ...(historyData['benefits'] as List).map((benefit) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('- $benefit', style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize)),
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
                pw.Text('APPLICATIONS', style: pw.TextStyle(font: font, fontSize: PDFSizes.mediumFontSize, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: PDFSizes.smallSpacing),
                ...(historyData['uses'] as List).map((use) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text('- $use', style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize)),
                )).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildHistoryFooter(pw.Font font, Map<String, dynamic> historyData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(PDFSizes.cardPadding),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(PDFSizes.borderRadius),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'NOTE',
            style: pw.TextStyle(font: font, fontSize: PDFSizes.smallFontSize, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: PDFSizes.smallSpacing),
          pw.Text(
            'This report is based on analysis conducted on ${historyData['date']}. Data displayed as recorded during the original analysis.',
            style: pw.TextStyle(font: font, fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: PDFSizes.mediumSpacing),
          pw.Text(
            '(c) ${DateTime.now().year} BioAlga - All Rights Reserved',
            style: pw.TextStyle(fontSize: PDFSizes.xsmallFontSize, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  // ================= HELPER FUNCTIONS =================

  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 130,
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

  static pw.Widget _buildMetricCard(String title, String value, PdfColor color, String subtitle, pw.Font font) {
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
    const cyanobacteria = ['Anabaena', 'Aphanizomenon', 'Microcystis', 'Nodularia', 'Nostoc', 'Oscillatoria'];
    if (cyanobacteria.contains(algaeName)) return 'Cyanobacteria';
    return 'Bacillariophyta / Dinoflagellata';
  }

  static String _getClass(String algaeName) {
    const cyanobacteria = ['Anabaena', 'Aphanizomenon', 'Microcystis', 'Nodularia', 'Nostoc', 'Oscillatoria'];
    const diatoms = ['Skeletonema'];
    if (cyanobacteria.contains(algaeName)) return 'Cyanophyceae';
    if (diatoms.contains(algaeName)) return 'Bacillariophyceae';
    return 'Dinophyceae';
  }

  static String _getOrder(String algaeName) {
    const orders = {
      'Anabaena': 'Nostocales',
      'Nostoc': 'Nostocales',
      'Microcystis': 'Chroococcales',
      'Skeletonema': 'Thalassiosirales',
      'Karenia': 'Gymnodiniales',
      'Gymnodinium': 'Gymnodiniales',
    };
    return orders[algaeName] ?? 'Various';
  }

  static String _getFamily(String algaeName) {
    const families = {
      'Anabaena': 'Nostocaceae',
      'Nostoc': 'Nostocaceae',
      'Microcystis': 'Microcystaceae',
      'Skeletonema': 'Skeletonemataceae',
      'Karenia': 'Kareniaceae',
    };
    return families[algaeName] ?? 'Various';
  }

  static Map<String, String> _getDetailedAlgaeInfo(String type) {
    const algaeData = {
      'Anabaena': {'habitat': 'Freshwater lakes, ponds, slow-moving rivers', 'characteristics': 'Filamentous, forms chains of cells, capable of nitrogen fixation'},
      'Aphanizomenon': {'habitat': 'Nutrient-rich freshwater systems, lakes, reservoirs', 'characteristics': 'Forms straight or slightly curved filaments, surface blooms'},
      'Gymnodinium': {'habitat': 'Marine and brackish waters worldwide', 'characteristics': 'Unarmored dinoflagellate, two flagella for movement'},
      'Karenia': {'habitat': 'Coastal marine waters, warm temperate to tropical regions', 'characteristics': 'Golden-brown color, unarmored, photosynthetic'},
      'Microcystis': {'habitat': 'Nutrient-rich freshwater lakes worldwide', 'characteristics': 'Forms irregular colonies, gas vesicles for buoyancy'},
      'Noctiluca': {'habitat': 'Coastal marine waters worldwide', 'characteristics': 'Large spherical cells, bioluminescent, heterotrophic'},
      'Nodularia': {'habitat': 'Brackish waters, estuaries, Baltic Sea', 'characteristics': 'Straight filaments, barrel-shaped cells'},
      'Nostoc': {'habitat': 'Diverse habitats including freshwater, terrestrial', 'characteristics': 'Forms gelatinous colonies, nitrogen-fixing'},
      'Oscillatoria': {'habitat': 'Freshwater systems, wastewater treatment plants', 'characteristics': 'Long straight filaments, gliding movement'},
      'Prorocentrum': {'habitat': 'Coastal marine waters, coral reefs', 'characteristics': 'Armored with protective plates, photosynthetic'},
      'Skeletonema': {'habitat': 'Coastal and oceanic waters worldwide', 'characteristics': 'Forms long chains, cylindrical cells'},
    };
    return algaeData[type] ?? {'habitat': 'Various aquatic environments', 'characteristics': 'Aquatic photosynthetic organism'};
  }

  static String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  static PdfColor _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppColorsPDF.confidenceHigh;
    if (confidence >= 0.7) return AppColorsPDF.confidenceMedium;
    return AppColorsPDF.confidenceLow;
  }

  static Future<void> _savePDF(pw.Document pdf, String name) async {
    try {
      final dir = await getDownloadsDirectory();
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