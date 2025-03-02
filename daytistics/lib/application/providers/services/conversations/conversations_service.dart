// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:daytistics/application/models/conversation.dart';
import 'package:daytistics/application/models/conversation_message.dart';
import 'package:daytistics/application/providers/di/posthog/posthog_dependency.dart';
import 'package:daytistics/application/providers/di/supabase/supabase.dart';
import 'package:daytistics/application/providers/state/current_conversation/current_conversation.dart';
import 'package:daytistics/config/settings.dart';
import 'package:daytistics/shared/exceptions.dart';
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
    final posthog = ref.read(posthogDependencyProvider);

    late FunctionResponse response;
    try {
      response = await Supabase.instance.client.functions.invoke(
        'send-conversation-message',
        body: {
          'query': query,
          'conversation_id': currentConversation?.id,
        },
      );
    } on FunctionException catch (e) {
      final String error = e.details['error'] as String;

      throw ServerException(error);
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      throw ServerException('An unknown error occurred');
    }

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

    if (currentConversation?.id == null) {
      await posthog.capture(eventName: 'conversation_started');
    }
    await posthog.capture(eventName: 'conversation_message_sent');

    return response.data['reply'] as String;
  }

  Future<List<Conversation>> fetchConversations({
    required int offset,
    int? amount,
  }) async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

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

    await ref
        .read(posthogDependencyProvider)
        .capture(eventName: 'conversations_fetched');

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

    await ref
        .read(posthogDependencyProvider)
        .capture(eventName: 'conversation_deleted');
  }

  Future<bool> hasAnyConversations() async {
    final SupabaseClient supabase = ref.read(supabaseClientDependencyProvider);

    try {
      final result = await supabase
          .from(SupabaseSettings.conversationsTableName)
          .select()
          .limit(1)
          .maybeSingle();
      return result != null;
    } on PostgrestException catch (e) {
      if (e.code == '42P01') {
        return false;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
