import 'package:daytistics/shared/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UserSettings {
  late String id;
  late TimeOfDay? dailyReminderTime;
  late bool conversationAnalytics;
  late DateTime createdAt;
  late DateTime updatedAt;

  UserSettings({
    String? id,
    this.dailyReminderTime,
    bool? conversationAnalytics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.conversationAnalytics = conversationAnalytics ?? false;
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  Map<String, dynamic> toSupabase({
    required String userId,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'daily_reminder_time': dailyReminderTime != null
          ? '${timeToUtc(dailyReminderTime!).hour.toString().padLeft(2, '0')}:${timeToUtc(dailyReminderTime!).minute.toString().padLeft(2, '0')}'
          : null,
      'conversation_analytics': conversationAnalytics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromSupabase(Map<String, dynamic> data) {
    final dailyReminderTime = data['daily_reminder_time'];

    if (dailyReminderTime == null) {
      return UserSettings(
        id: data['id'] as String,
        conversationAnalytics: data['conversation_analytics'] as bool,
        createdAt: DateTime.parse(data['created_at'] as String),
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    }

    final parts = dailyReminderTime.toString().split(':');

    return UserSettings(
      id: data['id'] as String,
      dailyReminderTime: timeFromUtc(
        TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        ),
      ),
      conversationAnalytics: data['conversation_analytics'] as bool,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  UserSettings copyWith({
    String? id,
    bool? conversationAnalytics,
    TimeOfDay? dailyReminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      dailyReminderTime: dailyReminderTime,
      conversationAnalytics:
          conversationAnalytics ?? this.conversationAnalytics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
