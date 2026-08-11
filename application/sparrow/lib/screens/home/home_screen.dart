import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../timeline/timeline_provider.dart';
import '../timeline/timeline_screen.dart';
import 'home_service.dart';
import 'home_widgets.dart';
import 'model/home_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddObservationBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String incidentId,
  ) async {
    try {
      final timelineDetails = await ref.read(timelineDetailsProvider(incidentId).future);
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddObservationBottomSheet(
          timelineDetails: timelineDetails,
          ref: ref,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load incident details: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showVictimsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String incidentId,
  ) async {
    try {
      final timelineDetails = await ref.read(timelineDetailsProvider(incidentId).future);
      if (!context.mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showVictimsBottomSheet(context, timelineDetails, ref, isDark);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load incident details: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showWitnessesBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String incidentId,
  ) async {
    try {
      final timelineDetails = await ref.read(timelineDetailsProvider(incidentId).future);
      if (!context.mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showWitnessesBottomSheet(context, timelineDetails, ref, isDark);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load incident details: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuspectsBottomSheet(
    BuildContext context,
    WidgetRef ref,
    String incidentId,
  ) async {
    try {
      final timelineDetails = await ref.read(timelineDetailsProvider(incidentId).future);
      if (!context.mounted) return;
      final isDark = Theme.of(context).brightness == Brightness.dark;
      showSuspectsBottomSheet(context, timelineDetails, ref, isDark);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load incident details: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: homeDataAsync.when(
        data: (homeData) {
          final officer = homeData.officer;
          final currentIncident = homeData.currentActiveIncident;
          final recentIncidents = homeData.topThreeRecentIncidents;

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              GreetingHeader(
                officerName: officer.name,
                designation: officer.designation,
                station: officer.station,
                profileImage: officer.profileImage,
                onLanguageToggleTap: () =>
                    ref.read(languageProvider.notifier).toggleLanguage(),
                onThemeToggleTap: () =>
                    ref.read(themeModeProvider.notifier).toggleTheme(),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.red.shade400
                          : Colors.red.shade700,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.red.shade400
                            : Colors.red.shade700,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          loc.text('prototype_notice'),
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.red.shade300
                                : Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.4,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: currentIncident != null
                    ? CurrentIncidentCard(
                        incidentName: currentIncident.incidentName,
                        location: currentIncident.location,
                        startedAt: currentIncident.startedAt,
                        startedDate: currentIncident.startedDate,
                        status: currentIncident.status.label,
                        onTimelineTap: () =>
                            context.go('/timeline/${currentIncident.id}'),
                      )
                    : NoActiveIncidentCard(
                        onStartNewIncident: () => context.go('/new-incident'),
                      ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuickActionsSection(
                  quickActions: homeData.quickActions,
                  onActionTap: (action) {
                    if (currentIncident != null) {
                      switch (action.actionType) {
                        case QuickActionType.observation:
                          _showAddObservationBottomSheet(context, ref, currentIncident.id);
                          break;
                        case QuickActionType.victimStatement:
                          _showVictimsBottomSheet(context, ref, currentIncident.id);
                          break;
                        case QuickActionType.witnessStatement:
                          _showWitnessesBottomSheet(context, ref, currentIncident.id);
                          break;
                        case QuickActionType.suspectStatement:
                          _showSuspectsBottomSheet(context, ref, currentIncident.id);
                          break;
                      }
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            loc.text('no_active_incident_action_error'),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RecentIncidentsSection(
                  recentIncidents: recentIncidents,
                  onIncidentTap: (incident) =>
                      context.go('/timeline/${incident.id}'),
                  onStartNewIncident: () => context.go('/new-incident'),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
