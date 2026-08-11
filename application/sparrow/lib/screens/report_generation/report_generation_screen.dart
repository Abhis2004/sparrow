import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/colors.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/police_report_generator_service.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import '../incidents/incidents_provider.dart';

class ReportGenerationScreen extends ConsumerStatefulWidget {
  const ReportGenerationScreen({super.key});

  @override
  ConsumerState<ReportGenerationScreen> createState() => _ReportGenerationScreenState();
}

class _ReportGenerationScreenState extends ConsumerState<ReportGenerationScreen> {
  String? _selectedIncidentId;
  String _selectedLanguage = 'English';
  bool _isGenerating = false;

  final List<String> _languages = ['English', 'Hindi'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    final allIncidentsAsync = ref.watch(allIncidentsProvider);
    final incidents = allIncidentsAsync.value ?? [];

    // Filter completed cases ONLY and sort by latest completion time descending
    final completedIncidents = incidents.where((inc) {
      return inc.status == IncidentStatus.completed ||
          inc.rawStatus.toLowerCase() == 'completed';
    }).toList();

    completedIncidents.sort((a, b) {
      DateTime parseCompletionTime(Incident incident) {
        if (incident.lastInteracted != null && incident.lastInteracted!.trim().isNotEmpty) {
          final parsed = DateTime.tryParse(incident.lastInteracted!.trim());
          if (parsed != null) return parsed;
        }
        final dateStr = (incident.completedDate != null && incident.completedDate!.trim().isNotEmpty)
            ? incident.completedDate!.trim()
            : incident.startedDate.trim();
        final timeStr = (incident.completedAt != null && incident.completedAt!.trim().isNotEmpty)
            ? incident.completedAt!.trim()
            : incident.startedAt.trim();

        if (dateStr.isNotEmpty) {
          final combined = DateTime.tryParse('$dateStr $timeStr');
          if (combined != null) return combined;
          final dateOnly = DateTime.tryParse(dateStr);
          if (dateOnly != null) return dateOnly;
        }
        return DateTime(1970);
      }

      return parseCompletionTime(b).compareTo(parseCompletionTime(a));
    });

    // Selected incident instance (only from completed cases, defaulting to latest completed)
    final Incident? selectedIncident = completedIncidents.isEmpty
        ? null
        : (_selectedIncidentId != null
            ? completedIncidents.firstWhere(
                (i) => i.id == _selectedIncidentId,
                orElse: () => completedIncidents.first,
              )
            : completedIncidents.first);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.text('report_generator'),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  loc.text('automated_case_summaries'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            colorScheme.primary.withValues(alpha: 0.25),
                            colorScheme.secondary.withValues(alpha: 0.15),
                          ]
                        : [
                            colorScheme.primary.withValues(alpha: 0.12),
                            colorScheme.secondary.withValues(alpha: 0.08),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.psychology_rounded,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('ai_case_report_generator'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loc.text('select_completed_case_banner'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 1. SELECT COMPLETED CASE BUTTON / DROPDOWN
              Text(
                loc.text('step_select_completed_case'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade300,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedIncident?.id,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.task_alt_rounded,
                      color: completedIncidents.isNotEmpty
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                  hint: Text(loc.text('select_completed_case_hint')),
                  items: completedIncidents.map((inc) {
                    return DropdownMenuItem<String>(
                      value: inc.id,
                      child: Text(
                        '${inc.incidentName} (${loc.text('completed_status')})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                  onChanged: completedIncidents.isEmpty
                      ? null
                      : (val) {
                          if (val != null) {
                            setState(() {
                              _selectedIncidentId = val;
                            });
                          }
                        },
                ),
              ),

              const SizedBox(height: 20),

              // 2. CASE DETAILS DISPLAY
              if (selectedIncident != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedIncident.icon,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              selectedIncident.incidentName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: selectedIncident.status == IncidentStatus.completed
                                  ? Colors.green.withValues(alpha: 0.15)
                                  : colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              selectedIncident.status == IncidentStatus.completed
                                  ? loc.text('completed_status')
                                  : selectedIncident.status.shortLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: selectedIncident.status == IncidentStatus.completed
                                    ? Colors.green
                                    : colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      // Metadata Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailTile(
                              context,
                              label: loc.text('category'),
                              value: selectedIncident.category.name.toUpperCase(),
                              icon: Icons.category_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildDetailTile(
                              context,
                              label: loc.text('location'),
                              value: selectedIncident.location,
                              icon: Icons.location_on_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDetailTile(
                              context,
                              label: loc.text('started_at'),
                              value: '${selectedIncident.startedDate} (${selectedIncident.startedAt})',
                              icon: Icons.calendar_today_rounded,
                            ),
                          ),
                          Expanded(
                            child: _buildDetailTile(
                              context,
                              label: loc.text('completed_at'),
                              value: selectedIncident.completedDate ?? loc.text('completed'),
                              icon: Icons.event_available_rounded,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Incident metrics summary
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatBadge(loc.text('observations'), selectedIncident.observationCount),
                            _buildStatBadge(loc.text('victims'), selectedIncident.victimCount),
                            _buildStatBadge(loc.text('witnesses'), selectedIncident.witnessCount),
                            _buildStatBadge(loc.text('suspects'), selectedIncident.suspectCount),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // 2. SELECT REPORT LANGUAGE (English & Hindi only)
              Opacity(
                opacity: selectedIncident != null ? 1.0 : 0.45,
                child: IgnorePointer(
                  ignoring: selectedIncident == null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.text('step_select_report_language'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: selectedIncident != null
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.38),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _languages.map((lang) {
                          final selected = _selectedLanguage == lang;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    lang,
                                    style: TextStyle(
                                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                      color: selectedIncident != null
                                          ? (selected ? colorScheme.onPrimary : colorScheme.onSurface)
                                          : colorScheme.onSurface.withValues(alpha: 0.38),
                                    ),
                                  ),
                                ),
                                selected: selected,
                                selectedColor: colorScheme.primary,
                                onSelected: selectedIncident == null
                                    ? null
                                    : (val) {
                                        if (val) {
                                          setState(() {
                                            _selectedLanguage = lang;
                                          });
                                        }
                                      },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // GENERATE BUTTON
              Opacity(
                opacity: selectedIncident != null ? 1.0 : 0.45,
                child: IgnorePointer(
                  ignoring: selectedIncident == null,
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.grey.shade300,
                        disabledForegroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.38)
                            : Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: selectedIncident != null ? 3 : 0,
                      ),
                      onPressed: _isGenerating || selectedIncident == null
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);

                              setState(() {
                                _isGenerating = true;
                              });

                              try {
                                final homeService = ref.read(homeServiceProvider);
                                final timelineDetails = await homeService.fetchTimelineDetails(selectedIncident.id);

                                final pdfBytes = await PoliceReportGeneratorService.instance.generateReportPdfBytes(
                                  details: timelineDetails,
                                  language: _selectedLanguage,
                                );

                                final savedPath = await PoliceReportGeneratorService.instance.saveIncidentPackageToDevice(
                                  details: timelineDetails,
                                  pdfBytes: pdfBytes,
                                  language: _selectedLanguage,
                                );

                                if (!mounted) return;

                                setState(() {
                                  _isGenerating = false;
                                });

                                final isHindi = loc.language == AppLanguage.hindi;
                                final isDark = Theme.of(context).brightness == Brightness.dark;

                                final dialogBg = isDark ? const Color(0xFF1E293B) : Colors.white;
                                final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
                                final textColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155);
                                final containerBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
                                final pathTextColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF17365D);
                                final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);

                                final titleStr = isHindi ? 'रिपोर्ट पैकेज सहेजा गया' : 'Report Package Saved';
                                final headerStr = isHindi
                                    ? 'पुलिस अन्वेषण प्रतिवेदन एवं साक्ष्य पैकेज सफलतापूर्वक सहेजा गया!'
                                    : 'Police Investigation Report & Evidence Package saved successfully!';
                                final pathLabelStr = isHindi ? 'फ़ाइल पथ:' : 'FILE LOCATION:';
                                final containsStr = isHindi
                                    ? 'पैकेज में आधिकारिक पीडीएफ रिपोर्ट, पूर्ण मामला जेएसओएन, टाइमलाइन साक्ष्य और ऑडियो रिकॉर्डिंग प्रतिलेख शामिल हैं।'
                                    : 'Package includes Official PDF Report, Complete Case JSON, Timeline Evidence & Audio Transcripts.';
                                final btnStr = isHindi ? 'ठीक है' : 'DONE';

                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor: dialogBg,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    title: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            titleStr,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: titleColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          headerStr,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          pathLabelStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: textColor.withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: containerBg,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: borderColor),
                                          ),
                                          child: SelectableText(
                                            savedPath,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: pathTextColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          containsStr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: textColor.withValues(alpha: 0.8),
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: Text(
                                          btnStr,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } catch (e) {
                                if (mounted) {
                                  setState(() {
                                    _isGenerating = false;
                                  });
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Error generating report: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.auto_awesome_rounded),
                      label: Text(
                        _isGenerating ? 'Generating Report...' : loc.text('generate_report_btn'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String label, int count) {
    return Column(
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
