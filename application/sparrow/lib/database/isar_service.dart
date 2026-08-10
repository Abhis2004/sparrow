import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../screens/home/model/home_model.dart';
import '../screens/timeline/timeline_model.dart';
import 'isar_incident.dart';
import 'isar_timeline_details.dart';

final isarServiceProvider = Provider<IsarService>((ref) {
  return IsarService();
});

class IsarService {
  static Isar? _isar;

  /// Initializes Isar database
  Future<Isar> get db async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    _isar = await _initIsar();
    return _isar!;
  }

  Future<Isar> _initIsar() async {
    final dir = await getApplicationDocumentsDirectory();
    return await Isar.open(
      [IsarIncidentSchema, IsarTimelineDetailsSchema],
      directory: dir.path,
      name: 'sparrow_incidents_db',
    );
  }

  /// Clears all incidents and timeline data from Isar DB
  Future<void> clearAllData() async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.isarIncidents.clear();
      await isar.isarTimelineDetails.clear();
    });
  }

  /// Fetches all root incidents from Isar database
  Future<List<Incident>> fetchIncidents() async {
    final isar = await db;
    final isarList = await isar.isarIncidents.where().findAll();
    return isarList.map((e) => e.toDomain()).toList();
  }

  /// Inserts or updates a root incident in Isar database
  Future<void> saveIncident(Incident incident) async {
    final isar = await db;
    final existing = await isar.isarIncidents.filter().idEqualTo(incident.id).findFirst();
    final nowIso = DateTime.now().toIso8601String();
    final updatedIncident = Incident(
      id: incident.id,
      incidentName: incident.incidentName,
      location: incident.location,
      startedAt: incident.startedAt,
      startedDate: incident.startedDate,
      completedAt: incident.completedAt,
      completedDate: incident.completedDate,
      lastInteracted: incident.lastInteracted ?? nowIso,
      status: incident.status,
      category: incident.category,
      rawStatus: incident.rawStatus,
      rawCategory: incident.rawCategory,
      observationCount: incident.observationCount,
      victimCount: incident.victimCount,
      witnessCount: incident.witnessCount,
      suspectCount: incident.suspectCount,
    );

    final isarIncident = updatedIncident.toIsar();
    if (existing != null) {
      isarIncident.isarAutoId = existing.isarAutoId;
    }
    await isar.writeTxn(() async {
      await isar.isarIncidents.put(isarIncident);
    });
  }

  /// Fetches detailed timeline for an incident from Isar database
  Future<TimelineDetails?> fetchTimelineDetails(String incidentId) async {
    final isar = await db;
    final isarDetails =
        await isar.isarTimelineDetails.filter().incidentIdEqualTo(incidentId).findFirst();

    if (isarDetails != null) {
      return isarDetails.toDomain();
    }
    return null;
  }

  /// Inserts or updates detailed timeline in Isar database and updates last_interacted in Root Incidents List DB
  Future<void> saveTimelineDetails(String incidentId, TimelineDetails details) async {
    final isar = await db;
    final nowIso = DateTime.now().toIso8601String();

    // Automatically update last_interacted timestamp on overview and root incident
    final updatedOverview = details.incident.copyWith(lastInteracted: nowIso);
    final updatedDetails = TimelineDetails(
      incident: updatedOverview,
      officer: details.officer,
      victims: details.victims,
      witnesses: details.witnesses,
      suspects: details.suspects,
      officerObservations: details.officerObservations,
      evidence: details.evidence,
      timeline: details.timeline,
    );

    final existingDetails =
        await isar.isarTimelineDetails.filter().incidentIdEqualTo(incidentId).findFirst();
    final isarDetail = updatedDetails.toIsar(incidentId);
    if (existingDetails != null) {
      isarDetail.isarAutoId = existingDetails.isarAutoId;
    }

    await isar.writeTxn(() async {
      await isar.isarTimelineDetails.put(isarDetail);
    });

    // Also update root incident summary & last_interacted field in Root Incidents List Database (isarIncidents)
    final rootIncident = updatedOverview.toRootIncident();
    final existingIncident =
        await isar.isarIncidents.filter().idEqualTo(incidentId).findFirst();
    final isarIncident = rootIncident.toIsar();
    if (existingIncident != null) {
      isarIncident.isarAutoId = existingIncident.isarAutoId;
    }
    await isar.writeTxn(() async {
      await isar.isarIncidents.put(isarIncident);
    });
  }

  /// Deletes an incident and its timeline details from Isar database
  Future<void> deleteIncident(String incidentId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.isarIncidents.filter().idEqualTo(incidentId).deleteAll();
      await isar.isarTimelineDetails.filter().incidentIdEqualTo(incidentId).deleteAll();
    });
  }
}

