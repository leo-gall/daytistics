// ignore_for_file: avoid_dynamic_calls

import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/current_conversation/current_conversation.dart';
import 'package:daytistics/application/providers/supabase/supabase.dart';
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
    final SupabaseClient supabase = ref.read(supabaseClientProvider);
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
    required int offset,
    int? amount,
  }) async {
    final SupabaseClient supabase = ref.read(supabaseClientProvider);

    final response = await supabase.functions.invoke(
      'fetch-conversations',
      body: {
        'offset': offset,
        'amount': amount,
      },
    );

    final conversations = <Conversation>[];
    final List<dynamic> responseData = response.data as List<dynamic>;

    for (final conversation in responseData) {
      conversations
          .add(Conversation.fromSupabase(conversation as Map<String, dynamic>));
    }

    return conversations;
  }

  Future<void> deleteConversation(Conversation conversation) async {
    final SupabaseClient supabase = ref.read(supabaseClientProvider);

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
