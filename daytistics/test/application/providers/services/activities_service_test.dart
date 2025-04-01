import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/activities/activities_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/config/settings.dart';
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
        currentDaytisticProvider.overrideWith(CurrentDaytistic.new),
      ],
    );
    container.read(currentDaytisticProvider.notifier).daytistic =
        Daytistic(date: DateTime(2025, 3), activities: []);
    activitiesService = container.read(activitiesServiceProvider.notifier);
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('addActivity', () {
    test('should add an activity to a daytistic', () async {
      // Act
      final success = await activitiesService.addActivity(
        name: 'Running',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        daytistic: container.read(currentDaytisticProvider)!,
      );

      // Assert

      expect(success, isTrue);

      // Check that activity was inserted into database
      final dbResult = await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .select();
      expect(dbResult.length, 1);
      expect(dbResult[0]['name'], 'Running');

      expect(fakeAnalytics.capturedEvents.contains('activity_added'), isTrue);
    });

    test('should return false when name is empty', () async {
      final daytistic = container.read(currentDaytisticProvider);

      final success = await activitiesService.addActivity(
        name: '',
        startTime: const TimeOfDay(hour: 9, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        daytistic: daytistic!,
      );

      // Assert
      expect(success, isFalse);
    });

    test('should return false when start time is after end time', () async {
      final daytistic = container.read(currentDaytisticProvider);

      final success = await activitiesService.addActivity(
        name: 'Running',
        startTime: const TimeOfDay(hour: 11, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        daytistic: daytistic!,
      );

      // Assert
      expect(success, isFalse);
    });

    test('should return false when start time equals end time', () async {
      final daytistic = container.read(currentDaytisticProvider);

      final success = await activitiesService.addActivity(
        name: 'Running',
        startTime: const TimeOfDay(hour: 10, minute: 0),
        endTime: const TimeOfDay(hour: 10, minute: 0),
        daytistic: daytistic!,
      );

      // Assert
      expect(success, isFalse);
    });
  });

  group('deleteActivity', () {
    test('should delete an activity', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final activity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Add the activity to the database and update the daytistic
      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final updatedDaytistic = daytistic.copyWith(
        activities: [activity],
      );
      container.read(currentDaytisticProvider.notifier).daytistic =
          updatedDaytistic;

      // Act
      final success = await activitiesService.deleteActivity(activity);

      // Assert
      expect(success, isTrue);

      // Check that activity was deleted from database
      final dbResult = await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .select();

      expect(fakeAnalytics.capturedEvents.contains('activity_deleted'), isTrue);

      for (final item in dbResult) {
        expect(item['id'], isNot(activity.id));
      }
    });

    test('should return false when activity does not exist', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final nonExistentActivity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Act
      final success =
          await activitiesService.deleteActivity(nonExistentActivity);

      // Assert
      expect(success, isFalse);
    });
  });

  group('updateActivity', () {
    test('should update an activity name', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final activity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Add the activity to the database and update the daytistic
      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final updatedDaytistic = daytistic.copyWith(
        activities: [activity],
      );
      container.read(currentDaytisticProvider.notifier).daytistic =
          updatedDaytistic;

      // Act
      final success = await activitiesService.updateActivity(
        activity: activity,
        daytistic: daytistic,
        name: 'Swimming',
      );

      // Assert
      expect(success, isTrue);

      // Check that activity was updated in database
      final dbResult = await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .select()
          .eq('id', activity.id)
          .single();
      expect(dbResult['name'], 'Swimming');

      expect(fakeAnalytics.capturedEvents.contains('activity_updated'), isTrue);
    });

    test('should update activity time', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final activity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Add the activity to the database and update the daytistic
      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      final updatedDaytistic = daytistic.copyWith(
        activities: [activity],
      );
      container.read(currentDaytisticProvider.notifier).daytistic =
          updatedDaytistic;

      // Act
      final success = await activitiesService.updateActivity(
        activity: activity,
        daytistic: daytistic,
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 11, minute: 0),
      );

      // Assert
      expect(success, isTrue);
    });

    test('should return false when no changes are provided', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final activity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Act
      final success = await activitiesService.updateActivity(
        activity: activity,
        daytistic: daytistic,
      );

      // Assert
      expect(success, isFalse);
    });

    test('should return false when only startTime is provided without endTime',
        () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final activity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Act
      final success = await activitiesService.updateActivity(
        activity: activity,
        daytistic: daytistic,
        startTime: const TimeOfDay(hour: 9, minute: 0),
      );

      // Assert
      expect(success, isFalse);
    });

    test('should return false when activity does not exist', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final nonExistentActivity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Act
      final success = await activitiesService.updateActivity(
        activity: nonExistentActivity,
        daytistic: daytistic,
        name: 'Updated Activity',
      );

      // Assert
      expect(success, isFalse);
    });
  });

  group('existsActivity', () {
    test('should return true when activity exists', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final activity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      await mockSupabase
          .from(SupabaseSettings.activitiesTableName)
          .insert(activity.toSupabase());

      // Act
      final result = await activitiesService.existsActivity(activity);

      // Assert
      expect(result, isTrue);
    });

    test('should return false when activity does not exist', () async {
      final daytistic = container.read(currentDaytisticProvider);

      // Arrange
      final nonExistentActivity = Activity(
        name: 'Running',
        daytisticId: daytistic!.id,
        startTime: DateTime(2025, 3, 1, 9),
        endTime: DateTime(2025, 3, 1, 10),
      );

      // Act
      final result =
          await activitiesService.existsActivity(nonExistentActivity);

      // Assert
      expect(result, isFalse);
    });
  });
}
