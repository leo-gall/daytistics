import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions/database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'daytistics_repository.g.dart';

class DaytisticsRepository {
  final _table =
      Supabase.instance.client.from(SupabaseSettings.daytisticsTableName);

  Future<void> addDaytistic(Daytistic daytistic) async {
    await _table.upsert(daytistic.toMap());
  }

  Future<Daytistic> fetchDaytistic(DateTime date) async {
    final response = await _table.select().eq('date', date.toIso8601String());
    if (response.isEmpty) {
      throw RecordNotFoundException('Daytistic not found');
    }

    // fetch all activities from Supabase

    final activitiesResponse = await Supabase.instance.client
        .from(SupabaseSettings.activitiesTableName)
        .select()
        .eq('daytistic_id', response.first['id']);

    // fetch wellbeing from Supabase

    final wellbeingResponse = await Supabase.instance.client
        .from(SupabaseSettings.wellbeingsTableName)
        .select()
        .eq('id', response.first['wellbeing_id']);

    return Daytistic.fromSupabase(
      response.first,
      activitiesResponse,
      wellbeingResponse.first,
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
