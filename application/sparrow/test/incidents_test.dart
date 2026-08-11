import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparrow/database/isar_service.dart';
import 'package:sparrow/screens/home/model/home_model.dart';
import 'package:sparrow/screens/incidents/incidents_model.dart';
import 'package:sparrow/screens/incidents/incidents_provider.dart';
import 'package:sparrow/screens/timeline/timeline_model.dart';
import 'package:sparrow/screens/timeline/timeline_provider.dart';
import 'package:sparrow/utils/time_formatter.dart';

final sampleIncidents = [
  const Incident(
    id: 'inc_001',
    incidentName: 'House Theft',
    location: 'Sector 18, Noida',
    startedAt: '09:18 AM',
    startedDate: '18 May 2026',
    status: IncidentStatus.active,
    category: IncidentCategory.theft,
    observationCount: 4,
    victimCount: 1,
    witnessCount: 2,
    suspectCount: 0,
  ),
  const Incident(
    id: 'inc_002',
    incidentName: 'Bike Theft',
    location: 'Sector 62, Noida',
    startedAt: '04:35 PM',
    startedDate: '17 May 2026',
    status: IncidentStatus.completed,
    category: IncidentCategory.vehicle,
    observationCount: 8,
    victimCount: 1,
    witnessCount: 3,
    suspectCount: 1,
  ),
];

class MockAllIncidentsNotifier extends AllIncidentsNotifier {
  MockAllIncidentsNotifier(this._initial);
  final List<Incident> _initial;

  @override
  Future<List<Incident>> build() async {
    return _initial;
  }

  @override
  Future<void> addIncident(Incident incident) async {
    final current = state.value ?? [];
    final updated = [incident, ...current];
    state = AsyncData(updated);
  }
}

class MockIsarService extends IsarService {
  @override
  Future<void> saveIncident(Incident incident) async {}

  @override
  Future<void> deleteIncident(String incidentId) async {}

  @override
  Future<void> saveTimelineDetails(String incidentId, TimelineDetails details) async {}
}

class MockTimelineMapNotifier extends TimelineMapNotifier {
  @override
  Future<void> saveTimelineDetails(String incidentId, TimelineDetails details) async {
    state = {...state, incidentId: details};
  }
}

