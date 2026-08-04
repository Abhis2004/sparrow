import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparrow/screens/home/model/home_model.dart';
import 'package:sparrow/screens/incidents/incidents_model.dart';
import 'package:sparrow/screens/incidents/incidents_provider.dart';
import 'package:sparrow/screens/timeline/timeline_model.dart';
import 'package:sparrow/screens/timeline/timeline_provider.dart';

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

class MockTimelineMapNotifier extends TimelineMapNotifier {
  @override
  Future<void> saveTimelineDetails(String incidentId, TimelineDetails details) async {
    state = {...state, incidentId: details};
  }
}

ProviderContainer createContainer() {
  return ProviderContainer(
    overrides: [
      allIncidentsProvider.overrideWith(() => MockAllIncidentsNotifier(sampleIncidents)),
      timelineMapNotifierProvider.overrideWith(() => MockTimelineMapNotifier()),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Date Parsing & Sort Tests', () {
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
          id: 'off_104',
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
  });
}
