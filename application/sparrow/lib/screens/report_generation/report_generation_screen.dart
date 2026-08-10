import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../services/police_report_generator_service.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import '../incidents/incidents_provider.dart';
import 'case_json_screen.dart';
import 'report_viewer_screen.dart';

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

    // Filter completed cases
    final completedIncidents = incidents.where((inc) {
      return inc.status == IncidentStatus.completed ||
          inc.rawStatus.toLowerCase() == 'completed';
    }).toList();

    // Fallback to all incidents if no completed cases exist yet
    final availableIncidents = completedIncidents.isNotEmpty ? completedIncidents : incidents;

    // Selected incident instance
    final Incident? selectedIncident = incidents.isEmpty
        ? null
        : (_selectedIncidentId != null
            ? incidents.firstWhere(
                (i) => i.id == _selectedIncidentId,
                orElse: () => availableIncidents.isNotEmpty ? availableIncidents.first : incidents.first,
              )
            : (availableIncidents.isNotEmpty ? availableIncidents.first : incidents.first));

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
                      color: colorScheme.primary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                  hint: Text(loc.text('select_completed_case_hint')),
                  items: availableIncidents.map((inc) {
                    final isCompleted = inc.status == IncidentStatus.completed ||
                        inc.rawStatus.toLowerCase() == 'completed';
                    return DropdownMenuItem<String>(
                      value: inc.id,
                      child: Text(
                        '${inc.incidentName} (${isCompleted ? loc.text('completed_status') : inc.status.shortLabel})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
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

                const SizedBox(height: 16),

                // 3. BUTTON TO SHOW CASE DETAILS IN SEPARATE JSON PAGE
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(
                        color: colorScheme.primary,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CaseJsonScreen(
                            incident: selectedIncident,
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.code_rounded,
                      color: colorScheme.primary,
                    ),
                    label: Text(
                      loc.text('view_case_details_json'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. SELECT REPORT LANGUAGE (English & Hindi only)
                Text(
                  loc.text('step_select_report_language'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
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
                                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                              ),
                            ),
                          ),
                          selected: selected,
                          selectedColor: colorScheme.primary,
                          onSelected: (val) {
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

                const SizedBox(height: 28),

                // 5. GENERATE BUTTON (SHOWS COMING SOON TOAST)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 3,
                    ),
                    onPressed: _isGenerating || selectedIncident == null
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            setState(() {
                              _isGenerating = true;
                            });

                            try {
                              final homeService = ref.read(homeServiceProvider);
                              final timelineDetails = await homeService.fetchTimelineDetails(selectedIncident.id);

                              final htmlContent = await PoliceReportGeneratorService.instance.generateReportHtml(
                                details: timelineDetails,
                                language: _selectedLanguage,
                              );

                              if (mounted) {
                                setState(() {
                                  _isGenerating = false;
                                });
                                nav.push(
                                  MaterialPageRoute(
                                    builder: (context) => ReportViewerScreen(
                                      incidentName: selectedIncident.incidentName,
                                      incidentId: selectedIncident.id,
                                      language: _selectedLanguage,
                                      htmlContent: htmlContent,
                                    ),
                                  ),
                                );
                              }
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
              ],
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
