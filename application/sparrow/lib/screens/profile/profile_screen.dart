import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/colors.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/locale_provider.dart';
import '../../widgets/officer_profile_dialog.dart';
import '../home/home_service.dart';
import '../incidents/incidents_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final currentLanguage = ref.watch(languageProvider);

    final homeDataAsync = ref.watch(homeDataProvider);
    final allIncidentsNotifier = ref.read(allIncidentsProvider.notifier);
    final isSimulatedEmpty = allIncidentsNotifier.isSimulatedEmpty;
    final metrics = ref.watch(incidentMetricsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(loc.text('profile')),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
      ),
      body: homeDataAsync.when(
        data: (homeData) {
          final officer = homeData.officer;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Text(
                        officer.initialLetter,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      officer.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${officer.designation} • Badge #8492',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${officer.station}, ${officer.district}, ${officer.state}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () {
                        OfficerProfileSetupDialog.show(context, isMandatory: false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Edit Officer Details'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Language Selector Tile
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.zero,
                elevation: 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.g_translate_rounded, color: colorScheme.primary),
                  ),
                  title: const Text(
                    'App Language / भाषा',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    currentLanguage == AppLanguage.english ? 'English' : 'हिंदी (Hindi)',
                    style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600),
                  ),
                  trailing: SegmentedButton<AppLanguage>(
                    segments: const [
                      ButtonSegment(value: AppLanguage.english, label: Text('EN')),
                      ButtonSegment(value: AppLanguage.hindi, label: Text('हिंदी')),
                    ],
                    selected: {currentLanguage},
                    onSelectionChanged: (selected) {
                      ref.read(languageProvider.notifier).setLanguage(selected.first);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Cases Summary Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                margin: EdgeInsets.zero,
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.text('recent_incidents'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _StatTile(
                            label: loc.text('all_cases'),
                            count: metrics['total'] ?? 0,
                            color: colorScheme.primary,
                          ),
                          _StatTile(
                            label: loc.text('active'),
                            count: metrics['active'] ?? 0,
                            color: AppColors.success,
                          ),
                          _StatTile(
                            label: loc.text('completed'),
                            count: metrics['completed'] ?? 0,
                            color: colorScheme.primary,
                          ),
                          _StatTile(
                            label: loc.text('draft'),
                            count: metrics['draft'] ?? 0,
                            color: AppColors.warning,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Edge Case Testing Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.science_outlined, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'First-Time Signup Simulation',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toggle ON to simulate a newly registered officer who has 0 cases. Test how Home, Incidents Log, and Timeline empty states behave.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Simulate New Officer (0 Cases)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        isSimulatedEmpty
                            ? 'Currently showing ZERO cases state'
                            : 'Currently showing demo dataset',
                        style: TextStyle(
                          color: isSimulatedEmpty ? AppColors.warning : AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      value: isSimulatedEmpty,
                      onChanged: (value) {
                        allIncidentsNotifier.toggleSimulatedEmptyState(value);
                      },
                    ),
                    const Divider(height: 24),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Clear Local Officer Profile',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Removes saved profile from SharedPreferences to re-trigger mandatory setup popup.',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: OutlinedButton(
                        onPressed: () {
                          ref.read(officerProfileProvider.notifier).clearProfile();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
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

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}