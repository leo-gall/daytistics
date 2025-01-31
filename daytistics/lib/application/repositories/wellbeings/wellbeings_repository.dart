import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'wellbeings_repository.g.dart';

class WellbeingsRepository {
  final _table =
      Supabase.instance.client.from(SupabaseSettings.wellbeingsTableName);

  Future<Wellbeing?> selectWellbeing(String id) async {
    final response = await _table.select().eq('id', id).single();

    return Wellbeing.fromSupabase(response);
  }

  Future<void> upsertWellbeing(Wellbeing wellbeing) async {
    await _table.upsert(wellbeing.toSupabase());
  }

  Future<void> insertWellbeing(Wellbeing wellbeing) async {
    await _table.insert(wellbeing.toSupabase());
  }
}

@riverpod
WellbeingsRepository wellbeingsRepository(Ref ref) => WellbeingsRepository();
