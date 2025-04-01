import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/services/daytistics/daytistics_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../container.dart';
import '../../../fakes.dart';

void main() {
  late DaytisticsService daytisticsService;
  late final SupabaseClient mockSupabase;
  late final MockSupabaseHttpClient mockHttpClient;
  late final User mockUser;
  late ProviderContainer container;
  late final FakeAnalytics fakeAnalytics;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();
    fakeAnalytics = FakeAnalytics();

    // Pass the mock client to the Supabase client
    mockSupabase = SupabaseClient(
      'https://mock.supabase.co', // Does not matter what URL you pass here as long as it's a valid URL
      'fakeAnonKey', // Does not matter what string you pass here
      httpClient: MockSupabaseHttpClient(),
    );
    mockUser = User(
      id: const Uuid().v4(),
      appMetadata: {},
      userMetadata: {},
      aud: 'aud_value',
      createdAt: DateTime.now().toIso8601String(),
    );
  });

  setUp(() {
    container = createContainer(
      overrides: [
        supabaseClientDependencyProvider.overrideWith((ref) => mockSupabase),
        userDependencyProvider.overrideWith((ref) => mockUser),
        analyticsDependencyProvider.overrideWith((ref) => fakeAnalytics),
      ],
    );
    daytisticsService = container.read(daytisticsServiceProvider.notifier);
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('fetchDaytistic', () {
    test('should return a daytistic without wellbeing and activities',
        () async {
      // arrange

      final Daytistic daytistic = Daytistic(
        date: DateTime.now(),
      );

      await mockSupabase.from(SupabaseSettings.daytisticsTableName).insert(
            daytistic.toSupabase(userId: mockUser.id),
          );

      await mockSupabase.from(SupabaseSettings.wellbeingsTableName).insert(
            Wellbeing(
              daytisticId: const Uuid().v4(),
              meTime: 3,
            ).toSupabase(),
          );

      // act

      final fetchedDaytistic = await daytisticsService.fetchDaytistic(
        daytistic.date,
      );

      // assert

      expect(fetchedDaytistic.id, daytistic.id);
      expect(fetchedDaytistic.date, daytistic.date);
      expect(fetchedDaytistic.wellbeing, null);
      expect(fetchedDaytistic.activities, <Activity>[]);

      expect(
        fakeAnalytics.capturedEvents.contains('daytistic_fetched'),
        isTrue,
      );
    });

    test('should return a daytistic with wellbeing and activities', () async {
      // arrange

      final Daytistic daytistic = Daytistic(
        date: DateTime.now(),
      );

      await mockSupabase.from(SupabaseSettings.daytisticsTableName).insert(
            daytistic.toSupabase(userId: mockUser.id),
          );

      final Wellbeing wellbeing = Wellbeing(
        daytisticId: daytistic.id,
        meTime: 3,
      );

      await mockSupabase.from(SupabaseSettings.wellbeingsTableName).insert(
            wellbeing.toSupabase(),
          );

      final Activity activity = Activity(
        daytisticId: daytistic.id,
        name: 'Running',
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(hours: 1)),
      );

      await mockSupabase.from(SupabaseSettings.activitiesTableName).insert(
            activity.toSupabase(),
          );

      // act

      final fetchedDaytistic = await daytisticsService.fetchDaytistic(
        daytistic.date,
      );

      // assert

      expect(fetchedDaytistic.id, daytistic.id);
      expect(fetchedDaytistic.date, daytistic.date);
      expect(fetchedDaytistic.wellbeing!.daytisticId, wellbeing.daytisticId);

      expect(
        fakeAnalytics.capturedEvents.contains('daytistic_fetched'),
        isTrue,
      );
    });

    test('should throw a NotFoundException when no daytistic is found',
        () async {
      // arrange

      final DateTime date = DateTime.now();

      // assert

      expect(
        () async => daytisticsService.fetchDaytistic(date),
        throwsA(isA<SupabaseException>()),
      );
    });
  });

  group('fetchOrAdd', () {
    test('should return existing daytistic when one exists for the given date',
        () async {
      // arrange
      final Daytistic existingDaytistic = Daytistic(
        date: DateTime.now(),
      );

      await mockSupabase.from(SupabaseSettings.daytisticsTableName).insert(
            existingDaytistic.toSupabase(userId: mockUser.id),
          );

      final Wellbeing wellbeing = Wellbeing(
        daytisticId: existingDaytistic.id,
        meTime: 3,
      );

      await mockSupabase.from(SupabaseSettings.wellbeingsTableName).insert(
            wellbeing.toSupabase(),
          );

      // act
      final fetchedDaytistic = await daytisticsService.fetchOrAdd(
        existingDaytistic.date,
      );

      // assert
      expect(fetchedDaytistic.id, existingDaytistic.id);
      expect(fetchedDaytistic.date, existingDaytistic.date);
      expect(fetchedDaytistic.wellbeing!.daytisticId, wellbeing.daytisticId);
      expect(fetchedDaytistic.wellbeing!.meTime, wellbeing.meTime);
    });

    test(
        'should create new daytistic with wellbeing when none exists for the date',
        () async {
      // arrange
      final DateTime date = DateTime.now();

      // act
      final createdDaytistic = await daytisticsService.fetchOrAdd(date);

      // assert
      expect(createdDaytistic.date, date);
      expect(createdDaytistic.wellbeing, isNotNull);
      expect(createdDaytistic.wellbeing!.daytisticId, createdDaytistic.id);

      // Verify the daytistic was actually inserted into the database
      final daytisticInDb = await mockSupabase
          .from(SupabaseSettings.daytisticsTableName)
          .select()
          .eq('id', createdDaytistic.id)
          .single();
      expect(daytisticInDb['id'], createdDaytistic.id);
      expect(DateTime.parse(daytisticInDb['date'] as String), date);
      expect(daytisticInDb['user_id'], mockUser.id);

      // Verify the wellbeing was actually inserted into the database
      final wellbeingInDb = await mockSupabase
          .from(SupabaseSettings.wellbeingsTableName)
          .select()
          .eq('daytistic_id', createdDaytistic.id)
          .single();
      expect(wellbeingInDb['daytistic_id'], createdDaytistic.id);

      expect(
        fakeAnalytics.capturedEvents.contains('daytistic_created'),
        isTrue,
      );
    });

    test('should set the created daytistic as current in the provider',
        () async {
      // arrange
      final DateTime date = DateTime.now();

      // act
      final createdDaytistic = await daytisticsService.fetchOrAdd(date);

      // assert
      final currentDaytistic = container.read(currentDaytisticProvider);
      expect(currentDaytistic!.id, createdDaytistic.id);
      expect(currentDaytistic.date, createdDaytistic.date);
    });
  });
}
