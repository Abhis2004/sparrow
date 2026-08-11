import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../database/isar_service.dart';
import '../incidents/incidents_provider.dart';
import '../timeline/timeline_model.dart';
import 'model/home_model.dart';

final officerProfileProvider =
    NotifierProvider<OfficerProfileNotifier, OfficerProfile>(
        OfficerProfileNotifier.new);

class OfficerProfileNotifier extends Notifier<OfficerProfile> {
  static const String _prefKey = 'sparrow_officer_profile';

  static const OfficerProfile emptyProfile = OfficerProfile(
    name: '',
    designation: '',
    station: '',
    district: '',
    state: '',
    profileImage: null,
  );

  @override
  OfficerProfile build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final jsonStr = prefs.getString(_prefKey);
    if (jsonStr == null || jsonStr.isEmpty) {
      return emptyProfile;
    }
    try {
      final Map<String, dynamic> jsonMap =
          jsonDecode(jsonStr) as Map<String, dynamic>;
      final profile = OfficerProfile.fromJson(jsonMap);
      return profile;
    } catch (_) {
      return emptyProfile;
    }
  }

  Future<void> saveProfile(OfficerProfile profile) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final jsonStr = jsonEncode(profile.toJson());
    await prefs.setString(_prefKey, jsonStr);
    state = profile;
  }

  Future<void> clearProfile() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_prefKey);
    state = emptyProfile;
  }
}

final homeServiceProvider = Provider<HomeService>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return HomeService(isarService, ref);
});

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final officer = ref.watch(officerProfileProvider);
  final incidents = ref.watch(allIncidentsProvider).value ?? [];
  return HomeData(
    officer: officer,
    incidents: incidents,
    quickActions: QuickAction.defaultActions,
  );
});

class HomeService {
  HomeService(this._isarService, this._ref);

  final IsarService _isarService;
  final Ref _ref;

  /// Fetches officer profile from local Riverpod state/SharedPreferences
  Future<OfficerProfile> fetchOfficerProfile() async {
    return _ref.read(officerProfileProvider);
  }

  /// Fetches all incidents from Isar local database
  Future<List<Incident>> fetchIncidents() async {
    return _isarService.fetchIncidents();
  }

  /// Returns full parsed TimelineDetails for an incident from Isar local database
  Future<TimelineDetails> fetchTimelineDetails(String incidentId) async {
    final officer = await fetchOfficerProfile();
    final detailsFromIsar = await _isarService.fetchTimelineDetails(incidentId);

    if (detailsFromIsar != null) {
      final updatedOfficer = AssignedOfficer(
        badgeNumber: officer.badgeNumber.isNotEmpty ? officer.badgeNumber : detailsFromIsar.officer.badgeNumber,
        name: officer.name.isNotEmpty ? officer.name : detailsFromIsar.officer.name,
        designation: officer.designation.isNotEmpty ? officer.designation : detailsFromIsar.officer.designation,
        station: officer.station.isNotEmpty ? officer.station : detailsFromIsar.officer.station,
        phone: officer.phone.isNotEmpty ? officer.phone : detailsFromIsar.officer.phone,
        district: officer.district.isNotEmpty ? officer.district : detailsFromIsar.officer.district,
        state: officer.state.isNotEmpty ? officer.state : detailsFromIsar.officer.state,
      );
      final updatedIncident = detailsFromIsar.incident.copyWith(
        station: officer.station.isNotEmpty ? officer.station : detailsFromIsar.incident.station,
        district: officer.district.isNotEmpty ? officer.district : detailsFromIsar.incident.district,
        state: officer.state.isNotEmpty ? officer.state : detailsFromIsar.incident.state,
      );
      return detailsFromIsar.copyWith(
        officer: updatedOfficer,
        incident: updatedIncident,
      );
    }

    // Fallback: create fresh timeline details using matching incident from Isar DB
    final allIncidents = await fetchIncidents();
    final matchingIncident = allIncidents.firstWhere(
      (e) => e.id == incidentId,
      orElse: () => Incident(
        id: incidentId,
        incidentName: 'Incident $incidentId',
        location: '',
        startedAt: '',
        startedDate: '',
        status: IncidentStatus.active,
        category: IncidentCategory.general,
        rawStatus: 'active',
        rawCategory: 'General',
      ),
    );

    final overview = IncidentOverview(
      id: matchingIncident.id,
      incidentName: matchingIncident.incidentName,
      location: matchingIncident.location,
      gps: const GpsLocation(latitude: 0, longitude: 0),
      startedAt: matchingIncident.startedAt,
      startedDate: matchingIncident.startedDate,
      completedAt: matchingIncident.completedAt ?? '',
      completedDate: matchingIncident.completedDate ?? '',
      status: matchingIncident.status,
      category: matchingIncident.category,
      rawStatus: matchingIncident.rawStatus,
      rawCategory: matchingIncident.rawCategory,
      weather: '',
      station: officer.station,
      district: officer.district,
      state: officer.state,
      summary: 'Initial case details for ${matchingIncident.incidentName}',
      observationCount: matchingIncident.observationCount,
      victimCount: matchingIncident.victimCount,
      witnessCount: matchingIncident.witnessCount,
      suspectCount: matchingIncident.suspectCount,
    );

    final newDetails = TimelineDetails(
      incident: overview,
      officer: AssignedOfficer(
        badgeNumber: officer.badgeNumber,
        name: officer.name,
        designation: officer.designation,
        station: officer.station,
        phone: officer.phone,
        district: officer.district,
        state: officer.state,
      ),
      victims: const [],
      witnesses: const [],
      suspects: const [],
      officerObservations: const [],
      evidence: const [],
      timeline: [
        TimelineEvent(
          timelineId: 'tl_${DateTime.now().millisecondsSinceEpoch}',
          timestamp: DateTime.now().toIso8601String(),
          eventType: 'case_brief',
          personId: officer.badgeNumber,
          referenceId: '',
          evidenceIds: const [],
          gps: const GpsLocation(latitude: 0, longitude: 0),
        ),
      ],
    );

    // Return generated in-memory fallback without persisting auto-generated data
    return newDetails;
  }

  /// Returns aggregated HomeData for UI presentation
  Future<HomeData> getHomeData() async {
    final officer = await fetchOfficerProfile();
    final incidents = await fetchIncidents();

    return HomeData(
      officer: officer,
      incidents: incidents,
      quickActions: QuickAction.defaultActions,
    );
  }
}
