import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../database/isar_service.dart';
import '../../utils/map_launcher.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import '../incidents/incidents_provider.dart';
import 'timeline_model.dart';
import 'timeline_provider.dart';


class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({
    super.key,
    required this.incidentId,
  });

  final String incidentId;

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  bool _isSummaryExpanded = false;
  bool _showTimelineLog = true;
  final GlobalKey _evidenceSectionKey = GlobalKey();
  final ScrollController _mainScrollController = ScrollController();

  @override
  void dispose() {
    _mainScrollController.dispose();
    super.dispose();
  }

  void _scrollToEvidenceSection() {
    final targetContext = _evidenceSectionKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.05,
      );
    }
  }


  void _showComingSoon(BuildContext context, String title) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - ${loc.text('coming_soon')}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }


  void _confirmDeleteIncident(BuildContext context, String incidentId) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 10),
            Text(loc.text('delete_incident'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          loc.text('confirm_delete_msg'),
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(loc.text('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              Navigator.of(dialogContext).pop();
              await ref.read(allIncidentsProvider.notifier).deleteIncident(incidentId);
              await ref.read(timelineMapNotifierProvider.notifier).removeTimelineDetails(incidentId);
              ref.invalidate(allIncidentsProvider);
              ref.invalidate(homeDataProvider);

              if (mounted) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(loc.text('incident_deleted')),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  if (context.mounted) {
                    context.go('/incidents');
                  }
                }
              }
            },
            child: Text(loc.text('delete'), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  void _showEditIncidentBottomSheet(BuildContext context, TimelineDetails timelineDetails) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditIncidentBottomSheet(
        timelineDetails: timelineDetails,
        ref: ref,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final timelineDetailsAsync =
        ref.watch(timelineDetailsProvider(widget.incidentId));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.text('incident_details'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              widget.incidentId,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            tooltip: loc.text('more'),
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              final timelineDetails = timelineDetailsAsync.value;
              if (value == 'edit') {
                if (timelineDetails != null) {
                  _showEditIncidentBottomSheet(context, timelineDetails);
                }
              } else if (value == 'delete') {
                _confirmDeleteIncident(context, widget.incidentId);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      loc.text('edit'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: const Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 10),
                    Text(
                      'Delete Incident',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: timelineDetailsAsync.when(
        data: (timelineDetails) {
          final incident = timelineDetails.incident;

          return SingleChildScrollView(
            controller: _mainScrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

              // ---------- 1. TOP INCIDENT OVERVIEW CARD ----------
              _TopOverviewCard(
                incident: incident,
                isDark: isDark,
                onViewMap: () => MapLauncher.openMap(
                  latitude: incident.gps.latitude,
                  longitude: incident.gps.longitude,
                  title: incident.location,
                ),
              ),
              const SizedBox(height: 16),

              // ---------- 2. COUNT METRICS BAR ----------
              _MetricsBar(
                timelineDetails: timelineDetails,
                isDark: isDark,
                onMetricTap: (label) => _showComingSoon(context, '$label List'),
                onEvidenceTap: _scrollToEvidenceSection,
              ),
              const SizedBox(height: 16),

              // ---------- 3. ADD / RECORD SECTION ----------
              _AddRecordSection(
                isDark: isDark,
                onActionTap: (action) => _showComingSoon(context, action),
              ),
              const SizedBox(height: 16),


              // ---------- 4. INCIDENT INFORMATION CARD ----------
              _IncidentInformationCard(
                incident: incident,
                isDark: isDark,
                isSummaryExpanded: _isSummaryExpanded,
                onToggleSummary: () {
                  setState(() {
                    _isSummaryExpanded = !_isSummaryExpanded;
                  });
                },
                onGpsTap: () => MapLauncher.openMap(
                  latitude: incident.gps.latitude,
                  longitude: incident.gps.longitude,
                  title: incident.location,
                ),
              ),
              const SizedBox(height: 16),



              // ---------- 6. EVIDENCE COLLECTED SECTION ----------
              _EvidenceCollectedSection(
                key: _evidenceSectionKey,
                evidenceList: timelineDetails.evidence,
                isDark: isDark,
                onViewAll: () => _showComingSoon(context, 'View All Evidence'),
                onEvidenceTap: (item) =>
                    _showComingSoon(context, 'Open ${item.fileName}'),
              ),

              const SizedBox(height: 16),

              // ---------- 7. CHRONOLOGICAL TIMELINE EVENTS TOGGLE & LIST ----------
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AppColors.border,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.timeline_rounded,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${loc.text('timeline_log')} (${timelineDetails.timeline.length})',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _showTimelineLog = !_showTimelineLog;
                            });
                          },
                          icon: Icon(
                            _showTimelineLog
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 20,
                          ),
                          label: Text(_showTimelineLog ? loc.text('collapse') : loc.text('expand')),
                        ),
                      ],
                    ),

                    if (_showTimelineLog) ...[
                      const Divider(height: 24),
                      if (timelineDetails.timeline.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              loc.text('no_events_logged'),
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: timelineDetails.timeline.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final event = timelineDetails.timeline[index];
                            return _TimelineEventTile(
                              event: event,
                              isLast: index == timelineDetails.timeline.length - 1,
                              isDark: isDark,
                            );
                          },
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );

        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading details: $err')),
      ),
    );
  }
}



