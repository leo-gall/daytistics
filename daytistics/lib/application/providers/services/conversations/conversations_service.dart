// ignore_for_file: avoid_dynamic_calls

import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/state/current_conversation/current_conversation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'conversations_service.g.dart';

class ConversationsServiceState {}

@Riverpod(keepAlive: true)
class ConversationsService extends _$ConversationsService {
  @override
  ConversationsServiceState build() {
    return ConversationsServiceState();
  }

  Future<String> sendMessage(String query) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);
    final currentConversationNotifier =
        ref.read(currentConversationProvider.notifier);
    final currentConversation = ref.read(currentConversationProvider);

    final response = await Supabase.instance.client.functions.invoke(
      'send-conversation-message',
      body: {
        'query': query,
        'timezone': DateTime.now().timeZoneName,
        'conversation_id': currentConversation?.id,
      },
    );

    if (currentConversation == null) {
      currentConversationNotifier.setConversation(
        await supabase
            .from('conversations')
            .select()
            .eq('id', response.data['conversation_id'] as String)
            .maybeSingle()
            .then((data) {
          if (data != null) {
            return Conversation.fromSupabase(data);
          }
          return null;
        }),
      );
    } else {
      currentConversationNotifier.updateTitle(response.data['title'] as String);
    }

    currentConversationNotifier.addMessage(
      ConversationMessage(
        conversationId: ref.read(currentConversationProvider)!.id,
        query: query,
        reply: response.data['reply'] as String,
      ),
    );

    return response.data['reply'] as String;
  }

  Future<List<Conversation>> fetchConversations({
    required int start,
    int? amount,
  }) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    final conversations = (await supabase
            .from('conversations')
            .select()
            .order('updated_at', ascending: false)
            .range(start, start + (amount ?? 10)))
        .toList()
        .map(Conversation.fromSupabase)
        .toList();

    for (final conversation in conversations) {
      final List<ConversationMessage> messages = (await supabase
              .from('conversation_messages')
              .select()
              .eq('conversation_id', conversation.id)
              .order('created_at', ascending: false))
          .toList()
          .map(ConversationMessage.fromSupabase)
          .toList();

      conversation.messages = messages;
    }

    return conversations;
  }

  Future<void> deleteConversation(Conversation conversation) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    await supabase.from('conversations').delete().eq('id', conversation.id);
    final Conversation? currentConversation =
        ref.read(currentConversationProvider);

    if (currentConversation != null) {
      if (currentConversation.id == conversation.id) {
        ref.read(currentConversationProvider.notifier).clear();
      }
    }
  }
}
