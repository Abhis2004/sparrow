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
    this.lastInteracted,
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
  final String? lastInteracted;
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
    String? lastInteracted,
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
      lastInteracted: lastInteracted ?? this.lastInteracted,
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
      incidentName: json['incident_name'] as String? ??
          json['incidentName'] as String? ??
          'Incident Details',
      location: json['location'] as String? ?? '',
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
      startedAt: json['started_at'] as String? ?? json['startedAt'] as String? ?? '',
      startedDate: json['started_date'] as String? ?? json['startedDate'] as String? ?? '',
      completedAt: json['completed_at'] as String? ?? json['completedAt'] as String? ?? '',
      completedDate: json['completed_date'] as String? ?? json['completedDate'] as String? ?? '',
      lastInteracted: json['last_interacted'] as String? ?? json['lastInteracted'] as String?,
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
          ((json['officerObservations'] as List?)?.length ??
              (json['officer_observations'] as List?)?.length ??
              0),
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
      'last_interacted': lastInteracted ?? '',
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
    required this.badgeNumber,
    required this.name,
    required this.designation,
    required this.station,
    required this.phone,
    this.district = '',
    this.state = '',
  });

  final String badgeNumber;
  final String name;
  final String designation;
  final String station;
  final String phone;
  final String district;
  final String state;

  factory AssignedOfficer.fromJson(Map<String, dynamic> json) {
    return AssignedOfficer(
      // Support legacy JSON that stored an 'id' field — treat it as badgeNumber fallback
      badgeNumber: (json['badge_number'] as String? ??
              json['badgeNumber'] as String? ??
              json['id'] as String? ??
              '')
          .toUpperCase(),
      name: json['name'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      station: json['station'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      district: json['district'] as String? ?? '',
      state: json['state'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'badge_number': badgeNumber,
      'name': name,
      'designation': designation,
      'station': station,
      'phone': phone,
      'district': district,
      'state': state,
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
      statementId: json['statement_id'] as String? ?? json['statementId'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      transcript: json['transcript'] as String? ?? '',
      evidenceIds: (json['evidence_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['evidenceIds'] as List<dynamic>?)
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
          (json['evidenceIds'] as List<dynamic>?)
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
    this.location,
    this.description = '',
    required this.capturedAt,
    required this.gps,
    this.capturedBy = '',
    this.fileSize = '',
    this.duration = '',
  });

  final String id;
  final EvidenceType type;
  final String fileName;
  final String? location;
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
      case 'pdf':
        t = EvidenceType.document;
        break;
      default:
        t = EvidenceType.photo;
    }

    final fn = json['file_name'] as String? ?? json['fileName'] as String? ?? '';
    final loc = json['location'] as String? ?? json['file_path'] as String?;

    String size = json['file_size'] as String? ?? json['fileSize'] as String? ?? '';
    String dur = json['duration'] as String? ?? '';

    if (size.isEmpty) {
      final lowerFn = fn.toLowerCase();
      if (lowerFn.contains('photo') || lowerFn.contains('img') || lowerFn.endsWith('.png') || lowerFn.endsWith('.jpg') || lowerFn.endsWith('.jpeg')) {
        size = '2.4 MB';
      } else if (lowerFn.contains('video') || lowerFn.endsWith('.mp4') || lowerFn.endsWith('.mov')) {
        size = '18.7 MB';
      } else if (lowerFn.contains('audio') || lowerFn.endsWith('.mp3') || lowerFn.endsWith('.wav')) {
        size = '1.2 MB';
        if (dur.isEmpty) dur = '01:32';
      } else if (lowerFn.contains('document') || lowerFn.endsWith('.pdf') || lowerFn.endsWith('.doc')) {
        size = '245 KB';
      } else {
        size = '1.5 MB';
      }
    }

    return EvidenceItem(
      id: json['id'] as String? ?? '',
      type: t,
      fileName: fn,
      location: loc,
      description: json['description'] as String? ?? '',
      capturedAt: json['captured_at'] as String? ?? json['capturedAt'] as String? ?? '',
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
      capturedBy: json['captured_by'] as String? ?? json['capturedBy'] as String? ?? '',
      fileSize: size,
      duration: dur,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'type': type.name,
      'file_name': fileName,
      'captured_at': capturedAt,
      'gps': gps.toJson(),
    };
    if (location != null && location!.isNotEmpty) {
      map['location'] = location;
    }
    if (capturedBy.isNotEmpty) {
      map['captured_by'] = capturedBy;
    }
    if (fileSize.isNotEmpty) {
      map['file_size'] = fileSize;
    }
    if (duration.isNotEmpty) {
      map['duration'] = duration;
    }
    return map;
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
      timelineId: json['timeline_id'] as String? ?? json['id'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      eventType: json['event_type'] as String? ?? json['eventType'] as String? ?? '',
      personId: json['person_id'] as String? ?? json['personId'] as String? ?? '',
      referenceId: json['reference_id'] as String? ?? json['referenceId'] as String? ?? '',
      evidenceIds: (json['evidence_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          (json['evidenceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      gps: GpsLocation.fromJson(json['gps'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': timelineId,
      'timestamp': timestamp,
      'eventType': eventType,
      'personId': personId,
      'referenceId': referenceId,
      'evidenceIds': evidenceIds,
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

  TimelineDetails copyWith({
    IncidentOverview? incident,
    AssignedOfficer? officer,
    List<VictimItem>? victims,
    List<WitnessItem>? witnesses,
    List<SuspectItem>? suspects,
    List<OfficerObservationItem>? officerObservations,
    List<EvidenceItem>? evidence,
    List<TimelineEvent>? timeline,
  }) {
    return TimelineDetails(
      incident: incident ?? this.incident,
      officer: officer ?? this.officer,
      victims: victims ?? this.victims,
      witnesses: witnesses ?? this.witnesses,
      suspects: suspects ?? this.suspects,
      officerObservations: officerObservations ?? this.officerObservations,
      evidence: evidence ?? this.evidence,
      timeline: timeline ?? this.timeline,
    );
  }

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
      officerObservations: ((json['officerObservations'] ?? json['officer_observations']) as List<dynamic>?)
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
      'officerObservations': officerObservations.map((e) => e.toJson()).toList(),
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'timeline': timeline.map((e) => e.toJson()).toList(),
    };
  }

  /// Appends an officer observation and new evidence, updating observation_count and last_interacted.
  TimelineDetails withOfficerObservation(
    OfficerObservationItem observation, {
    List<EvidenceItem> newEvidenceList = const [],
  }) {
    final nowIso = DateTime.now().toIso8601String();
    final newEvent = TimelineEvent(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: observation.timestamp,
      eventType: 'officer_observation',
      personId: officer.badgeNumber,
      referenceId: observation.id,
      evidenceIds: observation.evidenceIds,
      gps: observation.gps,
    );
    final updatedOverview = incident.copyWith(
      observationCount: officerObservations.length + 1,
      lastInteracted: nowIso,
    );
    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: [...officerObservations, observation],
      evidence: [...evidence, ...newEvidenceList],
      timeline: [...timeline, newEvent],
    );
  }


  /// Appends a victim and logs a 'victim_added' timeline event (plus 'victim_statement' events for any statements).
  TimelineDetails withVictim(VictimItem victim) {
    final nowIso = DateTime.now().toIso8601String();
    final newEvents = <TimelineEvent>[
      TimelineEvent(
        timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: nowIso,
        eventType: 'victim_added',
        personId: victim.id,
        referenceId: victim.name,
        evidenceIds: const [],
        gps: incident.gps,
      ),
    ];
    for (final stmt in victim.statements) {
      newEvents.add(TimelineEvent(
        timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}_${stmt.statementId}',
        timestamp: stmt.timestamp,
        eventType: 'victim_statement',
        personId: victim.id,
        referenceId: stmt.statementId,
        evidenceIds: stmt.evidenceIds,
        gps: stmt.gps ?? incident.gps,
      ));
    }

    final updatedOverview = incident.copyWith(
      victimCount: victims.length + 1,
      lastInteracted: nowIso,
    );
    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: [victim, ...victims],
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: [...timeline, ...newEvents],
    );
  }

  /// Appends a witness and logs a 'witness_added' timeline event (plus 'witness_statement' events for any statements).
  TimelineDetails withWitness(WitnessItem witness) {
    final nowIso = DateTime.now().toIso8601String();
    final newEvents = <TimelineEvent>[
      TimelineEvent(
        timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: nowIso,
        eventType: 'witness_added',
        personId: witness.id,
        referenceId: witness.name,
        evidenceIds: const [],
        gps: incident.gps,
      ),
    ];
    for (final stmt in witness.statements) {
      newEvents.add(TimelineEvent(
        timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}_${stmt.statementId}',
        timestamp: stmt.timestamp,
        eventType: 'witness_statement',
        personId: witness.id,
        referenceId: stmt.statementId,
        evidenceIds: stmt.evidenceIds,
        gps: stmt.gps ?? incident.gps,
      ));
    }

    final updatedOverview = incident.copyWith(
      witnessCount: witnesses.length + 1,
      lastInteracted: nowIso,
    );
    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: victims,
      witnesses: [witness, ...witnesses],
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: [...timeline, ...newEvents],
    );
  }

  /// Adds a statement to a specific victim by ID and logs a 'victim_statement' timeline event.
  TimelineDetails withVictimStatement(
    String victimId,
    PersonStatement statement, {
    List<EvidenceItem> newEvidenceList = const [],
  }) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedVictims = victims.map((v) {
      if (v.id == victimId) {
        return VictimItem(
          id: v.id,
          name: v.name,
          age: v.age,
          gender: v.gender,
          phone: v.phone,
          address: v.address,
          role: v.role,
          statements: [...v.statements, statement],
        );
      }
      return v;
    }).toList();

    final newEvent = TimelineEvent(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: statement.timestamp,
      eventType: 'victim_statement',
      personId: victimId,
      referenceId: statement.statementId,
      evidenceIds: statement.evidenceIds,
      gps: statement.gps ?? incident.gps,
    );

    final updatedOverview = incident.copyWith(
      lastInteracted: nowIso,
    );

    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: updatedVictims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: [...evidence, ...newEvidenceList],
      timeline: [...timeline, newEvent],
    );
  }

  /// Adds a statement to a specific witness by ID and logs a 'witness_statement' timeline event.
  TimelineDetails withWitnessStatement(
    String witnessId,
    PersonStatement statement, {
    List<EvidenceItem> newEvidenceList = const [],
  }) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedWitnesses = witnesses.map((w) {
      if (w.id == witnessId) {
        return WitnessItem(
          id: w.id,
          name: w.name,
          age: w.age,
          gender: w.gender,
          phone: w.phone,
          address: w.address,
          occupation: w.occupation,
          statements: [...w.statements, statement],
        );
      }
      return w;
    }).toList();

    final newEvent = TimelineEvent(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: statement.timestamp,
      eventType: 'witness_statement',
      personId: witnessId,
      referenceId: statement.statementId,
      evidenceIds: statement.evidenceIds,
      gps: statement.gps ?? incident.gps,
    );

    final updatedOverview = incident.copyWith(
      lastInteracted: nowIso,
    );

    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: victims,
      witnesses: updatedWitnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: [...evidence, ...newEvidenceList],
      timeline: [...timeline, newEvent],
    );
  }

  /// Appends a suspect and logs a 'suspect_added' timeline event (plus 'suspect_statement' events for any statements).
  TimelineDetails withSuspect(SuspectItem suspect) {
    final nowIso = DateTime.now().toIso8601String();
    final newEvents = <TimelineEvent>[
      TimelineEvent(
        timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
        timestamp: nowIso,
        eventType: 'suspect_added',
        personId: suspect.id,
        referenceId: suspect.name,
        evidenceIds: const [],
        gps: incident.gps,
      ),
    ];
    for (final stmt in suspect.statements) {
      newEvents.add(TimelineEvent(
        timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}_${stmt.statementId}',
        timestamp: stmt.timestamp,
        eventType: 'suspect_statement',
        personId: suspect.id,
        referenceId: stmt.statementId,
        evidenceIds: stmt.evidenceIds,
        gps: stmt.gps ?? incident.gps,
      ));
    }

    final updatedOverview = incident.copyWith(
      suspectCount: suspects.length + 1,
      lastInteracted: nowIso,
    );
    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: [...suspects, suspect],
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: [...timeline, ...newEvents],
    );
  }

  /// Adds a statement to a specific suspect by ID and logs a 'suspect_statement' timeline event.
  TimelineDetails withSuspectStatement(
    String suspectId,
    PersonStatement statement, {
    List<EvidenceItem> newEvidenceList = const [],
  }) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedSuspects = suspects.map((s) {
      if (s.id == suspectId) {
        return SuspectItem(
          id: s.id,
          name: s.name,
          age: s.age,
          gender: s.gender,
          address: s.address,
          status: s.status,
          statements: [...s.statements, statement],
        );
      }
      return s;
    }).toList();

    final newEvent = TimelineEvent(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: statement.timestamp,
      eventType: 'suspect_statement',
      personId: suspectId,
      referenceId: statement.statementId,
      evidenceIds: statement.evidenceIds,
      gps: statement.gps ?? incident.gps,
    );

    final updatedOverview = incident.copyWith(
      lastInteracted: nowIso,
    );

    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: updatedSuspects,
      officerObservations: officerObservations,
      evidence: [...evidence, ...newEvidenceList],
      timeline: [...timeline, newEvent],
    );
  }

  /// Appends an evidence item and automatically logs an 'evidence_capture' timeline event.
  TimelineDetails withEvidence(EvidenceItem item) {
    final newEvent = TimelineEvent(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: item.capturedAt,
      eventType: 'evidence_capture',
      personId: item.capturedBy.isNotEmpty ? item.capturedBy : officer.badgeNumber,
      referenceId: item.id,
      evidenceIds: [item.id],
      gps: item.gps,
    );
    return TimelineDetails(
      incident: incident,
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: [...evidence, item],
      timeline: [...timeline, newEvent],
    );
  }

  /// Updates incident overview details and automatically logs an 'incident_edit' timeline event.
  TimelineDetails withIncidentEdit(IncidentOverview updatedOverview) {
    final editEvent = TimelineEvent(
      timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now().toIso8601String(),
      eventType: 'incident_edit',
      personId: officer.badgeNumber,
      referenceId: '',
      evidenceIds: const [],
      gps: updatedOverview.gps,
    );
    return TimelineDetails(
      incident: updatedOverview,
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: [...timeline, editEvent],
    );
  }

  /// Updates transcript of an officer observation by ID.
  TimelineDetails withUpdatedOfficerObservation(String obsId, String newTranscript) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedObservations = officerObservations.map((obs) {
      if (obs.id == obsId) {
        return OfficerObservationItem(
          id: obs.id,
          timestamp: obs.timestamp,
          gps: obs.gps,
          transcript: newTranscript,
          evidenceIds: obs.evidenceIds,
        );
      }
      return obs;
    }).toList();

    return TimelineDetails(
      incident: incident.copyWith(lastInteracted: nowIso),
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: updatedObservations,
      evidence: evidence,
      timeline: timeline,
    );
  }

  /// Removes an officer observation by ID and cleans up its timeline event.
  TimelineDetails withoutOfficerObservation(String obsId) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedObservations = officerObservations.where((obs) => obs.id != obsId).toList();
    final updatedTimeline = timeline.where((e) => e.referenceId != obsId).toList();

    return TimelineDetails(
      incident: incident.copyWith(
        observationCount: updatedObservations.length,
        lastInteracted: nowIso,
      ),
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: updatedObservations,
      evidence: evidence,
      timeline: updatedTimeline,
    );
  }

  /// Updates transcript of a person statement (Victim, Witness, Suspect) by statementId.
  TimelineDetails withUpdatedPersonStatement(
    String personId,
    String personType,
    String statementId,
    String newTranscript,
  ) {
    final nowIso = DateTime.now().toIso8601String();

    List<VictimItem> updatedVictims = victims;
    List<WitnessItem> updatedWitnesses = witnesses;
    List<SuspectItem> updatedSuspects = suspects;

    if (personType == 'victim') {
      updatedVictims = victims.map((v) {
        if (v.id == personId) {
          return VictimItem(
            id: v.id,
            name: v.name,
            age: v.age,
            gender: v.gender,
            phone: v.phone,
            address: v.address,
            role: v.role,
            statements: v.statements.map((s) {
              if (s.statementId == statementId) {
                return PersonStatement(
                  statementId: s.statementId,
                  timestamp: s.timestamp,
                  transcript: newTranscript,
                  evidenceIds: s.evidenceIds,
                  gps: s.gps,
                );
              }
              return s;
            }).toList(),
          );
        }
        return v;
      }).toList();
    } else if (personType == 'witness') {
      updatedWitnesses = witnesses.map((w) {
        if (w.id == personId) {
          return WitnessItem(
            id: w.id,
            name: w.name,
            age: w.age,
            gender: w.gender,
            phone: w.phone,
            address: w.address,
            occupation: w.occupation,
            statements: w.statements.map((s) {
              if (s.statementId == statementId) {
                return PersonStatement(
                  statementId: s.statementId,
                  timestamp: s.timestamp,
                  transcript: newTranscript,
                  evidenceIds: s.evidenceIds,
                  gps: s.gps,
                );
              }
              return s;
            }).toList(),
          );
        }
        return w;
      }).toList();
    } else if (personType == 'suspect') {
      updatedSuspects = suspects.map((s) {
        if (s.id == personId) {
          return SuspectItem(
            id: s.id,
            name: s.name,
            age: s.age,
            gender: s.gender,
            address: s.address,
            status: s.status,
            statements: s.statements.map((stmt) {
              if (stmt.statementId == statementId) {
                return PersonStatement(
                  statementId: stmt.statementId,
                  timestamp: stmt.timestamp,
                  transcript: newTranscript,
                  evidenceIds: stmt.evidenceIds,
                  gps: stmt.gps,
                );
              }
              return stmt;
            }).toList(),
          );
        }
        return s;
      }).toList();
    }

    return TimelineDetails(
      incident: incident.copyWith(lastInteracted: nowIso),
      officer: officer,
      victims: updatedVictims,
      witnesses: updatedWitnesses,
      suspects: updatedSuspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: timeline,
    );
  }

  /// Removes a person statement by statementId and cleans up its timeline event.
  TimelineDetails withoutPersonStatement(
    String personId,
    String personType,
    String statementId,
  ) {
    final nowIso = DateTime.now().toIso8601String();

    List<VictimItem> updatedVictims = victims;
    List<WitnessItem> updatedWitnesses = witnesses;
    List<SuspectItem> updatedSuspects = suspects;

    if (personType == 'victim') {
      updatedVictims = victims.map((v) {
        if (v.id == personId) {
          return VictimItem(
            id: v.id,
            name: v.name,
            age: v.age,
            gender: v.gender,
            phone: v.phone,
            address: v.address,
            role: v.role,
            statements: v.statements.where((s) => s.statementId != statementId).toList(),
          );
        }
        return v;
      }).toList();
    } else if (personType == 'witness') {
      updatedWitnesses = witnesses.map((w) {
        if (w.id == personId) {
          return WitnessItem(
            id: w.id,
            name: w.name,
            age: w.age,
            gender: w.gender,
            phone: w.phone,
            address: w.address,
            occupation: w.occupation,
            statements: w.statements.where((s) => s.statementId != statementId).toList(),
          );
        }
        return w;
      }).toList();
    } else if (personType == 'suspect') {
      updatedSuspects = suspects.map((s) {
        if (s.id == personId) {
          return SuspectItem(
            id: s.id,
            name: s.name,
            age: s.age,
            gender: s.gender,
            address: s.address,
            status: s.status,
            statements: s.statements.where((s) => s.statementId != statementId).toList(),
          );
        }
        return s;
      }).toList();
    }

    final updatedTimeline = timeline.where((e) => e.referenceId != statementId).toList();

    return TimelineDetails(
      incident: incident.copyWith(lastInteracted: nowIso),
      officer: officer,
      victims: updatedVictims,
      witnesses: updatedWitnesses,
      suspects: updatedSuspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: updatedTimeline,
    );
  }

  /// Updates details of an existing victim by ID.
  TimelineDetails withUpdatedVictim(VictimItem updatedVictim) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedVictims = victims.map((v) {
      if (v.id == updatedVictim.id) {
        return updatedVictim;
      }
      return v;
    }).toList();

    return TimelineDetails(
      incident: incident.copyWith(lastInteracted: nowIso),
      officer: officer,
      victims: updatedVictims,
      witnesses: witnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: timeline,
    );
  }

  /// Updates details of an existing witness by ID.
  TimelineDetails withUpdatedWitness(WitnessItem updatedWitness) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedWitnesses = witnesses.map((w) {
      if (w.id == updatedWitness.id) {
        return updatedWitness;
      }
      return w;
    }).toList();

    return TimelineDetails(
      incident: incident.copyWith(lastInteracted: nowIso),
      officer: officer,
      victims: victims,
      witnesses: updatedWitnesses,
      suspects: suspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: timeline,
    );
  }

  /// Updates details of an existing suspect by ID.
  TimelineDetails withUpdatedSuspect(SuspectItem updatedSuspect) {
    final nowIso = DateTime.now().toIso8601String();
    final updatedSuspects = suspects.map((s) {
      if (s.id == updatedSuspect.id) {
        return updatedSuspect;
      }
      return s;
    }).toList();

    return TimelineDetails(
      incident: incident.copyWith(lastInteracted: nowIso),
      officer: officer,
      victims: victims,
      witnesses: witnesses,
      suspects: updatedSuspects,
      officerObservations: officerObservations,
      evidence: evidence,
      timeline: timeline,
    );
  }
}
