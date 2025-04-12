// ignore_for_file: avoid_setters_without_getters

import 'package:daytistics/application/models/daytistic.dart';
import 'package:daytistics/application/models/diary_entry.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_daytistic.g.dart';

@Riverpod(keepAlive: true)
class CurrentDaytistic extends _$CurrentDaytistic {
  @override
  Daytistic? build() {
    return null;
  }

  set daytistic(Daytistic? daytistic) {
    state = daytistic;
  }

  set wellbeing(Wellbeing wellbeing) {
    if (state != null) {
      state = state!.copyWith(wellbeing: wellbeing);
    }
  }

  set diaryEntry(DiaryEntry? diaryEntry) {
    if (state != null) {
      state = state!.copyWith(diaryEntry: diaryEntry);
    }
  }
}
