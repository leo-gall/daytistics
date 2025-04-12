import 'package:daytistics/application/models/diary_entry.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'diary_service.g.dart';

class DiaryService {
  final SupabaseClient supabase;

  DiaryService(this.supabase);

  Future<bool> upsertDiaryEntry(DiaryEntry diaryEntry) async {
    try {
      await supabase
          .from(SupabaseSettings.diaryEntriesTableName)
          .upsert(diaryEntry.toJson());
    } on PostgrestException {
      return false;
    }

    return true;
  }

  Future<DiaryEntry?> fetchDiaryEntry(String daytisticId) async {
    final response = await supabase
        .from(SupabaseSettings.diaryEntriesTableName)
        .select()
        .eq('daytistic_id', daytisticId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return DiaryEntry.fromJson(response);
  }
}

@Riverpod(keepAlive: true)
DiaryService diaryService(Ref ref) {
  final supabase = ref.watch(supabaseClientDependencyProvider);
  return DiaryService(supabase);
}
