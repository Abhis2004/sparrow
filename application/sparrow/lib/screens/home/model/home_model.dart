import 'package:flutter/material.dart';

import '../../../utils/time_formatter.dart';
import '../../incidents/incidents_model.dart';

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
    this.district = '',
    this.state = '',
    this.badgeNumber = '',
    this.phone = '',
    this.profileImage,
    this.unreadNotificationsCount = 0,
  });

  final String name;
  final String designation;
  final String station;
  final String district;
  final String state;
  /// Badge / service number — acts as the officer's primary identifier.
  final String badgeNumber;
  /// Contact phone number.
  final String phone;
  final String? profileImage;
  final int unreadNotificationsCount;

  bool get isComplete =>
      name.trim().isNotEmpty &&
      designation.trim().isNotEmpty &&
      station.trim().isNotEmpty &&
      district.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      badgeNumber.trim().isNotEmpty &&
      phone.trim().isNotEmpty;

  String get initialLetter =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'O';

  factory OfficerProfile.fromJson(Map<String, dynamic> json) {
    return OfficerProfile(
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      station: json['station'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      badgeNumber: json['badge_number'] as String? ?? json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
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
      'badge_number': badgeNumber,
      'phone': phone,
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
    this.lastInteracted,
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
  final String? lastInteracted;
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
    final formattedTime = formatTo12HourTime(startedAt);
    if (isActive) {
      return 'Started $formattedTime';
    }
    return '$startedDate • $formattedTime';
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
      lastInteracted: json['last_interacted'] as String?,
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
      'last_interacted': lastInteracted ?? '',
      'status': rawStatus.isNotEmpty ? rawStatus : status.name,
      'category': rawCategory.isNotEmpty ? rawCategory : category.name,
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
          title: 'Add Officer\nObservation',
          actionType: QuickActionType.observation,
        ),
        QuickAction(
          id: 'action_victim',
          title: 'Add Victim\nStatement',
          actionType: QuickActionType.victimStatement,
        ),
        QuickAction(
          id: 'action_witness',
          title: 'Add Witness\nStatement',
          actionType: QuickActionType.witnessStatement,
        ),
        QuickAction(
          id: 'action_suspect',
          title: 'Add Suspect\nStatement',
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

  /// Returns the active investigation with the most recent last interaction
  Incident? get currentActiveIncident {
    final activeIncidents = incidents.where((e) => e.isActive).toList();
    if (activeIncidents.isEmpty) return null;

    activeIncidents.sort((a, b) {
      final dtA = _getEffectiveInteractionTime(a);
      final dtB = _getEffectiveInteractionTime(b);
      return dtB.compareTo(dtA);
    });

    return activeIncidents.first;
  }

  static DateTime _getEffectiveInteractionTime(Incident incident) {
    if (incident.lastInteracted != null && incident.lastInteracted!.isNotEmpty) {
      final parsed = DateTime.tryParse(incident.lastInteracted!);
      if (parsed != null) return parsed;
    }
    return parseIncidentDateTime(incident.startedDate, incident.startedAt);
  }

  /// Returns top 3 incidents sorted by most recent last_interaction
  List<Incident> get topThreeRecentIncidents {
    final sortedList = List<Incident>.from(incidents);
    sortedList.sort((a, b) {
      final dtA = _getEffectiveInteractionTime(a);
      final dtB = _getEffectiveInteractionTime(b);
      return dtB.compareTo(dtA);
    });
    return sortedList.take(3).toList();
  }
}
