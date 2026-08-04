import 'package:flutter/material.dart';

import '../../app/colors.dart';
import '../../core/localization/app_localizations.dart';
import 'model/home_model.dart';

/// Top header widget displaying officer info, language toggle, and theme toggle icons
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.officerName,
    required this.designation,
    required this.station,
    this.profileImage,
    this.onLanguageToggleTap,
    this.onThemeToggleTap,
  });

  final String officerName;
  final String designation;
  final String station;
  final String? profileImage;
  final VoidCallback? onLanguageToggleTap;
  final VoidCallback? onThemeToggleTap;

  String _getGreetingKey() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) {
      return 'good_morning';
    } else if (hour >= 12 && hour < 17) {
      return 'good_afternoon';
    } else {
      return 'good_evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.surface,
                  child: Text(
                    officerName.trim().isNotEmpty
                        ? officerName.trim()[0].toUpperCase()
                        : 'O',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.text(_getGreetingKey()),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    officerName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$designation • $station',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.g_translate_rounded,
                  onTap: onLanguageToggleTap,
                ),
                const SizedBox(width: 8),
                _HeaderIconButton(
                  icon: isDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  onTap: onThemeToggleTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            color: colorScheme.onPrimary,
            size: 28,
          ),
        ),
      ),
    );
  }
}

/// Primary Card showing active investigation details
class CurrentIncidentCard extends StatelessWidget {
  const CurrentIncidentCard({
    super.key,
    required this.incidentName,
    required this.location,
    required this.startedAt,
    required this.startedDate,
    required this.status,
    this.onTimelineTap,
  });

