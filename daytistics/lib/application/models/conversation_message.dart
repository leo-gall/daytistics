import 'package:uuid/uuid.dart';

class ConversationMessage {
  late String id;
  late String query;
  late String reply;
  late DateTime createdAt;
  late bool upvoted;
  late bool downvoted;
  late bool copied;
  late String conversationId;

  ConversationMessage({
    String? id,
    required this.query,
    required this.reply,
    DateTime? createdAt,
    bool? upvoted,
    bool? downvoted,
    bool? copied,
    String? conversationId,
  }) {
    this.id = id ?? const Uuid().v4();
    this.createdAt = createdAt ?? DateTime.now();
    this.upvoted = upvoted ?? false;
    this.downvoted = downvoted ?? false;
    this.copied = copied ?? false;
    this.conversationId = conversationId ?? const Uuid().v4();
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'query': query,
      'reply': reply,
      'created_at': createdAt.toIso8601String(),
      'upvoted': upvoted,
      'downvoted': downvoted,
      'copied': copied,
      'conversation_id': conversationId,
    };
  }

  factory ConversationMessage.fromSupabase(Map<String, dynamic> data) {
    return ConversationMessage(
      id: data['id'] as String,
      query: data['query'] as String,
      reply: data['reply'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      upvoted: data['upvoted'] as bool,
      downvoted: data['downvoted'] as bool,
      copied: data['copied'] as bool,
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
      upvoted: upvoted ?? this.upvoted,
      downvoted: downvoted ?? this.downvoted,
      copied: copied ?? this.copied,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}
