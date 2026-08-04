import 'package:isar_community/isar.dart';

part 'isar_incident.g.dart';

@collection
class IsarIncident {
  Id isarAutoId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String id;

  late String incidentName;
  late String location;
  late String startedAt;
  late String startedDate;
  String? completedAt;
  String? completedDate;
  late String status;
  late String category;

  int observationCount = 0;
  int victimCount = 0;
  int witnessCount = 0;
  int suspectCount = 0;
}
