import 'package:daytistics/features/activities/models/activity_entry.dart';
import 'package:daytistics/features/wellbeing/models/wellbeing_entry.dart';

class DaytisticEntry {
  DateTime date;
  final List<ActivityEntry> activityEntries = <ActivityEntry>[];
  WellbeingEntry? wellbeingEntry;

  DaytisticEntry({required this.date});

  @override
  String toString() {
    return 'DaytisticEntry{date: $date}';
  }
}
