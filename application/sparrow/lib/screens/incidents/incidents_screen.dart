import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../home/model/home_model.dart';
import 'incidents_filter_sheet.dart';
import 'incidents_model.dart';
import 'incidents_provider.dart';
import 'incidents_widgets.dart';

class IncidentsScreen extends ConsumerStatefulWidget {
  const IncidentsScreen({super.key});

  @override
  ConsumerState<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends ConsumerState<IncidentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currentSearch = ref.read(incidentsFilterProvider).searchQuery;
    _searchController.text = currentSearch;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);

    final allIncidentsAsync = ref.watch(allIncidentsProvider);
    final filteredIncidents = ref.watch(filteredIncidentsProvider);
    final filterState = ref.watch(incidentsFilterProvider);
    final metrics = ref.watch(incidentMetricsProvider);
    final filterNotifier = ref.read(incidentsFilterProvider.notifier);

    final activeFilterCount = filterState.activeFilterCount;
    final isFiltered = !filterState.isDefault || filterState.searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        scrolledUnderElevation: 2,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.text('case_records'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${filteredIncidents.length} ${filteredIncidents.length == 1 ? 'incident' : 'incidents'} • ${filterState.sortOption.shortLabel}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          // Filter button with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  activeFilterCount > 0
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_outlined,
                  color: activeFilterCount > 0
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
                tooltip: loc.text('filter'),
                onPressed: () => IncidentsFilterSheet.show(context),
              ),
              if (activeFilterCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- SEARCH BAR & QUICK FILTERS ----------
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  // Search Input Box
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBackground
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.transparent,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => filterNotifier.setSearchQuery(value),
                      decoration: InputDecoration(
                        hintText: loc.text('search_cases_hint'),
                        hintStyle: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  filterNotifier.setSearchQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats Metric Bar (Total, Active, Completed, Draft)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        MetricChip(
                          label: loc.text('all_cases'),
                          count: metrics['total'] ?? 0,
                          color: AppColors.primary,
                          isSelected: filterState.selectedStatus == null,
                          onTap: () => filterNotifier.setStatus(null),
                        ),
                        const SizedBox(width: 8),
                        MetricChip(
                          label: loc.text('active'),
                          count: metrics['active'] ?? 0,
                          color: AppColors.success,
                          isSelected: filterState.selectedStatus == IncidentStatus.active,
                          onTap: () => filterNotifier.setStatus(
                            filterState.selectedStatus == IncidentStatus.active
                                ? null
                                : IncidentStatus.active,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MetricChip(
                          label: loc.text('completed'),
                          count: metrics['completed'] ?? 0,
                          color: AppColors.primary,
                          isSelected: filterState.selectedStatus == IncidentStatus.completed,
                          onTap: () => filterNotifier.setStatus(
                            filterState.selectedStatus == IncidentStatus.completed
                                ? null
                                : IncidentStatus.completed,
                          ),
                        ),
                        const SizedBox(width: 8),
                        MetricChip(
                          label: loc.text('draft'),
                          count: metrics['draft'] ?? 0,
                          color: AppColors.warning,
                          isSelected: filterState.selectedStatus == IncidentStatus.draft,
                          onTap: () => filterNotifier.setStatus(
                            filterState.selectedStatus == IncidentStatus.draft
                                ? null
                                : IncidentStatus.draft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ---------- INCIDENTS LIST / EMPTY STATE ----------
            Expanded(
              child: allIncidentsAsync.when(
                data: (_) {
                  if (filteredIncidents.isEmpty) {
                    return IncidentsEmptyState(
                      isFiltered: isFiltered,
                      onResetFilters: () {
                        _searchController.clear();
                        filterNotifier.resetFilters();
                      },
                      onStartNewIncident: () => context.go('/new-incident'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(allIncidentsProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredIncidents.length,
                      itemBuilder: (context, index) {
                        final incident = filteredIncidents[index];
                        return IncidentCard(
                          incident: incident,
                          onTap: () => context.go('/timeline/${incident.id}'),
                        );

                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.warning,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Failed to load incidents',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$error',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => ref.invalidate(allIncidentsProvider),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
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