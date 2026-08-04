import '../home/model/home_model.dart';

enum IncidentSortOption {
  recentToOldest,
  oldestToRecent,
  nameAZ,
  mostObservations,
}

extension IncidentSortOptionX on IncidentSortOption {
  String get label {
    switch (this) {
      case IncidentSortOption.recentToOldest:
        return 'Recent to Oldest';
      case IncidentSortOption.oldestToRecent:
        return 'Oldest to Recent';
      case IncidentSortOption.nameAZ:
        return 'Name (A - Z)';
      case IncidentSortOption.mostObservations:
        return 'Most Observations';
    }
  }

  String get shortLabel {
    switch (this) {
      case IncidentSortOption.recentToOldest:
        return 'Recent';
      case IncidentSortOption.oldestToRecent:
        return 'Oldest';
      case IncidentSortOption.nameAZ:
        return 'A-Z';
      case IncidentSortOption.mostObservations:
        return 'Observations';
    }
  }
}

/// Helper function to parse incident date and time into a comparable DateTime object
DateTime parseIncidentDateTime(String startedDate, String startedAt) {
  try {
    final dateParts = startedDate.trim().split(' ');
    if (dateParts.length < 3) return DateTime.fromMillisecondsSinceEpoch(0);
    
    final day = int.tryParse(dateParts[0]) ?? 1;
    final monthStr = dateParts[1].toLowerCase();
    final year = int.tryParse(dateParts[2]) ?? 2026;

    const months = {
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
      'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
    };
    
    final prefix = monthStr.length >= 3 ? monthStr.substring(0, 3) : monthStr;
    final month = months[prefix] ?? 1;

    int hour = 0;
    int minute = 0;
    final timeParts = startedAt.trim().split(' ');
    if (timeParts.length >= 2) {
      final hm = timeParts[0].split(':');
      if (hm.length == 2) {
        hour = int.tryParse(hm[0]) ?? 0;
        minute = int.tryParse(hm[1]) ?? 0;
        final ampm = timeParts[1].toUpperCase();
        if (ampm == 'PM' && hour < 12) hour += 12;
        if (ampm == 'AM' && hour == 12) hour = 0;
      }
    }

    return DateTime(year, month, day, hour, minute);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class IncidentFilterState {
  const IncidentFilterState({
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedCategory,
    this.selectedLocation,
    this.sortOption = IncidentSortOption.recentToOldest,
    this.hasSuspectsOnly = false,
    this.hasWitnessesOnly = false,
    this.hasVictimsOnly = false,
  });

  final String searchQuery;
  final IncidentStatus? selectedStatus;
  final String? selectedCategory;
  final String? selectedLocation;
  final IncidentSortOption sortOption;
  final bool hasSuspectsOnly;
  final bool hasWitnessesOnly;
  final bool hasVictimsOnly;

  /// Counts active filters applied by the user (excluding search query and default sort)
  int get activeFilterCount {
    int count = 0;
    if (selectedStatus != null) count++;
    if (selectedCategory != null) count++;
    if (selectedLocation != null) count++;
    if (sortOption != IncidentSortOption.recentToOldest) count++;
    if (hasSuspectsOnly) count++;
    if (hasWitnessesOnly) count++;
    if (hasVictimsOnly) count++;
    return count;
  }

  bool get isDefault {
    return searchQuery.isEmpty &&
        selectedStatus == null &&
        selectedCategory == null &&
        selectedLocation == null &&
        sortOption == IncidentSortOption.recentToOldest &&
        !hasSuspectsOnly &&
        !hasWitnessesOnly &&
        !hasVictimsOnly;
  }

  IncidentFilterState copyWith({
    String? searchQuery,
    IncidentStatus? Function()? selectedStatus,
    String? Function()? selectedCategory,
    String? Function()? selectedLocation,
    IncidentSortOption? sortOption,
    bool? hasSuspectsOnly,
    bool? hasWitnessesOnly,
    bool? hasVictimsOnly,
  }) {
    return IncidentFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus:
          selectedStatus != null ? selectedStatus() : this.selectedStatus,
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      selectedLocation:
          selectedLocation != null ? selectedLocation() : this.selectedLocation,
      sortOption: sortOption ?? this.sortOption,
      hasSuspectsOnly: hasSuspectsOnly ?? this.hasSuspectsOnly,
      hasWitnessesOnly: hasWitnessesOnly ?? this.hasWitnessesOnly,
      hasVictimsOnly: hasVictimsOnly ?? this.hasVictimsOnly,
    );
  }

  static const IncidentFilterState initial = IncidentFilterState();
}
