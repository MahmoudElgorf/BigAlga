/// PDF service for generating and saving algae analysis reports
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
  /// Generate and save PDF report from either AlgaeResult or history data
  static Future<void> generateAndSaveReport({
    required File imageFile,
    AlgaeResult? result,
    Map<String, dynamic>? historyData,
  }) async {
    try {
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
      rethrow;
    }
  }

  /// Generate PDF from AlgaeResult object
  static Future<void> _generateFromAlgaeResult(
      AlgaeResult result,
      File imageFile,
      pw.Font font,
      ) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load(AppAssets.appLogo);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    Uint8List? imageBytes;
    if (await imageFile.exists()) {
      imageBytes = await imageFile.readAsBytes();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              _buildHeader(logo, result.dateTime, font),
              pw.SizedBox(height: 8),
              _buildTitle(result, font),
              pw.SizedBox(height: 8),
              _buildImageAndInfoSection(imageBytes, result, font),
              pw.SizedBox(height: 8),
              _buildMainResult(result, font),
              pw.SizedBox(height: 8),
              if (result.scientificWarning.isNotEmpty)
                _buildScientificWarning(result, font),
              pw.SizedBox(height: 8),
              _buildToxinsAndSafety(result, font),
              pw.SizedBox(height: 8),
              _buildScientificInfo(result, font),
              pw.SizedBox(height: 8),
              _buildEnvironmentalAndCommercialInfo(result, font),
              pw.SizedBox(height: 8),
              _buildTechnicalInfo(result, font),
              pw.SizedBox(height: 8),
              _buildFooter(font),
            ],
          );
        },
      ),
    );

    await _savePDF(pdf, 'Algae_Analysis_${result.name}');
  }

  /// Generate PDF from history data
  static Future<void> _generateFromHistoryData(
      Map<String, dynamic> historyData,
      File imageFile,
      pw.Font font,
      ) async {
    final pdf = pw.Document();

    final logoBytes = await rootBundle.load(AppAssets.appLogo);
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

    Uint8List? imageBytes;
    if (await imageFile.exists()) {
      imageBytes = await imageFile.readAsBytes();
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              _buildHeader(logo, DateTime.now(), font),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 8),
              _buildHistoryTitle(historyData, font),
              pw.SizedBox(height: 8),
              _buildHistoryImageAndInfoSection(imageBytes, historyData, font),
              pw.SizedBox(height: 8),
              _buildHistoryResults(historyData, font),
              pw.SizedBox(height: 8),
              _buildHistoryFooter(font, historyData),
            ],
          );
        },
      ),
    );

    await _savePDF(pdf, 'History_${historyData['date']}_${historyData['algaeType']}');
  }

  /// Build image and info section (image on right, benefits/uses on left)
  static pw.Widget _buildImageAndInfoSection(
      Uint8List? imageBytes,
      AlgaeResult result,
      pw.Font font,
      ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 220,
          child: _buildInfoCard(result, font),
        ),
        pw.SizedBox(width: 12),
        pw.Container(
          width: 250,
          height: 250,
          child: _buildImageCard(imageBytes, font),
        ),
      ],
    );
  }

  /// Build info card with benefits and applications
  static pw.Widget _buildInfoCard(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
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
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.keyInformation,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: AppColorsPDF.lightGreen, thickness: 1),
          pw.SizedBox(height: 6),
          pw.Text(
            PDFStrings.benefitsLabel,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.successText,
            ),
          ),
          pw.SizedBox(height: 4),
          ...result.benefits.take(3).map((benefit) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 9, color: AppColorsPDF.successText)),
                pw.Container(
                  width: 180,
                  child: pw.Text(
                    benefit,
                    style: pw.TextStyle(font: font, fontSize: 9),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          )).toList(),
          pw.SizedBox(height: 6),
          pw.Text(
            PDFStrings.applicationsLabel,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(height: 4),
          ...result.uses.take(3).map((use) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 9, color: AppColorsPDF.primaryBlue)),
                pw.Container(
                  width: 180,
                  child: pw.Text(
                    use,
                    style: pw.TextStyle(font: font, fontSize: 9),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Build image card
  static pw.Widget _buildImageCard(Uint8List? imageBytes, pw.Font font) {
    if (imageBytes == null) {
      return pw.Container(
        width: 250,
        height: 250,
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(8),
          border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
        ),
        child: pw.Center(
          child: pw.Text(
            PDFStrings.noImageAvailable,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ),
      );
    }

    return pw.Container(
      width: 250,
      height: 250,
      decoration: pw.BoxDecoration(
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppColorsPDF.primaryBlue, width: 1.5),
        boxShadow: const [
          pw.BoxShadow(
            color: PdfColors.grey200,
            blurRadius: 4,
          ),
        ],
      ),
      child: pw.Image(
        pw.MemoryImage(imageBytes),
        width: 250,
        height: 250,
        fit: pw.BoxFit.cover,
      ),
    );
  }

  /// Build history image and info section
  static pw.Widget _buildHistoryImageAndInfoSection(
      Uint8List? imageBytes,
      Map<String, dynamic> historyData,
      pw.Font font,
      ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Container(
          width: 220,
          child: _buildHistoryInfoCard(historyData, font),
        ),
        pw.SizedBox(width: 12),
        pw.Container(
          width: 250,
          height: 250,
          child: _buildImageCard(imageBytes, font),
        ),
      ],
    );
  }

  /// Build history info card
  static pw.Widget _buildHistoryInfoCard(Map<String, dynamic> historyData, pw.Font font) {
    final benefits = historyData['benefits'] as List? ?? [];
    final uses = historyData['uses'] as List? ?? [];

    return pw.Container(
      width: 220,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
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
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.keyInformation,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: AppColorsPDF.lightGreen, thickness: 1),
          pw.SizedBox(height: 6),
          pw.Text(
            PDFStrings.benefitsLabel,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.successText,
            ),
          ),
          pw.SizedBox(height: 4),
          ...benefits.take(3).map((benefit) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 9, color: AppColorsPDF.successText)),
                pw.Container(
                  width: 180,
                  child: pw.Text(
                    benefit.toString(),
                    style: pw.TextStyle(font: font, fontSize: 9),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          )).toList(),
          pw.SizedBox(height: 6),
          pw.Text(
            PDFStrings.applicationsLabel,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(height: 4),
          ...uses.take(3).map((use) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 9, color: AppColorsPDF.primaryBlue)),
                pw.Container(
                  width: 180,
                  child: pw.Text(
                    use.toString(),
                    style: pw.TextStyle(font: font, fontSize: 9),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  /// Build header with logo and date/time
  static pw.Widget _buildHeader(pw.ImageProvider logo, DateTime dateTime, pw.Font font) {
    final year = dateTime.year;
    final month = _twoDigits(dateTime.month);
    final day = _twoDigits(dateTime.day);
    final hour = _twoDigits(dateTime.hour);
    final minute = _twoDigits(dateTime.minute);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisSize: pw.MainAxisSize.max,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(
              AppStrings.appName,
              style: pw.TextStyle(
                font: font,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
            pw.Text(
              AppStrings.marineSystem,
              style: pw.TextStyle(
                font: font,
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              '${PDFStrings.reportDate}: $year-$month-$day',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              '${PDFStrings.reportTime}: $hour:$minute',
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.Spacer(),
        pw.Image(logo, width: 100, height: 100),
      ],
    );
  }

  /// Build title section
  static pw.Widget _buildTitle(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: result.isToxic ? AppColorsPDF.errorBackground : AppColorsPDF.backgroundLight,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(
          color: result.isToxic ? AppColorsPDF.errorBorder : AppColorsPDF.accentGreen,
          width: 2,
        ),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            result.scientificName,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: result.isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              result.isToxic ? PDFStrings.toxicSpecies : PDFStrings.safeSpecies,
              style: pw.TextStyle(
                font: font,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build main result section
  static pw.Widget _buildMainResult(AlgaeResult result, pw.Font font) {
    final confidencePercent = (result.confidence * 100).toStringAsFixed(1);
    final confidenceColor = _getConfidenceColor(result.confidence);

    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
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
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.primaryIdentification,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: AppColorsPDF.lightGreen, thickness: 1),
          pw.SizedBox(height: 8),
          _buildInfoRow(PDFStrings.algaeName, result.name, font),
          _buildInfoRow(PDFStrings.scientificName, result.scientificName, font),
          _buildInfoRow(PDFStrings.category, result.category, font),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              _buildMetricCard(
                PDFStrings.confidenceLabel,
                '$confidencePercent%',
                confidenceColor,
                result.confidenceLevel,
                font,
              ),
              pw.SizedBox(width: 8),
              _buildMetricCard(
                PDFStrings.safetyStatus,
                result.isToxic ? PDFStrings.toxic : PDFStrings.safe,
                result.isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
                result.isToxic ? PDFStrings.handleCare : PDFStrings.safeHandling,
                font,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build scientific warning section
  static pw.Widget _buildScientificWarning(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: AppColorsPDF.errorBackground,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppColorsPDF.errorBorder, width: 1.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Text(
                '! ',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                PDFStrings.scientificWarningLabel,
                style: pw.TextStyle(
                  font: font,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: AppColorsPDF.errorText,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            width: 520,
            child: pw.Text(
              result.scientificWarning,
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: AppColorsPDF.errorText,
                lineSpacing: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build toxins and safety section
  static pw.Widget _buildToxinsAndSafety(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.toxinsAndSafety,
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          _buildInfoRow(PDFStrings.toxicityWarning, result.toxicityWarning, font),
          if (result.potentialToxins.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              PDFStrings.potentialToxinsLabel,
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
              ),
            ),
            pw.SizedBox(height: 4),
            ...result.potentialToxins.take(3).map((toxin) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
              child: pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text('• ', style: pw.TextStyle(font: font, fontSize: 9)),
                  pw.Container(
                    width: 500,
                    child: pw.Text(
                      toxin,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 9,
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

  /// Build scientific classification section
  static pw.Widget _buildScientificInfo(AlgaeResult result, pw.Font font) {
    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.scientificClassification,
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 6),
          _buildInfoRow(PDFStrings.domain, PDFStrings.bacteriaEukaryota, font),
          _buildInfoRow(PDFStrings.phylum, _getPhylum(result.name), font),
          _buildInfoRow(PDFStrings.classLabel, _getClass(result.name), font),
          _buildInfoRow(PDFStrings.orderLabel, _getOrder(result.name), font),
          _buildInfoRow(PDFStrings.family, _getFamily(result.name), font),
          _buildInfoRow(PDFStrings.genus, result.name, font),
        ],
      ),
    );
  }

  /// Build environmental and commercial info section
  static pw.Widget _buildEnvironmentalAndCommercialInfo(AlgaeResult result, pw.Font font) {
    final co2Text = result.co2PerKg > 0
        ? '~ ${result.co2PerKg.toStringAsFixed(2)} kg CO2/kg dry biomass'
        : PDFStrings.notApplicable;

    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: AppColorsPDF.infoBackground,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppColorsPDF.infoBorder),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.environmentalAndCommercial,
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.infoText,
            ),
          ),
          pw.Divider(color: AppColorsPDF.infoBorder),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Container(
                width: 250,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      PDFStrings.co2Sequestration,
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    pw.Text(
                      co2Text,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Container(
                width: 200,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.min,
                  children: [
                    pw.Text(
                      PDFStrings.commercialViability,
                      style: pw.TextStyle(
                        font: font,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    pw.Text(
                      result.sellable,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 9,
                        color: result.sellable.contains(PDFStrings.yes) ? AppColorsPDF.successText
                            : (result.sellable.contains(PDFStrings.no) ? AppColorsPDF.errorText : AppColorsPDF.warningOrange),
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

  /// Build technical info section
  static pw.Widget _buildTechnicalInfo(AlgaeResult result, pw.Font font) {
    final modelInfo = result.modelInfo;
    final isApiUsed = modelInfo['apiUsed'] == true;

    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.technicalInformation,
            style: pw.TextStyle(
              font: font,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 6),
          if (isApiUsed)
            pw.Text(
              PDFStrings.remoteApiService,
              style: pw.TextStyle(font: font, fontSize: 8, color: AppColorsPDF.infoText),
            ),
          pw.Text(
            '${PDFStrings.processingTime}: ${modelInfo['processingTime'] ?? 0} ${PDFStrings.milliseconds}',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  /// Build footer with notes and copyright
  static pw.Widget _buildFooter(pw.Font font) {
    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.importantNotes,
            style: pw.TextStyle(
              font: font,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${PDFStrings.autoGenerated}\n${PDFStrings.researchPurposes}\n${PDFStrings.consultSpecialists}',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey600,
              lineSpacing: 1.2,
            ),
            softWrap: true,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${PDFStrings.copyright} ${DateTime.now().year} - ${PDFStrings.allRightsReserved}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  /// Build history title section
  static pw.Widget _buildHistoryTitle(Map<String, dynamic> historyData, pw.Font font) {
    final isToxic = historyData['isToxic'] == true;
    final name = historyData['algaeType'] ?? AppStrings.unknown;

    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: isToxic ? AppColorsPDF.errorBackground : AppColorsPDF.backgroundLight,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: isToxic ? AppColorsPDF.errorBorder : AppColorsPDF.accentGreen, width: 2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            name,
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontStyle: pw.FontStyle.italic,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: pw.BoxDecoration(
              color: isToxic ? AppColorsPDF.errorText : AppColorsPDF.successText,
              borderRadius: pw.BorderRadius.circular(20),
            ),
            child: pw.Text(
              isToxic ? PDFStrings.toxicSpecies : PDFStrings.safeSpecies,
              style: pw.TextStyle(
                font: font,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build history results section
  static pw.Widget _buildHistoryResults(Map<String, dynamic> historyData, pw.Font font) {
    final confidence = ((historyData['confidence'] as num?)?.toDouble() ?? 0.0) * 100;
    final isToxic = historyData['isToxic'] == true;
    final scientificWarning = historyData['scientificWarning'] ?? '';

    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: AppColorsPDF.primaryBlue, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.analysisResults,
            style: pw.TextStyle(
              font: font,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: AppColorsPDF.primaryBlue,
            ),
          ),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          _buildInfoRow(PDFStrings.algaeType, historyData['algaeType'] ?? AppStrings.unknown, font),
          _buildInfoRow(PDFStrings.scientificName, historyData['scientificName'] ?? AppStrings.unknown, font),
          _buildInfoRow(PDFStrings.confidenceLevel, '${confidence.toStringAsFixed(1)}%', font),
          _buildInfoRow(PDFStrings.status, isToxic ? PDFStrings.toxicHandleCare : PDFStrings.safe, font),
          if (scientificWarning.isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Container(
              width: 520,
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: AppColorsPDF.errorBackground,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: AppColorsPDF.errorBorder),
              ),
              child: pw.Text(
                '! $scientificWarning',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 9,
                  color: AppColorsPDF.errorText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build history footer
  static pw.Widget _buildHistoryFooter(pw.Font font, Map<String, dynamic> historyData) {
    return pw.Container(
      width: 550,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            PDFStrings.note,
            style: pw.TextStyle(font: font, fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '${PDFStrings.reportBasedOnAnalysis} ${historyData['date']}. ${PDFStrings.dataAsRecorded}',
            style: pw.TextStyle(font: font, fontSize: 8, color: PdfColors.grey600),
            textAlign: pw.TextAlign.center,
            softWrap: true,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            '${PDFStrings.copyright} ${DateTime.now().year} - ${PDFStrings.allRightsReserved}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  /// Build info row (label + value)
  static pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Container(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                font: font,
                fontWeight: pw.FontWeight.bold,
                fontSize: 9,
                color: AppColorsPDF.primaryBlue,
              ),
            ),
          ),
          pw.Container(
            width: 350,
            child: pw.Text(
              value,
              style: pw.TextStyle(
                font: font,
                fontSize: 9,
                color: PdfColors.grey700,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Build metric card for confidence and safety status
  static pw.Widget _buildMetricCard(String title, String value, PdfColor color, String subtitle, pw.Font font) {
    return pw.Container(
      width: 180,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              font: font,
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  /// Get phylum based on algae name
  static String _getPhylum(String algaeName) {
    const cyanobacteria = ['Anabaena', 'Aphanizomenon', 'Microcystis', 'Nodularia', 'Nostoc', 'Oscillatoria'];
    if (cyanobacteria.contains(algaeName)) return PDFStrings.cyanobacteria;
    return PDFStrings.bacillariophyta;
  }

  /// Get class based on algae name
  static String _getClass(String algaeName) {
    const cyanobacteria = ['Anabaena', 'Aphanizomenon', 'Microcystis', 'Nodularia', 'Nostoc', 'Oscillatoria'];
    const diatoms = ['Skeletonema'];
    if (cyanobacteria.contains(algaeName)) return PDFStrings.cyanophyceae;
    if (diatoms.contains(algaeName)) return PDFStrings.bacillariophyceae;
    return PDFStrings.dinophyceae;
  }

  /// Get order based on algae name
  static String _getOrder(String algaeName) {
    const orders = {
      'Anabaena': 'Nostocales',
      'Nostoc': 'Nostocales',
      'Microcystis': 'Chroococcales',
      'Skeletonema': 'Thalassiosirales',
      'Karenia': 'Gymnodiniales',
      'Gymnodinium': 'Gymnodiniales',
    };
    return orders[algaeName] ?? PDFStrings.various;
  }

  /// Get family based on algae name
  static String _getFamily(String algaeName) {
    const families = {
      'Anabaena': 'Nostocaceae',
      'Nostoc': 'Nostocaceae',
      'Microcystis': 'Microcystaceae',
      'Skeletonema': 'Skeletonemataceae',
      'Karenia': 'Kareniaceae',
    };
    return families[algaeName] ?? PDFStrings.various;
  }

  /// Format number to two digits
  static String _twoDigits(int n) => n >= 10 ? '$n' : '0$n';

  /// Get confidence color based on value
  static PdfColor _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return AppColorsPDF.confidenceHigh;
    if (confidence >= 0.7) return AppColorsPDF.confidenceMedium;
    return AppColorsPDF.confidenceLow;
  }

  /// Save PDF to file system and open it
  static Future<void> _savePDF(pw.Document pdf, String name) async {
    try {
      final dir = await getDownloadsDirectory();
      final now = DateTime.now();
      final timestamp =
          '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}';
      final fileName = '${name}_$timestamp.pdf';
      final filePath = '${dir?.path}/$fileName';
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(filePath);
    } catch (e) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final fileName = 'BioAlga_Report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${dir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(await pdf.save());
        await OpenFile.open(filePath);
      } catch (e2) {
        rethrow;
      }
    }
  }
}