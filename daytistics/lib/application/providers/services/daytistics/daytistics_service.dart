import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/sembast/sembast.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sembast/sembast_io.dart';

part 'daytistics_service.g.dart';

class ActivitiesService {
  late final Database _db;
  late final Analytics _analytics;
  final _daytisticsStore = stringMapStoreFactory.store('daytistics');

  Future<Activity> create(Activity activity) async {
    final parentDaytistic = await _daytisticsStore.findFirst(
      _db,
      finder: Finder(filter: Filter.equals('id', activity.daytisticId)),
    );

    if (parentDaytistic == null) {
      throw SembastException('No daytistic found for the provided id.');
    }

    final parentDaytisticJson = parentDaytistic.value;
    final List<Map<String, dynamic>> activities =
        (parentDaytisticJson['activities'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
    activities.add(activity.toJson());
    parentDaytisticJson['activities'] = activities;

    await _daytisticsStore.update(
      _db,
      parentDaytisticJson,
      finder: Finder(filter: Filter.equals('id', activity.daytisticId)),
    );

    await _analytics.trackEvent(
      eventName: 'activity_added',
      properties: {
        'start_time': activity.startTime.toIso8601String(),
        'end_time': activity.endTime.toIso8601String(),
      },
    );

    return activity;
  }

  Future<void> delete(String id) {
    return _daytisticsStore.delete(
      
    )
  }
  Future<void> update(String id, Map<String, dynamic> fields) async {
    late Activity activity;
    try {
      activity = Activity.fromJson({
        'id': id,
        ...fields,
      });
    } on FormatException {
      throw Exception('Invalid activity data.');
    }

    final parentDaytistic = await _daytisticsStore.findFirst(
      _db,
      finder: Finder(filter: Filter.equals('id', activity.daytisticId)),
    );

    await _daytisticsStore.update(
      _db,
      activity.toJson(),
      finder: Finder(filter: Filter.equals('id', activity.daytisticId)),
    );
  }
}

class DaytisticsService {
  late final Database _db;
  late final Analytics _analytics;
  final _daytisticsStore = stringMapStoreFactory.store('daytistics');

  DaytisticsService({
    required Database sembast,
    required Analytics analytics,
  }) {
    _db = sembast;
    _analytics = analytics;
  }

  Future<Daytistic> fetchDaytistic(DateTime date) async {
    final daytisticSnapshot = await _daytisticsStore.findFirst(
      _db,
      finder: Finder(filter: Filter.equals('date', date.toIso8601String())),
    );

    if (daytisticSnapshot == null) {
      throw SupabaseException('No daytistic found for the provided date.');
    }

    final Daytistic daytistic = Daytistic.fromJson(daytisticSnapshot.value);

    // TODO: in view
    // ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    return daytistic;
  }

  Future<Daytistic> fetchOrAdd(DateTime date) async {
    late Daytistic daytistic;

    try {
      daytistic = await fetchDaytistic(date);
    } on SembastException {
      daytistic = Daytistic(
        date: date,
      );

      daytistic.wellbeing = Wellbeing(
        daytisticId: daytistic.id,
      );

      daytistic.diaryEntry = DiaryEntry(
        daytisticId: daytistic.id,
        shortEntry: '',
        happinessMoment: '',
      );

      await _daytisticsStore.add(
        _db,
        daytistic.toJson(),
      );

      await _analytics.trackEvent(
        eventName: 'daytistic_created',
        properties: {
          'date': date.toIso8601String(),
        },
      );
    }

    // TODO: in view
    // ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    return daytistic;
  }
}

@riverpod
Future<DaytisticsService> daytisticsService(Ref ref) async {
  final sembast = await ref.watch(sembastDependencyProvider.future);
  final analytics = ref.watch(analyticsDependencyProvider);
  return DaytisticsService(
    sembast: sembast!,
    analytics: analytics,
  );
}
