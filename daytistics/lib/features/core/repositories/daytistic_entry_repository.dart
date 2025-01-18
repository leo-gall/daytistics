import 'package:daytistics/config/settings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DaytisticEntryRepository {
  final SupabaseClient _supabase;
  late final SupabaseQueryBuilder _table;

  DaytisticEntryRepository(this._supabase) {
    _table = _supabase.from(SupabaseSettings.daytisticEntryTable);
  }

  Future<bool> existsDaytisticEntry(DateTime date) async {
    final List<Map<String, dynamic>> response =
        await _table.select().eq('date', date);
    return response.isNotEmpty;
  }
}