  final String incidentName;
  final String location;
  final String startedAt;
  final String startedDate;
  final String status;
  final VoidCallback? onTimelineTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: theme.shadowColor.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.text('current_incident'),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        incidentName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      loc.text('started_at'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startedAt,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      startedDate,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StatusChip(
              label: status,
              statusType: IncidentStatus.active,
            ),
            const SizedBox(height: 12),
            Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTimelineTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      loc.text('view_timeline'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hero Card displayed when an officer has no active investigation
class NoActiveIncidentCard extends StatelessWidget {
  const NoActiveIncidentCard({
    super.key,
    required this.onStartNewIncident,
  });

  final VoidCallback onStartNewIncident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shadowColor: theme.shadowColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    loc.text('no_active_investigation'),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.shield_outlined,
                  size: 24,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              loc.text('ready_for_duty'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              loc.text('no_active_cases_desc'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onStartNewIncident,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: Text(loc.text('start_new_incident')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section containing quick voice and observation action cards
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    super.key,
    required this.quickActions,
    required this.onActionTap,
  });

  final List<QuickAction> quickActions;
  final ValueChanged<QuickAction> onActionTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: loc.text('quick_actions')),
        const SizedBox(height: 12),
        Row(
          children: quickActions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: QuickActionCard(
                  action: action,
                  onTap: () => onActionTap(action),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.action,
    this.onTap,
  });

  final QuickAction action;
  final VoidCallback? onTap;

  String _getLocalizedTitle(BuildContext context, QuickActionType type) {
    final loc = AppLocalizations.of(context);
    switch (type) {
      case QuickActionType.observation:
        return loc.text('officer_observation');
      case QuickActionType.victimStatement:
        return loc.text('victim_statement');
      case QuickActionType.witnessStatement:
        return loc.text('witness_statement');
      case QuickActionType.suspectStatement:
        return loc.text('suspect_statement');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final colorStyle = _getQuickActionColors(action.actionType, isDark);
    final localizedTitle = _getLocalizedTitle(context, action.actionType);

    return Material(
      color: colorStyle.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 28,
                color: colorStyle.iconColor,
              ),
              const SizedBox(height: 10),
              Text(
                localizedTitle,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? colorScheme.onSurface : colorStyle.textColor,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _QuickActionStyle _getQuickActionColors(QuickActionType type, bool isDark) {
    if (isDark) {
      switch (type) {
        case QuickActionType.observation:
          return const _QuickActionStyle(
            background: AppColors.primarySubtleDark,
            iconColor: AppColors.secondary,
            textColor: AppColors.lightSurface,
          );
        case QuickActionType.victimStatement:
          return const _QuickActionStyle(
            background: AppColors.successSubtleDark,
            iconColor: AppColors.success,
            textColor: AppColors.lightSurface,
          );
        case QuickActionType.witnessStatement:
          return const _QuickActionStyle(
            background: AppColors.warningSubtleDark,
            iconColor: AppColors.warning,
            textColor: AppColors.lightSurface,
          );
        case QuickActionType.suspectStatement:
          return const _QuickActionStyle(
            background: AppColors.purpleSubtleDark,
            iconColor: AppColors.purple,
            textColor: AppColors.lightSurface,
          );
      }
    }

    switch (type) {
      case QuickActionType.observation:
        return const _QuickActionStyle(
          background: AppColors.primarySubtle,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
        );
      case QuickActionType.victimStatement:
        return const _QuickActionStyle(
          background: AppColors.successSubtle,
          iconColor: AppColors.success,
          textColor: AppColors.success,
        );
      case QuickActionType.witnessStatement:
        return const _QuickActionStyle(
          background: AppColors.warningSubtle,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
        );
      case QuickActionType.suspectStatement:
        return const _QuickActionStyle(
          background: AppColors.purpleSubtle,
          iconColor: AppColors.purple,
          textColor: AppColors.purple,
        );
    }
  }
}

class _QuickActionStyle {
  const _QuickActionStyle({
    required this.background,
    required this.iconColor,
    required this.textColor,
  });

  final Color background;
  final Color iconColor;
  final Color textColor;
}

/// Section listing recent incidents
class RecentIncidentsSection extends StatelessWidget {
  const RecentIncidentsSection({
    super.key,
    required this.recentIncidents,
    required this.onIncidentTap,
    this.onStartNewIncident,
  });

  final List<Incident> recentIncidents;
  final ValueChanged<Incident> onIncidentTap;
  final VoidCallback? onStartNewIncident;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: loc.text('recent_incidents'),
        ),
        const SizedBox(height: 12),
        if (recentIncidents.isEmpty)
          Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            shadowColor: theme.shadowColor.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.assignment_outlined,
                      size: 28,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.text('no_cases_logged'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    loc.text('no_cases_logged_desc'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (onStartNewIncident != null) ...[
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: onStartNewIncident,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(loc.text('create_first_incident')),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
        else
          Card(
            margin: EdgeInsets.zero,
            elevation: 1,
            shadowColor: theme.shadowColor.withValues(alpha: 0.08),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: recentIncidents.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.dividerColor.withValues(alpha: 0.4),
              ),
              itemBuilder: (context, index) {
                final incident = recentIncidents[index];
                return RecentIncidentTile(
                  incident: incident,
                  onTap: () => onIncidentTap(incident),
                );
              },
            ),
          ),
      ],
    );
  }
}

class RecentIncidentTile extends StatelessWidget {
  const RecentIncidentTile({
    super.key,
    required this.incident,
    this.onTap,
  });

  final Incident incident;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        incident.incidentName,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  incident.location,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  incident.timestampInfo,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StatusChip(
            label: incident.status.shortLabel,
            statusType: incident.status,
          ),
          const SizedBox(width: 6),
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

/// Reusable status pill chip with status-derived colors
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    required this.statusType,
  });

  final String label;
  final IncidentStatus statusType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    final style = _getStatusChipStyle(statusType, isDark, colorScheme);
    final localizedLabel = _getLocalizedStatusLabel(loc, statusType);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        localizedLabel,
        style: theme.textTheme.labelSmall?.copyWith(
          color: style.textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getLocalizedStatusLabel(AppLocalizations loc, IncidentStatus status) {
    switch (status) {
      case IncidentStatus.active:
        return loc.text('active');
      case IncidentStatus.completed:
        return loc.text('completed');
      case IncidentStatus.draft:
        return loc.text('draft');
    }
  }

  _StatusChipStyle _getStatusChipStyle(
    IncidentStatus status,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    if (isDark) {
      switch (status) {
        case IncidentStatus.active:
          return const _StatusChipStyle(
            background: AppColors.primarySubtleDark,
            textColor: AppColors.secondary,
          );
        case IncidentStatus.completed:
          return const _StatusChipStyle(
            background: AppColors.successSubtleDark,
            textColor: AppColors.success,
          );
        case IncidentStatus.draft:
          return const _StatusChipStyle(
            background: AppColors.neutralSubtleDark,
            textColor: AppColors.lightSurface,
          );
      }
    }

    switch (status) {
      case IncidentStatus.active:
        return const _StatusChipStyle(
          background: AppColors.primarySubtle,
          textColor: AppColors.primary,
        );
      case IncidentStatus.completed:
        return const _StatusChipStyle(
          background: AppColors.successSubtle,
          textColor: AppColors.success,
        );
      case IncidentStatus.draft:
        return const _StatusChipStyle(
          background: AppColors.neutralSubtle,
          textColor: AppColors.darkSurface,
        );
    }
  }
}

class _StatusChipStyle {
  const _StatusChipStyle({
    required this.background,
    required this.textColor,
  });

  final Color background;
  final Color textColor;
}

/// Reusable section title with optional action link
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        if (actionLabel != null)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onActionTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  Text(
                    actionLabel!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}