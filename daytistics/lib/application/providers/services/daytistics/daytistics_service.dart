import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/diary_entry.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/services/diary/diary_service.dart';
import 'package:daytistics/application/providers/state/current_daytistic/current_daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'daytistics_service.g.dart';

class DaytisticsServiceState {}

@riverpod
class DaytisticsService extends _$DaytisticsService {
  @override
  DaytisticsServiceState build() {
    return DaytisticsServiceState();
  }

  Future<Daytistic> fetchDaytistic(DateTime date) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    final daytisticMap = await supabase
        .from(SupabaseSettings.daytisticsTableName)
        .select()
        .eq('user_id', ref.read(userDependencyProvider)!.id)
        .eq('date', date.toIso8601String())
        .maybeSingle();

    if (daytisticMap == null) {
      throw SupabaseException('No daytistic found for the provided date.');
    }

    final Daytistic daytistic = Daytistic.fromSupabase(daytisticMap);

    final wellbeings = await supabase
        .from(SupabaseSettings.wellbeingsTableName)
        .select()
        .eq('daytistic_id', daytistic.id);

    if (wellbeings.isNotEmpty) {
      daytistic.wellbeing = Wellbeing.fromSupabase(wellbeings.first);
    }

    final List<Map<String, dynamic>> activitiesMap = await supabase
        .from(SupabaseSettings.activitiesTableName)
        .select()
        .eq('daytistic_id', daytistic.id);

    daytistic.activities = activitiesMap.map(Activity.fromSupabase).toList();

    daytistic.diaryEntry =
        await ref.read(diaryServiceProvider).fetchDiaryEntry(daytistic.id);

    ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'daytistic_fetched',
      properties: {
        'date': date.toIso8601String(),
      },
    );

    return daytistic;
  }

  Future<Daytistic> fetchOrAdd(DateTime date) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    late Daytistic daytistic;

    try {
      daytistic = await fetchDaytistic(date);
    } on SupabaseException {
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

      await supabase.from(SupabaseSettings.daytisticsTableName).upsert(
            daytistic.toSupabase(userId: ref.read(userDependencyProvider)!.id),
          );

      await supabase
          .from(SupabaseSettings.wellbeingsTableName)
          .upsert(daytistic.wellbeing!.toSupabase());

      await ref.read(diaryServiceProvider).upsertDiaryEntry(
            daytistic.diaryEntry!,
          );

      await ref.read(analyticsDependencyProvider).trackEvent(
        eventName: 'daytistic_created',
        properties: {
          'date': date.toIso8601String(),
        },
      );
    }

    ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    return daytistic;
  }
}
