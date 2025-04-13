// ignore_for_file: avoid_dynamic_calls

import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/di/analytics/analytics.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/di/user/user.dart';
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
  final User? user;

  ConversationsService({
    required this.currentConversationNotifier,
    required this.analytics,
    required this.supabase,
    required this.user,
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
    final response = await supabase
        .from('conversations')
        .select()
        .eq('user_id', user!.id)
        .order('updated_at', ascending: false)
        .range(offset, offset + (amount ?? 10) - 1);

    final List<Conversation> conversations = await Future.wait(
      response.map((data) async {
        final conversation = Conversation.fromSupabase(data);
        final messages = await supabase
            .from('conversation_messages')
            .select()
            .eq('conversation_id', conversation.id)
            .order('created_at', ascending: true);
        return conversation.copyWith(
          messages: messages.map(ConversationMessage.fromSupabase).toList(),
        );
      }),
    );

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
  final user = ref.watch(userDependencyProvider);

  return ConversationsService(
    currentConversationNotifier: currentConversationNotifier,
    analytics: analytics,
    supabase: supabase,
    user: user,
  );
}
