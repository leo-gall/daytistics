import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/wellbeings/wellbeings_service.dart';
import 'package:daytistics/application/providers/state/daytistics/daytistics.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../container.dart';
import '../../../fakes.dart';

void main() {
  late WellbeingsService wellbeingsService;
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
    // Setze den initialen Daytistic über den neuen Provider
    final initialDaytistic = Daytistic(date: DateTime(2025, 3));
    container
        .read(daytisticsProvider.notifier)
        .updateCurrentDaytistic(initialDaytistic);

    wellbeingsService = container.read(wellbeingsServiceProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('updateWellbeing', () {
    test('should update wellbeing and update current daytistic', () async {
      final currentDay =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;
      final wellbeing = Wellbeing(
        daytisticId: currentDay.id,
        meTime: 3,
        sleep: 7,
        stress: 2,
        mood: 4,
      );

      await wellbeingsService.updateWellbeing(wellbeing);

      // Prüfe, ob der Eintrag in der DB korrekt aktualisiert wurde
      final dbResult = await mockSupabase
          .from(SupabaseSettings.wellbeingsTableName)
          .select()
          .eq('daytistic_id', currentDay.id)
          .single();
      expect(dbResult['daytistic_id'], wellbeing.daytisticId);
      expect(dbResult['me_time'], 3);
      expect(dbResult['sleep'], 7);
      expect(dbResult['stress'], 2);
      expect(dbResult['mood'], 4);

      // Prüfe, ob der Provider den aktuellen Daytistic aktualisiert hat
      final updatedDaytistic =
          container.read(daytisticsProvider).requireValue.currentDaytistic!!;
      expect(updatedDaytistic.wellbeing, isNotNull);
      expect(updatedDaytistic.wellbeing!.id, wellbeing.id);
      expect(updatedDaytistic.wellbeing!.meTime, 3);
      expect(updatedDaytistic.wellbeing!.sleep, 7);
      expect(updatedDaytistic.wellbeing!.stress, 2);
      expect(updatedDaytistic.wellbeing!.mood, 4);

      expect(
        fakeAnalytics.capturedEvents.contains('wellbeing_updated'),
        isTrue,
      );
    });
  });
}
