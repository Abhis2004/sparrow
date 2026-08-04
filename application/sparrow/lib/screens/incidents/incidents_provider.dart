import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/isar_service.dart';
import '../home/home_service.dart';
import '../home/model/home_model.dart';
import 'incidents_model.dart';

class AllIncidentsNotifier extends AsyncNotifier<List<Incident>> {
  bool _isSimulatedEmpty = false;
  List<Incident>? _cachedOriginal;

  @override
  Future<List<Incident>> build() async {
    final service = ref.watch(homeServiceProvider);
    final incidents = await service.fetchIncidents();
    _cachedOriginal ??= List.from(incidents);
    if (_isSimulatedEmpty) return [];
    return incidents;
  }

  Future<void> addIncident(Incident incident) async {
    await ref.read(isarServiceProvider).saveIncident(incident);
    final current = state.value ?? [];
    final updated = [incident, ...current];
    _cachedOriginal = [incident, ...?_cachedOriginal];
    _isSimulatedEmpty = false;
    state = AsyncValue.data(updated);
  }

  Future<void> updateIncident(Incident updatedIncident) async {
    await ref.read(isarServiceProvider).saveIncident(updatedIncident);
    final current = state.value ?? [];
    final updated =
        current.map((e) => e.id == updatedIncident.id ? updatedIncident : e).toList();
    _cachedOriginal =
        _cachedOriginal?.map((e) => e.id == updatedIncident.id ? updatedIncident : e).toList();
    state = AsyncValue.data(updated);
  }

  Future<void> deleteIncident(String incidentId) async {
    await ref.read(isarServiceProvider).deleteIncident(incidentId);
    final current = state.value ?? [];
    final updated = current.where((e) => e.id != incidentId).toList();
    _cachedOriginal = _cachedOriginal?.where((e) => e.id != incidentId).toList();
    state = AsyncValue.data(updated);
  }

  void toggleSimulatedEmptyState(bool isEmpty) {
    _isSimulatedEmpty = isEmpty;
    if (isEmpty) {
      state = const AsyncValue.data([]);
    } else {
      state = AsyncValue.data(_cachedOriginal ?? []);
    }
  }

  bool get isSimulatedEmpty => _isSimulatedEmpty;
}


/// Provider for list of all incidents with dynamic mutation support
final allIncidentsProvider =
    AsyncNotifierProvider<AllIncidentsNotifier, List<Incident>>(
        AllIncidentsNotifier.new);

/// Unique available locations extracted from the incidents database
final availableLocationsProvider = Provider<List<String>>((ref) {
  final incidentsAsync = ref.watch(allIncidentsProvider);
  final incidents = incidentsAsync.value ?? [];
  final locations = incidents.map((e) => e.location).toSet().toList();
  locations.sort();
  return locations;
});

/// Unique available categories extracted dynamically from the incidents database
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final incidentsAsync = ref.watch(allIncidentsProvider);
  final incidents = incidentsAsync.value ?? [];
  final categories = incidents
      .map((e) => e.rawCategory.isNotEmpty ? e.rawCategory : e.category.name)
      .toSet()
      .toList();
  categories.sort();
  return categories;
});




