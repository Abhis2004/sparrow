import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../services/police_report_generator_service.dart';
import '../timeline/timeline_model.dart';

class ReportViewerScreen extends StatefulWidget {
  const ReportViewerScreen({
    super.key,
    required this.incidentName,
    required this.incidentId,
    required this.language,
    required this.htmlContent,
    this.timelineDetails,
  });

  final String incidentName;
  final String incidentId;
  final String language;
  final String htmlContent;
  final TimelineDetails? timelineDetails;

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  bool _showRawHtml = false;
  bool _showDocumentPreview = false;
  Uint8List? _cachedPdfBytes;
  String? _savedPackagePath;

  @override
  void initState() {
    super.initState();
    _autoSaveIncidentPackage();
  }

  Future<void> _autoSaveIncidentPackage() async {
    if (widget.timelineDetails != null) {
      try {
        final pdfBytes = await PoliceReportGeneratorService.instance.generateReportPdfBytes(
          details: widget.timelineDetails!,
          language: widget.language,
        );
        _cachedPdfBytes = pdfBytes;
        final path = await PoliceReportGeneratorService.instance.saveIncidentPackageToDevice(
          details: widget.timelineDetails!,
          pdfBytes: pdfBytes,
          language: widget.language,
        );
        if (mounted) {
          setState(() {
            _savedPackagePath = path;
          });
        }
      } catch (e) {
        debugPrint('Auto-save incident package error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 1,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Police Investigation Report (${widget.language})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${widget.incidentName} (${widget.incidentId})',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showDocumentPreview ? Icons.picture_as_pdf_rounded : Icons.article_rounded),
            tooltip: _showDocumentPreview ? 'View Print Preview (PDF)' : 'View Document Text',
            onPressed: () {
              setState(() {
                _showDocumentPreview = !_showDocumentPreview;
                _showRawHtml = false;
              });
            },
          ),
          IconButton(
            icon: Icon(_showRawHtml ? Icons.picture_as_pdf_rounded : Icons.code_rounded),
            tooltip: _showRawHtml ? 'View Print Preview (PDF)' : 'View Raw HTML Code',
            onPressed: () {
              setState(() {
                _showRawHtml = !_showRawHtml;
                _showDocumentPreview = false;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_zip_rounded),
            tooltip: 'Download Incident Package to Storage',
            onPressed: _handleManualDownloadPackage,
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded),
            tooltip: 'Copy Report HTML',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.htmlContent));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report HTML copied to clipboard!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_savedPackagePath != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: const Color(0xFF17365D),
                child: Row(
                  children: [
                    const Icon(Icons.folder_special_rounded, color: Colors.amber, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Saved to Internal Storage: ${_savedPackagePath!} (Includes PDF report & evidence/ folder)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _showRawHtml
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: SelectableText(
                            widget.htmlContent,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              height: 1.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    )
                  : _showDocumentPreview
                      ? SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: SelectableText(
                                _formatReportText(widget.htmlContent),
                                style: TextStyle(
                                  fontFamily: widget.language.toLowerCase() == 'hindi'
                                      ? 'Noto Sans Devanagari'
                                      : 'Times New Roman',
                                  fontSize: 13,
                                  height: 1.6,
                                  color: const Color(0xFF111827),
                                ),
                              ),
                            ),
                          ),
                        )
                      : PdfPreview(
                          build: (format) async {
                            if (_cachedPdfBytes != null) {
                              return _cachedPdfBytes!;
                            }
                            if (widget.timelineDetails != null) {
                              final bytes = await PoliceReportGeneratorService.instance.generateReportPdfBytes(
                                details: widget.timelineDetails!,
                                language: widget.language,
                              );
                              _cachedPdfBytes = bytes;
                              return bytes;
                            }
                            // ignore: deprecated_member_use
                            return await Printing.convertHtml(
                              format: PdfPageFormat.a4,
                              html: widget.htmlContent,
                            );
                          },
                          allowPrinting: true,
                          allowSharing: true,
                          canChangeOrientation: false,
                          canChangePageFormat: false,
                          canDebug: false,
                          pdfFileName: 'Police_Report_${widget.incidentId}_${widget.language}.pdf',
                          actions: [
                            PdfPreviewAction(
                              icon: const Icon(Icons.download_for_offline_rounded),
                              onPressed: (context, build, pageFormat) async {
                                await _handleManualDownloadPackage();
                              },
                            ),
                          ],
                          loadingWidget: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text(
                                  'Loading Official Print Preview...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF17365D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleManualDownloadPackage() async {
    if (widget.timelineDetails != null) {
      try {
        final pdfBytes = _cachedPdfBytes ??
            await PoliceReportGeneratorService.instance.generateReportPdfBytes(
              details: widget.timelineDetails!,
              language: widget.language,
            );
        _cachedPdfBytes = pdfBytes;
        final path = await PoliceReportGeneratorService.instance.saveIncidentPackageToDevice(
          details: widget.timelineDetails!,
          pdfBytes: pdfBytes,
          language: widget.language,
        );
        if (mounted) {
          setState(() {
            _savedPackagePath = path;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved Incident Package to storage: $path\nContains evidence/ subfolder & PDF Report'),
              backgroundColor: const Color(0xFF17365D),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download Error: $e')),
          );
        }
      }
    }
  }

  static String _formatReportText(String html) {
    return html
        .replaceAll(RegExp(r'<style[^>]*>[\s\S]*?</style>'), '')
        .replaceAll(RegExp(r'<head[^>]*>[\s\S]*?</head>'), '')
        .replaceAll(RegExp(r'</?(div|p|h1|h2|h3|header|table|tr|td|th)[^>]*>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'&amp;'), '&')
        .replaceAll(RegExp(r'&lt;'), '<')
        .replaceAll(RegExp(r'&gt;'), '>')
        .replaceAll(RegExp(r'&quot;'), '"')
        .replaceAll(RegExp(r'&#039;'), "'")
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n')
        .trim();
  }
}
