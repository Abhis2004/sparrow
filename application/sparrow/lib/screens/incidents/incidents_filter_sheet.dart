import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/colors.dart';
import '../../core/localization/app_localizations.dart';
import '../home/model/home_model.dart';
import 'incidents_model.dart';
import 'incidents_provider.dart';

class IncidentsFilterSheet extends ConsumerStatefulWidget {
  const IncidentsFilterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const IncidentsFilterSheet(),
    );
  }

  @override
  ConsumerState<IncidentsFilterSheet> createState() =>
      _IncidentsFilterSheetState();
}

class _IncidentsFilterSheetState extends ConsumerState<IncidentsFilterSheet> {
  late IncidentFilterState _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = ref.read(incidentsFilterProvider);
  }

  void _reset() {
    setState(() {
      _tempFilter = _tempFilter.copyWith(
        selectedStatus: () => null,
        selectedCategory: () => null,
        selectedLocation: () => null,
        sortOption: IncidentSortOption.recentToOldest,
        hasSuspectsOnly: false,
        hasWitnessesOnly: false,
        hasVictimsOnly: false,
      );
    });
  }

  void _apply() {
    ref.read(incidentsFilterProvider.notifier).updateState(_tempFilter);
    Navigator.of(context).pop();
  }

  String _getSortOptionLabel(IncidentSortOption sortOpt, AppLocalizations loc) {
    switch (sortOpt) {
      case IncidentSortOption.recentToOldest:
        return loc.text('recent_to_oldest');
      case IncidentSortOption.oldestToRecent:
        return loc.text('oldest_to_recent');
      case IncidentSortOption.nameAZ:
        return loc.text('name_az');
      case IncidentSortOption.mostObservations:
        return loc.text('most_observations');
    }
  }

  String _getStatusLabel(IncidentStatus status, AppLocalizations loc) {
    switch (status) {
      case IncidentStatus.active:
        return loc.text('active');
      case IncidentStatus.completed:
        return loc.text('completed_status');
      case IncidentStatus.draft:
        return loc.text('draft');
    }
  }

  String _getCategoryLabel(String catStr) {
    if (catStr.isEmpty) return 'General';
    return catStr[0].toUpperCase() + catStr.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context);
    final locations = ref.watch(availableLocationsProvider);
    final availableCategories = ref.watch(availableCategoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Sheet Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      loc.text('filter_and_sort'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _reset,
                      child: Text(
                        loc.text('reset_filters'),
                        style: const TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),

              // Filter Form Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ---------- SECTION: SORT BY ----------
                    _SectionTitle(
                      title: loc.text('sort_by'),
                      subtitle: loc.text('sort_by_subtitle'),
                      icon: Icons.sort_rounded,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: IncidentSortOption.values.map((sortOpt) {
                        final isSelected = _tempFilter.sortOption == sortOpt;
                        return ChoiceChip(
                          label: Text(_getSortOptionLabel(sortOpt, loc)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  sortOption: sortOpt,
                                );
                              });
                            }
                          },
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ---------- SECTION: INCIDENT STATUS ----------
                    _SectionTitle(
                      title: loc.text('incident_status'),
                      icon: Icons.bubble_chart_rounded,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(loc.text('all_statuses')),
                          selected: _tempFilter.selectedStatus == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  selectedStatus: () => null,
                                );
                              });
                            }
                          },
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _tempFilter.selectedStatus == null
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ...IncidentStatus.values.map((status) {
                          final isSelected =
                              _tempFilter.selectedStatus == status;
                          return ChoiceChip(
                            label: Text(_getStatusLabel(status, loc)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  selectedStatus: () =>
                                      selected ? status : null,
                                );
                              });
                            },
                            selectedColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ---------- SECTION: INCIDENT CATEGORY ----------
                    _SectionTitle(
                      title: loc.text('category'),
                      icon: Icons.category_rounded,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(loc.text('all_categories')),
                          selected: _tempFilter.selectedCategory == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  selectedCategory: () => null,
                                );
                              });
                            }
                          },
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _tempFilter.selectedCategory == null
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ...availableCategories.map((catStr) {
                          final isSelected = _tempFilter.selectedCategory?.toLowerCase() ==
                              catStr.toLowerCase();
                          return ChoiceChip(
                            label: Text(_getCategoryLabel(catStr)),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  selectedCategory: () =>
                                      selected ? catStr : null,
                                );
                              });
                            },
                            selectedColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ---------- SECTION: LOCATION / SECTOR ----------
                    _SectionTitle(
                      title: loc.text('location_sector'),
                      icon: Icons.location_on_rounded,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(loc.text('all_locations')),
                          selected: _tempFilter.selectedLocation == null,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  selectedLocation: () => null,
                                );
                              });
                            }
                          },
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: _tempFilter.selectedLocation == null
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        ...locations.map((loc) {
                          final isSelected =
                              _tempFilter.selectedLocation == loc;
                          return ChoiceChip(
                            label: Text(loc),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _tempFilter = _tempFilter.copyWith(
                                  selectedLocation: () =>
                                      selected ? loc : null,
                                );
                              });
                            },
                            selectedColor: colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ---------- SECTION: REQUIREMENTS / FLAGS ----------
                    _SectionTitle(
                      title: loc.text('entity_requirements'),
                      icon: Icons.fact_check_rounded,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.text('has_suspects_only')),
                      subtitle: Text(loc.text('has_suspects_subtitle')),
                      value: _tempFilter.hasSuspectsOnly,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(hasSuspectsOnly: val);
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.text('has_witnesses_only')),
                      subtitle: Text(loc.text('has_witnesses_subtitle')),
                      value: _tempFilter.hasWitnessesOnly,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(hasWitnessesOnly: val);
                        });
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(loc.text('has_victims_only')),
                      subtitle: Text(loc.text('has_victims_subtitle')),
                      value: _tempFilter.hasVictimsOnly,
                      activeThumbColor: colorScheme.primary,
                      onChanged: (val) {
                        setState(() {
                          _tempFilter = _tempFilter.copyWith(hasVictimsOnly: val);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Bottom Sticky Footer Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            loc.text('apply_filters'),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
