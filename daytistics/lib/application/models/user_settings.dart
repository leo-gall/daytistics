import 'package:uuid/uuid.dart';

class UserSettings {
  late String id;
  late bool notifications;
  late bool conversationAnalytics;
  late DateTime createdAt;
  late DateTime updatedAt;

  UserSettings({
    String? id,
    bool? notifications,
    bool? conversationAnalytics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.conversationAnalytics = conversationAnalytics ?? false;
    this.notifications = notifications ?? false;
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  Map<String, dynamic> toSupabase({
    required String userId,
  }) {
    return {
      'id': id,
      'user_id': userId,
      'notifications': notifications,
      'conversation_analytics': conversationAnalytics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserSettings.fromSupabase(Map<String, dynamic> data) {
    return UserSettings(
      id: data['id'] as String,
      notifications: data['notifications'] as bool,
      conversationAnalytics: data['conversation_analytics'] as bool,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }

  UserSettings copyWith({
    String? id,
    bool? notifications,
    bool? conversationAnalytics,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      notifications: notifications ?? this.notifications,
      conversationAnalytics:
          conversationAnalytics ?? this.conversationAnalytics,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
