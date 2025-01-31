import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'daytistics_repository.g.dart';

class DaytisticsRepository {
  final _table =
      Supabase.instance.client.from(SupabaseSettings.daytisticsTableName);
  final _userId = Supabase.instance.client.auth.currentUser!.id;

  Future<void> upsertDaytistic(Daytistic daytistic) async {
    await _table.upsert(daytistic.toSupabase());
  }

  Future<Daytistic?> selectDaytistic(DateTime date) async {
    Map<String, dynamic>? daytisticResponse;
    List<Map<String, dynamic>> activitiesResponse;
    Map<String, dynamic>? wellbeingResponse;

    try {
      daytisticResponse = await _table
          .select()
          .eq('user_id', _userId)
          .eq('date', date.toIso8601String())
          .single();

      activitiesResponse = await Supabase.instance.client
          .from(SupabaseSettings.activitiesTableName)
          .select()
          .eq('daytistic_id', daytisticResponse['id']);

      wellbeingResponse = await Supabase.instance.client
          .from(SupabaseSettings.wellbeingsTableName)
          .select()
          .eq('id', daytisticResponse['wellbeing_id'])
          .single();
    } catch (e) {
      return null;
    }

    return Daytistic.fromSupabase(
      daytisticResponse,
      activitiesResponse,
      wellbeingResponse,
    );
  }

  Future<bool> existsDaytistic(Daytistic daytistic) async {
    final response =
        await _table.select().eq('date', daytistic.date.toIso8601String());
    return response.isNotEmpty;
  }
}

@riverpod
DaytisticsRepository daytisticsRepository(Ref ref) => DaytisticsRepository();
