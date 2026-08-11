import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


import '../../app/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../database/isar_service.dart';
import '../../utils/map_launcher.dart';
import '../../utils/time_formatter.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import '../incidents/incidents_provider.dart';
import '../../services/location_weather_service.dart';
import '../../widgets/full_screen_image_viewer.dart';
import '../../widgets/full_screen_video_player.dart';
import '../../widgets/full_screen_audio_player.dart';
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


  Future<void> _updateIncidentStatus(TimelineDetails details, String newStatusStr) async {
    final currentStatusStr = details.incident.rawStatus.toLowerCase();
    if (currentStatusStr == newStatusStr.toLowerCase()) {
      return; // Already in this status
    }

    final now = DateTime.now();
    final nowIso = now.toIso8601String();

    IncidentStatus newStatusEnum;
    switch (newStatusStr.toLowerCase()) {
      case 'active':
        newStatusEnum = IncidentStatus.active;
        break;
      case 'completed':
        newStatusEnum = IncidentStatus.completed;
        break;
      default:
        newStatusEnum = IncidentStatus.draft;
    }

    String completedAt = details.incident.completedAt;
    String completedDate = details.incident.completedDate;

    if (newStatusEnum == IncidentStatus.completed) {
      final formattedTime = formatTo12HourTime(nowIso);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final formattedDateStr = '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';

      completedAt = formattedTime;
      completedDate = formattedDateStr;
    }

    final updatedOverview = details.incident.copyWith(
      status: newStatusEnum,
      rawStatus: newStatusStr.toLowerCase(),
      completedAt: completedAt,
      completedDate: completedDate,
      lastInteracted: nowIso,
    );

    final statusEvent = TimelineEvent(
      timelineId: 'tl_${now.millisecondsSinceEpoch}',
      timestamp: nowIso,
      eventType: 'status_change',
      personId: details.officer.badgeNumber,
      referenceId: '',
      evidenceIds: const [],
      gps: updatedOverview.gps,
    );

    final updatedDetails = TimelineDetails(
      incident: updatedOverview,
      officer: details.officer,
      victims: details.victims,
      witnesses: details.witnesses,
      suspects: details.suspects,
      officerObservations: details.officerObservations,
      evidence: details.evidence,
      timeline: [...details.timeline, statusEvent],
    );

    final rootIncident = updatedOverview.toRootIncident();

    // Persist to Database 2 (Specific Timeline Details) & Database 1 (All Incidents Summary)
    await ref
        .read(timelineMapNotifierProvider.notifier)
        .saveTimelineDetails(widget.incidentId, updatedDetails);
    await ref
        .read(allIncidentsProvider.notifier)
        .updateIncident(rootIncident);

    // Invalidate Riverpod providers for immediate UI refresh across all screens
    ref.invalidate(timelineDetailsProvider(widget.incidentId));
    ref.invalidate(allIncidentsProvider);
    ref.invalidate(homeDataProvider);

    if (mounted) {
      final label = newStatusStr[0].toUpperCase() + newStatusStr.substring(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status changed to $label'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  void _showAddObservationBottomSheet(BuildContext context, TimelineDetails timelineDetails) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddObservationBottomSheet(
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          context.pop();
        } else {
          context.go('/incidents');
        }
      },
      child: Scaffold(
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
                context.go('/incidents');
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
              if (timelineDetails == null) return;
              if (value == 'edit') {
                _showEditIncidentBottomSheet(context, timelineDetails);
              } else if (value == 'status_active') {
                _updateIncidentStatus(timelineDetails, 'active');
              } else if (value == 'status_draft') {
                _updateIncidentStatus(timelineDetails, 'draft');
              } else if (value == 'status_completed') {
                _updateIncidentStatus(timelineDetails, 'completed');
              } else if (value == 'delete') {
                _confirmDeleteIncident(context, widget.incidentId);
              }
            },
            itemBuilder: (context) {
              final currentStatus = timelineDetailsAsync.value?.incident.rawStatus.toLowerCase() ?? 'active';
              return [
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
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'status_active',
                  child: Row(
                    children: [
                      Icon(
                        currentStatus == 'active' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mark as Active',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: currentStatus == 'active' ? FontWeight.bold : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'status_draft',
                  child: Row(
                    children: [
                      Icon(
                        currentStatus == 'draft' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: const Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mark as Draft',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: currentStatus == 'draft' ? FontWeight.bold : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'status_completed',
                  child: Row(
                    children: [
                      Icon(
                        currentStatus == 'completed' ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Mark as Completed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: currentStatus == 'completed' ? FontWeight.bold : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
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
              ];
            },
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
                ref: ref,
                onMetricTap: (label) => _showComingSoon(context, '$label List'),
                onEvidenceTap: _scrollToEvidenceSection,
                onAddObservation: () => _showAddObservationBottomSheet(context, timelineDetails),
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
                onEvidenceTap: (item) {
                  if (item.type == EvidenceType.audio &&
                      item.location != null &&
                      item.location!.isNotEmpty) {
                    FullScreenAudioPlayer.open(
                      context,
                      audioPath: item.location!,
                      title: item.fileName,
                      caption:
                          'Captured at ${item.capturedAt} \u2022 Size: ${item.fileSize}',
                    );
                    return;
                  }

                  if (item.type == EvidenceType.video &&
                      item.location != null &&
                      item.location!.isNotEmpty) {
                    FullScreenVideoPlayer.open(
                      context,
                      videoPath: item.location!,
                      title: item.fileName,
                      caption:
                          'Captured at ${item.capturedAt} \u2022 Size: ${item.fileSize}',
                    );
                    return;
                  }

                  final photoItems = timelineDetails.evidence
                      .where((e) =>
                          e.type == EvidenceType.photo &&
                          e.location != null &&
                          e.location!.isNotEmpty)
                      .toList();
                  final index = photoItems.indexWhere((e) => e.id == item.id);
                  if (index >= 0) {
                    final viewerItems = photoItems.map((e) {
                      return ImageViewerItem.fromPath(
                        e.location!,
                        title: e.fileName,
                        caption:
                            'Captured at ${e.capturedAt} \u2022 Size: ${e.fileSize}',
                        heroTag: 'evidence_${e.id}',
                      );
                    }).toList();

                    FullScreenImageViewer.open(
                      context,
                      items: viewerItems,
                      initialIndex: index,
                    );
                  } else if (item.location != null && item.location!.isNotEmpty) {
                    FullScreenImageViewer.openSingle(
                      context,
                      imagePath: item.location!,
                      title: item.fileName,
                      caption:
                          'Captured at ${item.capturedAt} \u2022 Size: ${item.fileSize}',
                    );
                  } else {
                    _showComingSoon(context, 'Open ${item.fileName}');
                  }
                },
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
                            '${incident.startedDate}, ${formatTo12HourTime(incident.startedAt)}',
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
                            '${incident.completedDate}, ${formatTo12HourTime(incident.completedAt)}',
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
    required this.ref,
    required this.onMetricTap,
    this.onEvidenceTap,
    this.onAddObservation,
  });

  final TimelineDetails timelineDetails;
  final bool isDark;
  final WidgetRef ref;
  final ValueChanged<String> onMetricTap;
  final VoidCallback? onEvidenceTap;
  final VoidCallback? onAddObservation;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Add Observation action card
          _MetricActionCard(
            icon: Icons.mic_rounded,
            iconColor: const Color(0xFF2563EB),
            label: loc.text('add_observation'),
            isDark: isDark,
            onTap: onAddObservation ?? () {},
          ),
          const SizedBox(width: 8),
          _MetricItemCard(
            icon: Icons.visibility_rounded,
            iconColor: const Color(0xFF2563EB),
            count: timelineDetails.officerObservations.length,
            label: loc.text('observations'),
            isDark: isDark,
            onTap: () => _showObservationsBottomSheet(
              context,
              timelineDetails,
              ref,
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
            onTap: () => showVictimsBottomSheet(
              context,
              timelineDetails,
              ref,
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
            onTap: () => showWitnessesBottomSheet(
              context,
              timelineDetails,
              ref,
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
            onTap: () => showSuspectsBottomSheet(
              context,
              timelineDetails,
              ref,
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

/// Action card used in the metrics bar for quick-add buttons (e.g., Add Observation).
class _MetricActionCard extends StatelessWidget {
  const _MetricActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 102,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 20, color: iconColor),
                Positioned(
                  top: -6,
                  right: -8,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: iconColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
            ),
          ],
        ),
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
                      value: '${incident.startedDate}, ${formatTo12HourTime(incident.startedAt)}',
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.check_circle_outline_rounded,
                      label: loc.text('completed_at'),
                      value: '${incident.completedDate}, ${formatTo12HourTime(incident.completedAt)}',
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
    required this.onEvidenceTap,
  });

  final List<EvidenceItem> evidenceList;
  final bool isDark;
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
          Text(
            'Evidence Collected',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
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
        typeLabel = 'Photo \u2022 ${item.fileSize}';
        final hasLocalFile = item.location != null &&
            item.location!.isNotEmpty &&
            File(item.location!).existsSync();

        thumbnailWidget = Container(
          color: const Color(0xFF334155),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasLocalFile)
                Image.file(
                  File(item.location!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.camera_alt_rounded, color: Colors.white70, size: 32),
                  ),
                )
              else
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
        typeLabel = 'Video \u2022 ${item.fileSize}';
        thumbnailWidget = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
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
        typeLabel = 'Audio \u2022 ${item.fileSize}';
        thumbnailWidget = Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF431407), Color(0xFF9A3412)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Stack(
            children: [
              Center(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          _AudioWaveBar(height: 12),
                          _AudioWaveBar(height: 22),
                          _AudioWaveBar(height: 32),
                          _AudioWaveBar(height: 16),
                          _AudioWaveBar(height: 28),
                          _AudioWaveBar(height: 38),
                          _AudioWaveBar(height: 20),
                          _AudioWaveBar(height: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        break;

      case EvidenceType.document:
        typeLabel = 'Document \u2022 ${item.fileSize}';
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

class _AudioWaveBar extends StatelessWidget {
  const _AudioWaveBar({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(3),
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

  String _getEventTitle(String eventType, AppLocalizations loc) {
    switch (eventType) {
      case 'case_brief':
        return 'Case Brief (Initial Report)';
      case 'officer_observation':
        return 'Officer Observation';
      case 'victim_added':
        return loc.text('victim_added_title');
      case 'witness_added':
        return loc.text('witness_added_title');
      case 'suspect_added':
        return loc.text('suspect_added_title');
      case 'victim_statement':
        return loc.text('victim_statement_title');
      case 'witness_statement':
        return loc.text('witness_statement_title');
      case 'suspect_statement':
        return loc.text('suspect_statement_title');
      case 'evidence_capture':
        return 'Evidence Capture';
      case 'incident_edit':
        return 'Incident Details Modified';
      case 'status_change':
        return 'Case Status Updated';
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
      return parts.join(' \u2022 ');
    }
    if (event.eventType == 'incident_edit') {
      parts.add('Incident parameters updated by officer');
      if (event.personId.isNotEmpty) {
        parts.add('Officer: ${event.personId}');
      }
      return parts.join(' \u2022 ');
    }
    if (event.eventType == 'victim_added' ||
        event.eventType == 'witness_added' ||
        event.eventType == 'suspect_added') {
      if (event.referenceId.isNotEmpty) {
        parts.add('Name: ${event.referenceId}');
      }
      if (event.personId.isNotEmpty) {
        parts.add('ID: ${event.personId}');
      }
      return parts.join(' \u2022 ');
    }
    if (event.referenceId.isNotEmpty) {
      parts.add('Ref: ${event.referenceId}');
    }
    if (event.personId.isNotEmpty) {
      parts.add('ID: ${event.personId}');
    }
    if (parts.isEmpty && event.gps.formatted.isNotEmpty) {
      parts.add('GPS: ${event.gps.formatted}');
    }
    return parts.isEmpty ? 'Timeline Logged Event' : parts.join(' \u2022 ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

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
      case 'victim_added':
        badgeColor = Colors.green;
        eventIcon = Icons.person_add_alt_1_rounded;
        break;
      case 'witness_added':
        badgeColor = Colors.orange;
        eventIcon = Icons.person_add_alt_1_rounded;
        break;
      case 'suspect_added':
        badgeColor = Colors.purple;
        eventIcon = Icons.person_add_alt_1_rounded;
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
      case 'incident_edit':
        badgeColor = const Color(0xFF6366F1);
        eventIcon = Icons.edit_note_rounded;
        break;
      case 'status_change':
        badgeColor = const Color(0xFFD97706);
        eventIcon = Icons.rule_rounded;
        break;
      default:
        badgeColor = colorScheme.primary;
        eventIcon = Icons.circle_outlined;
    }

    final formattedTime = formatTo12HourTime(event.timestamp);

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
                _getEventTitle(event.eventType, loc),
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

/// Dialog for editing an Observation or Statement transcript
void _showEditTranscriptDialog({
  required BuildContext context,
  required WidgetRef ref,
  required TimelineDetails timelineDetails,
  required String targetId,
  required String initialTranscript,
  required bool isObservation,
  String personId = '',
  String personType = '',
}) {
  final controller = TextEditingController(text: initialTranscript);
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final loc = AppLocalizations.of(context);

  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: isObservation
                ? const Color(0xFF2563EB).withValues(alpha: 0.15)
                : const Color(0xFF9333EA).withValues(alpha: 0.15),
            child: Icon(
              Icons.edit_note_rounded,
              color: isObservation ? const Color(0xFF2563EB) : const Color(0xFF9333EA),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            loc.text(isObservation ? 'edit_observation' : 'edit_statement'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller,
                minLines: 3,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: loc.text('transcript_label'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: Text(loc.text('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isObservation ? const Color(0xFF2563EB) : const Color(0xFF9333EA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            final newTranscript = controller.text.trim();
            if (newTranscript.isEmpty) return;

            Navigator.of(dialogCtx).pop();

            TimelineDetails updatedDetails;
            if (isObservation) {
              updatedDetails = timelineDetails.withUpdatedOfficerObservation(targetId, newTranscript);
            } else {
              updatedDetails = timelineDetails.withUpdatedPersonStatement(
                personId,
                personType,
                targetId,
                newTranscript,
              );
            }

            final rootIncident = updatedDetails.incident.toRootIncident();

            await ref
                .read(timelineMapNotifierProvider.notifier)
                .saveTimelineDetails(timelineDetails.incident.id, updatedDetails);
            await ref
                .read(allIncidentsProvider.notifier)
                .updateIncident(rootIncident);

            ref.invalidate(timelineDetailsProvider(timelineDetails.incident.id));
            ref.invalidate(allIncidentsProvider);
            ref.invalidate(homeDataProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.text(isObservation ? 'observation_updated' : 'statement_updated')),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text(loc.text('save_changes'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

/// Dialog for deleting an Observation or Statement
void _showDeleteTranscriptDialog({
  required BuildContext context,
  required WidgetRef ref,
  required TimelineDetails timelineDetails,
  required String targetId,
  required bool isObservation,
  String personId = '',
  String personType = '',
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final loc = AppLocalizations.of(context);

  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      title: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFFEE2E2),
            child: Icon(Icons.warning_amber_rounded, color: AppColors.error),
          ),
          const SizedBox(width: 12),
          Text(
            loc.text(isObservation ? 'delete_observation' : 'delete_statement'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      content: Text(
        loc.text(isObservation ? 'delete_observation_confirm' : 'delete_statement_confirm'),
        style: const TextStyle(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(),
          child: Text(loc.text('cancel')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () async {
            Navigator.of(dialogCtx).pop();

            TimelineDetails updatedDetails;
            if (isObservation) {
              updatedDetails = timelineDetails.withoutOfficerObservation(targetId);
            } else {
              updatedDetails = timelineDetails.withoutPersonStatement(
                personId,
                personType,
                targetId,
              );
            }

            final rootIncident = updatedDetails.incident.toRootIncident();

            await ref
                .read(timelineMapNotifierProvider.notifier)
                .saveTimelineDetails(timelineDetails.incident.id, updatedDetails);
            await ref
                .read(allIncidentsProvider.notifier)
                .updateIncident(rootIncident);

            ref.invalidate(timelineDetailsProvider(timelineDetails.incident.id));
            ref.invalidate(allIncidentsProvider);
            ref.invalidate(homeDataProvider);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loc.text(isObservation ? 'observation_deleted' : 'statement_deleted')),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: Text(loc.text('delete'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

/// 8. Officer Observations Bottom Sheet & Timeline Tiles
void _showObservationsBottomSheet(
  BuildContext context,
  TimelineDetails timelineDetails,
  WidgetRef ref,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _OfficerObservationsBottomSheet(
      timelineDetails: timelineDetails,
      ref: ref,
      isDark: isDark,
    ),
  );
}

class _OfficerObservationsBottomSheet extends ConsumerWidget {
  const _OfficerObservationsBottomSheet({
    required this.timelineDetails,
    required this.ref,
    required this.isDark,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final liveDetailsAsync = ref.watch(timelineDetailsProvider(timelineDetails.incident.id));
    final liveDetails = liveDetailsAsync.value ?? timelineDetails;
    final observations = liveDetails.officerObservations.reversed.toList();

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
                          loc.text('no_officer_observations_logged'),
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
                            timelineDetails: liveDetails,
                            ref: ref,
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
    required this.timelineDetails,
    required this.ref,
    required this.isLast,
    required this.isDark,
  });

  final OfficerObservationItem item;
  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final formattedTime = formatTo12HourTime(item.timestamp);

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
                    Row(
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showEditTranscriptDialog(
                                context: context,
                                ref: ref,
                                timelineDetails: timelineDetails,
                                targetId: item.id,
                                initialTranscript: item.transcript,
                                isObservation: true,
                              );
                            } else if (val == 'delete') {
                              _showDeleteTranscriptDialog(
                                context: context,
                                ref: ref,
                                timelineDetails: timelineDetails,
                                targetId: item.id,
                                isObservation: true,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Text(loc.text('edit'), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                  const SizedBox(width: 8),
                                  Text(loc.text('delete'), style: const TextStyle(fontSize: 13, color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                        Row(
                          children: item.evidenceIds
                              .map(
                                (evId) => Container(
                                  margin: const EdgeInsets.only(right: 4),
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
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper to open Add Statement bottom sheet for a person
void _showAddStatementBottomSheet(
  BuildContext context,
  TimelineDetails timelineDetails,
  WidgetRef ref,
  String personId,
  String personName,
  String personType,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddObservationBottomSheet(
      timelineDetails: timelineDetails,
      ref: ref,
      personId: personId,
      personName: personName,
      personType: personType,
    ),
  );
}

/// Dialog Popup for adding or editing a Victim, Witness, or Suspect
class _AddPersonDialog extends StatefulWidget {
  const _AddPersonDialog({
    required this.timelineDetails,
    required this.ref,
    required this.personType,
    this.personId,
    this.initialName,
    this.initialAge,
    this.initialGender,
    this.initialPhone,
    this.initialAddress,
    this.initialExtraText,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final String personType;

  final String? personId;
  final String? initialName;
  final int? initialAge;
  final String? initialGender;
  final String? initialPhone;
  final String? initialAddress;
  final String? initialExtraText;

  bool get isEditing => personId != null && personId!.isNotEmpty;

  @override
  State<_AddPersonDialog> createState() => _AddPersonDialogState();
}

class _AddPersonDialogState extends State<_AddPersonDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _roleOrOccupationController = TextEditingController();

  String _gender = 'Male';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _nameController.text = widget.initialName ?? '';
      _ageController.text = widget.initialAge != null ? widget.initialAge.toString() : '';
      _phoneController.text = widget.initialPhone ?? '';
      _addressController.text = widget.initialAddress ?? '';
      _roleOrOccupationController.text = widget.initialExtraText ?? '';
      if (widget.initialGender != null && widget.initialGender!.isNotEmpty) {
        _gender = widget.initialGender!;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _roleOrOccupationController.dispose();
    super.dispose();
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      if (word == word.toLowerCase()) {
        return word[0].toUpperCase() + word.substring(1);
      }
      return word;
    }).join(' ');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final loc = AppLocalizations.of(context);

    try {
      final name = _toTitleCase(_nameController.text.trim());
      final age = int.tryParse(_ageController.text.trim()) ?? 0;
      final phone = _phoneController.text.trim();
      final address = _toTitleCase(_addressController.text.trim());
      final extraText = _toTitleCase(_roleOrOccupationController.text.trim());

      TimelineDetails updatedDetails;
      String successKey;

      if (widget.isEditing) {
        if (widget.personType == 'witness') {
          final existing = widget.timelineDetails.witnesses.firstWhere(
            (w) => w.id == widget.personId,
            orElse: () => WitnessItem(
              id: widget.personId!,
              name: name,
              age: age,
              gender: _gender,
              phone: phone,
              address: address,
              occupation: extraText,
              statements: const [],
            ),
          );
          final updatedWitness = WitnessItem(
            id: widget.personId!,
            name: name,
            age: age,
            gender: _gender,
            phone: phone,
            address: address,
            occupation: extraText,
            statements: existing.statements,
          );
          updatedDetails = widget.timelineDetails.withUpdatedWitness(updatedWitness);
          successKey = 'witness_updated';
        } else if (widget.personType == 'suspect') {
          final existing = widget.timelineDetails.suspects.firstWhere(
            (s) => s.id == widget.personId,
            orElse: () => SuspectItem(
              id: widget.personId!,
              name: name,
              age: age,
              gender: _gender,
              address: address,
              status: extraText.isNotEmpty ? extraText : 'Suspect',
              statements: const [],
            ),
          );
          final updatedSuspect = SuspectItem(
            id: widget.personId!,
            name: name,
            age: age,
            gender: _gender,
            address: address,
            status: extraText.isNotEmpty ? extraText : 'Suspect',
            statements: existing.statements,
          );
          updatedDetails = widget.timelineDetails.withUpdatedSuspect(updatedSuspect);
          successKey = 'suspect_updated';
        } else {
          final existing = widget.timelineDetails.victims.firstWhere(
            (v) => v.id == widget.personId,
            orElse: () => VictimItem(
              id: widget.personId!,
              name: name,
              age: age,
              gender: _gender,
              phone: phone,
              address: address,
              role: extraText,
              statements: const [],
            ),
          );
          final updatedVictim = VictimItem(
            id: widget.personId!,
            name: name,
            age: age,
            gender: _gender,
            phone: phone,
            address: address,
            role: extraText,
            statements: existing.statements,
          );
          updatedDetails = widget.timelineDetails.withUpdatedVictim(updatedVictim);
          successKey = 'victim_updated';
        }
      } else {
        if (widget.personType == 'witness') {
          final existingCount = widget.timelineDetails.witnesses.length;
          final autoId = 'wit_${(existingCount + 1).toString().padLeft(3, '0')}';
          final newWitness = WitnessItem(
            id: autoId,
            name: name,
            age: age,
            gender: _gender,
            phone: phone,
            address: address,
            occupation: extraText,
            statements: const [],
          );
          updatedDetails = widget.timelineDetails.withWitness(newWitness);
          successKey = 'witness_added';
        } else if (widget.personType == 'suspect') {
          final existingCount = widget.timelineDetails.suspects.length;
          final autoId = 'sus_${(existingCount + 1).toString().padLeft(3, '0')}';
          final newSuspect = SuspectItem(
            id: autoId,
            name: name,
            age: age,
            gender: _gender,
            address: address,
            status: extraText.isNotEmpty ? extraText : 'Suspect',
            statements: const [],
          );
          updatedDetails = widget.timelineDetails.withSuspect(newSuspect);
          successKey = 'suspect_added';
        } else {
          final existingCount = widget.timelineDetails.victims.length;
          final autoId = 'vic_${(existingCount + 1).toString().padLeft(3, '0')}';
          final newVictim = VictimItem(
            id: autoId,
            name: name,
            age: age,
            gender: _gender,
            phone: phone,
            address: address,
            role: extraText,
            statements: const [],
          );
          updatedDetails = widget.timelineDetails.withVictim(newVictim);
          successKey = 'victim_added';
        }
      }

      final rootIncident = updatedDetails.incident.toRootIncident();

      await widget.ref
          .read(timelineMapNotifierProvider.notifier)
          .saveTimelineDetails(widget.timelineDetails.incident.id, updatedDetails);
      await widget.ref
          .read(allIncidentsProvider.notifier)
          .updateIncident(rootIncident);

      widget.ref.invalidate(timelineDetailsProvider(widget.timelineDetails.incident.id));
      widget.ref.invalidate(allIncidentsProvider);
      widget.ref.invalidate(homeDataProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.text(successKey)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
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
    final loc = AppLocalizations.of(context);

    String title;
    Color accentColor;
    String nameHint;
    String extraLabel;
    String extraHint;
    IconData extraIcon;

    if (widget.personType == 'witness') {
      title = loc.text(widget.isEditing ? 'edit_witness_btn' : 'add_witness_btn');
      accentColor = const Color(0xFFEA580C);
      nameHint = loc.text('person_name_hint');
      extraLabel = loc.text('occupation');
      extraHint = loc.text('witness_occupation_hint');
      extraIcon = Icons.work_outline;
    } else if (widget.personType == 'suspect') {
      title = loc.text(widget.isEditing ? 'edit_suspect_btn' : 'add_suspect_btn');
      accentColor = const Color(0xFF9333EA);
      nameHint = loc.text('suspect_name_hint');
      extraLabel = loc.text('suspect_status');
      extraHint = loc.text('suspect_status_hint');
      extraIcon = Icons.badge_outlined;
    } else {
      title = loc.text(widget.isEditing ? 'edit_victim_btn' : 'add_victim_btn');
      accentColor = const Color(0xFF16A34A);
      nameHint = loc.text('person_name_hint');
      extraLabel = loc.text('role');
      extraHint = loc.text('victim_role_hint');
      extraIcon = Icons.badge_outlined;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      child: Icon(Icons.person_add_alt_1_rounded, color: accentColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 16),

                // Name (Mandatory)
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: '${loc.text('name')} *',
                    hintText: nameHint,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return loc.text('name_required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Age & Gender (Mandatory)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: '${loc.text('age')} *',
                          hintText: loc.text('age_hint'),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return loc.text('age_required');
                          }
                          if (int.tryParse(val.trim()) == null) {
                            return loc.text('valid_age');
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: '${loc.text('gender')} *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        ),
                        items: [
                          DropdownMenuItem(value: 'Male', child: Text(loc.text('male'))),
                          DropdownMenuItem(value: 'Female', child: Text(loc.text('female'))),
                          DropdownMenuItem(value: 'Other', child: Text(loc.text('other_gender'))),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _gender = val);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Phone (Optional - Victim & Witness)
                if (widget.personType != 'suspect') ...[
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: loc.text('phone'),
                      hintText: loc.text('phone_hint'),
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Address (Optional)
                TextFormField(
                  controller: _addressController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: loc.text('address'),
                    hintText: loc.text('address_hint'),
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),

                // Extra field: Role / Occupation / Status (Optional)
                TextFormField(
                  controller: _roleOrOccupationController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: extraLabel,
                    hintText: extraHint,
                    prefixIcon: Icon(extraIcon),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(loc.text('cancel')),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isSaving ? null : _submit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: _isSaving ? accentColor.withValues(alpha: 0.5) : accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                loc.text(widget.isEditing ? 'save_changes' : 'save'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper to open Edit Person dialog for a victim, witness, or suspect
void _showEditPersonDialog(
  BuildContext context,
  TimelineDetails timelineDetails,
  WidgetRef ref, {
  required String personType,
  required String personId,
  required String name,
  required int age,
  required String gender,
  required String phone,
  required String address,
  required String extraText,
}) {
  showDialog(
    context: context,
    builder: (context) => _AddPersonDialog(
      timelineDetails: timelineDetails,
      ref: ref,
      personType: personType,
      personId: personId,
      initialName: name,
      initialAge: age,
      initialGender: gender,
      initialPhone: phone,
      initialAddress: address,
      initialExtraText: extraText,
    ),
  );
}

/// 9. Victims Bottom Sheet & Statements Accordion Timeline
void showVictimsBottomSheet(
  BuildContext context,
  TimelineDetails timelineDetails,
  WidgetRef ref,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _VictimsBottomSheet(
      timelineDetails: timelineDetails,
      ref: ref,
      isDark: isDark,
    ),
  );
}

class _VictimsBottomSheet extends ConsumerStatefulWidget {
  const _VictimsBottomSheet({
    required this.timelineDetails,
    required this.ref,
    required this.isDark,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isDark;

  @override
  ConsumerState<_VictimsBottomSheet> createState() => _VictimsBottomSheetState();
}

class _VictimsBottomSheetState extends ConsumerState<_VictimsBottomSheet> {
  String? _expandedVictimId;

  @override
  void initState() {
    super.initState();
    if (widget.timelineDetails.victims.isNotEmpty) {
      _expandedVictimId = widget.timelineDetails.victims.last.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final liveDetailsAsync = ref.watch(timelineDetailsProvider(widget.timelineDetails.incident.id));
    final liveDetails = liveDetailsAsync.value ?? widget.timelineDetails;
    final victims = liveDetails.victims.reversed.toList();
    const accentColor = Color(0xFF16A34A);

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

              // Header Row with "Add Victim" Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: accentColor,
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
                            '${victims.length} ${loc.text('victims')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (ctx) => _AddPersonDialog(
                            timelineDetails: liveDetails,
                            ref: widget.ref,
                            personType: 'victim',
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              loc.text('add_victim_btn'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
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
                child: victims.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 48,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              loc.text('no_victims_recorded'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (ctx) => _AddPersonDialog(
                                    timelineDetails: liveDetails,
                                    ref: widget.ref,
                                    personType: 'victim',
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.text('add_victim_btn'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: victims.length,
                        itemBuilder: (context, index) {
                          final victim = victims[index];
                          final isExpanded = _expandedVictimId == victim.id;
                          return _PersonCard(
                            personId: victim.id,
                            name: victim.name,
                            subtitle: victim.role,
                            age: victim.age,
                            gender: victim.gender,
                            phone: victim.phone,
                            address: victim.address,
                            statements: victim.statements,
                            accentColor: accentColor,
                            avatarLetter: 'V',
                            personType: 'victim',
                            timelineDetails: liveDetails,
                            ref: widget.ref,
                            isExpanded: isExpanded,
                            isDark: widget.isDark,
                            onToggleExpand: () {
                              setState(() {
                                _expandedVictimId = isExpanded ? null : victim.id;
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

/// 10. Witnesses Bottom Sheet & Statements Accordion Timeline
void showWitnessesBottomSheet(
  BuildContext context,
  TimelineDetails timelineDetails,
  WidgetRef ref,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _WitnessesBottomSheet(
      timelineDetails: timelineDetails,
      ref: ref,
      isDark: isDark,
    ),
  );
}

class _WitnessesBottomSheet extends ConsumerStatefulWidget {
  const _WitnessesBottomSheet({
    required this.timelineDetails,
    required this.ref,
    required this.isDark,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isDark;

  @override
  ConsumerState<_WitnessesBottomSheet> createState() => _WitnessesBottomSheetState();
}

class _WitnessesBottomSheetState extends ConsumerState<_WitnessesBottomSheet> {
  String? _expandedWitnessId;

  @override
  void initState() {
    super.initState();
    if (widget.timelineDetails.witnesses.isNotEmpty) {
      _expandedWitnessId = widget.timelineDetails.witnesses.last.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final liveDetailsAsync = ref.watch(timelineDetailsProvider(widget.timelineDetails.incident.id));
    final liveDetails = liveDetailsAsync.value ?? widget.timelineDetails;
    final witnesses = liveDetails.witnesses.reversed.toList();
    const accentColor = Color(0xFFEA580C);

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

              // Header Row with "Add Witness" Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: accentColor,
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
                            '${witnesses.length} ${loc.text('witnesses')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (ctx) => _AddPersonDialog(
                            timelineDetails: liveDetails,
                            ref: widget.ref,
                            personType: 'witness',
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              loc.text('add_witness_btn'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
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
                child: witnesses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 48,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              loc.text('no_witnesses_recorded'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (ctx) => _AddPersonDialog(
                                    timelineDetails: liveDetails,
                                    ref: widget.ref,
                                    personType: 'witness',
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.text('add_witness_btn'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: witnesses.length,
                        itemBuilder: (context, index) {
                          final witness = witnesses[index];
                          final isExpanded = _expandedWitnessId == witness.id;
                          return _PersonCard(
                            personId: witness.id,
                            name: witness.name,
                            subtitle: witness.occupation,
                            age: witness.age,
                            gender: witness.gender,
                            phone: witness.phone,
                            address: witness.address,
                            statements: witness.statements,
                            accentColor: accentColor,
                            avatarLetter: 'W',
                            personType: 'witness',
                            timelineDetails: liveDetails,
                            ref: widget.ref,
                            isExpanded: isExpanded,
                            isDark: widget.isDark,
                            onToggleExpand: () {
                              setState(() {
                                _expandedWitnessId = isExpanded ? null : witness.id;
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

/// 11. Suspects Bottom Sheet & Statements Accordion Timeline
void showSuspectsBottomSheet(
  BuildContext context,
  TimelineDetails timelineDetails,
  WidgetRef ref,
  bool isDark,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _SuspectsBottomSheet(
      timelineDetails: timelineDetails,
      ref: ref,
      isDark: isDark,
    ),
  );
}

class _SuspectsBottomSheet extends ConsumerStatefulWidget {
  const _SuspectsBottomSheet({
    required this.timelineDetails,
    required this.ref,
    required this.isDark,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isDark;

  @override
  ConsumerState<_SuspectsBottomSheet> createState() => _SuspectsBottomSheetState();
}

class _SuspectsBottomSheetState extends ConsumerState<_SuspectsBottomSheet> {
  String? _expandedSuspectId;

  @override
  void initState() {
    super.initState();
    if (widget.timelineDetails.suspects.isNotEmpty) {
      _expandedSuspectId = widget.timelineDetails.suspects.last.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    final liveDetailsAsync = ref.watch(timelineDetailsProvider(widget.timelineDetails.incident.id));
    final liveDetails = liveDetailsAsync.value ?? widget.timelineDetails;
    final suspects = liveDetails.suspects.reversed.toList();
    const accentColor = Color(0xFF9333EA);

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

              // Header Row with "Add Suspect" Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_rounded,
                        color: accentColor,
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
                            '${suspects.length} ${loc.text('suspects')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          useRootNavigator: true,
                          builder: (ctx) => _AddPersonDialog(
                            timelineDetails: liveDetails,
                            ref: widget.ref,
                            personType: 'suspect',
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              loc.text('add_suspect_btn'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
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
                child: suspects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_off_outlined,
                              size: 48,
                              color: colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              loc.text('no_suspects_recorded'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  useRootNavigator: true,
                                  builder: (ctx) => _AddPersonDialog(
                                    timelineDetails: liveDetails,
                                    ref: widget.ref,
                                    personType: 'suspect',
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(
                                      loc.text('add_suspect_btn'),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(20),
                        itemCount: suspects.length,
                        itemBuilder: (context, index) {
                          final suspect = suspects[index];
                          final isExpanded = _expandedSuspectId == suspect.id;
                          return _PersonCard(
                            personId: suspect.id,
                            name: suspect.name,
                            subtitle: suspect.status.isNotEmpty ? suspect.status : 'Suspect',
                            age: suspect.age,
                            gender: suspect.gender,
                            address: suspect.address,
                            statements: suspect.statements,
                            accentColor: accentColor,
                            avatarLetter: 'S',
                            personType: 'suspect',
                            timelineDetails: liveDetails,
                            ref: widget.ref,
                            isExpanded: isExpanded,
                            isDark: widget.isDark,
                            onToggleExpand: () {
                              setState(() {
                                _expandedSuspectId = isExpanded ? null : suspect.id;
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

/// Reusable Person Card for Victims, Witnesses, and Suspects
class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.personId,
    required this.name,
    this.subtitle,
    required this.age,
    required this.gender,
    this.phone,
    this.address,
    required this.statements,
    required this.accentColor,
    required this.avatarLetter,
    required this.personType,
    required this.timelineDetails,
    required this.ref,
    required this.isExpanded,
    required this.isDark,
    required this.onToggleExpand,
  });

  final String personId;
  final String name;
  final String? subtitle;
  final int age;
  final String gender;
  final String? phone;
  final String? address;
  final List<PersonStatement> statements;
  final Color accentColor;
  final String avatarLetter;
  final String personType;
  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? accentColor
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AppColors.border),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
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
                    backgroundColor: accentColor.withValues(alpha: 0.15),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : avatarLetter,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
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
                                name,
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
                                color: accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${statements.length} Statements',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
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
                              color: colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$age ${loc.text('yrs')} • $gender',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            if (phone != null && phone!.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              Icon(
                                Icons.phone_outlined,
                                size: 13,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  phone!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (address != null && address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () {
                      _showEditPersonDialog(
                        context,
                        timelineDetails,
                        ref,
                        personType: personType,
                        personId: personId,
                        name: name,
                        age: age,
                        gender: gender,
                        phone: phone ?? '',
                        address: address ?? '',
                        extraText: subtitle ?? '',
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? accentColor : colorScheme.onSurface.withValues(alpha: 0.5),
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
                  GestureDetector(
                    onTap: () => _showAddStatementBottomSheet(
                      context,
                      timelineDetails,
                      ref,
                      personId,
                      name,
                      personType,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.mic_rounded, size: 16, color: accentColor),
                          const SizedBox(width: 8),
                          Text(
                            loc.text('add_statement'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.record_voice_over_outlined, size: 16, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        '${loc.text('recorded_statements')} (${statements.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (statements.isEmpty)
                    Text(
                      loc.text('no_recorded_statements'),
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: statements.length,
                      itemBuilder: (context, index) {
                        final statement = statements[index];
                        final isLast = index == statements.length - 1;
                        return _StatementTimelineTile(
                          statement: statement,
                          personId: personId,
                          personType: personType,
                          timelineDetails: timelineDetails,
                          ref: ref,
                          isLast: isLast,
                          isDark: isDark,
                          accentColor: accentColor,
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
    required this.personId,
    required this.personType,
    required this.timelineDetails,
    required this.ref,
    required this.isLast,
    required this.isDark,
    required this.accentColor,
  });

  final PersonStatement statement;
  final String personId;
  final String personType;
  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final bool isLast;
  final bool isDark;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final formattedTime = formatTo12HourTime(statement.timestamp);

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
                    Row(
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (val) {
                            if (val == 'edit') {
                              _showEditTranscriptDialog(
                                context: context,
                                ref: ref,
                                timelineDetails: timelineDetails,
                                targetId: statement.statementId,
                                initialTranscript: statement.transcript,
                                isObservation: false,
                                personId: personId,
                                personType: personType,
                              );
                            } else if (val == 'delete') {
                              _showDeleteTranscriptDialog(
                                context: context,
                                ref: ref,
                                timelineDetails: timelineDetails,
                                targetId: statement.statementId,
                                isObservation: false,
                                personId: personId,
                                personType: personType,
                              );
                            }
                          },
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  const Icon(Icons.edit_outlined, size: 16),
                                  const SizedBox(width: 8),
                                  Text(loc.text('edit'), style: const TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.error),
                                  const SizedBox(width: 8),
                                  Text(loc.text('delete'), style: const TextStyle(fontSize: 13, color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
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
                        Row(
                          children: statement.evidenceIds
                              .map(
                                (evId) => Container(
                                  margin: const EdgeInsets.only(right: 4),
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
                ),
              ],
            ),
          ),
        ),
      ],
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


/// Modal Bottom Sheet for adding Officer Observation with Audio/Text & Evidence
class AddObservationBottomSheet extends StatefulWidget {
  const AddObservationBottomSheet({
    super.key,
    required this.timelineDetails,
    required this.ref,
    this.personId,
    this.personName,
    this.personType,
  });

  final TimelineDetails timelineDetails;
  final WidgetRef ref;
  final String? personId;
  final String? personName;
  final String? personType;

  @override
  State<AddObservationBottomSheet> createState() => _AddObservationBottomSheetState();
}

class _AddObservationBottomSheetState extends State<AddObservationBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _transcriptController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  bool _isSaving = false;
  String _selectedLanguage = 'English';

  final List<EvidenceItem> _addedEvidenceList = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  @override
  void dispose() {
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (val) {
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
        onStatus: (val) {
          if (mounted) {
            setState(() {
              _isListening = (val == 'listening');
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechAvailable = available;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _speechAvailable = false;
        });
      }
    }
  }

  void _toggleListening() async {
    if (!_speechAvailable) {
      await _initSpeech();
      if (!_speechAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speech recognition is not available or enabled on this device.'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }

    if (_isListening) {
      await _speech.stop();
      if (mounted) {
        setState(() => _isListening = false);
      }
    } else {
      final initialText = _transcriptController.text.trim();
      final localeId = _selectedLanguage == 'Hindi' ? 'hi_IN' : 'en_IN';

      if (mounted) {
        setState(() => _isListening = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Listening in $_selectedLanguage... Speak now'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await _speech.listen(
        listenOptions: stt.SpeechListenOptions(
          localeId: localeId,
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation,
        ),
        onResult: (result) {
          if (mounted) {
            final recognized = result.recognizedWords;
            if (recognized.isNotEmpty) {
              final newText = initialText.isEmpty
                  ? recognized
                  : '$initialText $recognized';
              setState(() {
                _transcriptController.value = TextEditingValue(
                  text: newText,
                  selection: TextSelection.collapsed(offset: newText.length),
                );
              });
            }
            if (result.finalResult || !_speech.isListening) {
              setState(() {
                _isListening = false;
              });
            }
          }
        },
      );
    }
  }


  Future<GpsLocation> _getCurrentDeviceGps() async {
    try {
      final available = await LocationWeatherService.isLocationAvailable();
      if (available) {
        final locData = await LocationWeatherService.fetchLocationAndWeather();
        return GpsLocation(
          latitude: locData.latitude,
          longitude: locData.longitude,
        );
      }
    } catch (_) {}
    return widget.timelineDetails.incident.gps;
  }

  Future<void> _addPhotoEvidence() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo == null) return;

      final GpsLocation currentGps = await _getCurrentDeviceGps();
      final newId = 'photo_evidence_${DateTime.now().millisecondsSinceEpoch}';
      final fileLength = await photo.length();
      final double mbSize = fileLength / (1024 * 1024);
      final String sizeStr = fileLength > 0
          ? (mbSize >= 1.0 ? '${mbSize.toStringAsFixed(1)} MB' : '${(fileLength / 1024).toStringAsFixed(0)} KB')
          : '2.4 MB';

      final item = EvidenceItem(
        id: newId,
        type: EvidenceType.photo,
        fileName: photo.name.isNotEmpty ? photo.name : 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg',
        location: photo.path,
        description: 'Photo evidence captured during officer observation',
        capturedAt: DateTime.now().toIso8601String(),
        gps: currentGps,
        capturedBy: widget.timelineDetails.officer.badgeNumber,
        fileSize: sizeStr,
      );

      if (mounted) {
        setState(() {
          _addedEvidenceList.add(item);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take photo: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addVideoEvidence() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 10),
      );
      if (video == null) return;

      final GpsLocation currentGps = await _getCurrentDeviceGps();
      final newId = 'video_evidence_${DateTime.now().millisecondsSinceEpoch}';
      final fileLength = await video.length();
      final double mbSize = fileLength / (1024 * 1024);
      final String sizeStr = fileLength > 0
          ? (mbSize >= 1.0 ? '${mbSize.toStringAsFixed(1)} MB' : '${(fileLength / 1024).toStringAsFixed(0)} KB')
          : '18.7 MB';

      final item = EvidenceItem(
        id: newId,
        type: EvidenceType.video,
        fileName: video.name.isNotEmpty ? video.name : 'video_${DateTime.now().millisecondsSinceEpoch}.mp4',
        location: video.path,
        description: 'Video recording captured during officer observation',
        capturedAt: DateTime.now().toIso8601String(),
        gps: currentGps,
        capturedBy: widget.timelineDetails.officer.badgeNumber,
        fileSize: sizeStr,
        duration: '00:30',
      );

      if (mounted) {
        setState(() {
          _addedEvidenceList.add(item);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to record video: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addEvidenceFromDevice() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickMedia();
      if (file == null) return;

      // Fetch live device GPS coordinates for this option
      final GpsLocation currentGps = await _getCurrentDeviceGps();

      final newId = 'device_evidence_${DateTime.now().millisecondsSinceEpoch}';
      final fileLength = await file.length();
      final double mbSize = fileLength / (1024 * 1024);
      final String sizeStr = fileLength > 0
          ? (mbSize >= 1.0 ? '${mbSize.toStringAsFixed(1)} MB' : '${(fileLength / 1024).toStringAsFixed(0)} KB')
          : '2.4 MB';

      final ext = file.name.split('.').last.toLowerCase();
      EvidenceType type = EvidenceType.photo;
      if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(ext)) {
        type = EvidenceType.video;
      } else if (['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'].contains(ext)) {
        type = EvidenceType.audio;
      } else if (['pdf', 'doc', 'docx', 'txt'].contains(ext)) {
        type = EvidenceType.document;
      }

      final item = EvidenceItem(
        id: newId,
        type: type,
        fileName: file.name.isNotEmpty ? file.name : 'evidence_${DateTime.now().millisecondsSinceEpoch}.$ext',
        location: file.path,
        description: 'Evidence selected from device storage',
        capturedAt: DateTime.now().toIso8601String(),
        gps: currentGps,
        capturedBy: widget.timelineDetails.officer.badgeNumber,
        fileSize: sizeStr,
        duration: type == EvidenceType.video ? '00:30' : (type == EvidenceType.audio ? '01:30' : ''),
      );

      if (mounted) {
        setState(() {
          _addedEvidenceList.add(item);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file from device: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddEvidencePicker(AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.text('select_evidence_type'),
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF2563EB),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white),
              ),
              title: Text(loc.text('click_picture')),
              onTap: () {
                Navigator.of(ctx).pop();
                _addPhotoEvidence();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF9333EA),
                child: Icon(Icons.videocam_rounded, color: Colors.white),
              ),
              title: Text(loc.text('record_video')),
              onTap: () {
                Navigator.of(ctx).pop();
                _addVideoEvidence();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF0284C7),
                child: Icon(Icons.perm_media_rounded, color: Colors.white),
              ),
              title: Text(loc.text('choose_from_device')),
              onTap: () {
                Navigator.of(ctx).pop();
                _addEvidenceFromDevice();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitObservation(AppLocalizations loc) async {
    final transcript = _transcriptController.text.trim();
    if (transcript.isEmpty && _addedEvidenceList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.text('enter_observation_or_evidence')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final nowIso = DateTime.now().toIso8601String();
      final evidenceIds = _addedEvidenceList.map((e) => e.id).toList();

      TimelineDetails updatedDetails;
      String messageKey;

      if (widget.personType == 'victim' && widget.personId != null) {
        final stmtId = 'stmt_${widget.personId.toString().replaceAll('vic_', 'v')}_${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(2, '0')}';
        final newStatement = PersonStatement(
          statementId: stmtId,
          timestamp: nowIso,
          transcript: transcript.isNotEmpty ? transcript : 'Victim statement recorded with evidence.',
          evidenceIds: evidenceIds,
          gps: widget.timelineDetails.incident.gps,
        );
        updatedDetails = widget.timelineDetails.withVictimStatement(
          widget.personId!,
          newStatement,
          newEvidenceList: _addedEvidenceList,
        );
        messageKey = 'statement_added';
      } else if (widget.personType == 'witness' && widget.personId != null) {
        final stmtId = 'stmt_${widget.personId.toString().replaceAll('wit_', 'w')}_${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(2, '0')}';
        final newStatement = PersonStatement(
          statementId: stmtId,
          timestamp: nowIso,
          transcript: transcript.isNotEmpty ? transcript : 'Witness statement recorded with evidence.',
          evidenceIds: evidenceIds,
          gps: widget.timelineDetails.incident.gps,
        );
        updatedDetails = widget.timelineDetails.withWitnessStatement(
          widget.personId!,
          newStatement,
          newEvidenceList: _addedEvidenceList,
        );
        messageKey = 'statement_added';
      } else if (widget.personType == 'suspect' && widget.personId != null) {
        final stmtId = 'stmt_${widget.personId.toString().replaceAll('sus_', 's')}_${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(2, '0')}';
        final newStatement = PersonStatement(
          statementId: stmtId,
          timestamp: nowIso,
          transcript: transcript.isNotEmpty ? transcript : 'Suspect statement recorded with evidence.',
          evidenceIds: evidenceIds,
          gps: widget.timelineDetails.incident.gps,
        );
        updatedDetails = widget.timelineDetails.withSuspectStatement(
          widget.personId!,
          newStatement,
          newEvidenceList: _addedEvidenceList,
        );
        messageKey = 'statement_added';
      } else {
        final obsId = 'obs_${DateTime.now().millisecondsSinceEpoch}';
        final newObservation = OfficerObservationItem(
          id: obsId,
          timestamp: nowIso,
          gps: widget.timelineDetails.incident.gps,
          transcript: transcript.isNotEmpty ? transcript : 'Officer observation recorded with evidence.',
          evidenceIds: evidenceIds,
        );
        updatedDetails = widget.timelineDetails.withOfficerObservation(
          newObservation,
          newEvidenceList: _addedEvidenceList,
        );
        messageKey = 'observation_added';
      }

      final rootIncident = updatedDetails.incident.toRootIncident();

      // Persist to Database 2 (Specific Timeline Details) & Database 1 (All Incidents Summary)
      await widget.ref
          .read(timelineMapNotifierProvider.notifier)
          .saveTimelineDetails(widget.timelineDetails.incident.id, updatedDetails);
      await widget.ref
          .read(allIncidentsProvider.notifier)
          .updateIncident(rootIncident);

      // Invalidate providers for real-time UI refresh
      widget.ref.invalidate(timelineDetailsProvider(widget.timelineDetails.incident.id));
      widget.ref.invalidate(allIncidentsProvider);
      widget.ref.invalidate(homeDataProvider);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.text(messageKey)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save statement: $e'),
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

    final accentColor = widget.personType == 'victim'
        ? const Color(0xFF16A34A)
        : (widget.personType == 'witness'
            ? const Color(0xFFEA580C)
            : const Color(0xFF2563EB));

    final headerIcon = widget.personType == 'victim'
        ? Icons.person_rounded
        : (widget.personType == 'witness'
            ? Icons.people_alt_rounded
            : Icons.remove_red_eye_rounded);

    final buttonLabel = (widget.personName != null && widget.personName!.isNotEmpty)
        ? loc.text('add_statement')
        : loc.text('add_observation_single');

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

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(headerIcon, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        (widget.personName != null && widget.personName!.isNotEmpty)
                            ? '${loc.text('statement_for')} ${widget.personName}'
                            : loc.text('add_observation_single'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 20),

                Text(
                  loc.text('officer_remarks_transcript'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isListening
                          ? Colors.red
                          : (isDark ? Colors.white12 : AppColors.border),
                      width: _isListening ? 2.0 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _transcriptController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: loc.text('enter_statement_hint'),
                          hintStyle: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('English'),
                                selected: _selectedLanguage == 'English',
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedLanguage = 'English');
                                },
                              ),
                              const SizedBox(width: 8),
                              ChoiceChip(
                                label: const Text('हिन्दी'),
                                selected: _selectedLanguage == 'Hindi',
                                onSelected: (sel) {
                                  if (sel) setState(() => _selectedLanguage = 'Hindi');
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: _isListening
                                  ? Colors.red
                                  : accentColor.withValues(alpha: 0.12),
                            ),
                            icon: Icon(
                              _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                              color: _isListening ? Colors.white : accentColor,
                            ),
                            onPressed: _toggleListening,
                            tooltip: 'Voice Input',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${loc.text('evidence_attachments')} (${_addedEvidenceList.length})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showAddEvidencePicker(loc),
                      icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                      label: Text(loc.text('add_evidence')),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_addedEvidenceList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        loc.text('no_evidence_attached'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _addedEvidenceList.length,
                      itemBuilder: (context, index) {
                        final item = _addedEvidenceList[index];
                        IconData iconData;
                        Color typeColor;

                        switch (item.type) {
                          case EvidenceType.video:
                            iconData = Icons.videocam_rounded;
                            typeColor = const Color(0xFF9333EA);
                            break;
                          case EvidenceType.audio:
                            iconData = Icons.audiotrack_rounded;
                            typeColor = const Color(0xFFEA580C);
                            break;
                          case EvidenceType.document:
                            iconData = Icons.insert_drive_file_rounded;
                            typeColor = const Color(0xFF16A34A);
                            break;
                          case EvidenceType.photo:
                            iconData = Icons.camera_alt_rounded;
                            typeColor = const Color(0xFF2563EB);
                            break;
                        }

                        return Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  if (item.location != null && item.location!.isNotEmpty) {
                                    if (item.type == EvidenceType.audio) {
                                      FullScreenAudioPlayer.open(
                                        context,
                                        audioPath: item.location!,
                                        title: item.fileName,
                                        subtitle: 'Attached Audio Recording',
                                        caption: 'Size: ${item.fileSize}',
                                      );
                                    } else if (item.type == EvidenceType.video) {
                                      FullScreenVideoPlayer.open(
                                        context,
                                        videoPath: item.location!,
                                        title: item.fileName,
                                        subtitle: 'Attached Video Evidence',
                                        caption: 'Size: ${item.fileSize}',
                                      );
                                    } else if (item.type == EvidenceType.photo) {
                                      FullScreenImageViewer.openSingle(
                                        context,
                                        imagePath: item.location!,
                                        title: item.fileName,
                                        subtitle: 'Attached Photo Evidence',
                                        caption: 'Size: ${item.fileSize}',
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  width: 110,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: typeColor,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        iconData,
                                        color: typeColor,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        item.fileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        item.fileSize,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _addedEvidenceList.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSaving ? null : () => _submitObservation(loc),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            buttonLabel,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
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






