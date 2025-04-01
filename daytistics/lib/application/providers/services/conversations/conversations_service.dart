// ignore_for_file: avoid_dynamic_calls

import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/state/current_conversation/current_conversation.dart';
import 'package:daytistics/shared/exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'conversations_service.g.dart';

class ConversationsService {
  final CurrentConversation currentConversationNotifier;
  final Analytics analytics;
  final SupabaseClient supabase;

  ConversationsService({
    required this.currentConversationNotifier,
    required this.analytics,
    required this.supabase,
  });

  Future<String> sendMessage(
    String query, {
    Conversation? conversation,
  }) async {
    late FunctionResponse response;
    try {
      response = await Supabase.instance.client.functions.invoke(
        'send-conversation-message',
        body: {
          'query': query,
          'conversation_id': conversation?.id,
        },
      );
    } on FunctionException catch (e) {
      final String error = e.details['error'] as String;

      throw SupabaseException(error);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      throw SupabaseException('An unknown error occurred');
    }

    if (conversation == null) {
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
        conversationId:
            conversation?.id ?? response.data['conversation_id'] as String,
        query: query,
        reply: response.data['reply'] as String,
      ),
    );

    if (conversation?.id == null) {
      await analytics.trackEvent(eventName: 'conversation_started');
    }
    await analytics.trackEvent(eventName: 'conversation_message_sent');

    return response.data['reply'] as String;
  }

  Future<List<Conversation>> fetchConversations({
    required int offset,
    int? amount,
  }) async {
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

    await analytics.trackEvent(eventName: 'conversations_fetched');

    return conversations;
  }

  Future<void> deleteConversation(Conversation conversation) async {
    await supabase.from('conversations').delete().eq('id', conversation.id);

    currentConversationNotifier.unsetIfEqual(conversation);

    await analytics.trackEvent(eventName: 'conversation_deleted');
  }
}

@Riverpod(keepAlive: true)
ConversationsService conversationsService(Ref ref) {
  final currentConversationNotifier =
      ref.watch(currentConversationProvider.notifier);
  final analytics = ref.watch(analyticsDependencyProvider);
  final supabase = ref.watch(supabaseClientDependencyProvider);

  return ConversationsService(
    currentConversationNotifier: currentConversationNotifier,
    analytics: analytics,
    supabase: supabase,
  );
}
