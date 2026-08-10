import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReportViewerScreen extends StatefulWidget {
  const ReportViewerScreen({
    super.key,
    required this.incidentName,
    required this.incidentId,
    required this.language,
    required this.htmlContent,
  });

  final String incidentName;
  final String incidentId;
  final String language;
  final String htmlContent;

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  bool _showRawHtml = false;

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
            icon: Icon(_showRawHtml ? Icons.article_rounded : Icons.code_rounded),
            tooltip: _showRawHtml ? 'View Formatted Document' : 'View Raw HTML Code',
            onPressed: () {
              setState(() {
                _showRawHtml = !_showRawHtml;
              });
            },
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
        child: SingleChildScrollView(
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
              child: _showRawHtml
                  ? SelectableText(
                      widget.htmlContent,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        height: 1.5,
                        color: Color(0xFF0F172A),
                      ),
                    )
                  : SelectableText(
                      _formatReportText(widget.htmlContent),
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 13,
                        height: 1.6,
                        color: Color(0xFF111827),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
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
        .replaceAll(RegExp(r'&#39;'), "'")
        .replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n')
        .trim();
  }
}
