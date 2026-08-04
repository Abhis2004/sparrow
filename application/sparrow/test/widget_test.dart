import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparrow/screens/home/model/home_model.dart';
import 'package:sparrow/screens/incidents/incidents_provider.dart';
import 'package:sparrow/screens/incidents/incidents_screen.dart';

class MockAllIncidentsNotifier extends AllIncidentsNotifier {
  MockAllIncidentsNotifier(this._initial);
  final List<Incident> _initial;

  @override
  Future<List<Incident>> build() async {
    return _initial;
  }
}

void main() {
  testWidgets('IncidentsScreen renders title, metric chips and incident cards',
      (WidgetTester tester) async {
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
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allIncidentsProvider.overrideWith(() => MockAllIncidentsNotifier(sampleIncidents)),
        ],
        child: const MaterialApp(
          home: IncidentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Case Records'), findsOneWidget);
    expect(find.text('House Theft'), findsOneWidget);
    expect(find.byIcon(Icons.filter_alt_outlined), findsOneWidget);
  });
}
