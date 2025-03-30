import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/activities/activities_service.dart';
import 'package:daytistics/application/providers/state/daytistics/daytistics.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../container.dart';
import '../../../fakes.dart';

void main() {
  late ActivitiesService activitiesService;
  late final SupabaseClient mockSupabase;
  late final MockSupabaseHttpClient mockHttpClient;
  late ProviderContainer container;
  late final FakeAnalytics fakeAnalytics;

  setUpAll(() {
    fakeAnalytics = FakeAnalytics();
    mockHttpClient = MockSupabaseHttpClient();
    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  setUp(() {
    container = createContainer(
      overrides: [
        supabaseClientDependencyProvider.overrideWith((ref) => mockSupabase),
        analyticsDependencyProvider.overrideWith((ref) => fakeAnalytics),
      ],
    );
    // Initialisiere den aktuellen Daytistic mit leeren Aktivitäten
    final initialDaytistic = Daytistic(date: DateTime(2025, 3), activities: []);
    container
        .read(daytisticsProvider.notifier)
        .updateCurrentDaytistic(initialDaytistic);

    activitiesService = container.read(activitiesServiceProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('addActivity', () {
    test('should add an activity to a daytistic', () async {
      await activitiesService.addActivity(
        name: 'Running',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
      );

      final dbResult = await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .select();
      expect(dbResult.length, 1);
      expect(dbResult[0]['name'], 'Running');

      final updatedDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;
      expect(updatedDaytistic.activities.length, 1);
      expect(updatedDaytistic.activities[0].name, 'Running');

      expect(fakeAnalytics.capturedEvents.contains('activity_added'), isTrue);
    });

    test('should throw when name is empty', () async {
      expect(
        () => activitiesService.addActivity(
          name: '',
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        throwsA(
          isA<InvalidInputException>().having(
            (e) => e.message,
            'message',
            'Name cannot be empty',
          ),
        ),
      );
    });

    test('should throw when start time is after end time', () async {
      expect(
        () => activitiesService.addActivity(
          name: 'Running',
          startTime: const TimeOfDay(hour: 11, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        throwsA(
          isA<InvalidInputException>().having(
            (e) => e.message,
            'message',
            'Start time cannot be after end time',
          ),
        ),
      );
    });

    test('should throw when start time equals end time', () async {
      expect(
        () => activitiesService.addActivity(
          name: 'Running',
          startTime: const TimeOfDay(hour: 10, minute: 0),
          endTime: const TimeOfDay(hour: 10, minute: 0),
        ),
        throwsA(
          isA<InvalidInputException>().having(
            (e) => e.message,
            'message',
            'Start time cannot be the same as end time',
          ),
        ),
      );
    });
  });

  group('deleteActivity', () {
    test('should delete an activity', () async {
      final currentDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;

      final activity = Activity(
        name: 'Running',
        daytisticId: currentDaytistic.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final updatedDaytistic = currentDaytistic.copyWith(
        activities: [activity],
      );
      container
          .read(daytisticsProvider.notifier)
          .updateCurrentDaytistic(updatedDaytistic);

      await activitiesService.deleteActivity(activity);

      expect(
        () async => await mockSupabase
            .from(SupabaseSettings.activitiesTableName)
            .select()
            .eq('id', activity.id),
        throwsA(isA<StateError>()),
      );

      final finalDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!;
      expect(finalDaytistic.activities.length, 0);

      expect(fakeAnalytics.capturedEvents.contains('activity_deleted'), isTrue);
    });

    test('should throw when activity does not exist', () async {
      final currentDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;

      final nonExistentActivity = Activity(
        name: 'Running',
        daytisticId: currentDaytistic.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      expect(
        () => activitiesService.deleteActivity(nonExistentActivity),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Activity does not exist',
          ),
        ),
      );
    });
  });

  group('updateActivity', () {
    test('should update an activity name', () async {
      final currentDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;

      final activity = Activity(
        name: 'Running',
        daytisticId: currentDaytistic.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final updatedDaytistic = currentDaytistic.copyWith(
        activities: [activity],
      );
      container
          .read(daytisticsProvider.notifier)
          .updateCurrentDaytistic(updatedDaytistic);

      await activitiesService.updateActivity(
        id: activity.id,
        name: 'Swimming',
      );

      final dbResult = await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .select()
          .eq('id', activity.id)
          .single();
      expect(dbResult['name'], 'Swimming');

      final finalDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;
      expect(finalDaytistic.activities.length, 1);
      expect(finalDaytistic.activities[0].name, 'Swimming');

      expect(fakeAnalytics.capturedEvents.contains('activity_updated'), isTrue);
    });

    test('should update activity time', () async {
      final currentDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;

      final activity = Activity(
        name: 'Running',
        daytisticId: currentDaytistic.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final updatedDaytistic = currentDaytistic.copyWith(
        activities: [activity],
      );
      container
          .read(daytisticsProvider.notifier)
          .updateCurrentDaytistic(updatedDaytistic);

      await activitiesService.updateActivity(
        id: activity.id,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
      );

      final finalDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;
      expect(finalDaytistic.activities[0].startTime.hour, 8);
      expect(finalDaytistic.activities[0].startTime.minute, 0);
      expect(finalDaytistic.activities[0].endTime.hour, 11);
      expect(finalDaytistic.activities[0].endTime.minute, 0);
    });

    test('should throw when no changes are provided', () async {
      expect(
        () => activitiesService.updateActivity(id: 'some-id'),
        throwsA(
          isA<InvalidInputException>().having(
            (e) => e.message,
            'message',
            'No changes to update',
          ),
        ),
      );
    });

    test('should throw when only startTime is provided without endTime',
        () async {
      expect(
        () => activitiesService.updateActivity(
          id: 'some-id',
          startTime: const TimeOfDay(hour: 9, minute: 0),
        ),
        throwsA(
          isA<InvalidInputException>().having(
            (e) => e.message,
            'message',
            'Both start and end time must be provided',
          ),
        ),
      );
    });

    test('should throw when activity does not exist', () async {
      expect(
        () => activitiesService.updateActivity(
          id: 'non-existent-id',
          name: 'Updated Activity',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Activity does not exist',
          ),
        ),
      );
    });
  });

  group('existsActivity', () {
    test('should return true when activity exists', () async {
      final currentDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;

      final activity = Activity(
        name: 'Running',
        daytisticId: currentDaytistic.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final result = await activitiesService.existsActivity(activity);
      expect(result, isTrue);
    });

    test('should return false when activity does not exist', () async {
      final currentDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;

      final nonExistentActivity = Activity(
        name: 'Running',
        daytisticId: currentDaytistic.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      final result =
          await activitiesService.existsActivity(nonExistentActivity);
      expect(result, isFalse);
    });
  });
}
