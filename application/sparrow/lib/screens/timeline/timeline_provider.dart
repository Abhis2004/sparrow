import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/isar_service.dart';
import '../home/home_service.dart';
import 'timeline_model.dart';

class TimelineMapNotifier extends Notifier<Map<String, TimelineDetails>> {
  @override
  Map<String, TimelineDetails> build() => {};

  Future<void> saveTimelineDetails(String incidentId, TimelineDetails details) async {
    await ref.read(isarServiceProvider).saveTimelineDetails(incidentId, details);
    state = {...state, incidentId: details};
  }

  Future<void> removeTimelineDetails(String incidentId) async {
    await ref.read(isarServiceProvider).deleteIncident(incidentId);
    final newState = Map<String, TimelineDetails>.from(state);
    newState.remove(incidentId);
    state = newState;
  }
}


final timelineMapNotifierProvider =
    NotifierProvider<TimelineMapNotifier, Map<String, TimelineDetails>>(
        TimelineMapNotifier.new);

/// Riverpod Provider family returning full TimelineDetails by Incident ID
final timelineDetailsProvider =
    FutureProvider.family<TimelineDetails, String>((ref, incidentId) async {
  final createdMap = ref.watch(timelineMapNotifierProvider);
  if (createdMap.containsKey(incidentId)) {
    return createdMap[incidentId]!;
  }
  final service = ref.watch(homeServiceProvider);
  return service.fetchTimelineDetails(incidentId);
});


