import '../home/model/home_model.dart';

/// GPS Coordinates model
class GpsLocation {
  const GpsLocation({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get formatted => '$latitude, $longitude';
}

/// Incident Overview header & info
class IncidentOverview {
  const IncidentOverview({
    required this.id,
    required this.incidentName,
    required this.location,
    required this.gps,
    required this.startedAt,
    required this.startedDate,
    required this.completedAt,
    required this.completedDate,
    required this.status,
    required this.category,
    this.rawStatus = '',
    this.rawCategory = '',
    required this.weather,
    required this.station,
    required this.district,
    required this.state,
    required this.summary,
    required this.observationCount,
    required this.victimCount,
    required this.witnessCount,
    required this.suspectCount,
  });

  final String id;
  final String incidentName;
  final String location;
  final GpsLocation gps;
  final String startedAt;
  final String startedDate;
  final String completedAt;
  final String completedDate;
  final IncidentStatus status;
  final IncidentCategory category;
  final String rawStatus;
  final String rawCategory;
  final String weather;
  final String station;
  final String district;
  final String state;
  final String summary;
  final int observationCount;
  final int victimCount;
  final int witnessCount;
  final int suspectCount;

  IncidentOverview copyWith({
    String? id,
    String? incidentName,
    String? location,
    GpsLocation? gps,
    String? startedAt,
    String? startedDate,
    String? completedAt,
    String? completedDate,
    IncidentStatus? status,
    IncidentCategory? category,
    String? rawStatus,
    String? rawCategory,
    String? weather,
    String? station,
    String? district,
    String? state,
    String? summary,
    int? observationCount,
    int? victimCount,
    int? witnessCount,
    int? suspectCount,
  }) {
    return IncidentOverview(
      id: id ?? this.id,
      incidentName: incidentName ?? this.incidentName,
      location: location ?? this.location,
      gps: gps ?? this.gps,
      startedAt: startedAt ?? this.startedAt,
      startedDate: startedDate ?? this.startedDate,
      completedAt: completedAt ?? this.completedAt,
      completedDate: completedDate ?? this.completedDate,
      status: status ?? this.status,
      category: category ?? this.category,
      rawStatus: rawStatus ?? this.rawStatus,
      rawCategory: rawCategory ?? this.rawCategory,
      weather: weather ?? this.weather,
      station: station ?? this.station,
      district: district ?? this.district,
      state: state ?? this.state,
      summary: summary ?? this.summary,
      observationCount: observationCount ?? this.observationCount,
      victimCount: victimCount ?? this.victimCount,
      witnessCount: witnessCount ?? this.witnessCount,
      suspectCount: suspectCount ?? this.suspectCount,
    );
  }

  factory IncidentOverview.fromJson(Map<String, dynamic> json) {

    final rawStatusStr = json['status'] as String? ?? 'draft';
    final rawCategoryStr = json['category'] as String? ?? 'general';

    IncidentStatus st;
    switch (rawStatusStr.toLowerCase()) {
      case 'active':
        st = IncidentStatus.active;
        break;
      case 'completed':
        st = IncidentStatus.completed;
        break;
      default:
        st = IncidentStatus.draft;
    }

    IncidentCategory cat;
    switch (rawCategoryStr.toLowerCase()) {
      case 'theft':
        cat = IncidentCategory.theft;
        break;
      case 'vehicle':
      case 'vehicle crime':
        cat = IncidentCategory.vehicle;
        break;
      case 'assault':
        cat = IncidentCategory.assault;
        break;
      default:
        cat = IncidentCategory.general;
    }

    return IncidentOverview(
      id: json['id'] as String? ?? '',
      incidentName: json['incident_name'] as String? ?? 'Incident Details',
      location: json['location'] as String? ?? '',
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
      startedAt: json['started_at'] as String? ?? '',
      startedDate: json['started_date'] as String? ?? '',
      completedAt: json['completed_at'] as String? ?? '',
      completedDate: json['completed_date'] as String? ?? '',
      status: st,
      category: cat,
      rawStatus: rawStatusStr,
      rawCategory: rawCategoryStr,
      weather: json['weather'] as String? ?? '',
      station: json['station'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      observationCount: (json['observation_count'] as num?)?.toInt() ??
          ((json['officerObservations'] as List?)?.length ?? 0),
      victimCount: (json['victim_count'] as num?)?.toInt() ??
          ((json['victims'] as List?)?.length ?? 0),
      witnessCount: (json['witness_count'] as num?)?.toInt() ??
          ((json['witnesses'] as List?)?.length ?? 0),
      suspectCount: (json['suspect_count'] as num?)?.toInt() ??
          ((json['suspects'] as List?)?.length ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incident_name': incidentName,
      'location': location,
      'gps': gps.toJson(),
      'started_at': startedAt,
      'started_date': startedDate,
      'completed_at': completedAt,
      'completed_date': completedDate,
      'status': rawStatus.isNotEmpty ? rawStatus : status.name,
      'category': rawCategory.isNotEmpty ? rawCategory : category.name,
      'weather': weather,
      'station': station,
      'district': district,
      'state': state,
      'summary': summary,
      'observation_count': observationCount,
      'victim_count': victimCount,
      'witness_count': witnessCount,
      'suspect_count': suspectCount,
    };
  }
}

/// Assigned Officer model
class AssignedOfficer {
  const AssignedOfficer({
    required this.id,
    required this.badgeNumber,
    required this.name,
    required this.designation,
    required this.station,
    required this.phone,
  });

  final String id;
  final String badgeNumber;
  final String name;
  final String designation;
  final String station;
  final String phone;

  factory AssignedOfficer.fromJson(Map<String, dynamic> json) {
    return AssignedOfficer(
      id: json['id'] as String? ?? '',
      badgeNumber: json['badge_number'] as String? ?? '',
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      station: json['station'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'badge_number': badgeNumber,
      'name': name,
      'designation': designation,
      'station': station,
      'phone': phone,
    };
  }
}

/// Person Statement Model
class PersonStatement {
  const PersonStatement({
    required this.statementId,
    required this.timestamp,
    required this.transcript,
    required this.evidenceIds,
    this.gps,
  });

  final String statementId;
  final String timestamp;
  final String transcript;
  final List<String> evidenceIds;
  final GpsLocation? gps;

  factory PersonStatement.fromJson(Map<String, dynamic> json) {
    return PersonStatement(
      statementId: json['statement_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      transcript: json['transcript'] as String? ?? '',
      evidenceIds: (json['evidence_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      gps: json['gps'] != null
          ? GpsLocation.fromJson(json['gps'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statement_id': statementId,
      'timestamp': timestamp,
      'transcript': transcript,
      'evidence_ids': evidenceIds,
      'gps': gps?.toJson(),
    };
  }
}

/// Victim Person Model
class VictimItem {
  const VictimItem({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.role,
    required this.statements,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final String role;
  final List<PersonStatement> statements;

  factory VictimItem.fromJson(Map<String, dynamic> json) {
    return VictimItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      role: json['role'] as String? ?? '',
      statements: (json['statements'] as List<dynamic>?)
              ?.map((e) => PersonStatement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'role': role,
      'statements': statements.map((e) => e.toJson()).toList(),
    };
  }
}

/// Witness Person Model
class WitnessItem {
  const WitnessItem({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.address,
    required this.occupation,
    required this.statements,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String phone;
  final String address;
  final String occupation;
  final List<PersonStatement> statements;

  factory WitnessItem.fromJson(Map<String, dynamic> json) {
    return WitnessItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      occupation: json['occupation'] as String? ?? '',
      statements: (json['statements'] as List<dynamic>?)
              ?.map((e) => PersonStatement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'occupation': occupation,
      'statements': statements.map((e) => e.toJson()).toList(),
    };
  }
}

/// Suspect Person Model
class SuspectItem {
  const SuspectItem({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.address,
    required this.status,
    required this.statements,
  });

  final String id;
  final String name;
  final int age;
  final String gender;
  final String address;
  final String status;
  final List<PersonStatement> statements;

  factory SuspectItem.fromJson(Map<String, dynamic> json) {
    return SuspectItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statements: (json['statements'] as List<dynamic>?)
              ?.map((e) => PersonStatement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'address': address,
      'status': status,
      'statements': statements.map((e) => e.toJson()).toList(),
    };
  }
}

/// Officer Observation Model
class OfficerObservationItem {
  const OfficerObservationItem({
    required this.id,
    required this.timestamp,
    required this.gps,
    required this.transcript,
    required this.evidenceIds,
  });

  final String id;
  final String timestamp;
  final GpsLocation gps;
  final String transcript;
  final List<String> evidenceIds;

  factory OfficerObservationItem.fromJson(Map<String, dynamic> json) {
    return OfficerObservationItem(
      id: json['id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
      transcript: json['transcript'] as String? ?? '',
      evidenceIds: (json['evidence_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'gps': gps.toJson(),
      'transcript': transcript,
      'evidence_ids': evidenceIds,
    };
  }
}

/// Evidence Item Model
enum EvidenceType { photo, video, audio, document }

class EvidenceItem {
  const EvidenceItem({
    required this.id,
    required this.type,
    required this.fileName,
    required this.description,
    required this.capturedAt,
    required this.gps,
    required this.capturedBy,
    this.fileSize = '',
    this.duration = '',
  });

  final String id;
  final EvidenceType type;
  final String fileName;
  final String description;
  final String capturedAt;
  final GpsLocation gps;
  final String capturedBy;
  final String fileSize;
  final String duration;

  factory EvidenceItem.fromJson(Map<String, dynamic> json) {
    EvidenceType t;
    final typeStr = (json['type'] as String? ?? '').toLowerCase();
    switch (typeStr) {
      case 'video':
        t = EvidenceType.video;
        break;
      case 'audio':
        t = EvidenceType.audio;
        break;
      case 'document':
        t = EvidenceType.document;
        break;
      default:
        t = EvidenceType.photo;
    }

    String size = '';
    String dur = '';
    final fn = json['file_name'] as String? ?? '';
    if (fn.contains('photo')) {
      size = '2.4 MB';
    } else if (fn.contains('video')) {
      size = '18.7 MB';
    } else if (fn.contains('audio')) {
      size = '1.2 MB';
      dur = '01:32';
    } else if (fn.contains('document')) {
      size = '245 KB';
    }

    return EvidenceItem(
      id: json['id'] as String? ?? '',
      type: t,
      fileName: fn,
      description: json['description'] as String? ?? '',
      capturedAt: json['captured_at'] as String? ?? '',
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
      capturedBy: json['captured_by'] as String? ?? '',
      fileSize: size,
      duration: dur,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'file_name': fileName,
      'description': description,
      'captured_at': capturedAt,
      'gps': gps.toJson(),
      'captured_by': capturedBy,
    };
  }
}

/// Timeline Chronological Event Model
class TimelineEvent {
  const TimelineEvent({
    required this.timelineId,
    required this.timestamp,
    required this.eventType,
    required this.personId,
    required this.referenceId,
    required this.evidenceIds,
    required this.gps,
  });

  final String timelineId;
  final String timestamp;
  final String eventType;
  final String personId;
  final String referenceId;
  final List<String> evidenceIds;
  final GpsLocation gps;

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      timelineId: json['timeline_id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      personId: json['person_id'] as String? ?? '',
      referenceId: json['reference_id'] as String? ?? '',
      evidenceIds: (json['evidence_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timeline_id': timelineId,
      'timestamp': timestamp,
      'event_type': eventType,
      'person_id': personId,
      'reference_id': referenceId,
      'evidence_ids': evidenceIds,
      'gps': gps.toJson(),
    };
  }
}

/// Root Detailed Timeline Model
class TimelineDetails {
  const TimelineDetails({
    required this.incident,
    required this.officer,
    required this.victims,
    required this.witnesses,
    required this.suspects,
    required this.officerObservations,
    required this.evidence,
    required this.timeline,
  });

  final IncidentOverview incident;
  final AssignedOfficer officer;
  final List<VictimItem> victims;
  final List<WitnessItem> witnesses;
  final List<SuspectItem> suspects;
  final List<OfficerObservationItem> officerObservations;
  final List<EvidenceItem> evidence;
  final List<TimelineEvent> timeline;

  factory TimelineDetails.fromJson(Map<String, dynamic> json) {
    return TimelineDetails(
      incident: IncidentOverview.fromJson(
          json['incident'] as Map<String, dynamic>? ?? {}),
      officer: AssignedOfficer.fromJson(
          json['officer'] as Map<String, dynamic>? ?? {}),
      victims: (json['victims'] as List<dynamic>?)
              ?.map((e) => VictimItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      witnesses: (json['witnesses'] as List<dynamic>?)
              ?.map((e) => WitnessItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      suspects: (json['suspects'] as List<dynamic>?)
              ?.map((e) => SuspectItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      officerObservations: (json['officer_observations'] as List<dynamic>?)
              ?.map((e) =>
                  OfficerObservationItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => EvidenceItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => TimelineEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'incident': incident.toJson(),
      'officer': officer.toJson(),
      'victims': victims.map((e) => e.toJson()).toList(),
      'witnesses': witnesses.map((e) => e.toJson()).toList(),
      'suspects': suspects.map((e) => e.toJson()).toList(),
      'officer_observations': officerObservations.map((e) => e.toJson()).toList(),
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }
}
