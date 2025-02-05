import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/models/wellbeing.dart';
import 'package:daytistics/config/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'conversations_repository.g.dart';

class ConversationsRepository {
  final _conversationsTable =
      Supabase.instance.client.from(SupabaseSettings.conversationsTableName);

  final _messagesTable = Supabase.instance.client
      .from(SupabaseSettings.conversationMessagesTableName);

  final _userId = Supabase.instance.client.auth.currentUser!.id;

  Future<void> insertConversation(Conversation conversation) async {
    final Map<String, dynamic> conversationMap = conversation.toSupabase();
    conversationMap['user_id'] = _userId;
    await _conversationsTable.insert(conversationMap);
  }

  Future<void> insertMessage(ConversationMessage message) async {
    await _messagesTable.insert(message.toSupabase());
  }

  Future<bool> existsConversation(Conversation conversation) async {
    final response = await _conversationsTable
        .select()
        .eq('id', conversation.id)
        .eq('user_id', _userId);
    return response.isNotEmpty;
  }

  Future<bool> existsMessage(ConversationMessage message) async {
    final response = await _messagesTable
        .select()
        .eq('id', message.id)
        .eq('conversation_id', message.conversationId);
    return response.isNotEmpty;
  }

  Future<void> updateConversation(Conversation conversation) async {
    await _conversationsTable
        .update(conversation.toSupabase())
        .eq('id', conversation.id)
        .eq('user_id', _userId);

    for (final message in conversation.messages) {
      await _messagesTable
          .update(message.toSupabase())
          .eq('id', message.id)
          .eq('conversation_id', message.conversationId);
    }
  }

  Future<void> updateMessage(ConversationMessage message) async {
    await _messagesTable
        .update(message.toSupabase())
        .eq('id', message.id)
        .eq('conversation_id', message.conversationId);
  }

  Future<List<ConversationMessage>> fetchMessages(String conversationId) async {
    final response = await _messagesTable
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: false);
    return response.map(ConversationMessage.fromSupabase).toList();
  }

  Future<List<Conversation>> fetchConversations({
    required int start,
    int? amount,
  }) async {
    final response = await _conversationsTable
        .select()
        .range(start, start + (amount ?? 10) - 1);
    return response.map(Conversation.fromSupabase).toList();
  }

  Future<void> deleteConversation(Conversation conversation) async {
    await _conversationsTable
        .delete()
        .eq('id', conversation.id)
        .eq('user_id', _userId);
  }

  Future<void> deleteMessage(ConversationMessage message) async {
    await _messagesTable
        .delete()
        .eq('id', message.id)
        .eq('conversation_id', message.conversationId);
  }
}

@riverpod
ConversationsRepository conversationsRepository(Ref ref) =>
    ConversationsRepository();