ProviderContainer createContainer() {
  return ProviderContainer(
    overrides: [
      isarServiceProvider.overrideWithValue(MockIsarService()),
      allIncidentsProvider.overrideWith(() => MockAllIncidentsNotifier(sampleIncidents)),
      timelineMapNotifierProvider.overrideWith(() => MockTimelineMapNotifier()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Date Parsing & Sort Tests', () {
    test('formatTo12HourTime converts 24-hour and ISO strings to 12-hour format', () {
      expect(formatTo12HourTime('09:18 AM'), '09:18 AM');
      expect(formatTo12HourTime('14:30:00'), '02:30 PM');
      expect(formatTo12HourTime('00:15:00'), '12:15 AM');
      final formattedIso = formatTo12HourTime('2026-08-09T22:30:00.000Z');
      expect(formattedIso.contains('AM') || formattedIso.contains('PM'), isTrue);
    });

    test('parseIncidentDateTime converts date and time strings correctly', () {
      final dt1 = parseIncidentDateTime('18 May 2026', '09:18 AM');
      final dt2 = parseIncidentDateTime('17 May 2026', '04:35 PM');
      final dt3 = parseIncidentDateTime('18 May 2026', '10:00 AM');

      expect(dt1.year, 2026);
      expect(dt1.month, 5);
      expect(dt1.day, 18);
      expect(dt1.hour, 9);
      expect(dt1.minute, 18);

      expect(dt2.hour, 16);
      expect(dt2.minute, 35);

      // dt3 is later than dt1 on the same day
      expect(dt3.isAfter(dt1), isTrue);
      // dt1 is later than dt2
      expect(dt1.isAfter(dt2), isTrue);
    });

    test('filteredIncidentsProvider defaults to Recent to Oldest sorting', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      final incidents = container.read(filteredIncidentsProvider);

      expect(incidents.isNotEmpty, isTrue);

      // Verify each consecutive incident is older than or equal to the previous incident
      for (int i = 0; i < incidents.length - 1; i++) {
        final currentDt = parseIncidentDateTime(
          incidents[i].startedDate,
          incidents[i].startedAt,
        );
        final nextDt = parseIncidentDateTime(
          incidents[i + 1].startedDate,
          incidents[i + 1].startedAt,
        );

        expect(
          currentDt.isAfter(nextDt) || currentDt.isAtSameMomentAs(nextDt),
          isTrue,
          reason:
              'Incident ${incidents[i].incidentName} ($currentDt) should be more recent than ${incidents[i + 1].incidentName} ($nextDt)',
        );
      }
    });

    test('Filter by Status returns matching incidents', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      container
          .read(incidentsFilterProvider.notifier)
          .setStatus(IncidentStatus.active);

      final filtered = container.read(filteredIncidentsProvider);
      expect(filtered.every((inc) => inc.status == IncidentStatus.active), isTrue);
    });

    test('Filter by Category returns matching incidents', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      container
          .read(incidentsFilterProvider.notifier)
          .setCategory('theft');

      final filtered = container.read(filteredIncidentsProvider);
      expect(
        filtered.every((inc) => inc.category == IncidentCategory.theft || inc.rawCategory == 'theft'),
        isTrue,
      );
    });

    test('Search filter matches incident title or location', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      container
          .read(incidentsFilterProvider.notifier)
          .setSearchQuery('House Theft');

      final filtered = container.read(filteredIncidentsProvider);
      expect(filtered.length, 1);
      expect(filtered.first.incidentName, 'House Theft');
    });

    test('Reset filters restores default Recent to Oldest state', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      final notifier = container.read(incidentsFilterProvider.notifier);
      notifier.setStatus(IncidentStatus.completed);
      notifier.setSortOption(IncidentSortOption.oldestToRecent);
      notifier.toggleHasSuspectsOnly(true);

      expect(container.read(incidentsFilterProvider).isDefault, isFalse);

      notifier.resetFilters();
      final resetState = container.read(incidentsFilterProvider);

      expect(resetState.selectedStatus, isNull);
      expect(resetState.sortOption, IncidentSortOption.recentToOldest);
      expect(resetState.hasSuspectsOnly, isFalse);
    });

    test('Zero cases simulated empty state returns empty list and metrics', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      container.read(allIncidentsProvider.notifier).toggleSimulatedEmptyState(true);

      final incidents = container.read(filteredIncidentsProvider);
      final metrics = container.read(incidentMetricsProvider);

      expect(incidents.isEmpty, isTrue);
      expect(metrics['total'], 0);
      expect(metrics['active'], 0);
      expect(metrics['completed'], 0);
      expect(metrics['draft'], 0);
    });

    test('addIncident creates new case and updates state dynamically', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      final initialCount = container.read(filteredIncidentsProvider).length;

      const newInc = Incident(
        id: 'inc_test_999',
        incidentName: 'Test Emergency Report',
        location: 'Sector 18',
        startedAt: '10:00 AM',
        startedDate: '02 Aug 2026',
        status: IncidentStatus.active,
        category: IncidentCategory.general,
      );

      await container.read(allIncidentsProvider.notifier).addIncident(newInc);

      final updatedIncidents = container.read(filteredIncidentsProvider);
      expect(updatedIncidents.length, initialCount + 1);
      expect(updatedIncidents.first.incidentName, 'Test Emergency Report');
    });

    test('addIncident with timeline details saves case_brief timeline event', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      final timelineNotifier = container.read(timelineMapNotifierProvider.notifier);
      const testDetails = TimelineDetails(
        incident: IncidentOverview(
          id: 'inc_test_001',
          incidentName: 'Test Bike Theft',
          location: 'Sector 62, Noida',
          gps: GpsLocation(latitude: 28.6272, longitude: 77.3635),
          startedAt: '04:35 PM',
          startedDate: '17 May 2026',
          completedAt: '',
          completedDate: '',
          status: IncidentStatus.active,
          category: IncidentCategory.vehicle,
          rawStatus: 'active',
          rawCategory: 'vehicle',
          weather: 'Clear, 34°C, slight humidity',
          station: 'Sector 58 Police Station',
          district: 'Gautam Buddha Nagar',
          state: 'Uttar Pradesh',
          summary: 'Reported theft of a black Pulsar',
          observationCount: 0,
          victimCount: 0,
          witnessCount: 0,
          suspectCount: 0,
        ),
        officer: AssignedOfficer(
          badgeNumber: 'UP-GBN-8821',
          name: 'Inspector Rajeshwar Dayal',
          designation: 'Sub-Inspector of Police',
          station: 'Sector 58 Police Station',
          phone: '+91-9454403812',
        ),
        victims: [],
        witnesses: [],
        suspects: [],
        officerObservations: [],
        evidence: [],
        timeline: [
          TimelineEvent(
            timelineId: 'tl_001',
            timestamp: '2026-08-03T21:12:00.000Z',
            eventType: 'case_brief',
            personId: 'off_104',
            referenceId: '',
            evidenceIds: [],
            gps: GpsLocation(latitude: 28.6272, longitude: 77.3635),
          ),
        ],
      );

      timelineNotifier.saveTimelineDetails('inc_test_001', testDetails);

      final fetched = await container.read(timelineDetailsProvider('inc_test_001').future);
      expect(fetched.incident.id, 'inc_test_001');
      expect(fetched.incident.status, IncidentStatus.active);
      expect(fetched.incident.station, 'Sector 58 Police Station');
      expect(fetched.timeline.first.eventType, 'case_brief');
      expect(fetched.timeline.first.personId, 'off_104');
    });

    test('TimelineDetails parses user sample JSON database schema correctly', () {
      final userSampleJson = {
        "incident": {
          "id": "inc_010",
          "incident_name": "Public Nuisance",
          "location": "Sector 12, Noida",
          "gps": {
            "lat": 28.5951,
            "lng": 77.3310
          },
          "started_at": "11:00 PM",
          "started_date": "09 May 2026",
          "completed_at": "01:15 AM",
          "completed_date": "10 May 2026",
          "status": "completed",
          "category": "general",
          "weather": "Clear, 28°C",
          "station": "Sector 20 Police Station",
          "district": "Gautam Buddha Nagar",
          "state": "Uttar Pradesh",
          "summary": "Late night public disturbance...",
          "observation_count": 0,
          "victim_count": 1,
          "witness_count": 1,
          "suspect_count": 1
        },
        "officer": {
          "id": "off_010",
          "badge_number": "UP14521",
          "name": "Anil Verma",
          "designation": "Inspector",
          "station": "Sector 20 Police Station",
          "phone": "+919811223344"
        },
        "victims": [],
        "witnesses": [
          {
            "id": "wit_010_1",
            "name": "Harish Rawat",
            "age": 52,
            "gender": "Male",
            "phone": "+919811776655",
            "address": "Sector 12, Noida",
            "occupation": "Resident",
            "statements": [
              {
                "statement_id": "stmt_wit10_1",
                "timestamp": "2026-05-09T23:20:00Z",
                "transcript": "Loud music and DJ speakers were operating past 11 PM without police permission.",
                "evidence_ids": []
              }
            ]
          }
        ],
        "suspects": [
          {
            "id": "sus_010_1",
            "name": "Rohan Sethi",
            "age": 27,
            "gender": "Male",
            "address": "Sector 12, Noida",
            "status": "Cited",
            "statements": [
              {
                "statement_id": "stmt_sus10_1",
                "timestamp": "2026-05-09T23:45:00Z",
                "transcript": "We were celebrating a private birthday party...",
                "evidence_ids": []
              }
            ]
          }
        ],
        "officerObservations": [
          {
            "id": "obs_001",
            "timestamp": "2026-05-17T16:38:00+05:30",
            "gps": {
              "latitude": 28.6273,
              "longitude": 77.3636
            },
            "transcript": "Arrived at the scene...",
            "evidence_ids": [
              "photo_evidence_001"
            ]
          }
        ],
        "evidence": [
          {
            "id": "photo_evidence_001",
            "type": "photo",
            "file_name": "image.png",
            "captured_at": "2026-05-09T23:35:00",
            "gps": {
              "latitude": 28.6273,
              "longitude": 77.3636
            }
          }
        ],
        "timeline": [
          {
            "id": "evt_001",
            "timestamp": "2026-05-09T23:00:00Z",
            "eventType": "officer_observation",
            "evidenceIds": [
              "photo_evidence_001"
            ]
          }
        ]
      };

      final parsed = TimelineDetails.fromJson(userSampleJson);
      expect(parsed.incident.id, 'inc_010');
      expect(parsed.incident.incidentName, 'Public Nuisance');
      expect(parsed.incident.gps.latitude, 28.5951);
      expect(parsed.incident.gps.longitude, 77.3310);
      expect(parsed.officer.name, 'Anil Verma');
      expect(parsed.witnesses.first.name, 'Harish Rawat');
      expect(parsed.suspects.first.name, 'Rohan Sethi');
      expect(parsed.officerObservations.first.id, 'obs_001');
      expect(parsed.evidence.first.id, 'photo_evidence_001');
      expect(parsed.evidence.first.fileName, 'image.png');
      expect(parsed.evidence.first.type, EvidenceType.photo);
      expect(parsed.timeline.first.eventType, 'officer_observation');

      final serialized = parsed.toJson();
      expect(serialized['evidence'], isNotNull);
      final evList = serialized['evidence'] as List;
      expect((evList.first as Map)['file_name'], 'image.png');
    });

    test('TimelineDetails automatically logs timeline events for every user action', () {
      final initialDetails = TimelineDetails(
        incident: const IncidentOverview(
          id: 'inc_test_999',
          incidentName: 'Test Incident',
          location: 'Test Location',
          gps: GpsLocation(latitude: 28.5, longitude: 77.3),
          startedAt: '10:00 AM',
          startedDate: '04 Aug 2026',
          completedAt: '',
          completedDate: '',
          status: IncidentStatus.active,
          category: IncidentCategory.general,
          weather: 'Clear',
          station: 'Station 1',
          district: 'District 1',
          state: 'State 1',
          summary: 'Summary',
          observationCount: 0,
          victimCount: 0,
          witnessCount: 0,
          suspectCount: 0,
        ),
        officer: const AssignedOfficer(
          badgeNumber: 'UP-1234',
          name: 'Test Officer',
          designation: 'SI',
          station: 'Test Station',
          phone: '+919000000000',
        ),
        victims: const [],
        witnesses: const [],
        suspects: const [],
        officerObservations: const [],
        evidence: const [],
        timeline: const [],
      );

      // 1. Add Officer Observation
      final withObs = initialDetails.withOfficerObservation(
        const OfficerObservationItem(
          id: 'obs_001',
          timestamp: '2026-08-04T10:00:00Z',
          gps: GpsLocation(latitude: 28.5, longitude: 77.3),
          transcript: 'Observed broken window locks.',
          evidenceIds: [],
        ),
      );
      expect(withObs.officerObservations.length, 1);
      expect(withObs.timeline.length, 1);
      expect(withObs.timeline.last.eventType, 'officer_observation');

      // 2. Add Victim
      final withVic = withObs.withVictim(
        const VictimItem(
          id: 'vic_001',
          name: 'John Doe',
          age: 30,
          gender: 'Male',
          phone: '+919811000000',
          address: 'Address 1',
          role: 'Victim',
          statements: [
            PersonStatement(
              statementId: 'stmt_vic_1',
              timestamp: '2026-08-04T10:05:00Z',
              transcript: 'I heard loud noises outside.',
              evidenceIds: [],
            )
          ],
        ),
      );
      expect(withVic.victims.length, 1);
      expect(withVic.timeline.length, 3);
      expect(withVic.timeline.last.eventType, 'victim_statement');

      // 3. Add Witness
      final withWit = withVic.withWitness(
        const WitnessItem(
          id: 'wit_001',
          name: 'Jane Smith',
          age: 28,
          gender: 'Female',
          phone: '+919811000001',
          address: 'Address 2',
          occupation: 'Neighbor',
          statements: [
            PersonStatement(
              statementId: 'stmt_wit_1',
              timestamp: '2026-08-04T10:10:00Z',
              transcript: 'I saw a vehicle speeding away.',
              evidenceIds: [],
            )
          ],
        ),
      );
      expect(withWit.witnesses.length, 1);
      expect(withWit.timeline.length, 5);
      expect(withWit.timeline.last.eventType, 'witness_statement');

      // 4. Add Suspect
      final withSus = withWit.withSuspect(
        const SuspectItem(
          id: 'sus_001',
          name: 'Suspect X',
          age: 25,
          gender: 'Male',
          address: 'Address 3',
          status: 'Under Investigation',
          statements: [
            PersonStatement(
              statementId: 'stmt_sus_1',
              timestamp: '2026-08-04T10:15:00Z',
              transcript: 'No comments.',
              evidenceIds: [],
            )
          ],
        ),
      );
      expect(withSus.suspects.length, 1);
      expect(withSus.timeline.length, 7);
      expect(withSus.timeline.last.eventType, 'suspect_statement');

      // 5. Add Evidence
      final withEv = withSus.withEvidence(
        const EvidenceItem(
          id: 'ev_001',
          type: EvidenceType.photo,
          fileName: 'photo.jpg',
          capturedAt: '2026-08-04T10:20:00Z',
          gps: GpsLocation(latitude: 28.5, longitude: 77.3),
        ),
      );
      expect(withEv.evidence.length, 1);
      expect(withEv.timeline.length, 8);
      expect(withEv.timeline.last.eventType, 'evidence_capture');

      // 6. Edit Incident Details
      final withEdit = withEv.withIncidentEdit(
        withEv.incident.copyWith(summary: 'Updated crime summary'),
      );
      expect(withEdit.timeline.length, 9);
      expect(withEdit.timeline.last.eventType, 'incident_edit');
    });

    test('updateIncident updates Database 1 root incident summary', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      final notifier = container.read(allIncidentsProvider.notifier);

      final updatedIncident = const Incident(
        id: 'inc_001',
        incidentName: 'House Theft - Updated Title',
        location: 'Sector 18, Noida',
        startedAt: '09:18 AM',
        startedDate: '18 May 2026',
        status: IncidentStatus.completed,
        category: IncidentCategory.theft,
      );

      await notifier.updateIncident(updatedIncident);
      final incidents = container.read(allIncidentsProvider).value ?? [];
      final target = incidents.firstWhere((e) => e.id == 'inc_001');
      expect(target.incidentName, 'House Theft - Updated Title');
      expect(target.status, IncidentStatus.completed);
    });

    test('deleteIncident removes case from both Database 1 and Database 2 state', () async {
      final container = createContainer();
      addTearDown(container.dispose);

      await container.read(allIncidentsProvider.future);
      final notifier = container.read(allIncidentsProvider.notifier);

      await notifier.deleteIncident('inc_001');
      final incidents = container.read(allIncidentsProvider).value ?? [];
      expect(incidents.any((e) => e.id == 'inc_001'), isFalse);
    });
  });
}
