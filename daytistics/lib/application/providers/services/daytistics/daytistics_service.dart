import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
import 'package:daytistics/application/providers/state/daytistics/daytistics.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'daytistics_service.g.dart';

class DaytisticsServiceState {}

@Riverpod(keepAlive: true)
class DaytisticsService extends _$DaytisticsService {
  @override
  DaytisticsServiceState build() {
    return DaytisticsServiceState();
  }

  Future<Daytistic> fetchDaytistic(DateTime date) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    final daytistics = ref.read(daytisticsProvider).requireValue.daytistics;

    final bool isCached = daytistics.any(
      (d) =>
          d.date.day == date.day &&
          d.date.month == date.month &&
          d.date.year == date.year,
    );

    if (isCached) {
      final Daytistic cachedDaytistic = ref
          .read(daytisticsProvider)
          .requireValue
          .daytistics
          .firstWhere((d) => d.date == date);

      return cachedDaytistic;
    }

    final daytisticMap = await supabase
        .from(SupabaseSettings.daytisticsTableName)
        .select()
        .eq('user_id', ref.read(userDependencyProvider)!.id)
        .eq('date', date.toIso8601String())
        .maybeSingle();

    if (daytisticMap == null) {
      throw NotFoundException('No daytistic found for the provided date.');
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

    ref.read(daytisticsProvider.notifier).updateCurrentDaytistic(daytistic);

    await ref.read(analyticsDependencyProvider).trackEvent(
      eventName: 'daytistic_fetched',
      properties: {
        'date': date.toIso8601String(),
      },
    );

    ref.read(daytisticsProvider.notifier).addDaytistic(daytistic);

    return daytistic;
  }

  Future<Daytistic> fetchOrAdd(DateTime date) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    late Daytistic daytistic;

    try {
      daytistic = await fetchDaytistic(date);
    } on NotFoundException {
      daytistic = Daytistic(
        date: date,
      );

      daytistic.wellbeing = Wellbeing(
        daytisticId: daytistic.id,
      );

      await supabase.from(SupabaseSettings.daytisticsTableName).upsert(
            daytistic.toSupabase(userId: ref.read(userDependencyProvider)!.id),
          );

      await supabase
          .from(SupabaseSettings.wellbeingsTableName)
          .upsert(daytistic.wellbeing!.toSupabase());

      await ref.read(analyticsDependencyProvider).trackEvent(
        eventName: 'daytistic_created',
        properties: {
          'date': date.toIso8601String(),
        },
      );

      final daytisticsNotifier = ref.read(daytisticsProvider.notifier);

      daytisticsNotifier.updateCurrentDaytistic(daytistic);
      daytisticsNotifier.addDaytistic(daytistic);
    }

    return daytistic;
  }

  Future<List<Daytistic>> fetchRecentDaytistics({int daysBefore = 7}) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    final List<Map<String, dynamic>> daytisticsMap = await supabase
        .from(SupabaseSettings.daytisticsTableName)
        .select()
        .gte('date', DateTime.now().subtract(Duration(days: daysBefore)))
        .eq('user_id', ref.read(userDependencyProvider)!.id)
        .order('date', ascending: false);

    final List<Daytistic> daytistics =
        daytisticsMap.map(Daytistic.fromSupabase).toList();

    return daytistics;
  }
}
