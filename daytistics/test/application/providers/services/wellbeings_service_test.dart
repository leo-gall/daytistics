import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/services/wellbeings/wellbeings_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
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
  late final FakePosthog fakePosthog;

  setUpAll(() {
    fakePosthog = FakePosthog();
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
        posthogDependencyProvider.overrideWith((ref) => fakePosthog),
        currentDaytisticProvider.overrideWith(CurrentDaytistic.new),
      ],
    );
    container.read(currentDaytisticProvider.notifier).daytistic = Daytistic(
      date: DateTime(2025, 3),
    );

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
      // Arrange
      final wellbeing = Wellbeing(
        daytisticId: container.read(currentDaytisticProvider)!.id,
        meTime: 3,
        sleep: 7,
        stress: 2,
        mood: 4,
      );

      // Act
      await wellbeingsService.updateWellbeing(wellbeing);

      // Assert
      // Check that wellbeing was upserted into database
      final dbResult = await mockSupabase
          .from(SupabaseSettings.wellbeingsTableName)
          .select()
          .eq('daytistic_id', container.read(currentDaytisticProvider)!.id)
          .single();
      expect(
        dbResult['daytistic_id'],
        container.read(currentDaytisticProvider)!.wellbeing!.daytisticId,
      );
      expect(dbResult['me_time'], 3);
      expect(dbResult['sleep'], 7);
      expect(dbResult['stress'], 2);
      expect(dbResult['mood'], 4);

      // Check that the current daytistic wellbeing was updated
      final updatedDaytistic = container.read(currentDaytisticProvider);
      expect(updatedDaytistic!.wellbeing, isNotNull);
      expect(
        updatedDaytistic.wellbeing!.id,
        container.read(currentDaytisticProvider)!.wellbeing!.id,
      );
      expect(updatedDaytistic.wellbeing!.meTime, 3);
      expect(updatedDaytistic.wellbeing!.sleep, 7);
      expect(updatedDaytistic.wellbeing!.stress, 2);
      expect(updatedDaytistic.wellbeing!.mood, 4);

      // Verify PostHog event
      expect(fakePosthog.capturedEvents.contains('wellbeing_updated'), isTrue);
    });
  });
}