// Model Mapper Extensions
extension IsarIncidentMapper on IsarIncident {
  Incident toDomain() {
    IncidentCategory catEnum;
    final lowerCat = category.toLowerCase();
    if (lowerCat.contains('theft') || lowerCat.contains('चोरी')) {
      catEnum = IncidentCategory.theft;
    } else if (lowerCat.contains('vehicle') || lowerCat.contains('वाहन')) {
      catEnum = IncidentCategory.vehicle;
    } else if (lowerCat.contains('assault') || lowerCat.contains('हमला')) {
      catEnum = IncidentCategory.assault;
    } else {
      catEnum = IncidentCategory.general;
    }

    IncidentStatus statusEnum;
    switch (status.toLowerCase()) {
      case 'active':
        statusEnum = IncidentStatus.active;
        break;
      case 'completed':
        statusEnum = IncidentStatus.completed;
        break;
      default:
        statusEnum = IncidentStatus.draft;
    }

    return Incident(
      id: id,
      incidentName: incidentName,
      location: location,
      startedAt: startedAt,
      startedDate: startedDate,
      completedAt: completedAt,
      completedDate: completedDate,
      lastInteracted: lastInteracted,
      status: statusEnum,
      category: catEnum,
      rawStatus: status,
      rawCategory: category,
      observationCount: observationCount,
      victimCount: victimCount,
      witnessCount: witnessCount,
      suspectCount: suspectCount,
    );
  }
}

extension IncidentToIsar on Incident {
  IsarIncident toIsar() {
    return IsarIncident()
      ..id = id
      ..incidentName = incidentName
      ..location = location
      ..startedAt = startedAt
      ..startedDate = startedDate
      ..completedAt = completedAt
      ..completedDate = completedDate
      ..lastInteracted = lastInteracted
      ..status = rawStatus.isNotEmpty ? rawStatus : status.name
      ..category = rawCategory.isNotEmpty ? rawCategory : category.name
      ..observationCount = observationCount
      ..victimCount = victimCount
      ..witnessCount = witnessCount
      ..suspectCount = suspectCount;
  }
}

extension IsarTimelineDetailsMapper on IsarTimelineDetails {
  TimelineDetails toDomain() {
    final Map<String, dynamic> jsonMap = jsonDecode(detailsJson);
    return TimelineDetails.fromJson(jsonMap);
  }
}

extension TimelineDetailsToIsar on TimelineDetails {
  IsarTimelineDetails toIsar(String incId) {
    return IsarTimelineDetails()
      ..incidentId = incId
      ..detailsJson = jsonEncode(toJson());
  }
}

extension IncidentOverviewToRoot on IncidentOverview {
  Incident toRootIncident() {
    IncidentCategory catEnum;
    final lowerCat = rawCategory.toLowerCase();
    if (lowerCat.contains('theft') || lowerCat.contains('चोरी')) {
      catEnum = IncidentCategory.theft;
    } else if (lowerCat.contains('vehicle') || lowerCat.contains('वाहन')) {
      catEnum = IncidentCategory.vehicle;
    } else if (lowerCat.contains('assault') || lowerCat.contains('हमला')) {
      catEnum = IncidentCategory.assault;
    } else {
      catEnum = IncidentCategory.general;
    }

    IncidentStatus statusEnum;
    switch (rawStatus.toLowerCase()) {
      case 'active':
        statusEnum = IncidentStatus.active;
        break;
      case 'completed':
        statusEnum = IncidentStatus.completed;
        break;
      default:
        statusEnum = IncidentStatus.draft;
    }

    return Incident(
      id: id,
      incidentName: incidentName,
      location: location,
      startedAt: startedAt,
      startedDate: startedDate,
      completedAt: completedAt,
      completedDate: completedDate,
      lastInteracted: lastInteracted,
      status: statusEnum,
      category: catEnum,
      rawStatus: rawStatus,
      rawCategory: rawCategory,
      observationCount: observationCount,
      victimCount: victimCount,
      witnessCount: witnessCount,
      suspectCount: suspectCount,
    );
  }
}
