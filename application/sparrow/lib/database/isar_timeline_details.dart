import 'package:isar_community/isar.dart';

part 'isar_timeline_details.g.dart';

@collection
class IsarTimelineDetails {
  Id isarAutoId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String incidentId;

  late String detailsJson;
}
