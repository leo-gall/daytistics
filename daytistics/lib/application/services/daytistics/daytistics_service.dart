import 'package:daytistics/application/models/activity.dart';
import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/application/providers/current_daytistic/current_daytistic.dart';
import 'package:daytistics/application/providers/supabase/supabase.dart';
import 'package:daytistics/application/providers/user/user.dart';
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
    final SupabaseClient supabase = ref.read(supabaseClientProvider);

    final daytisticMap = await supabase
        .from(SupabaseSettings.daytisticsTableName)
        .select()
        .eq('user_id', ref.read(userProvider)!.id)
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

    ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    return daytistic;
  }

  Future<Daytistic> fetchOrAdd(DateTime date) async {
    final SupabaseClient supabase = ref.read(supabaseClientProvider);

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

      await supabase
          .from(SupabaseSettings.daytisticsTableName)
          .upsert(daytistic.toSupabase(userId: ref.read(userProvider)!.id));

      await supabase
          .from(SupabaseSettings.wellbeingsTableName)
          .upsert(daytistic.wellbeing!.toSupabase());
    }

    ref.read(currentDaytisticProvider.notifier).daytistic = daytistic;

    return daytistic;
  }
}