/// 1. Top Overview Card Component
class _TopOverviewCard extends StatelessWidget {
  const _TopOverviewCard({
    required this.incident,
    required this.isDark,
    required this.onViewMap,
  });

  final IncidentOverview incident;
  final bool isDark;
  final VoidCallback onViewMap;

  Color _getStatusBgColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.active:
        return const Color(0xFFD1FAE5);
      case IncidentStatus.completed:
        return const Color(0xFFDBEAFE);
      case IncidentStatus.draft:
        return const Color(0xFFFEF3C7);
    }
  }

  Color _getStatusTextColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.active:
        return const Color(0xFF065F46);
      case IncidentStatus.completed:
        return const Color(0xFF1E40AF);
      case IncidentStatus.draft:
        return const Color(0xFF92400E);
    }
  }

  static String getCategoryText(IncidentOverview incident) {
    if (incident.rawCategory.isNotEmpty) {
      return incident.rawCategory;
    }
    return incident.category.name;
  }

  static String getStatusText(IncidentOverview incident) {
    if (incident.rawStatus.isNotEmpty) {
      return incident.rawStatus;
    }
    return incident.status.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);


    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title, Status, Location, Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            incident.incidentName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusBgColor(incident.status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            getStatusText(incident),
                            style: TextStyle(
                              color: _getStatusTextColor(incident.status),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            getCategoryText(incident),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurface.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),


              // Right Map Badge Sub-Card
              InkWell(
                onTap: onViewMap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 110,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : const Color(0xFFDBEAFE),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'ID',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            incident.id,
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Mini Map Box
                      Container(
                        height: 52,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? Colors.blue.withValues(alpha: 0.3)
                                : const Color(0xFFBAE6FD),
                          ),
                        ),
                        child: Stack(
                          children: [
                            const Positioned.fill(
                              child: Opacity(
                                opacity: 0.12,
                                child: GridPaper(
                                  color: Colors.blue,
                                  divisions: 1,
                                  subdivisions: 1,
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      incident.location,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            loc.text('view_map'),
                            style: TextStyle(
                              fontSize: 10,
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Brief text paragraph
          Text(
            incident.summary,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Date Grid: Started / Completed
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('started'),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            '${incident.startedDate}, ${incident.startedAt}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.event_available_outlined,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('completed'),
                            style: TextStyle(
                              fontSize: 11,
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          Text(
                            '${incident.completedDate}, ${incident.completedAt}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
}

/// 2. Count Metrics Bar (5 distinct cards derived directly from JSON)
class _MetricsBar extends StatelessWidget {
  const _MetricsBar({
    required this.timelineDetails,
    required this.isDark,
    required this.onMetricTap,
    this.onEvidenceTap,
  });

  final TimelineDetails timelineDetails;
  final bool isDark;
  final ValueChanged<String> onMetricTap;
  final VoidCallback? onEvidenceTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _MetricItemCard(
            icon: Icons.visibility_rounded,
            iconColor: const Color(0xFF2563EB),
            count: timelineDetails.officerObservations.length,
            label: loc.text('observations'),
            isDark: isDark,
            onTap: () => _showObservationsBottomSheet(
              context,
              timelineDetails.officerObservations,
              isDark,
            ),
          ),

          const SizedBox(width: 8),
          _MetricItemCard(
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFF16A34A),
            count: timelineDetails.victims.length,
            label: loc.text('victims'),
            isDark: isDark,
            onTap: () => _showVictimsBottomSheet(
              context,
              timelineDetails.victims,
              isDark,
            ),
          ),

          const SizedBox(width: 8),
          _MetricItemCard(
            icon: Icons.people_alt_rounded,
            iconColor: const Color(0xFFEA580C),
            count: timelineDetails.witnesses.length,
            label: loc.text('witnesses'),
            isDark: isDark,
            onTap: () => _showWitnessesBottomSheet(
              context,
              timelineDetails.witnesses,
              isDark,
            ),
          ),
          const SizedBox(width: 8),
          _MetricItemCard(
            icon: Icons.face_rounded,
            iconColor: const Color(0xFF9333EA),
            count: timelineDetails.suspects.length,
            label: loc.text('suspects'),
            isDark: isDark,
            onTap: () => _showSuspectsBottomSheet(
              context,
              timelineDetails.suspects,
              isDark,
            ),
          ),

          const SizedBox(width: 8),
          _MetricItemCard(
            icon: Icons.description_rounded,
            iconColor: const Color(0xFFDC2626),
            count: timelineDetails.evidence.length,
            label: loc.text('evidence'),
            isDark: isDark,
            onTap: onEvidenceTap ?? () => onMetricTap(loc.text('evidence')),
          ),
        ],
      ),
    );
  }
}


class _MetricItemCard extends StatelessWidget {
  const _MetricItemCard({
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final int count;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 102,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. Add / Record Section Component
class _AddRecordItemData {
  const _AddRecordItemData({
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;
}

class _AddRecordSection extends StatelessWidget {
  const _AddRecordSection({
    required this.isDark,
    required this.onActionTap,
  });

  final bool isDark;
  final ValueChanged<String> onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    final actions = [
      _AddRecordItemData(
        title: loc.text('add_observation'),
        icon: Icons.mic_rounded,
        color: const Color(0xFF2563EB),
      ),
      _AddRecordItemData(
        title: loc.text('add_victim_statement'),
        icon: Icons.person_rounded,
        color: const Color(0xFF16A34A),
      ),
      _AddRecordItemData(
        title: loc.text('add_witness_statement'),
        icon: Icons.person_rounded,
        color: const Color(0xFFEA580C),
      ),
      _AddRecordItemData(
        title: loc.text('add_suspect_statement'),
        icon: Icons.face_rounded,
        color: const Color(0xFF9333EA),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.text('add_record'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 105,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: actions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = actions[index];
                return InkWell(
                  onTap: () => onActionTap(item.title.replaceAll('\n', ' ')),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 95,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: 26,
                          color: item.color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


/// 4. Incident Information Grid & Expandable Summary Card
class _IncidentInformationCard extends StatelessWidget {
  const _IncidentInformationCard({
    required this.incident,
    required this.isDark,
    required this.isSummaryExpanded,
    required this.onToggleSummary,
    required this.onGpsTap,
  });

  final IncidentOverview incident;
  final bool isDark;
  final bool isSummaryExpanded;
  final VoidCallback onToggleSummary;
  final VoidCallback onGpsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loc.text('incident_information'),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // 2-Column Key Value List
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.category_outlined,
                      label: loc.text('category'),
                      value: _TopOverviewCard.getCategoryText(incident),
                    ),

                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.wb_sunny_outlined,
                      label: loc.text('weather'),
                      value: incident.weather,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.local_police_outlined,
                      label: loc.text('police_station'),
                      value: incident.station,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.location_city_outlined,
                      label: loc.text('district'),
                      value: incident.district,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.map_outlined,
                      label: loc.text('state'),
                      value: incident.state,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Right Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.my_location_outlined,
                      label: loc.text('gps_location'),
                      value: incident.gps.formatted,
                      valueColor: colorScheme.primary,
                      onTap: onGpsTap,
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.access_time_rounded,
                      label: loc.text('started_at'),
                      value: '${incident.startedDate}, ${incident.startedAt}',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: loc.text('completed_at'),
                      value: '${incident.completedDate}, ${incident.completedAt}',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.info_outline_rounded,
                      label: loc.text('status'),
                      value: _TopOverviewCard.getStatusText(incident),
                      valueColor: const Color(0xFF10B981),
                    ),

                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Summary Text Section
          Text(
            loc.text('summary'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            incident.summary,
            maxLines: isSummaryExpanded ? null : 3,
            overflow: isSummaryExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: onToggleSummary,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSummaryExpanded ? loc.text('show_less') : loc.text('show_more'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                Icon(
                  isSummaryExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



/// 6. Evidence Collected Horizontal Media Cards Section
class _EvidenceCollectedSection extends StatelessWidget {
  const _EvidenceCollectedSection({
    super.key,
    required this.evidenceList,
    required this.isDark,
    required this.onViewAll,
    required this.onEvidenceTap,
  });


  final List<EvidenceItem> evidenceList;
  final bool isDark;
  final VoidCallback onViewAll;
  final ValueChanged<EvidenceItem> onEvidenceTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Evidence Collected',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: evidenceList.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),

              itemBuilder: (context, index) {
                final item = evidenceList[index];
                return _EvidenceCard(
                  item: item,
                  isDark: isDark,
                  onTap: () => onEvidenceTap(item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  final EvidenceItem item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget thumbnailWidget;
    String typeLabel;

    switch (item.type) {
      case EvidenceType.photo:
        typeLabel = 'Photo • ${item.fileSize}';
        thumbnailWidget = Container(
          color: const Color(0xFF334155),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const Center(
                child: Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white70,
                  size: 32,
                ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.image_outlined,
                      size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        );
        break;

      case EvidenceType.video:
        typeLabel = 'Video • ${item.fileSize}';
        thumbnailWidget = Container(
          color: const Color(0xFF1E1B4B),
          child: const Center(
            child: Icon(
              Icons.play_circle_fill_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        );
        break;

      case EvidenceType.audio:
        typeLabel = 'Audio • ${item.fileSize}';
        thumbnailWidget = Container(
          color: const Color(0xFF0F172A),
          padding: const EdgeInsets.all(8),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.mic, color: Colors.white70, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Icon(Icons.graphic_eq_rounded,
                          color: Colors.blue.shade300, size: 24),
                    ),
                  ],
                ),
              ),
              if (item.duration.isNotEmpty)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Text(
                    item.duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
        break;

      case EvidenceType.document:
        typeLabel = 'Document • ${item.fileSize}';
        thumbnailWidget = Container(
          color: const Color(0xFFF1F5F9),
          child: const Center(
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.red,
              size: 40,
            ),
          ),
        );
        break;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 155,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 90,
              width: double.infinity,
              child: thumbnailWidget,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 7. Individual Timeline Event Step Tile
class _TimelineEventTile extends StatelessWidget {
  const _TimelineEventTile({
    required this.event,
    required this.isLast,
    required this.isDark,
  });

  final TimelineEvent event;
  final bool isLast;
  final bool isDark;

  String _getEventTitle(String eventType) {
    switch (eventType) {
      case 'case_brief':
        return 'Case Brief (Initial Report)';
      case 'officer_observation':
        return 'Officer Observation';
      case 'victim_statement':
        return 'Victim Statement';
      case 'witness_statement':
        return 'Witness Statement';
      case 'suspect_statement':
        return 'Suspect Statement';
      case 'evidence_capture':
        return 'Evidence Capture';
      default:
        return eventType.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getEventSubtitle(TimelineEvent event) {
    final parts = <String>[];
    if (event.eventType == 'case_brief') {
      parts.add('Initial case summary logged at incident creation');
      if (event.personId.isNotEmpty) {
        parts.add('Officer: ${event.personId}');
      }
      return parts.join(' • ');
    }
    if (event.referenceId.isNotEmpty) {
      parts.add('Ref: ${event.referenceId}');
    }
    if (event.personId.isNotEmpty) {
      parts.add('Person: ${event.personId}');
    }
    if (parts.isEmpty && event.gps.formatted.isNotEmpty) {
      parts.add('GPS: ${event.gps.formatted}');
    }
    return parts.isEmpty ? 'Timeline Logged Event' : parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color badgeColor;
    IconData eventIcon;

    switch (event.eventType) {
      case 'case_brief':
        badgeColor = const Color(0xFF0D9488);
        eventIcon = Icons.assignment_rounded;
        break;
      case 'officer_observation':
        badgeColor = Colors.blue;
        eventIcon = Icons.visibility_outlined;
        break;
      case 'victim_statement':
        badgeColor = Colors.green;
        eventIcon = Icons.person_outline;
        break;
      case 'witness_statement':
        badgeColor = Colors.orange;
        eventIcon = Icons.record_voice_over_outlined;
        break;
      case 'suspect_statement':
        badgeColor = Colors.purple;
        eventIcon = Icons.warning_amber_rounded;
        break;
      case 'evidence_capture':
        badgeColor = Colors.red;
        eventIcon = Icons.camera_alt_outlined;
        break;
      default:
        badgeColor = colorScheme.primary;
        eventIcon = Icons.circle_outlined;
    }

    final formattedTime = event.timestamp.contains('T')
        ? event.timestamp.split('T')[1].split('+')[0]
        : event.timestamp;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time & Dot Column
        SizedBox(
          width: 75,
          child: Text(
            formattedTime,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                eventIcon,
                size: 14,
                color: badgeColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getEventTitle(event.eventType),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEventSubtitle(event),
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),

              if (event.evidenceIds.isNotEmpty) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: event.evidenceIds
                      .map((evId) => Chip(
                            label: Text(evId),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelStyle: const TextStyle(fontSize: 10),
                            backgroundColor:
                                colorScheme.primary.withValues(alpha: 0.08),
                            side: BorderSide.none,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 8. Officer Observations Bottom Sheet & Timeline Tiles
void _showObservationsBottomSheet(
  BuildContext context,
  List<OfficerObservationItem> observations,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _OfficerObservationsBottomSheet(
      observations: observations,
      isDark: isDark,
    ),
  );
}

class _OfficerObservationsBottomSheet extends StatelessWidget {
  const _OfficerObservationsBottomSheet({
    required this.observations,
    required this.isDark,
  });

  final List<OfficerObservationItem> observations;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle Bar
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.visibility_rounded,
                        color: Color(0xFF2563EB),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('officer_observations'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${observations.length} ${loc.text('observations')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // Observations List
              Expanded(
                child: observations.isEmpty
                    ? Center(
                        child: Text(
                          'No officer observations logged.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: observations.length,
                        itemBuilder: (context, index) {
                          final item = observations[index];
                          final isLast = index == observations.length - 1;
                          return _ObservationTimelineTile(
                            item: item,
                            isLast: isLast,
                            isDark: isDark,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ObservationTimelineTile extends StatelessWidget {
  const _ObservationTimelineTile({
    required this.item,
    required this.isLast,
    required this.isDark,
  });

  final OfficerObservationItem item;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formattedTime = item.timestamp.contains('T')
        ? item.timestamp.split('T')[1].split('+')[0]
        : item.timestamp;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time & Timeline Dot Column
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.visibility_outlined,
                size: 16,
                color: Color(0xFF2563EB),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 140,
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Observation Detail Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.id.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Transcript Section
                if (item.transcript.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.record_voice_over_outlined,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.transcript,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Footer: GPS Location & Evidence Tags

                Row(
                  children: [
                    InkWell(
                      onTap: () => MapLauncher.openMap(
                        latitude: item.gps.latitude,
                        longitude: item.gps.longitude,
                        title: 'Observation ${item.id}',
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.gps.formatted,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (item.evidenceIds.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 4,
                        children: item.evidenceIds
                            .map(
                              (evId) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  evId,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 9. Victims Bottom Sheet & Statements Accordion Timeline
void _showVictimsBottomSheet(
  BuildContext context,
  List<VictimItem> victims,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _VictimsBottomSheet(
      victims: victims,
      isDark: isDark,
    ),
  );
}

class _VictimsBottomSheet extends StatefulWidget {
  const _VictimsBottomSheet({
    required this.victims,
    required this.isDark,
  });

  final List<VictimItem> victims;
  final bool isDark;

  @override
  State<_VictimsBottomSheet> createState() => _VictimsBottomSheetState();
}

class _VictimsBottomSheetState extends State<_VictimsBottomSheet> {
  String? _expandedVictimId;

  @override
  void initState() {
    super.initState();
    if (widget.victims.isNotEmpty) {
      _expandedVictimId = widget.victims.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Color(0xFF16A34A),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('victims'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${widget.victims.length} ${loc.text('victims')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // Victims Accordion List
              Expanded(
                child: widget.victims.isEmpty
                    ? Center(
                        child: Text(
                          'No victims recorded.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: widget.victims.length,
                        itemBuilder: (context, index) {
                          final victim = widget.victims[index];
                          final isExpanded = _expandedVictimId == victim.id;
                          return _VictimCard(
                            victim: victim,
                            isExpanded: isExpanded,
                            isDark: widget.isDark,
                            onToggleExpand: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedVictimId = null;
                                } else {
                                  _expandedVictimId = victim.id;
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VictimCard extends StatelessWidget {
  const _VictimCard({
    required this.victim,
    required this.isExpanded,
    required this.isDark,
    required this.onToggleExpand,
  });

  final VictimItem victim;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF16A34A)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: const Color(0xFF16A34A).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header Row (Always Visible)
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFF16A34A).withValues(alpha: 0.15),
                    child: Text(
                      victim.name.isNotEmpty
                          ? victim.name[0].toUpperCase()
                          : 'V',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                victim.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF16A34A)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${victim.statements.length} Statements',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (victim.role.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            victim.role,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 13,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${victim.age} Yrs • ${victim.gender}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            if (victim.phone.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  victim.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (victim.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  victim.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded
                        ? const Color(0xFF16A34A)
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Statements Timeline Section
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_outlined,
                        size: 16,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recorded Statements (${victim.statements.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (victim.statements.isEmpty)
                    Text(
                      'No recorded statements.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: victim.statements.length,
                      itemBuilder: (context, index) {
                        final statement = victim.statements[index];
                        final isLast = index == victim.statements.length - 1;
                        return _StatementTimelineTile(
                          statement: statement,
                          isLast: isLast,
                          isDark: isDark,
                          accentColor: const Color(0xFF16A34A),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatementTimelineTile extends StatelessWidget {
  const _StatementTimelineTile({
    required this.statement,
    required this.isLast,
    required this.isDark,
    required this.accentColor,
  });

  final PersonStatement statement;
  final bool isLast;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formattedTime = statement.timestamp.contains('T')
        ? statement.timestamp.split('T')[1].split('+')[0]
        : statement.timestamp;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Dot & Line
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.format_quote_rounded,
                size: 14,
                color: accentColor,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 100,
                color: colorScheme.onSurface.withValues(alpha: 0.1),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Statement Card
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statement.statementId.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Transcript Text
                Text(
                  statement.transcript,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // Footer: GPS Location & Evidence Tags
                Row(
                  children: [
                    if (statement.gps != null)
                      InkWell(
                        onTap: () => MapLauncher.openMap(
                          latitude: statement.gps!.latitude,
                          longitude: statement.gps!.longitude,
                          title: 'Statement ${statement.statementId}',
                        ),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                statement.gps!.formatted,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (statement.evidenceIds.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Wrap(
                        spacing: 4,
                        children: statement.evidenceIds
                            .map(
                              (evId) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  evId,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 10. Witnesses Bottom Sheet & Statements Accordion Timeline
void _showWitnessesBottomSheet(
  BuildContext context,
  List<WitnessItem> witnesses,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _WitnessesBottomSheet(
      witnesses: witnesses,
      isDark: isDark,
    ),
  );
}

class _WitnessesBottomSheet extends StatefulWidget {
  const _WitnessesBottomSheet({
    required this.witnesses,
    required this.isDark,
  });

  final List<WitnessItem> witnesses;
  final bool isDark;

  @override
  State<_WitnessesBottomSheet> createState() => _WitnessesBottomSheetState();
}

class _WitnessesBottomSheetState extends State<_WitnessesBottomSheet> {
  String? _expandedWitnessId;

  @override
  void initState() {
    super.initState();
    if (widget.witnesses.isNotEmpty) {
      _expandedWitnessId = widget.witnesses.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Color(0xFFEA580C),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('witnesses'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${widget.witnesses.length} ${loc.text('witnesses')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // Witnesses Accordion List
              Expanded(
                child: widget.witnesses.isEmpty
                    ? Center(
                        child: Text(
                          'No witnesses recorded.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: widget.witnesses.length,
                        itemBuilder: (context, index) {
                          final witness = widget.witnesses[index];
                          final isExpanded = _expandedWitnessId == witness.id;
                          return _WitnessCard(
                            witness: witness,
                            isExpanded: isExpanded,
                            isDark: widget.isDark,
                            onToggleExpand: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedWitnessId = null;
                                } else {
                                  _expandedWitnessId = witness.id;
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WitnessCard extends StatelessWidget {
  const _WitnessCard({
    required this.witness,
    required this.isExpanded,
    required this.isDark,
    required this.onToggleExpand,
  });

  final WitnessItem witness;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFFEA580C)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFFEA580C).withValues(alpha: 0.15),
                    child: Text(
                      witness.name.isNotEmpty
                          ? witness.name[0].toUpperCase()
                          : 'W',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA580C),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                witness.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEA580C)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${witness.statements.length} Statements',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (witness.occupation.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            witness.occupation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 13,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${witness.age} Yrs • ${witness.gender}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            if (witness.phone.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  witness.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (witness.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  witness.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded
                        ? const Color(0xFFEA580C)
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Statements Timeline Section
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_outlined,
                        size: 16,
                        color: Color(0xFFEA580C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recorded Statements (${witness.statements.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEA580C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (witness.statements.isEmpty)
                    Text(
                      'No recorded statements.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: witness.statements.length,
                      itemBuilder: (context, index) {
                        final statement = witness.statements[index];
                        final isLast = index == witness.statements.length - 1;
                        return _StatementTimelineTile(
                          statement: statement,
                          isLast: isLast,
                          isDark: isDark,
                          accentColor: const Color(0xFFEA580C),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 11. Suspects Bottom Sheet & Statements Accordion Timeline
void _showSuspectsBottomSheet(
  BuildContext context,
  List<SuspectItem> suspects,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SuspectsBottomSheet(
      suspects: suspects,
      isDark: isDark,
    ),
  );
}

class _SuspectsBottomSheet extends StatefulWidget {
  const _SuspectsBottomSheet({
    required this.suspects,
    required this.isDark,
  });

  final List<SuspectItem> suspects;
  final bool isDark;

  @override
  State<_SuspectsBottomSheet> createState() => _SuspectsBottomSheetState();
}

class _SuspectsBottomSheetState extends State<_SuspectsBottomSheet> {
  String? _expandedSuspectId;

  @override
  void initState() {
    super.initState();
    if (widget.suspects.isNotEmpty) {
      _expandedSuspectId = widget.suspects.first.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9333EA).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_rounded,
                        color: Color(0xFF9333EA),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.text('suspects'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            '${widget.suspects.length} ${loc.text('suspects')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),

              // Suspects Accordion List
              Expanded(
                child: widget.suspects.isEmpty
                    ? Center(
                        child: Text(
                          'No suspects recorded.',
                          style: TextStyle(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: widget.suspects.length,
                        itemBuilder: (context, index) {
                          final suspect = widget.suspects[index];
                          final isExpanded = _expandedSuspectId == suspect.id;
                          return _SuspectCard(
                            suspect: suspect,
                            isExpanded: isExpanded,
                            isDark: widget.isDark,
                            onToggleExpand: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedSuspectId = null;
                                } else {
                                  _expandedSuspectId = suspect.id;
                                }
                              });
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SuspectCard extends StatelessWidget {
  const _SuspectCard({
    required this.suspect,
    required this.isExpanded,
    required this.isDark,
    required this.onToggleExpand,
  });

  final SuspectItem suspect;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onToggleExpand;

  Color _getStatusColor(String status) {
    return const Color(0xFF9333EA);
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _getStatusColor(suspect.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF9333EA)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: const Color(0xFF9333EA).withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Column(
        children: [
          // Header Row
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        const Color(0xFF9333EA).withValues(alpha: 0.15),
                    child: Text(
                      suspect.name.isNotEmpty
                          ? suspect.name[0].toUpperCase()
                          : 'S',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9333EA),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                suspect.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                suspect.status.isNotEmpty
                                    ? suspect.status
                                    : 'Suspect',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 13,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${suspect.age} Yrs • ${suspect.gender}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9333EA)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${suspect.statements.length} Statements',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF9333EA),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (suspect.address.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  suspect.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded
                        ? const Color(0xFF9333EA)
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Statements Timeline Section
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.record_voice_over_outlined,
                        size: 16,
                        color: Color(0xFF9333EA),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Recorded Statements (${suspect.statements.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9333EA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (suspect.statements.isEmpty)
                    Text(
                      'No recorded statements.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: suspect.statements.length,
                      itemBuilder: (context, index) {
                        final statement = suspect.statements[index];
                        final isLast = index == suspect.statements.length - 1;
                        return _StatementTimelineTile(
                          statement: statement,
                          isLast: isLast,
                          isDark: isDark,
                          accentColor: const Color(0xFF9333EA),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Modal Bottom Sheet for editing Incident Title, Category, and Summary
class _EditIncidentBottomSheet extends StatefulWidget {
  const _EditIncidentBottomSheet({
    required this.timelineDetails,
    required this.ref,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;

  @override
  State<_EditIncidentBottomSheet> createState() => _EditIncidentBottomSheetState();
}

class _EditIncidentBottomSheetState extends State<_EditIncidentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _summaryController;
  bool _isSaving = false;

  final List<Map<String, String>> _presetCategories = [
    {'key': 'theft_crime', 'fallback': 'Theft'},
    {'key': 'vehicle_crime', 'fallback': 'Vehicle'},
    {'key': 'assault_crime', 'fallback': 'Assault'},
    {'key': 'cyber_crime', 'fallback': 'Cyber Crime'},
    {'key': 'fraud_crime', 'fallback': 'Fraud'},
    {'key': 'general_crime', 'fallback': 'General'},
  ];

  @override
  void initState() {
    super.initState();
    final overview = widget.timelineDetails.incident;
    _titleController = TextEditingController(text: overview.incidentName);
    _categoryController = TextEditingController(
      text: overview.rawCategory.isNotEmpty ? overview.rawCategory : overview.category.name,
    );
    _summaryController = TextEditingController(text: overview.summary);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final currentDetails = widget.timelineDetails;
      final newTitle = _titleController.text.trim();
      final newCategory = _categoryController.text.trim();
      final newSummary = _summaryController.text.trim();

      IncidentCategory catEnum;
      final lowerCat = newCategory.toLowerCase();
      if (lowerCat.contains('theft') || lowerCat.contains('चोरी')) {
        catEnum = IncidentCategory.theft;
      } else if (lowerCat.contains('vehicle') || lowerCat.contains('वाहन')) {
        catEnum = IncidentCategory.vehicle;
      } else if (lowerCat.contains('assault') || lowerCat.contains('हमला')) {
        catEnum = IncidentCategory.assault;
      } else {
        catEnum = IncidentCategory.general;
      }

      final updatedOverview = currentDetails.incident.copyWith(
        incidentName: newTitle,
        rawCategory: newCategory,
        category: catEnum,
        summary: newSummary,
      );

      final updatedDetails = TimelineDetails(
        incident: updatedOverview,
        officer: currentDetails.officer,
        victims: currentDetails.victims,
        witnesses: currentDetails.witnesses,
        suspects: currentDetails.suspects,
        officerObservations: currentDetails.officerObservations,
        evidence: currentDetails.evidence,
        timeline: currentDetails.timeline,
      );

      final rootIncident = updatedOverview.toRootIncident();

      // Persist to BOTH places across app (Specific timeline details + Root all incidents summary)
      await widget.ref
          .read(timelineMapNotifierProvider.notifier)
          .saveTimelineDetails(currentDetails.incident.id, updatedDetails);
      await widget.ref
          .read(allIncidentsProvider.notifier)
          .updateIncident(rootIncident);

      // Invalidate providers so UI updates instantly everywhere
      widget.ref.invalidate(timelineDetailsProvider(currentDetails.incident.id));
      widget.ref.invalidate(allIncidentsProvider);
      widget.ref.invalidate(homeDataProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.text('incident_updated')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update incident: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag Indicator Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      loc.text('edit_incident_details'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 20),

                // Incident Title Field
                Text(
                  loc.text('incident_title'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: loc.text('incident_title_hint'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? loc.text('enter_incident_title') : null,
                ),
                const SizedBox(height: 16),

                // Category Chips & Input Field
                Text(
                  loc.text('category'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _presetCategories.map((item) {
                    final catLabel = loc.text(item['key']!);
                    final isSelected =
                        _categoryController.text.trim().toLowerCase() == catLabel.toLowerCase() ||
                        _categoryController.text.trim().toLowerCase() == item['fallback']!.toLowerCase();
                    return ChoiceChip(
                      label: Text(catLabel),
                      selected: isSelected,
                      selectedColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _categoryController.text = catLabel;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: loc.text('category_hint'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (val) =>
                      val == null || val.trim().isEmpty ? loc.text('enter_category') : null,
                ),
                const SizedBox(height: 16),

                // Summary / Officer Remarks Input
                Text(
                  loc.text('summary'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _summaryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: loc.text('enter_summary'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 24),

                // Bottom Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                        child: Text(loc.text('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isSaving ? null : () => _saveChanges(loc),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(loc.text('save_changes'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





