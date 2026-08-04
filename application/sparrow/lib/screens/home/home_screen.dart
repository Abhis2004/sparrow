import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import 'home_service.dart';
import 'home_widgets.dart';
import 'model/home_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    final loc = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - ${loc.text('coming_soon')}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

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
                    if (homeData.incidents.isEmpty) {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Please start a new incident first to record ${action.title.replaceAll('\n', ' ')}.',
                          ),
                          action: SnackBarAction(
                            label: 'New Incident',
                            onPressed: () => context.go('/new-incident'),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } else {
                      _showComingSoon(
                          context, action.title.replaceAll('\n', ' '));
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
