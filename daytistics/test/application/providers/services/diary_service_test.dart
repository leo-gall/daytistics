import 'package:daytistics/application/models/diary_entry.dart';
import 'package:daytistics/application/providers/services/diary/diary_service.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_supabase_http_client/mock_supabase_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

void main() {
  late final SupabaseClient mockSupabase;
  late final MockSupabaseHttpClient mockHttpClient;
  late DiaryService diaryService;

  setUpAll(() {
    mockHttpClient = MockSupabaseHttpClient();

    mockSupabase = SupabaseClient(
      'https://mock.supabase.co',
      'fakeAnonKey',
      httpClient: mockHttpClient,
    );
  });

  setUp(() {
    diaryService = DiaryService(mockSupabase);
  });

  tearDown(() async {
    mockHttpClient.reset();
  });

  tearDownAll(() {
    mockHttpClient.close();
  });

  group('DiaryService', () {
    test('upsertDiaryEntry should insert a new diary entry', () async {
      // arrange
      final diaryEntry = DiaryEntry(
        id: const Uuid().v4(),
        daytisticId: const Uuid().v4(),
        shortEntry: 'Today was nice.',
        happinessMoment: 'Walk in the park',
      );

      // act
      await diaryService.upsertDiaryEntry(diaryEntry);

      // assert for insert
      final insertedResult = await mockSupabase
          .from(SupabaseSettings.diaryEntriesTableName)
          .select()
          .eq('daytistic_id', diaryEntry.daytisticId)
          .single();

      expect(insertedResult['daytistic_id'], diaryEntry.daytisticId);
      expect(insertedResult['short_entry'], diaryEntry.shortEntry);
      expect(insertedResult['happiness_moment'], diaryEntry.happinessMoment);
    });

    test('upsertDiaryEntry should update an existing diary entry', () async {
      // arrange
      final diaryEntry = DiaryEntry(
        id: const Uuid().v4(),
        daytisticId: const Uuid().v4(),
        shortEntry: 'Today was nice.',
        happinessMoment: 'Walk in the park',
      );

      await diaryService.upsertDiaryEntry(diaryEntry);

      final updatedDiaryEntry = DiaryEntry(
        id: diaryEntry.id,
        daytisticId: diaryEntry.daytisticId,
        shortEntry: 'Updated entry.',
        happinessMoment: 'Updated moment',
      );

      // act
      await diaryService.upsertDiaryEntry(updatedDiaryEntry);

      // assert for update
      final updatedResult = await mockSupabase
          .from(SupabaseSettings.diaryEntriesTableName)
          .select()
          .eq('daytistic_id', updatedDiaryEntry.daytisticId)
          .single();

      expect(updatedResult['daytistic_id'], updatedDiaryEntry.daytisticId);
      expect(updatedResult['short_entry'], updatedDiaryEntry.shortEntry);
      expect(
        updatedResult['happiness_moment'],
        updatedDiaryEntry.happinessMoment,
      );
    });

    test('fetchDiaryEntry should return correct DiaryEntry', () async {
      // arrange
      final diaryEntry = DiaryEntry(
        id: const Uuid().v4(),
        daytisticId: const Uuid().v4(),
        shortEntry: 'Felt productive',
        happinessMoment: 'Coding session',
      );

      await mockSupabase
          .from(SupabaseSettings.diaryEntriesTableName)
          .insert(diaryEntry.toJson());

      // act
      final fetched =
          await diaryService.fetchDiaryEntry(diaryEntry.daytisticId);

      // assert
      expect(fetched!.daytisticId, diaryEntry.daytisticId);
      expect(fetched.shortEntry, diaryEntry.shortEntry);
      expect(fetched.happinessMoment, diaryEntry.happinessMoment);
    });

    test('fetchDiaryEntry should return null if no entry found', () async {
      // arrange
      final nonExistentId = const Uuid().v4();

      // act
      final fetched = await diaryService.fetchDiaryEntry(nonExistentId);

      // assert
      expect(fetched, null);
    });
  });
}
