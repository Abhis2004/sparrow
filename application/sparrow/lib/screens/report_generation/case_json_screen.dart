import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/localization/app_localizations.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import '../timeline/timeline_model.dart';

class CaseJsonScreen extends ConsumerStatefulWidget {
  const CaseJsonScreen({
    super.key,
    required this.incident,
  });

  final Incident incident;

  @override
  ConsumerState<CaseJsonScreen> createState() => _CaseJsonScreenState();
}

class _CaseJsonScreenState extends ConsumerState<CaseJsonScreen> {
  late Future<TimelineDetails> _timelineFuture;

  @override
  void initState() {
    super.initState();
    _timelineFuture = ref.read(homeServiceProvider).fetchTimelineDetails(widget.incident.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.text('incident_specific_db_json'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${widget.incident.incidentName} (${widget.incident.id})',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.cyanAccent,
              ),
            ),
          ],
        ),
        actions: [
          FutureBuilder<TimelineDetails>(
            future: _timelineFuture,
            builder: (context, snapshot) {
              final jsonMap = snapshot.hasData
                  ? snapshot.data!.toJson()
                  : widget.incident.toJson();
              final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

              return IconButton(
                icon: const Icon(Icons.copy_rounded, color: Colors.cyanAccent),
                tooltip: loc.text('copy_json'),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: jsonString));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(loc.text('json_copied_toast')),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<TimelineDetails>(
          future: _timelineFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            }

            final jsonMap = snapshot.hasData
                ? snapshot.data!.toJson()
                : widget.incident.toJson();
            final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: SelectableText(
                  jsonString,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
