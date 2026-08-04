import 'package:flutter/material.dart';

enum IncidentStatus {
  active,
  completed,
  draft,
}

extension IncidentStatusX on IncidentStatus {
  String get label {
    switch (this) {
      case IncidentStatus.active:
        return 'INVESTIGATION ACTIVE';
      case IncidentStatus.completed:
        return 'COMPLETED';
      case IncidentStatus.draft:
        return 'DRAFT';
    }
  }

  String get shortLabel {
    switch (this) {
      case IncidentStatus.active:
        return 'ACTIVE';
      case IncidentStatus.completed:
        return 'COMPLETED';
      case IncidentStatus.draft:
        return 'DRAFT';
    }
  }

  static IncidentStatus fromString(String statusStr) {
    switch (statusStr.toLowerCase()) {
      case 'active':
        return IncidentStatus.active;
      case 'completed':
        return IncidentStatus.completed;
      case 'draft':
      default:
        return IncidentStatus.draft;
    }
  }
}

class OfficerProfile {
  const OfficerProfile({
    required this.name,
    required this.designation,
    required this.station,
    this.district = 'Gautam Budh Nagar',
    this.state = 'Uttar Pradesh',
    this.profileImage,
    this.unreadNotificationsCount = 0,
  });

  final String name;
  final String designation;
  final String station;
  final String district;
  final String state;
  final String? profileImage;
  final int unreadNotificationsCount;

  bool get isComplete =>
      name.trim().isNotEmpty &&
      designation.trim().isNotEmpty &&
      station.trim().isNotEmpty &&
      district.trim().isNotEmpty &&
      state.trim().isNotEmpty;

  String get initialLetter =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'O';

  factory OfficerProfile.fromJson(Map<String, dynamic> json) {
    return OfficerProfile(
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      station: json['station'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      profileImage: json['profile_image'] as String?,
      unreadNotificationsCount: json['unread_notifications_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'designation': designation,
      'station': station,
      'district': district,
      'state': state,
      'profile_image': profileImage,
      'unread_notifications_count': unreadNotificationsCount,
    };
  }
}

enum IncidentCategory {
  theft,
  vehicle,
  assault,
  general,
}

/// Incident data model corresponding to documents in 'incidents' collection
class Incident {
  const Incident({
    required this.id,
    required this.incidentName,
    required this.location,
    required this.startedAt,
    required this.startedDate,
    this.completedAt,
    this.completedDate,
    required this.status,
    required this.category,
    this.rawStatus = '',
    this.rawCategory = '',
    this.observationCount = 0,
    this.victimCount = 0,
    this.witnessCount = 0,
    this.suspectCount = 0,
  });

  final String id;
  final String incidentName;
  final String location;
  final String startedAt;
  final String startedDate;
  final String? completedAt;
  final String? completedDate;
  final IncidentStatus status;
  final IncidentCategory category;
  final String rawStatus;
  final String rawCategory;
  final int observationCount;
  final int victimCount;
  final int witnessCount;
  final int suspectCount;

  bool get isActive => status == IncidentStatus.active;

  /// Computed timestamp for tile subtitle display
  String get timestampInfo {
    if (isActive) {
      return 'Started $startedAt';
    }
    return '$startedDate • $startedAt';
  }

  IconData get icon {
    switch (category) {
      case IncidentCategory.theft:
        return Icons.home_rounded;
      case IncidentCategory.vehicle:
        return Icons.two_wheeler_rounded;
      case IncidentCategory.assault:
        return Icons.warning_amber_rounded;
      case IncidentCategory.general:
        return Icons.assignment_outlined;
    }
  }

  factory Incident.fromJson(Map<String, dynamic> json) {
    final rawStatusStr = json['status'] as String? ?? 'draft';
    final rawCatStr = json['category'] as String? ?? 'general';
    IncidentCategory cat;
    switch (rawCatStr.toLowerCase()) {
      case 'theft':
        cat = IncidentCategory.theft;
        break;
      case 'vehicle':
        cat = IncidentCategory.vehicle;
        break;
      case 'assault':
        cat = IncidentCategory.assault;
        break;
      case 'general':
      default:
        cat = IncidentCategory.general;
        break;
    }

    return Incident(
      id: json['id'] as String? ?? '',
      incidentName: json['incident_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startedAt: json['started_at'] as String? ?? '',
      startedDate: json['started_date'] as String? ?? '',
      completedAt: json['completed_at'] as String?,
      completedDate: json['completed_date'] as String?,
      status: IncidentStatusX.fromString(rawStatusStr),
      category: cat,
      rawStatus: rawStatusStr,
      rawCategory: rawCatStr,
      observationCount: json['observation_count'] as int? ?? 0,
      victimCount: json['victim_count'] as int? ?? 0,
      witnessCount: json['witness_count'] as int? ?? 0,
      suspectCount: json['suspect_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incident_name': incidentName,
      'location': location,
      'started_at': startedAt,
      'started_date': startedDate,
      'completed_at': completedAt ?? '',
      'completed_date': completedDate ?? '',
      'status': status.name,
      'category': rawCategory.isNotEmpty ? rawCategory : category.name,
      'observation_count': observationCount,
      'victim_count': victimCount,
      'witness_count': witnessCount,
      'suspect_count': suspectCount,
    };
  }
}

enum QuickActionType {
  observation,
  victimStatement,
  witnessStatement,
  suspectStatement,
}

class QuickAction {
  const QuickAction({
    required this.id,
    required this.title,
    required this.actionType,
  });

  final String id;
  final String title;
  final QuickActionType actionType;

  IconData get icon {
    switch (actionType) {
      case QuickActionType.observation:
        return Icons.mic_rounded;
      case QuickActionType.victimStatement:
        return Icons.person_rounded;
      case QuickActionType.witnessStatement:
        return Icons.groups_rounded;
      case QuickActionType.suspectStatement:
        return Icons.face_retouching_natural_rounded;
    }
  }

  static List<QuickAction> get defaultActions => const [
        QuickAction(
          id: 'action_obs',
          title: 'Officer\nObservation',
          actionType: QuickActionType.observation,
        ),
        QuickAction(
          id: 'action_victim',
          title: 'Victim\nStatement',
          actionType: QuickActionType.victimStatement,
        ),
        QuickAction(
          id: 'action_witness',
          title: 'Witness\nStatement',
          actionType: QuickActionType.witnessStatement,
        ),
        QuickAction(
          id: 'action_suspect',
          title: 'Suspect\nStatement',
          actionType: QuickActionType.suspectStatement,
        ),
      ];
}

class HomeData {
  const HomeData({
    required this.officer,
    required this.incidents,
    this.quickActions = const [],
  });

  final OfficerProfile officer;
  final List<Incident> incidents;
  final List<QuickAction> quickActions;

  /// Returns the currently active investigation dynamically from incidents list
  Incident? get currentActiveIncident {
    for (final incident in incidents) {
      if (incident.isActive) {
        return incident;
      }
    }
    return null;
  }

  /// Returns 3 most recent incidents for the Recent Incidents widget
  List<Incident> get topThreeRecentIncidents {
    return incidents.take(3).toList();
  }
}