/// Notifier to manage filter and sorting parameters
class IncidentFilterNotifier extends Notifier<IncidentFilterState> {
  @override
  IncidentFilterState build() {
    return IncidentFilterState.initial;
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setStatus(IncidentStatus? status) {
    state = state.copyWith(
      selectedStatus: () => status,
    );
  }

  void setCategory(String? category) {
    state = state.copyWith(
      selectedCategory: () => category,
    );
  }

  void setLocation(String? location) {
    state = state.copyWith(
      selectedLocation: () => location,
    );
  }

  void setSortOption(IncidentSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void toggleHasSuspectsOnly(bool value) {
    state = state.copyWith(hasSuspectsOnly: value);
  }

  void toggleHasWitnessesOnly(bool value) {
    state = state.copyWith(hasWitnessesOnly: value);
  }

  void toggleHasVictimsOnly(bool value) {
    state = state.copyWith(hasVictimsOnly: value);
  }

  void updateState(IncidentFilterState newState) {
    state = newState;
  }

  void resetFilters() {
    state = IncidentFilterState.initial.copyWith(
      searchQuery: state.searchQuery, // Preserve search query on filter reset
    );
  }

  void clearAll() {
    state = IncidentFilterState.initial;
  }
}

final incidentsFilterProvider =
    NotifierProvider<IncidentFilterNotifier, IncidentFilterState>(
        IncidentFilterNotifier.new);

/// Computed provider returning incidents filtered and sorted (Default: Recent to Oldest)
final filteredIncidentsProvider = Provider<List<Incident>>((ref) {
  final incidentsAsync = ref.watch(allIncidentsProvider);
  final incidents = incidentsAsync.value ?? [];
  final filter = ref.watch(incidentsFilterProvider);




  List<Incident> result = incidents.where((inc) {
    // Search query filter
    if (filter.searchQuery.isNotEmpty) {
      final q = filter.searchQuery.toLowerCase();
      final matchName = inc.incidentName.toLowerCase().contains(q);
      final matchLocation = inc.location.toLowerCase().contains(q);
      final matchId = inc.id.toLowerCase().contains(q);
      final matchCategory = inc.category.name.toLowerCase().contains(q) ||
          inc.rawCategory.toLowerCase().contains(q);
      if (!matchName && !matchLocation && !matchId && !matchCategory) {
        return false;
      }
    }

    // Status filter
    if (filter.selectedStatus != null && inc.status != filter.selectedStatus) {
      return false;
    }

    // Category filter (matches rawCategory or category enum name)
    if (filter.selectedCategory != null) {
      final sel = filter.selectedCategory!.toLowerCase();
      final incCat = inc.rawCategory.isNotEmpty ? inc.rawCategory : inc.category.name;
      if (incCat.toLowerCase() != sel) {
        return false;
      }
    }

    // Location filter
    if (filter.selectedLocation != null &&
        inc.location != filter.selectedLocation) {
      return false;
    }

    // Flag filters
    if (filter.hasSuspectsOnly && inc.suspectCount <= 0) {
      return false;
    }
    if (filter.hasWitnessesOnly && inc.witnessCount <= 0) {
      return false;
    }
    if (filter.hasVictimsOnly && inc.victimCount <= 0) {
      return false;
    }

    return true;
  }).toList();

  // Sort logic (Default: Recent to Oldest)
  result.sort((a, b) {
    switch (filter.sortOption) {
      case IncidentSortOption.recentToOldest:
        final dtA = parseIncidentDateTime(a.startedDate, a.startedAt);
        final dtB = parseIncidentDateTime(b.startedDate, b.startedAt);
        return dtB.compareTo(dtA); // Descending order (recent first)

      case IncidentSortOption.oldestToRecent:
        final dtA = parseIncidentDateTime(a.startedDate, a.startedAt);
        final dtB = parseIncidentDateTime(b.startedDate, b.startedAt);
        return dtA.compareTo(dtB); // Ascending order (oldest first)

      case IncidentSortOption.nameAZ:
        return a.incidentName.toLowerCase().compareTo(b.incidentName.toLowerCase());

      case IncidentSortOption.mostObservations:
        return b.observationCount.compareTo(a.observationCount);
    }
  });

  return result;
});

/// Metrics summary provider for stats display
final incidentMetricsProvider = Provider<Map<String, int>>((ref) {
  final incidentsAsync = ref.watch(allIncidentsProvider);
  final incidents = incidentsAsync.value ?? [];
  int active = 0;



  int completed = 0;
  int draft = 0;

  for (final inc in incidents) {
    switch (inc.status) {
      case IncidentStatus.active:
        active++;
        break;
      case IncidentStatus.completed:
        completed++;
        break;
      case IncidentStatus.draft:
        draft++;
        break;
    }
  }

  return {
    'total': incidents.length,
    'active': active,
    'completed': completed,
    'draft': draft,
  };
});
