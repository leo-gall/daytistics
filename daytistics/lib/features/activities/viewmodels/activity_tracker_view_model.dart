import 'package:daytistics/features/activities/models/activity_entry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'activity_tracker_view_model.g.dart';

class ActivityTrackerState {
  final ActivityEntry? currentActivity;
  const ActivityTrackerState({this.currentActivity});

  bool get isActivityInProgress => currentActivity != null;
  String? get getCurrentActivityDurationAsString {
    if (currentActivity == null) {
      return null;
    }

    final Duration duration =
        currentActivity!.endTime.difference(currentActivity!.startTime);
    return duration.toString().split('.').first.padLeft(8, '0');
  }

  ActivityTrackerState copyWith({ActivityEntry? currentActivity}) {
    return ActivityTrackerState(
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}

@riverpod
class ActivityTrackerViewModel extends _$ActivityTrackerViewModel {
  @override
  ActivityTrackerState build() => const ActivityTrackerState();

  void startActivity(ActivityEntry activity) {
    state = state.copyWith(currentActivity: activity);
  }

  void stopActivity() {
    state = state.copyWith(currentActivity: null);
  }
}
