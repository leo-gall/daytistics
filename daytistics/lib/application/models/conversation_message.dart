import 'package:uuid/uuid.dart';

class ConversationMessage {
  String query;
  String reply;
  String conversationId;
  late String id;
  late DateTime createdAt;
  late DateTime updatedAt;
  late List<String> calledFunctions;

  ConversationMessage({
    required this.query,
    required this.reply,
    required this.conversationId,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? calledFunctions,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
    this.calledFunctions = calledFunctions ?? [];
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'query': query,
      'reply': reply,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'called_functions': calledFunctions,
      'conversation_id': conversationId,
    };
  }

  factory ConversationMessage.fromSupabase(Map<String, dynamic> data) {
    return ConversationMessage(
      id: data['id'] as String,
      query: data['query'] as String,
      reply: data['reply'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      calledFunctions: (data['called_functions'] as List).cast<String>(),
      conversationId: data['conversation_id'] as String,
    );
  }

  ConversationMessage copyWith({
    String? id,
    String? query,
    String? reply,
    DateTime? createdAt,
    bool? upvoted,
    bool? downvoted,
    bool? copied,
    String? conversationId,
  }) {
    return ConversationMessage(
      id: id ?? this.id,
      query: query ?? this.query,
      reply: reply ?? this.reply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
      calledFunctions: calledFunctions,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
