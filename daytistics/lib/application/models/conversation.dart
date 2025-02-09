import 'package:daytistics/application/models/conversation_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class Conversation {
  late String id;
  late String title;
  late List<ConversationMessage> messages;
  late DateTime createdAt;
  late DateTime updatedAt;

  Conversation({
    String? id,
    List<ConversationMessage>? messages,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    this.id = id ?? const Uuid().v4();
    this.messages = messages ?? [];
    this.title = title ?? 'No title';
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  Conversation copyWith({
    String? id,
    List<ConversationMessage>? messages,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Conversation(
      id: id ?? this.id,
      messages: messages ?? this.messages,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toSupabase({
    required String userId,
  }) {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_id': userId,
    };
  }

  factory Conversation.fromSupabase(Map<String, dynamic> data) {
    return Conversation(
      id: data['id'] as String,
      title: data['title'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }
}
